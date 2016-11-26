package org.apache.tez.dag.profiler;


import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.io.IOException;
import java.util.HashMap;

import org.apache.tez.common.counters.FileSystemCounter;
import org.apache.tez.common.counters.TaskCounter;
import org.apache.tez.dag.app.dag.Task;
import org.apache.tez.dag.records.TezTaskID;
import org.apache.tez.runtime.api.events.TaskStatusUpdateEvent;

/**
 * keep track of specific resource 
 * information per vertex
 */
public class VertexProfiler {
	
	String vertexName;
	
	// per vertex resource profile
	public ResourceProfile vertexProfile = null;
	
	// keep track of actual resource demands which goes into the wire for 
	// every task into this vertex
	public ResourceProfile vertexProfileReal = null;	
	
	// keep track of stats per vertex based on current job
	public ResourceProfile updateVertexProfile = null;		
	
	// keep track for each task in the vertex his resource requirements
	HashMap<TezTaskID, ResourceProfile> tasksProfile = new HashMap<TezTaskID, ResourceProfile>();

	// reference to DAG profiler
	DAGProfiler dagReference;
	
	public static int NUM_DIMENSIONS = 6;
	
	public double[] rsrcAreaVertex;

	static final Log LOG = LogFactory.getLog(VertexProfiler.class);
	
	public VertexProfiler(String _vertexName, DAGProfiler _dagReference) {
		
		vertexName  = _vertexName;
		dagReference= _dagReference;
		
		vertexProfile = new ResourceProfile();			
		
		updateVertexProfile = new ResourceProfile();		
	}
	
	public VertexProfiler(String _vertexName, DAGProfiler _dagReference, ResourceProfile profile) {
		vertexName = _vertexName;
		dagReference = _dagReference;
		
		vertexProfile = profile;
		vertexProfileReal = profile;
		
		updateVertexProfile = new ResourceProfile();
		
	}
		
	/* compute rsrc area for a vertex */
	public void computeRsrcAreaVertex() {
		
		LOG.info("[Tan] - computeRsrcArea for vertex:"+this.vertexName+" num_tasks:"+this.vertexProfileReal.num_tasks+" "+this.vertexProfile.num_tasks);
		
		rsrcAreaVertex = new double[VertexProfiler.NUM_DIMENSIONS];
		for (int dim = 0; dim < VertexProfiler.NUM_DIMENSIONS; dim++) {
						
			double x = this.vertexProfile.num_tasks * this.vertexProfileReal.getDuration();
			
			if (dim == 0)
				x *= this.vertexProfileReal.getCpuUsage();
			else if (dim == 1)
				x *= this.vertexProfileReal.getMemUsage();
			else if (dim == 2)
				x *= this.vertexProfileReal.getInNetworkUsage();
			else if (dim == 3)
				x *= this.vertexProfileReal.getOutNetworkUsage();
			else if (dim == 4)
				x *= this.vertexProfileReal.getInStorageUsage();
			else if (dim == 5)
				x *= this.vertexProfileReal.getOutStorageUsage();
			
			rsrcAreaVertex[dim] = x;
		}	
	}
	
	public double getMaxRsrcArea() {
		
		double max_val = Double.MIN_VALUE;
		for (int dim = 0; dim < VertexProfiler.NUM_DIMENSIONS; dim++) {
			if (rsrcAreaVertex[dim] > max_val)
				max_val = rsrcAreaVertex[dim];
		}
		
		return max_val;
	}
	
	/*
	 * update vertex profiler with info from dag profiler
	 * */
	public void updateTaskProfileFromResourceFile(String[] info) throws Exception {
		
		LOG.info("updateTaskProfileFromResourceFile");
		
		if (info.length != 6) 
			throw new IOException("Insufficient resource parameters for vertex: "+vertexName);
		
		if (updateVertexProfile == null)
			updateVertexProfile = new ResourceProfile();
		
		vertexProfile.num_tasks 	 = Integer.parseInt(info[0]); 
		vertexProfile.task_duration  = Integer.parseInt(info[1]);
		vertexProfile.task_cpu_usage = Integer.parseInt(info[2]);
		vertexProfile.task_mem_usage = Integer.parseInt(info[3]);
		vertexProfile.task_input     = Integer.parseInt(info[4]);
		vertexProfile.task_output    = Integer.parseInt(info[5]);		
		
		// update vertex with real resource requirements
		computeVertexActualResourceRequirements();
		
	}
	
