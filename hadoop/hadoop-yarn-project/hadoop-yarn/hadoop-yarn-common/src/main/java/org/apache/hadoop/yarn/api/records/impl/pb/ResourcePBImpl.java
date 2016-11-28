/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.hadoop.yarn.api.records.impl.pb;


import org.apache.hadoop.classification.InterfaceAudience.Private;
import org.apache.hadoop.classification.InterfaceStability.Unstable;
import org.apache.hadoop.yarn.api.records.Resource;
import org.apache.hadoop.yarn.proto.YarnProtos.ResourceProto;
import org.apache.hadoop.yarn.proto.YarnProtos.ResourceProtoOrBuilder;

@Private
@Unstable
public class ResourcePBImpl extends Resource {
  ResourceProto proto = ResourceProto.getDefaultInstance();
  ResourceProto.Builder builder = null;
  boolean viaProto = false;
  
  public ResourcePBImpl() {
    builder = ResourceProto.newBuilder();
  }

  public ResourcePBImpl(ResourceProto proto) {
    this.proto = proto;
    viaProto = true;
  }
  
  public ResourceProto getProto() {
    proto = viaProto ? proto : builder.build();
    viaProto = true;
    return proto;
  }

  private void maybeInitBuilder() {
    if (viaProto || builder == null) {
      builder = ResourceProto.newBuilder(proto);
    }
    viaProto = false;
  }
    
  
  @Override
  public int getMemory() {
    ResourceProtoOrBuilder p = viaProto ? proto : builder;
    return (p.getMemory());
  }

  @Override
  public void setMemory(int memory) {
    maybeInitBuilder();
    builder.setMemory((memory));
  }

  @Override
  public int getVirtualCores() {
    ResourceProtoOrBuilder p = viaProto ? proto : builder;
    return (p.getVirtualCores());
  }

  @Override
  public void setVirtualCores(int vCores) {
    maybeInitBuilder();
    builder.setVirtualCores((vCores));
  }

  @Override
  public int compareTo(Resource other) {
    int diff = this.getMemory() - other.getMemory();
    if (diff == 0) {
      diff = this.getVirtualCores() - other.getVirtualCores();
    }
    return diff;
  }

  // emulation <<
  boolean isMapResource = false;
  
  @Override
	public int getInNetwork() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    return (p.getInNetwork());
	}
	
	@Override
	public void setInNetwork(int in_network) {
	    maybeInitBuilder();
	    builder.setInNetwork(in_network);
	}

	@Override
	public int getOutNetwork() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    return (p.getOutNetwork());
	}
	
	@Override
	public void setOutNetwork(int out_network) {
	    maybeInitBuilder();
	    builder.setOutNetwork(out_network);
	}
	
	@Override
	public int getInStorage() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    return (p.getInStorage());
	}
	
	@Override
	public void setInStorage(int in_storage) {
	    maybeInitBuilder();
	    builder.setInStorage(in_storage);
	}
	
	@Override
	public int getOutStorage() {	
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    return (p.getOutStorage());
	}
	
	@Override
	public void setOutStorage(int out_storage) {
	    maybeInitBuilder();
	    builder.setOutStorage(out_storage);
	}

	@Override
	public int getCpu() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    return (p.getCpu());
	}

	@Override
	public void setCpu(int cpu_avail) {
	    maybeInitBuilder();
	    builder.setCpu(cpu_avail);
	}

	@Override
	public int getVMem() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    return (p.getVmem());
	}

	@Override
	public void setVMem(int mem_avail) {
	    maybeInitBuilder();
	    builder.setVmem(mem_avail);
	}

	@Override
	public boolean isAMResource() {
		
		if ( (getCpu() == 0)        &&
			 (getVMem() == 0)       &&
			 (getInNetwork() == 0)  &&
			 (getOutNetwork() == 0) &&
			 (getInStorage() == 0)  &&
			 (getOutStorage() == 0)	&& 
			 (getMemory() > 0) 
			) {
			return true;
		}		
		return false;
	}

	@Override
	public boolean isMapResource() {
		return isMapResource;
	}

	@Override
	public void setMapResource() {
		isMapResource = true;		
	}

	@Override
	public int getRemRedTasksToSched() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    int rem_red_tasks = p.getRemRedTasksToSched();
	    return rem_red_tasks;
	}

	@Override
	public void setRemRedTasksToSched(int tasks_to_sched) {
	    maybeInitBuilder();
	    builder.setRemRedTasksToSched(tasks_to_sched);
    }

	@Override
	public int getRemMapTasksToSched() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    int rem_map_tasks = p.getRemMapTasksToSched();
	    return rem_map_tasks;
	}

	@Override
	public void setRemMapTasksToSched(int tasks_to_sched) {
	    maybeInitBuilder();
	    builder.setRemMapTasksToSched(tasks_to_sched);
    }
	
	@Override
	public int getMapTaskDuration() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    int map_dur = p.getMapDuration();
	    return map_dur;
	}

	@Override
	public void setMapTaskDuration(int task_duration) {
		maybeInitBuilder();
		builder.setMapDuration(task_duration);
	}

	@Override
	public int getRedTaskDuration() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    int red_dur = p.getRedDuration();
	    return red_dur;
	}

	@Override
	public void setRedTaskDuration(int task_duration) {
		maybeInitBuilder();
		builder.setRedDuration(task_duration);	
	}

	@Override
	public int getCpuOther() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    return (p.getCpuOther());
	}

	@Override
	public void setCpuOther(int cpu_avail) {
	    maybeInitBuilder();
	    builder.setCpuOther(cpu_avail);
	}

	@Override
	public int getVMemOther() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    return (p.getVmemOther());
	}

	@Override
	public void setVMemOther(int mem_avail) {
	    maybeInitBuilder();
	    builder.setVmemOther(mem_avail);
	}

	@Override
	public int getInNetworkOther() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    return (p.getInNetworkOther());
	}

	@Override
	public void setInNetworkOther(int in_network) {
	    maybeInitBuilder();
	    builder.setInNetworkOther(in_network);
	}

	@Override
	public int getOutNetworkOther() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    return (p.getOutNetworkOther());
	}

	@Override
	public void setOutNetworkOther(int out_network) {
	    maybeInitBuilder();
	    builder.setOutNetworkOther(out_network);
	}

	@Override
	public int getInStorageOther() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    return (p.getInStorageOther());
	}

	@Override
	public void setInStorageOther(int in_storage) {
	    maybeInitBuilder();
	    builder.setInStorageOther(in_storage);
	}

	@Override
	public int getOutStorageOther() {
	    ResourceProtoOrBuilder p = viaProto ? proto : builder;
	    return (p.getOutStorageOther());
	}

	@Override
	public void setOutStorageOther(int out_storage) {
	    maybeInitBuilder();
	    builder.setOutStorageOther(out_storage);
	}
  // emulation >>

  @Override
  public int getTaskDuration() {
    ResourceProtoOrBuilder p = viaProto ? proto : builder;
    return (p.getTaskDuration());
  }

  @Override
  public void setTaskDuration(int task_duration) {
    maybeInitBuilder();
    builder.setTaskDuration(task_duration);
  }
  
  
}  
