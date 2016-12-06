package org.apache.tez.dag.profiler;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.yarn.api.records.Resource;
import org.apache.tez.dag.api.EdgeProperty;
import org.apache.tez.dag.api.InputDescriptor;
import org.apache.tez.dag.api.OutputDescriptor;
import org.apache.tez.dag.api.ProcessorDescriptor;
import org.apache.tez.dag.api.TezConfiguration;
import org.apache.tez.dag.api.EdgeProperty.DataMovementType;
import org.apache.tez.dag.api.EdgeProperty.DataSourceType;
import org.apache.tez.dag.api.EdgeProperty.SchedulingType;
import org.apache.tez.dag.api.records.DAGProtos.DAGPlan;
import org.apache.tez.dag.api.records.DAGProtos.EdgePlan;
import org.apache.tez.dag.api.records.DAGProtos.PlanEdgeDataMovementType;
import org.apache.tez.dag.api.records.DAGProtos.PlanEdgeDataSourceType;
import org.apache.tez.dag.api.records.DAGProtos.PlanEdgeSchedulingType;
import org.apache.tez.dag.api.records.DAGProtos.PlanTaskConfiguration;
import org.apache.tez.dag.api.records.DAGProtos.PlanTaskLocationHint;
import org.apache.tez.dag.api.records.DAGProtos.PlanVertexType;
import org.apache.tez.dag.api.records.DAGProtos.TezEntityDescriptorProto;
import org.apache.tez.dag.api.records.DAGProtos.VertexPlan;
import org.apache.tez.dag.app.AppContext;
import org.apache.tez.dag.app.dag.Task;
import org.apache.tez.dag.app.dag.Vertex;
import org.apache.tez.dag.records.TezTaskID;
import org.apache.tez.runtime.api.events.TaskStatusUpdateEvent;


/** 
 * GRAPHENE - DAG profiler class
 * keeps track of resources used by each vertex in the DAG
 */
@SuppressWarnings("unused")
public class DAGProfiler {

	public boolean readProfileFromFile = false;
	
	String dagName;
	AppContext appContext = null;
			
	// keep track of the DAG structure
	// for every vertex -> parents, children
	public HashMap<String, Set<String>> parents;
	public HashMap<String, Set<String>> children;
	
	// keep track of profile per vertex
	public HashMap<String, VertexProfiler> vertices;
		
	boolean enableProfileResources = false;
	boolean enableProfileSet = false;
		
	// DAGSimulation object -> to write DAG structure for simulator
	// same DAG should be used to make requests to simulator at real time
	DAGSimulation sim_dag = null;
	
	// keep track of all critical paths from every vertex //
	public HashMap<String, Double> criticalPathLengths;		
	
	// compute rsrcArea for the whole DAG - required by GRAPHENE //
	public double[] rsrcAreaStage;
	public int tightestDim;
	
	static final Log LOG = LogFactory.getLog(DAGProfiler.class);
	
	public DAGProfiler(AppContext _appContext, DAGPlan jobPlan, String _dagName) {
				
		LOG.info("[Tan] New DAGProfiler: dagName="+_dagName);
		dagName = _dagName;
		
		appContext 	= _appContext;		
		
		vertices 	= new HashMap<String, VertexProfiler>();	
		
		parents  	= new HashMap<String, Set<String>>();
		children 	= new HashMap<String, Set<String>>();			
		
		rsrcAreaStage = new double[VertexProfiler.NUM_DIMENSIONS];
		
		appContext.getAMConf().addResource("tez-site.xml");
		
		//TODO: load the DAG structures from files instead of using the submitted ones.
		// populate DAG structure
		// parents and children structures
		// create default resource profiles
		populateDAGStructure(jobPlan);
		
		// load DAG profile
//		loadDAGResourceProfile(false);
		
		// load DAG profiler
		//loadDAGResourceProfile(true);
		
		// create a simulation dag
		sim_dag = new DAGSimulation(this);
		
		// compute critical path lengths
		criticalPathLengths = new HashMap<String, Double>();	
		setAllCriticalPaths();
		
		// compute rsrc area information for dag
		// computeRsrcArea();
	}
	