	// compute the actual resources used by vertex
	public void computeVertexActualResourceRequirements() {
		
		LOG.info("computeVertexActualResourceRequirements");
		
		int cpu_req = Math.max(vertexProfile.getCpuUsage(), ResourceProfile.TASK_CPU_USAGE);
		//int cpu_req = vertexProfile.getCpuUsage(); //ResourceProfile.TASK_CPU_USAGE; //Math.max(vertexResourceProfile.getCpuUsage(), ResourceProfile.TASK_CPU_USAGE);
		int mem_req = vertexProfile.getMemUsage(); //Math.max(vertexProfile.getMemUsage(), ResourceProfile.TASK_MEM_USAGE);
		int dur_req = Math.max(vertexProfile.getDuration(), ResourceProfile.TASK_DURATION);
	
		double input_task_vertex  = vertexProfile.getInput();
		double output_task_vertex = vertexProfile.getOutput();
		
		int SIM_IN_NW = 0, SIM_OUT_NW = 0, SIM_IN_ST = 0, SIM_OUT_ST = 0;
		
		int in_nw, out_nw, in_st, out_st;
		int EPSILON = 5; // MB
		if (dagReference.num_vertices_in(vertexName) == 0) {
			in_nw = (int)(0.2 * ((double)(input_task_vertex)/dur_req) + EPSILON);
			out_st= (int)(0.8 * ((double)(input_task_vertex)/dur_req) + EPSILON);
			
			SIM_IN_NW = (int)(0.2 * ((double)(input_task_vertex)/dur_req));
			SIM_OUT_ST= (int)(0.8 * ((double)(input_task_vertex)/dur_req));
		}
		else {
			in_nw = (int)(0.8 * ((double)(input_task_vertex)/dur_req) + EPSILON);
			out_st= (int)(0.2 * ((double)(input_task_vertex)/dur_req) + EPSILON);
			
			SIM_IN_NW = (int)(0.8 * ((double)(input_task_vertex)/dur_req));
			SIM_OUT_ST= (int)(0.2 * ((double)(input_task_vertex)/dur_req));
		}
		
		if (dagReference.num_vertices_out(vertexName) == 0) {
			out_nw = EPSILON; //(int)(((double)(output_task_vertex)/dur_req) + EPSILON);
			in_st  = (int)(((double)(output_task_vertex)/dur_req) + EPSILON);
			
			SIM_OUT_NW = EPSILON; //(int)(((double)(output_task_vertex)/dur_req));
			SIM_IN_ST  = (int)(((double)(output_task_vertex)/dur_req));
		}
		else {
			out_nw = (int)(0.2 * ((double)(input_task_vertex)/dur_req) + EPSILON);
			in_st  = (int)(((double)(input_task_vertex)/dur_req) + EPSILON);
			
			SIM_OUT_NW = (int)(0.2 * ((double)(input_task_vertex)/dur_req));
			SIM_IN_ST  = (int)(((double)(input_task_vertex)/dur_req));
		}		
		
		vertexProfileReal =  new ResourceProfile((int)dur_req, cpu_req, mem_req,
												  in_nw, out_nw, in_st, out_st, 
												  (int)input_task_vertex, (int)output_task_vertex);				
		
		vertexProfileReal.updateTaskSimulationFungibleResources(SIM_IN_NW, SIM_OUT_NW, SIM_IN_ST, SIM_OUT_ST);
		
	}
	
	
	public void updateTaskProfileFromUpdateFile(String[] info) throws Exception {
		
		if (info.length != 6) 
			throw new IOException("Insufficient resource parameters for vertex: "+vertexName);
		
		updateVertexProfile.update_num_tasks_stats = Integer.parseInt(info[0]);
		updateVertexProfile.update_task_duration   = Integer.parseInt(info[1]);
		updateVertexProfile.update_task_cpu_usage  = Integer.parseInt(info[2]);
		updateVertexProfile.update_task_mem_usage  = Integer.parseInt(info[3]);
		updateVertexProfile.update_task_input      = Integer.parseInt(info[4]);
		updateVertexProfile.update_task_output     = Integer.parseInt(info[5]);
	
	}	
	
