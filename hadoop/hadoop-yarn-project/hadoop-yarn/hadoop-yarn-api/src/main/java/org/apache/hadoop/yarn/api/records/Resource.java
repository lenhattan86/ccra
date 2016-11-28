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

package org.apache.hadoop.yarn.api.records;

import org.apache.hadoop.classification.InterfaceAudience.Public;
import org.apache.hadoop.classification.InterfaceStability.Evolving;
import org.apache.hadoop.classification.InterfaceStability.Stable;
import org.apache.hadoop.yarn.api.ApplicationMasterProtocol;
import org.apache.hadoop.yarn.util.Records;

/**
 * <p><code>Resource</code> models a set of computer resources in the 
 * cluster.</p>
 * 
 * <p>Currently it models both <em>memory</em> and <em>CPU</em>.</p>
 * 
 * <p>The unit for memory is megabytes. CPU is modeled with virtual cores
 * (vcores), a unit for expressing parallelism. A node's capacity should
 * be configured with virtual cores equal to its number of physical cores. A
 * container should be requested with the number of cores it can saturate, i.e.
 * the average number of threads it expects to have runnable at a time.</p>
 * 
 * <p>Virtual cores take integer values and thus currently CPU-scheduling is
 * very coarse.  A complementary axis for CPU requests that represents processing
 * power will likely be added in the future to enable finer-grained resource
 * configuration.</p>
 * 
 * <p>Typically, applications request <code>Resource</code> of suitable
 * capability to run their component tasks.</p>
 * 
 * @see ResourceRequest
 * @see ApplicationMasterProtocol#allocate(org.apache.hadoop.yarn.api.protocolrecords.AllocateRequest)
 */
@Public
@Stable
public abstract class Resource implements Comparable<Resource> {

  @Public
  @Stable
  public static Resource newInstance(int memory, int vCores) {
    Resource resource = Records.newRecord(Resource.class);
    resource.setMemory(memory);
    resource.setVirtualCores(vCores);
    return resource;
  }

  /**
   * Get <em>memory</em> of the resource.
   * @return <em>memory</em> of the resource
   */
  @Public
  @Stable
  public abstract int getMemory();
  
  /**
   * Set <em>memory</em> of the resource.
   * @param memory <em>memory</em> of the resource
   */
  @Public
  @Stable
  public abstract void setMemory(int memory);


  /**
   * Get <em>number of virtual cpu cores</em> of the resource.
   * 
   * Virtual cores are a unit for expressing CPU parallelism. A node's capacity
   * should be configured with virtual cores equal to its number of physical cores.
   * A container should be requested with the number of cores it can saturate, i.e.
   * the average number of threads it expects to have runnable at a time.
   *   
   * @return <em>num of virtual cpu cores</em> of the resource
   */
  @Public
  @Evolving
  public abstract int getVirtualCores();
  
  /**
   * Set <em>number of virtual cpu cores</em> of the resource.
   * 
   * Virtual cores are a unit for expressing CPU parallelism. A node's capacity
   * should be configured with virtual cores equal to its number of physical cores.
   * A container should be requested with the number of cores it can saturate, i.e.
   * the average number of threads it expects to have runnable at a time.
   *    
   * @param vCores <em>number of virtual cpu cores</em> of the resource
   */
  @Public
  @Evolving
  public abstract void setVirtualCores(int vCores);

  @Override
  public int hashCode() {
    final int prime = 263167;
    int result = 3571;
    result = 939769357 + getMemory(); // prime * result = 939769357 initially
    result = prime * result + getVirtualCores();
    return result;
  }

  @Override
  public boolean equals(Object obj) {
    if (this == obj)
      return true;
    if (obj == null)
      return false;
    if (!(obj instanceof Resource))
      return false;
    Resource other = (Resource) obj;
    if (getMemory() != other.getMemory() || 
        getVirtualCores() != other.getVirtualCores()) {
      return false;
    }
    return true;
  }