	/* useful metrics used by DAGGrapheneScheduler */
	/* compute MaxCP() */
	public double MaxCP() {
		
		if ( (criticalPathLengths == null) || (criticalPathLengths.size() <= 0) )
			setAllCriticalPaths();
		
		return Collections.max(criticalPathLengths.values());
	}
	
	
	/* end useful metrics used by DAGGrapheneScheduler */
	
	public AppContext getContext() {
		return this.appContext;
	}
	
	public String getDAGName() {
		return this.dagName;
	}
	
	/* print DAG */
	public void viewDAG() {
		
		LOG.info("[Tan] -- VIEW DAG: -- num of Vertices = " + this.vertices.size());
		for (String vertex : this.vertices.keySet()) {
			
			LOG.info("\t vertex: "+vertex + " num of tasks: ");
			for (String vertex_p : parents.get(vertex))
				LOG.info("\t --> parent: "+vertex_p);
			
			for (String vertex_c : children.get(vertex))
				LOG.info("\t --> child: "+vertex_c);
		}
	}
	
	/*
	 * return instance of simulation dag
	 * */
	public DAGSimulation simulationDAG() {
		
		boolean enabled_sim = appContext.getAMConf()										 
									 .getBoolean(TezConfiguration.TEZ_GRAPHENE_SIM_LOGGING_INFO_ENABLED, 
											     TezConfiguration.TEZ_GRAPHENE_SIM_LOGGING_INFO_ENABLED_DEFAULT);
		
		if (!enabled_sim)
			return null;
		
		return sim_dag;
	}
	
	
	/* populate with parents and children for every vertex */
	public void populateDAGStructure(DAGPlan jobPlan) {
	  LOG.info("[Tan] - populate DAG structure");
	  
		
		List<VertexPlan> vertices = jobPlan.getVertexList();
		
				
		// for every vertex, for every outEdge, looks who has inEdge
		// and update parent -> child relationship.
		for (VertexPlan vertex1 : vertices) {
		  
			String vertex1Name = vertex1.getName();
			
			if (children.get(vertex1Name) == null)
				children.put(vertex1Name, new HashSet<String>());						
			if (parents.get(vertex1Name) == null)
				parents.put(vertex1Name, new HashSet<String>());		
						
			if ( !this.vertices.containsKey(vertex1Name) ) {
				ResourceProfile default_profile = ResourceProfile.createDefaultResourceProfile(appContext.getAMConf()); 												
				this.vertices.put(vertex1Name, new VertexProfiler(vertex1Name, this, default_profile));
			}
			
			for (String outEdge : vertex1.getOutEdgeIdList()) {
				
				for (VertexPlan vertex2 : vertices) {
													
					String vertex2Name = vertex2.getName();
					
					if (children.get(vertex2Name) == null)
						children.put(vertex2Name, new HashSet<String>());						
					if (parents.get(vertex2Name) == null)
						parents.put(vertex2Name, new HashSet<String>());
					
					for (String inEdge : vertex2.getInEdgeIdList()) {
						if (outEdge.equals(inEdge)) {
							
							// populate parents and children lists
							children.get(vertex1Name).add(vertex2Name);
							parents.get(vertex2Name).add(vertex1Name);
						}
					}
				}
			}			
		}	
		
		viewDAG();
	}	
	
		
	
