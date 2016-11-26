package org.apache.tez.dag.profiler;

import org.apache.hadoop.conf.Configuration;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class ResourceProfile {

	long last_tstamp_update = -1;
		
	// DEFAULT RESOURCE PROFILES
	// constants with default minimum resources used by a task
	public static int NUM_CORES_DEFAULT  = 2; //100 / NUM_CORES;
	public static int TASK_CPU_USAGE_DEFAULT  = 20; //100 / NUM_CORES;
	public static int TASK_MEM_USAGE_DEFAULT  = 2000; // MB
	public static int TASK_IN_NETWORK_DEFAULT = 10;   // MB/s
	public static int TASK_OUT_NETWORK_DEFAULT= 10;   // MB/s
	public static int TASK_IN_STORAGE_DEFAULT = 10;   // MB/s
	public static int TASK_OUT_STORAGE_DEFAULT= 10;   // MB/s
	public static int TASK_DURATION_DEFAULT   = 10;   // s
	
	// constants with values taken from resource profile
	public static int NUM_CORES  	    = -1; //100 / NUM_CORES;
	public static int TASK_CPU_USAGE  = -1; //100 / NUM_CORES;
	public static int TASK_MEM_USAGE  = -1; // MB
	public static int TASK_IN_NETWORK = -1;   // MB/s
	public static int TASK_OUT_NETWORK= -1;   // MB/s
	public static int TASK_IN_STORAGE = -1;   // MB/s
	public static int TASK_OUT_STORAGE= -1;   // MB/s
	public static int TASK_DURATION   = -1;   // s
	////////////////////////
	
	// fields used in resource profile
	int task_cpu_usage   = -1;
	int task_mem_usage   = -1;
	int task_in_nw_usage = -1;
	int task_out_nw_usage= -1;
	int task_in_st_usage = -1;
	int task_out_st_usage= -1;
	int task_duration    = -1;
	
	// fields used when reading DAG profile
	int task_input = -1;
	int task_output= -1;
	int num_tasks  = -1;
	
	// constants required when doing resource normalization
	static long MSEC_TO_SEC = 1000;
	static long B_TO_MB     = 1048576;
	
	
	// resources updated by profiler at runtime
	int update_task_cpu_usage = -1;
	int update_task_mem_usage = -1;
	int update_task_input     = -1;
	int update_task_output    = -1;
	int update_task_duration  = -1;
	int update_num_tasks_stats= 0;
	
	// fungible resources values required by simulation
	int task_in_nw_usage_sim    = -1;
	int task_out_nw_usage_sim   = -1;
	int task_in_st_usage_sim    = -1;
	int task_out_st_usage_sim   = -1;
	
	static final Log LOG = LogFactory.getLog(ResourceProfile.class);
	
	public ResourceProfile() {
		last_tstamp_update = System.currentTimeMillis();
	}

	
	public ResourceProfile(int _dur, int _cpu, int _mem, int _in_nw, int _out_nw, int _in_st, int _out_st) {
		
		task_cpu_usage   = _cpu;
		task_mem_usage   = _mem;
		task_in_nw_usage = _in_nw;
		task_out_nw_usage= _out_nw;
		task_in_st_usage = _in_st;
		task_out_st_usage= _out_st;
		task_duration    = _dur;
	}
	
	public ResourceProfile(int _dur, int _cpu, int _mem, int _in_nw, int _out_nw, int _in_st, int _out_st,
							int _in_task, int _out_task) {
		
		task_cpu_usage   = _cpu;
		task_mem_usage   = _mem;
		task_in_nw_usage = _in_nw;
		task_out_nw_usage= _out_nw;
		task_in_st_usage = _in_st;
		task_out_st_usage= _out_st;
		task_duration    = _dur;
		
		task_input = _in_task;
		task_output= _out_task;		
	}
	
	public static ResourceProfile createDefaultResourceProfile(Configuration conf) {
		ResourceProfile res  = new ResourceProfile();
		
		res.task_cpu_usage   = conf.getInt("rsrc.container.default.cpu_usage", ResourceProfile.TASK_CPU_USAGE_DEFAULT); 
		res.task_mem_usage   = conf.getInt("rsrc.container.default.mem_usage", ResourceProfile.TASK_MEM_USAGE_DEFAULT);			
		res.task_in_nw_usage = conf.getInt("rsrc.container.default.in_nw_usage", ResourceProfile.TASK_IN_NETWORK_DEFAULT);
		res.task_out_nw_usage= conf.getInt("rsrc.container.default.out_nw_usage", ResourceProfile.TASK_OUT_NETWORK_DEFAULT);
		res.task_in_st_usage = conf.getInt("rsrc.container.default.in_st_usage", ResourceProfile.TASK_IN_STORAGE_DEFAULT);
		res.task_out_st_usage= conf.getInt("rsrc.container.default.out_st_usage", ResourceProfile.TASK_OUT_STORAGE_DEFAULT);		
		res.task_duration    = conf.getInt("rsrc.container.default.duration", ResourceProfile.TASK_DURATION_DEFAULT);
		
		ResourceProfile.NUM_CORES  = conf.getInt("rsrc.container.default.num_cores", ResourceProfile.NUM_CORES_DEFAULT); 
		
		ResourceProfile.TASK_CPU_USAGE  = res.task_cpu_usage;
		ResourceProfile.TASK_MEM_USAGE  = res.task_mem_usage;
		ResourceProfile.TASK_IN_NETWORK = res.task_in_nw_usage;
		ResourceProfile.TASK_OUT_NETWORK= res.task_out_nw_usage;
		ResourceProfile.TASK_IN_STORAGE = res.task_in_st_usage;
		ResourceProfile.TASK_OUT_STORAGE= res.task_out_st_usage;
		ResourceProfile.TASK_DURATION   = res.task_duration;
		
		LOG.info("[Tan] createDefaultResourceProfile");
		LOG.info("TASK_CPU_USAGE="+ResourceProfile.TASK_CPU_USAGE+
				 " NUM_CORES="+ResourceProfile.NUM_CORES+
				 "TASK_MEM_USAGE="+ResourceProfile.TASK_MEM_USAGE+
				 "TASK_IN_NETWORK="+ResourceProfile.TASK_IN_NETWORK+
				 "TASK_OUT_NETWORK="+ResourceProfile.TASK_OUT_NETWORK+
				 "TASK_IN_STORAGE="+ResourceProfile.TASK_IN_STORAGE+
				 "TASK_OUT_STORAGE="+ResourceProfile.TASK_OUT_STORAGE+
				 "TASK_DURATION="+ResourceProfile.TASK_DURATION
				);
		
		return res;
	}
	
	
	public void updateTaskSimulationFungibleResources(int _in_nw_sim, int _out_nw_sim, 
													   int _in_st_sim, int _out_st_sim) {
		
		task_in_nw_usage_sim    = _in_nw_sim;
		task_out_nw_usage_sim   = _out_nw_sim;
		task_in_st_usage_sim    = _in_st_sim;
		task_out_st_usage_sim   = _out_st_sim;		
	}
	
	public int getTaskInNwUsageSim() {
		return task_in_nw_usage_sim;
	}
	public int getTaskOutNwUsageSim() {
		return task_out_nw_usage_sim;
	}
	public int getTaskInStUsageSim() {
		return task_in_st_usage_sim;
	}
	public int getTaskOutStUsageSim() {
		return task_out_st_usage_sim;
	}

	
	public void setLastTstampUpdate(long _val) {
		last_tstamp_update = _val;
	}
	
	
	public long getLastTstampUpdate() {
		return last_tstamp_update;
	}	

	public int getDuration() {
		return task_duration;
	}
	public int getCpuUsage() {
		return task_cpu_usage;
	}
	public int getMemUsage() {
		return task_mem_usage;
	}
	public int getInNetworkUsage() {
		return task_in_nw_usage;
	}
	public int getOutNetworkUsage() {
		return task_out_nw_usage;
	}
	public int getInStorageUsage() {
		return task_in_st_usage;
	}
	public int getOutStorageUsage() {
		return task_out_st_usage;
	}
	public int getInput() {
		return task_input;
	}
	public int getOutput() {
		return task_output;
	}
	public int getNumTasks() {
		return num_tasks;
	}
}