  @Override
  public String toString() {
    String str = "<memory:" + getMemory() + ", vCores:" + getVirtualCores() + ">";
    // emulation <<
    str+= " <cpu:" + this.getCpu()+",vmem:" +getVMem()+ " > " ;
    str+= " <network-in:" + this.getInNetwork()+",network-out:" +getOutNetwork()+ " > " ;
    str+= " <storage-in:" + this.getInStorage()+",storage-out:" +getOutStorage()+ " > " ;
    str+= " <duration:" + this.getTaskDuration()+">" ;
    // emulation >>
    return str;
  }
  
  public boolean isEmpty(){ // iglf
    return this.getMemory()<=0 && this.getVirtualCores()<=0;
  }

  //emulation <<
  
  public static Resource newInstance(int cpu, int vmemory,
      int in_nw, int out_nw,
      int in_st, int out_st) {
      Resource resource = Records.newRecord(Resource.class);      
      
    resource.setCpu(cpu);
    resource.setVMem(vmemory);
    resource.setInNetwork(in_nw);
    resource.setOutNetwork(out_nw);
    resource.setInStorage(in_st);
    resource.setOutStorage(out_st);
    
    return resource;
  }
  
  /**
   * return if the resource is for an AM container or not
   */
  public abstract boolean isAMResource();

  /**
   * return if the resource is for a MAP task
   */
  public abstract boolean isMapResource();
  
  /**
   * set the resource for a map task
   */
  public abstract void setMapResource();
  
  @Public
  @Evolving
  public abstract int getCpu();

  @Public
  @Evolving
  public abstract void setCpu(int cpu_avail);

  @Public
  @Evolving
  public abstract int getVMem();

  @Public
  @Evolving
  public abstract void setVMem(int mem_avail);
  
  @Public
  @Evolving
  public abstract int getInNetwork();  

  @Public
  @Evolving
  public abstract void setInNetwork(int in_network);

  @Public
  @Evolving
  public abstract int getOutNetwork();  

  @Public
  @Evolving
  public abstract void setOutNetwork(int out_network);
  
  @Public
  @Evolving
  public abstract int getInStorage();  

  @Public
  @Evolving
  public abstract void setInStorage(int in_storage);

  @Public
  @Evolving
  public abstract int getOutStorage();  

  @Public
  @Evolving
  public abstract void setOutStorage(int out_storage);  
  
  @Public
  @Evolving
  public abstract int getCpuOther();

  @Public
  @Evolving
  public abstract void setCpuOther(int cpu_avail);

  @Public
  @Evolving
  public abstract int getVMemOther();

  @Public
  @Evolving
  public abstract void setVMemOther(int mem_avail);
  
  @Public
  @Evolving
  public abstract int getInNetworkOther();  

  @Public
  @Evolving
  public abstract void setInNetworkOther(int in_network);

  @Public
  @Evolving
  public abstract int getOutNetworkOther();  

  @Public
  @Evolving
  public abstract void setOutNetworkOther(int out_network);
  
  @Public
  @Evolving
  public abstract int getInStorageOther();  

  @Public
  @Evolving
  public abstract void setInStorageOther(int in_storage);

  @Public
  @Evolving
  public abstract int getOutStorageOther();  

  @Public
  @Evolving
  public abstract void setOutStorageOther(int out_storage);  

  
  @Public
  @Evolving
  public abstract int getRemMapTasksToSched();  

  @Public
  @Evolving
  public abstract void setRemMapTasksToSched(int tasks_to_sched);  
  
  @Public
  @Evolving
  public abstract int getRemRedTasksToSched();  

  @Public
  @Evolving
  public abstract void setRemRedTasksToSched(int tasks_to_sched);  
  
  @Public
  @Evolving
  public abstract int getMapTaskDuration();  

  @Public
  @Evolving
  public abstract void setMapTaskDuration(int task_duration); 
  
  @Public
  @Evolving
  public abstract int getRedTaskDuration();  

  @Public
  @Evolving
  public abstract void setRedTaskDuration(int task_duration);  
  
  @Public
  @Evolving
  public abstract int getTaskDuration();  

  @Public
  @Evolving
  public abstract void setTaskDuration(int task_duration); 
  // emulation >>
}