	/* compute score of the DAG jobs*/
	public double computeScoreSRTF() {
		
		/*
		if (true)
			return 1;
		*/		
		double score_srtf = 0;				
		for (String vertexName : vertices.keySet()) {
			
			ResourceProfile vertexResources = vertices.get(vertexName).vertexProfileReal;
			
			double vertex_norm = Math.pow(vertexResources.task_cpu_usage, 2);
			vertex_norm += Math.pow(vertexResources.task_mem_usage,        2);
			vertex_norm += Math.pow(vertexResources.task_in_nw_usage,  	   2);
			vertex_norm += Math.pow(vertexResources.task_out_nw_usage, 	   2);
			vertex_norm += Math.pow(vertexResources.task_in_st_usage,      2);
			vertex_norm += Math.pow(vertexResources.task_out_st_usage, 	   2);
			
			int remTasksVertex = appContext.getCurrentDAG().
										getVertex(vertexName).getRemainingTasks();
			score_srtf += remTasksVertex * Math.sqrt(vertex_norm) * vertexResources.task_duration;			
		}
		
		//LOG.info("[Tan] score job SRTF:"+score_srtf);
		return score_srtf;
	}
	
	
	/* vertex specific functions to update resource profiles per task */
	/* load DAG resource demands profile if any existing one */ 
	public synchronized void loadDAGResourceProfile(boolean isResourceUpdateProfile) {
		
		LOG.info("[Tan] load DAG resource profile; looking for dag resource profile: "+dagName+".profile");
		
		// keep 2 files in each directory
		// one with profile to used in the job
		// second is continuously updated with new stats				
		String dag_profile_location = appContext.getAMConf().get(TezConfiguration.TEZ_DIR_GRAPHENE_LOGGING_INFO, 
				   															TezConfiguration.TEZ_DIR_GRAPHENE_LOGGING_INFO_DEFAULT);
				
		dag_profile_location += "/profiles/";
		
		String location = dag_profile_location + dagName + ( (!isResourceUpdateProfile) ? ".profile" : ".profile_update" ); 
		LOG.info("[Tan] location loaded: "+location);
		File fr = new File(location);
		
		// create profile directory if does not exists
		createDir(dag_profile_location);
		
		if ( fr.isDirectory() || !fr.exists() ) {
			LOG.info("[Tan] profile not found; remains with default resource profile");
			return;
		} else {
  		try {
  			BufferedReader br = new BufferedReader(new FileReader(fr));
  			String line = null;			
  			try {
  				while ( (line = br.readLine()) != null ) {
  					LOG.info("line="+line+"|done");
  					String vertexName = line.split(":")[0];					
  					if ( !vertices.containsKey(vertexName) )
  						vertices.put(vertexName, new VertexProfiler(vertexName, this));
  					
  					String[] vertexProfile = line.split(":")[1].split(" ");															
  					
  					try {
  						if ( !isResourceUpdateProfile )
  							vertices.get(vertexName).updateTaskProfileFromResourceFile(vertexProfile);
  						else
  							vertices.get(vertexName).updateTaskProfileFromUpdateFile(vertexProfile);
  					} catch (Exception e) {
  						e.printStackTrace();
  					}
  				}				
  			} catch (IOException e) {
  				LOG.info("[Tan]: Unable to read profile for"+dagName+".profile");
  				e.printStackTrace();
  			}
  		} catch (FileNotFoundException e) {
  			LOG.info("[Tan]: Unable to read profile for"+dagName+".profile");
  			e.printStackTrace();
  		}	
  		
  		LOG.info("[Tan]: updated profile for dag "+dagName);			
  	  
  	  for (String vertex : vertices.keySet()) {
  	  	LOG.info("[Tan]:: Vertex: "+vertex+" duration: "+vertices.get(vertex).vertexProfile.getDuration());
  	  }
  	  
  	  for (String vertex : children.keySet()) 
  		  LOG.info("[Tan]: vertex: "+vertex+" children="+children.get(vertex));
  	  for (String vertex : parents.keySet()) 
  		  LOG.info("[Tan]: vertex: "+vertex+" parents="+parents.get(vertex));
		}
	}
		
	
	/* return the vertex profiler for a vertex */
	public ResourceProfile getVertexResourceProfile(String vertexName) {
		return vertices.get(vertexName).vertexProfile;
	}	
	
	/* return the vertex profiler for actual resource demands used by vertex */
	public ResourceProfile getVertexTaskResourceRequirements(String vertexName) {
	  VertexProfiler vp = vertices.get(vertexName);
	  if (vp==null)
	    return null;
		return vp.vertexProfileReal;
	}	
	
	/* return the update vertex profiler for a vertex */
	public ResourceProfile getUpdateVertexResourceProfile(String vertexName) {
		return vertices.get(vertexName).updateVertexProfile;
	}

