package org.apache.hadoop.mapreduce.v2.app.rm;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class TaskProfile {

	/**
	 * cpu_usage = CPU_TIME_SPENT / (num_cores * duration)
	 * mem_usage = PEAK_MEMORY_AT_SOME_POINT
	 * in_network = total_in_network / duration
	 * out_network= total_out_network / duration
	 * in_storage = total_in_storage / duration
	 * out_storage= total_out_storage / duration
	 */
	private int cpu_usage  = -1;
	private int mem_usage  = -1;
	private int in_network = -1;
	private int out_network= -1;
	private int in_storage = -1;
	private int out_storage= -1;

	private int map_duration = -1;
	private int red_duration = -1;
	
	// max values
	private int max_cpu_usage  = -1;
	private int max_mem_usage  = -1;
	private int max_in_network = -1;
	private int max_out_network= -1;
	private int max_in_storage = -1;
	private int max_out_storage= -1;	
	
	private int max_map_duration= -1;
	private int max_red_duration= -1;
	
	private final double WEIGHT = 0.7;
	
	private int num_entries_cpu    = 0;
	private int num_entries_mem    = 0;
	private int num_entries_in_nw  = 0;
	private int num_entries_out_nw = 0;
	private int num_entries_in_st  = 0;
	private int num_entries_out_st = 0;
	
	private int num_entries_map_dur= 0;
	private int num_entries_red_dur= 0;
	
	boolean isUpdated = false;
	
	static final Log LOG = LogFactory.getLog(TaskProfile.class);
	
	TaskProfile() {}
	
	TaskProfile(int map_dur, int red_dur,
			int cpu_used, int mem_used, 
			int in_nw, int out_nw, 
			int in_st, int out_st) {
		max_map_duration= map_dur;
		max_red_duration= red_dur;
		max_cpu_usage  = cpu_used;
		max_mem_usage  = mem_used;
		max_in_network = in_nw;
		max_out_network= out_nw;
		max_in_storage = in_st;
		max_out_storage= out_st;
	}

	public void setMapDuration(int val) {
		max_map_duration = val;
	}
	public void setRedDuration(int val) {
		max_red_duration = val;
	}
	
	public void setTaskCpuUsage(int val) {
		max_cpu_usage = val;
	}
	public void setTaskMemUsage(int val) {
		max_mem_usage = val;
	}
	public void setTaskInNetworkBwUsage(int val) {
		max_in_network = val;
	}
	public void setTaskOutNetworkBwUsage(int val) {
		max_out_network = val;
	}
	public void setTaskInStorageBwUsage(int val) {
		max_in_storage = val;
	}
	public void setTaskOutStorageBwUsage(int val) {
		max_out_storage = val;
	}

	/**
	 * completion time per map task
	 */
	public void updateMapDuration(int map_dur) {
		if (map_duration == -1)
			map_duration = map_dur;
		else {
			map_duration = (int)Math.ceil((double)(num_entries_map_dur*map_duration+map_dur) 
										/ (num_entries_map_dur + 1));
		}
		num_entries_map_dur++;
	}
	
	/**
	 * completion time per red task
	 */
	public void updateRedDuration(int red_dur) {
		if (red_duration == -1)
			red_duration = red_dur;
		else {
			red_duration = (int)Math.ceil((double)(num_entries_red_dur*red_duration+red_dur) 
										/ (num_entries_red_dur + 1));
		}
		num_entries_red_dur++;
	}
	
	
	/**
	 * amount of Cpu used by a task in % 
	 * */
	public void updateTaskCpuUsage(int cpu_update_val) {

		if (cpu_usage == -1) 
			cpu_usage = cpu_update_val;
		else {
			//cpu_usage = WEIGHT*cpu_usage+(1-WEIGHT)*cpu_update_val;
			cpu_usage = (int)Math.ceil((double)(num_entries_cpu*cpu_usage+cpu_update_val) / (num_entries_cpu + 1));
		}
		num_entries_cpu++;
	}
	
	/**
	 * amount of Mem used by a task - peak memory val in Mbytes
	 * */
	public void updateTaskMemUsage(int mem_update_val) {

		if (mem_usage == -1)
			mem_usage = mem_update_val;
		else {
			//mem_usage = WEIGHT*mem_usage+(1-WEIGHT)*mem_update_val;
			mem_usage = (int)Math.ceil((double)(num_entries_mem*mem_usage+mem_update_val) / (num_entries_mem + 1));
		}
		num_entries_mem++;
	}
	
	/**
	 * return amount of in_network used by a task in MB/s
	 * */
	public void updateTaskInNetworkBwUsage(int in_nw_update_val) {
		
		if (in_nw_update_val < 0)
			return;
		
		if (in_network == -1)
			in_network = in_nw_update_val;
		else {
			//in_network= WEIGHT*in_network+(1-WEIGHT)*in_nw_update_val;
			in_network = (int)Math.ceil((double)(num_entries_in_nw*in_network+in_nw_update_val) / (num_entries_in_nw + 1));
		}
		num_entries_in_nw++;
	}
	
	/**
	 * return amount of out_network used by a task in MB/s 
	 * */
	public void updateTaskOutNetworkBwUsage(int out_nw_update_val) {

		if (out_nw_update_val < 0)
			return;
		
		if (out_network == -1)
			out_network = out_nw_update_val;
		else {
			//out_network= WEIGHT*out_network+(1-WEIGHT)*out_nw_update_val;
			out_network = (int)Math.ceil((double)(num_entries_out_nw*out_network+out_nw_update_val) / (num_entries_out_nw + 1));
		}
		num_entries_out_nw++;
	}
	
	/**
	 * return amount of in_storage used by a task in MB/s 
	 * */
	public void updateTaskInStorageBwUsage(int in_st_update_val) {

		if (in_st_update_val < 0)
			return;
		
		if (in_storage == -1)
			in_storage = in_st_update_val;
		else {
			//in_storage= WEIGHT*in_storage+(1-WEIGHT)*in_st_update_val;
			in_storage = (int)Math.ceil((double)(num_entries_in_st*in_storage+in_st_update_val) / (num_entries_in_st + 1));
		}
		num_entries_in_st++;
	}
	
	/**
	 * return amount of out_storage used by a task in MB/s 
	 * */
	public void updateTaskOutStorageBwUsage(int out_st_update_val) {

		if (out_st_update_val < 0)
			return;
		
		if (out_storage == -1)
			out_storage = out_st_update_val;
		else {
			//out_storage= WEIGHT*out_storage+(1-WEIGHT)*out_st_update_val;
			out_storage = (int)Math.ceil((double)(num_entries_out_st*out_storage+out_st_update_val) / (num_entries_out_st + 1));
		}
		num_entries_out_st++;
	}
	
	
	public int getMapDuration() {
		return (map_duration == -1) ? max_map_duration:map_duration;
	}
	public int getRedDuration() {
		return (red_duration == -1) ? max_red_duration:red_duration;
	}
	public int getTaskCpuUsage() {
		return (cpu_usage == -1) ? max_cpu_usage:cpu_usage;
	}
	public int getTaskMemUsage() {
		return (mem_usage == -1) ? max_mem_usage:mem_usage;
	}
	public int getTaskInNetworkUsage() {
		return (in_network == -1) ? max_in_network:in_network;
	}
	public int getTaskOutNetworkUsage() {
		return (out_network == -1) ? max_out_network:out_network;
	}
	public int getTaskInStorageUsage() {
		return (in_storage == -1) ? max_in_storage:in_storage;
	}
	public int getTaskOutStorageUsage() {
		return (out_storage == -1) ? max_out_storage:out_storage;
	}
	
	 @Override
	  public String toString() {
		    return "<cpuUsage:" + getTaskCpuUsage() + ", vmemUsage:" + getTaskMemUsage() +
		    		", inNwUsage:" + getTaskInNetworkUsage() + ", outNwUsage: " + getTaskOutNetworkUsage() + 
		    		", inStUsage:" + getTaskInStorageUsage() + ", outStUsage: " + getTaskOutStorageUsage() + ">";
	  }
}