	/* update a task resource profile whenever an update event is triggered by TEZ  */
	public void updateTaskProfileEvent(Task _t, TaskStatusUpdateEvent sEvent) {

	  synchronized(this) {
		
		//LOG.info("[GR]: task profile event for task: "+_t.getTaskId().toString());

		TezTaskID _tId = _t.getTaskId();
		
		if ( !tasksProfile.containsKey(_tId) )
			tasksProfile.put(_tId, new ResourceProfile());
		
		
		double cpu_used = sEvent.getCounters().findCounter(TaskCounter.CPU_MILLISECONDS).getValue();
		cpu_used = (double)(cpu_used / ResourceProfile.MSEC_TO_SEC);
		cpu_used *= 100;
		if (cpu_used > 0) {
			tasksProfile.get(_tId).update_task_cpu_usage = (int)Math.round(cpu_used); 					 
		}
		
		double peak_memory_used = sEvent.getCounters().findCounter(TaskCounter.PHYSICAL_MEMORY_BYTES).getValue();
		peak_memory_used = (double) peak_memory_used / ResourceProfile.B_TO_MB;
		if (peak_memory_used > tasksProfile.get(_tId).update_task_mem_usage) 
			tasksProfile.get(_tId).update_task_mem_usage = (int)Math.round(peak_memory_used*1000)/1000; 
		
		//TODO double check
		//double currentInputProcessed = sEvent.getCounters().findCounter(TaskCounter.INPUT_BYTES_PROCESSED).getValue(); // ??
		double currentInputProcessed = sEvent.getCounters().findCounter(TaskCounter.INPUT_RECORDS_PROCESSED).getValue(); // ??
		double currentInputShuffleIn = sEvent.getCounters().findCounter(TaskCounter.SHUFFLE_BYTES).getValue();
		double inputProcessed = Math.max(currentInputProcessed, currentInputShuffleIn);				
		inputProcessed = (double)inputProcessed / ResourceProfile.B_TO_MB;		
		if (inputProcessed > 0) 
			tasksProfile.get(_tId).update_task_input = (int)Math.round(inputProcessed*1000)/1000;
		
		
		double currentOutputLocal = sEvent.getCounters().findCounter(TaskCounter.OUTPUT_BYTES).getValue();
		double currentOutputHDFS = sEvent.getCounters().findCounter("hdfs", FileSystemCounter.BYTES_WRITTEN).getValue(); 
		double outputProcessed = Math.max(currentOutputLocal, currentOutputHDFS);
		outputProcessed = (double)outputProcessed / ResourceProfile.B_TO_MB;
		if (outputProcessed > 0) {
			tasksProfile.get(_tId).update_task_output = (int)Math.round(outputProcessed*1000)/1000;
		}
	  }		
	}
	