	/* update a task profile whenever a status update event is triggered */
	public synchronized void statusUpdateTask(String _vertexName, 
								  TezTaskID _tezTId,
								  TaskStatusUpdateEvent sEvent) {				
		
		if (appContext.getCurrentDAG() == null)
			return;
				
		enableProfileResources = appContext.getAMConf().getBoolean(TezConfiguration.TEZ_ENABLE_VERTEX_PROFILE_UPDATE, 
				 TezConfiguration.TEZ_ENABLE_VERTEX_PROFILE_UPDATE_DEFAULT);
		
		if (!enableProfileResources)
			return;
				
			//LOG.info("[Tan] update profile for vertex: " +_vertexName + " for dag: " + dagName);
			
			Task t = appContext.getCurrentDAG().getVertex(_vertexName).getTask(_tezTId);			
			
			if ( !vertices.containsKey(_vertexName) )	
				vertices.put(_vertexName, new VertexProfiler(_vertexName, this));
					
			vertices.get(_vertexName).updateTaskProfileEvent(t, sEvent);			
	}
	
	
	/* whenever a task have finished update the stats to vertex profile */
	public synchronized void statusFinishTask(String _vertexName, 
								  TezTaskID _tezId,
								  long task_duration) {
		if (appContext.getCurrentDAG() == null)
			return;
				
		enableProfileResources = appContext.getAMConf().getBoolean(TezConfiguration.TEZ_ENABLE_VERTEX_PROFILE_UPDATE, 
				 TezConfiguration.TEZ_ENABLE_VERTEX_PROFILE_UPDATE_DEFAULT);
		
		if (!enableProfileResources)
			return;
		
			//LOG.info("[Tan] task finished for vertex: "+_vertexName+" duration: "+task_duration);
			
			if ( !vertices.containsKey(_vertexName) )
				vertices.put(_vertexName, new VertexProfiler(_vertexName, this));
			
			vertices.get(_vertexName).notificationTaskFinished(_tezId, task_duration);		
	}
	
	public void createDir(String location) {
		
		File dir = new File(location);
		if (!dir.exists()) {
			LOG.info("[Tan] creating directory: "+location);
			dir.mkdirs();
		}
		
	}
	
	/* off-load updated profile content to file on disk */
	/* eventually update dag.profile */
	@SuppressWarnings("unchecked")
	public synchronized void jobFinished() {			
						
		if (appContext.getCurrentDAG() == null)
			return;

		// create sim file if any
		if (sim_dag != null)
			sim_dag.writeDAGToFileStageLevel();
		
		enableProfileResources = appContext.getAMConf().getBoolean(TezConfiguration.TEZ_ENABLE_VERTEX_PROFILE_UPDATE, 
				 TezConfiguration.TEZ_ENABLE_VERTEX_PROFILE_UPDATE_DEFAULT);
		
		if (!enableProfileResources)
			return;
		
		enableProfileSet = appContext.getAMConf().getBoolean(TezConfiguration.TEZ_ENABLE_VERTEX_PROFILE_SET, 
				   TezConfiguration.TEZ_ENABLE_VERTEX_PROFILE_SET_DEFAULT);
		
		// keep 2 files in each directory
		// one with profile to used in the job
		// second is continuously updated with new stats
		String dag_profile_location = appContext.getAMConf().get(TezConfiguration.TEZ_DIR_GRAPHENE_LOGGING_INFO, 
				   															TezConfiguration.TEZ_DIR_GRAPHENE_LOGGING_INFO_DEFAULT);
				
		dag_profile_location += "/profiles/";
		
		createDir(dag_profile_location);
		
		LOG.info("[Tan] job finished; DAG "+dagName+ " close and write to resource file !");							

		try {
			String location = dag_profile_location + dagName + ".profile_update"; 
			FileWriter file = new FileWriter(location);
							
			for (String vertex : vertices.keySet()) {
				
				file.write(vertex+":"+
						  	vertices.get(vertex).updateVertexProfile.update_num_tasks_stats + " " +
						  	vertices.get(vertex).updateVertexProfile.update_task_duration + " "   +
						  	vertices.get(vertex).updateVertexProfile.update_task_cpu_usage + " "  +
						  	vertices.get(vertex).updateVertexProfile.update_task_mem_usage + " "  +
						  	vertices.get(vertex).updateVertexProfile.update_task_input + " " 	  +
						  	vertices.get(vertex).updateVertexProfile.update_task_output + "\n");
				file.flush();
			}					
			file.close();	
				
		
		// if enabled allows to update vertex profile as well
		if (enableProfileSet) {
			
			location = dag_profile_location + dagName + ".profile"; 
			file = new FileWriter(location);
			
			for (String vertex : vertices.keySet()) {
				
				file.write(vertex+":"+
						  	vertices.get(vertex).tasksProfile.keySet().size() + " " +
						  	vertices.get(vertex).updateVertexProfile.update_task_duration + " "   +
						  	vertices.get(vertex).updateVertexProfile.update_task_cpu_usage + " "  +
						  	vertices.get(vertex).updateVertexProfile.update_task_mem_usage + " "  +
						  	vertices.get(vertex).updateVertexProfile.update_task_input + " " 	  +
						  	vertices.get(vertex).updateVertexProfile.update_task_output + "\n");
				file.flush();
			}					
			file.close();	
		}
				
		} catch (IOException e) {
			e.printStackTrace();
		}	
	}
	
	/* get children nodes*/
	public HashMap<String, Set<String>> getChildren() {
		return this.children;
	}
	
	/* get number of vertices in/out for a vertex*/
	public int num_vertices_in(String vertexName) {
		return parents.get(vertexName).size();
	}
	
	public int num_vertices_out(String vertexName) {
		LOG.info("vertexName="+vertexName);
		LOG.info("children.size="+children.size());
		LOG.info("children.keys="+children.keySet());
		return children.get(vertexName).size();
	}
	
	/* compute rsrc area information for all the nodes */
	public synchronized void computeRsrcArea() {
		
		LOG.info("[Tan] - computeRsrcArea -");
		
		// compute rsrc area per individual stages
		for ( String vertexName : vertices.keySet() ) {
			LOG.info("[Tan] - vertexName:"+vertexName);
			int num_tasks_vertex = appContext.getCurrentDAG().getVertex(vertexName).getTotalTasks();
			LOG.info("[Tan] - num_tasks_vertex");
			vertices.get(vertexName).computeRsrcAreaVertex();
		}
		
		double maxRsrc = 0;
		// compute rsrc area per whole dag
		for (int dim=0; dim < VertexProfiler.NUM_DIMENSIONS; dim++) {
			double x = 0;
			for (String vertexName : vertices.keySet())
				x += vertices.get(vertexName).rsrcAreaVertex[dim];
			
			rsrcAreaStage[dim] = x;
			
			if (x > maxRsrc) {
				maxRsrc = x;
				tightestDim = dim;
			}
		}
	}
	
	
	/* computes critical paths for all the nodes */	
	public synchronized void setAllCriticalPaths() {
		
		// the pointers to next hop are set inside longestCriticalPath
		for ( String vertexName : vertices.keySet() ) {
			this.criticalPathLengths.put(vertexName, 
						longestCriticalPath(vertexName, this.criticalPathLengths));					
		}
		
		LOG.info("[Tan] -- allCriticalPaths: --");
		for (String vertex : this.criticalPathLengths.keySet())
			LOG.info("[Tan] "+vertex+" -> "+this.criticalPathLengths.get(vertex));
	}
	
	/* computes the longest critical path for a vertex */
	double longestCriticalPath(String vertex_start, Map<String, Double> criticalPathLengthsOfChildren) {
		
		if (criticalPathLengthsOfChildren == null)
			criticalPathLengthsOfChildren = new HashMap<String, Double>();
		
		// did it already ?
		if ( criticalPathLengthsOfChildren.containsKey(vertex_start) )
			return criticalPathLengthsOfChildren.get(vertex_start);
		
		double maxChildCriticalPathLength = Double.MIN_VALUE;
		
		// if it is leaf
		if (num_vertices_out(vertex_start)== 0) {
			maxChildCriticalPathLength = 0;
		}
		else {
			
			// take max of children					
			for ( String childVertex : getChildren().get(vertex_start) ) {
				double x = longestCriticalPath(childVertex, criticalPathLengthsOfChildren);
				
				if (x > maxChildCriticalPathLength) {
					maxChildCriticalPathLength = x;
				}
			}	
		}
			
		int vertex_start_duration = getVertexResourceProfile(vertex_start).getDuration();
		//vertex_start_duration = Math.max(vertex_start_duration, ResourceProfile.TASK_DURATION);		
		
		criticalPathLengthsOfChildren.put(vertex_start, maxChildCriticalPathLength + vertex_start_duration);
		
		return criticalPathLengthsOfChildren.get(vertex_start);		
	}

	// return the longest critical path for a vertex
	public double getLongestCriticalPathVertex(String vertexName) {
		
		if ( !criticalPathLengths.containsKey(vertexName) ) 
			return -1;
		
		return criticalPathLengths.get(vertexName);
	}
}