	/* update profiler file based on when a task finish */
	public void notificationTaskFinished(TezTaskID _tId, long _task_duration) {
		
	  //LOG.info("[GR] notification task finished !");
		
	  synchronized(this) {
		
		// not necessarily true, a task can finish even w/o a previous report
		if (!tasksProfile.containsKey(_tId)) { 
			LOG.info("[GR]: ERROR -> no profile for task: "+_tId.toString());
			return;
		}		
				
		double task_duration = (double) _task_duration / ResourceProfile.MSEC_TO_SEC;
		//LOG.info("[GR] task_duration="+task_duration);
		//LOG.info("[GR] updateVertexProfile.update_task_duration="+updateVertexProfile.update_task_duration);
		if (updateVertexProfile.update_task_duration < 0) {
			updateVertexProfile.update_task_duration = 
						Math.max((int)Math.round(task_duration*1000)/1000, 0);
		}
		else {
			double vertex_duration = updateVertexProfile.update_task_duration * updateVertexProfile.update_num_tasks_stats;
			vertex_duration = (double)(vertex_duration + task_duration) / (updateVertexProfile.update_num_tasks_stats + 1);
			//LOG.info("[GR] vertex_duration="+vertex_duration);
			updateVertexProfile.update_task_duration = 
						Math.max((int)Math.round(vertex_duration*1000)/1000, 0);
		}
		
		LOG.info("notificationTaskFinished("+vertexName+")"+" cpu_usage:"+tasksProfile.get(_tId).update_task_cpu_usage+" num_cores="+ResourceProfile.NUM_CORES+" task_duration="+task_duration);

		double cpu_used = (double) tasksProfile.get(_tId).update_task_cpu_usage / (ResourceProfile.NUM_CORES * task_duration);		
		
		LOG.info("notificationTaskFinished("+vertexName+")"+"cpu_used="+cpu_used);
		
		if (updateVertexProfile.update_task_cpu_usage < 0) {
			updateVertexProfile.update_task_cpu_usage = 
						Math.max((int)cpu_used, 0);
		}
		else {
			double vertex_cpu_cycles = updateVertexProfile.update_task_cpu_usage * updateVertexProfile.update_num_tasks_stats;
			vertex_cpu_cycles = (double)(vertex_cpu_cycles + cpu_used) / (updateVertexProfile.update_num_tasks_stats + 1);
			updateVertexProfile.update_task_cpu_usage = 
						Math.max((int)vertex_cpu_cycles, 0);
		}
		
		double peak_mem_used = (double) tasksProfile.get(_tId).update_task_mem_usage;
		if (updateVertexProfile.update_task_mem_usage < 0)
			updateVertexProfile.update_task_mem_usage = 
						Math.max((int)Math.round(peak_mem_used*1000)/1000, 0);
		else {
			double vertex_mem_peak_used = updateVertexProfile.update_task_mem_usage * updateVertexProfile.update_num_tasks_stats;
			vertex_mem_peak_used = (double)(vertex_mem_peak_used + peak_mem_used) / (updateVertexProfile.update_num_tasks_stats + 1);
			updateVertexProfile.update_task_mem_usage = 
						Math.max((int)Math.round(vertex_mem_peak_used*1000)/1000, 0);
		}
		
		double total_task_input = (double) tasksProfile.get(_tId).update_task_input;
		if (updateVertexProfile.update_task_input < 0)
			updateVertexProfile.update_task_input = 
						Math.max((int)Math.round(total_task_input*1000)/1000, 0);
		else {
			double vertex_total_input = updateVertexProfile.update_task_input * updateVertexProfile.update_num_tasks_stats;
			vertex_total_input = (double)(vertex_total_input + total_task_input) / (updateVertexProfile.update_num_tasks_stats + 1);
			updateVertexProfile.update_task_input = 
						Math.max((int)Math.round(vertex_total_input*1000)/1000, 0);
		}

		double total_task_output = (double) tasksProfile.get(_tId).update_task_output;
		if (updateVertexProfile.update_task_output < 0) {
			updateVertexProfile.update_task_output = 
						Math.max((int)Math.round(total_task_output*1000)/1000, 0);
		}
		else {
			double vertex_total_output = updateVertexProfile.update_task_output * updateVertexProfile.update_num_tasks_stats;
			vertex_total_output = (double)(vertex_total_output + total_task_output) / (updateVertexProfile.update_num_tasks_stats + 1);
			updateVertexProfile.update_task_output = 
						Math.max((int)Math.round(vertex_total_output*1000)/1000, 0);
		}
		
		updateVertexProfile.update_num_tasks_stats++;			

/*		
		LOG.info("[GR]: after vertex " + vertexName + " status");
		LOG.info("[GR]: #tasks: "+vertexProfile.num_tasks_vertex+
				" #tasks_stats: "+vertexProfile.num_tasks_stats+
				" dur="+vertexProfile.total_duration+
				" cpu="+vertexProfile.cpu_cycles+
				" mem="+vertexProfile.mem_peak+
				" in="+vertexProfile.total_input+
				" out="+vertexProfile.total_output);
		*/
		}
	}
	
}
