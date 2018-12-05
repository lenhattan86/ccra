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
package org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.policies;

import static org.apache.hadoop.yarn.server.resourcemanager.resource.ResourceType.CPU;
import static org.apache.hadoop.yarn.server.resourcemanager.resource.ResourceType.MEMORY;

import java.io.Serializable;
import java.util.Collection;
import java.util.Comparator;

import org.apache.hadoop.classification.InterfaceAudience.Private;
import org.apache.hadoop.classification.InterfaceStability.Unstable;
import org.apache.hadoop.yarn.api.records.Resource;
import org.apache.hadoop.yarn.server.resourcemanager.resource.ResourceType;
import org.apache.hadoop.yarn.server.resourcemanager.resource.ResourceWeights;
import org.apache.hadoop.yarn.server.resourcemanager.rmapp.RMAppMetrics;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FSQueue;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.JobInfo;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.Schedulable;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.SchedulingPolicy;
import org.apache.hadoop.yarn.util.resource.DefaultResourceCalculator;
import org.apache.hadoop.yarn.util.resource.Resources;

import com.google.common.annotations.VisibleForTesting;

import org.apache.commons.logging.LogFactory;
import org.apache.commons.logging.Log;

@Private
@Unstable
public class BoPFSchedulerPolicy extends SchedulingPolicy {
  @VisibleForTesting
  public static final String NAME = "BoPF";
  private BoPFComparator comparator = new BoPFComparator();

  private static String SQ_NAME = "bursty";
  private static String TQ_NAME = "batch";
  private static String IQ_NAME = "IQ";

  private static final DefaultResourceCalculator RESOURCE_CALCULATOR = new DefaultResourceCalculator();

  private static final Log LOG = LogFactory.getLog(BoPFSchedulerPolicy.class);
  static boolean isEDF = true;

  static String IntraQueueSchedulingPolity = "BoPFSched"; // FIFO, EDF,
  // static String IntraQueueSchedulingPolity = "EDF"; // FIFO, EDF,

  public static final boolean DEBUG = true; // enabling this can resulting
                                            // failing the data nodes.
  @Override
  public String getName() {
    return NAME;
  }
  
  @Override
  public void initialize(Resource clusterCapacity) {
    comparator.setClusterCapacity(clusterCapacity);
  }


  static class BoPFComparator implements Comparator<Schedulable>, Serializable {
    private static final long serialVersionUID = -5905036205491177060L;
    private static final int NUM_RESOURCES = ResourceType.values().length;
    
    private Resource clusterCapacity;

    public void setClusterCapacity(Resource clusterCapacity) {
      this.clusterCapacity = clusterCapacity;
    }

    @Override
    public int compare(Schedulable s1, Schedulable s2) {
      // Allocation
      if (s1.isLeafQueue()) {
//        return fair(s1, s2, weight1, weight2);
        return drf(s1, s2);
      } else {
        long now = System.currentTimeMillis();
        // for TQ only
        if (s1.getParentQueue().getQueueName().contains(TQ_NAME)) {
          String jobId1 = s1.getAppName();
          String jobId2 = s2.getAppName();
          
          JobInfo job1 = mapJobInfo.get(jobId1);
          JobInfo job2 = mapJobInfo.get(jobId2);
          if (job1==null) job1 = new JobInfo("job1", 1, 1, 1, 1);
          if (job2==null) job2 = new JobInfo("job2", 1, 1, 1, 1);

          if (IntraQueueSchedulingPolity.equals("FIFO")) {
            return (int) (s1.getStartTime() - s2.getStartTime());
          } else if (IntraQueueSchedulingPolity.equals("EDF")) {
            long deadline1 = s1.getStartTime()/1000 + job1.deadline;
            long deadline2 = s2.getStartTime()/1000 + job2.deadline;
            return (int) (deadline1 - deadline2);

          } else {
            long totalDemand1 = job1.totalDemand;
            long totalDemand2 = job2.totalDemand;

            long receivedRes1 = getAggregateResouce(s1.getAppMetrics(),
                ResourceType.CPU);
            long receivedRes2 = getAggregateResouce(s2.getAppMetrics(),
                ResourceType.CPU);

            long remainTime1 = (totalDemand1 - receivedRes1)
                / job1.demand;
            long remainTime2 = (totalDemand2 - receivedRes2)
                / job2.demand;
            remainTime1 = Math.max(remainTime1, 0);
            remainTime2 = Math.max(remainTime2, 0);

            // sorted based on deadline - processing time.
            long val1 = job1.deadline - remainTime1
                - (now - s1.getStartTime()) / 1000;
            long val2 = job2.deadline - remainTime2
                - (now - s2.getStartTime()) / 1000;
            
//            log(s1.getAppName() + ": remainTime1:" + remainTime1 + " seconds ");
//            log(s2.getAppName() + ": remainTime2:" + remainTime2 + " seconds ");

            // ignore the jobs that are already late.
            if (val1 < 0) {
              val1 = Integer.MAX_VALUE;
              s1.setGuaranteeShare(Resources.clone(Resources.none()));
              log(s1.getAppName() + " is behind the deadline " + val1 + " seconds ");
            } else {
              log(s1.getAppName() + " may complete before the deadline " + val1 + " seconds ");
              s1.setGuaranteeShare(Resource.newInstance(
                  (int) job1.demand * 1024,
                  (int) job1.demand));
            }
            if (val2 < 0) {
              s2.setGuaranteeShare(Resources.clone(Resources.none()));
              val2 = Integer.MAX_VALUE;
              log(s2.getAppName() + " is behind the deadline " + val2 + " seconds ");
            } else {
              log(s2.getAppName() + " may complete before the deadline " + val2 + " seconds ");
              s1.setGuaranteeShare(Resource.newInstance(
                  (int) job2.demand * 1024,
                  (int) job2.demand));
            }

            if (val1 == val2) {
              // break the tie by FIFO
              return (int) Math.signum(s1.getStartTime() - s2.getStartTime());
            }

            return (int) (val1 - val2); // prioritize small val2 closing to
                                        // deadline.
          }
        } else {
          // FIFO
          return (int) Math.signum(s1.getStartTime() - s2.getStartTime());
        }
      }
    }

    private static long getAggregateResouce(RMAppMetrics metrics,
        ResourceType type) {
      if (type.equals(ResourceType.MEMORY))
        return (long) metrics.getMemorySeconds();
      else
        return (long) metrics.getVcoreSeconds();
    }

    private static final Resource ONE = Resources.createResource(1);

    public int fair(Schedulable s1, Schedulable s2) {
      float weight1 = s1.getWeights().getWeight(ResourceType.CPU);
      float weight2 = s2.getWeights().getWeight(ResourceType.CPU);
      if(s1.isBursty())
        weight1 = Float.MAX_VALUE;
      if(s2.isBursty())
        weight2 = Float.MAX_VALUE;
      
      double minShareRatio1, minShareRatio2;
      double useToWeightRatio1, useToWeightRatio2;
      Resource minShare1 = Resources.min(RESOURCE_CALCULATOR, null,
          s1.getMinShare(), s1.getDemand());
      Resource minShare2 = Resources.min(RESOURCE_CALCULATOR, null,
          s2.getMinShare(), s2.getDemand());
      boolean s1Needy = Resources.lessThan(RESOURCE_CALCULATOR, null,
          s1.getResourceUsage(), minShare1);
      boolean s2Needy = Resources.lessThan(RESOURCE_CALCULATOR, null,
          s2.getResourceUsage(), minShare2);
      minShareRatio1 = (double) s1.getResourceUsage().getCpu()
          / Resources.max(RESOURCE_CALCULATOR, null, minShare1, ONE).getCpu();
      minShareRatio2 = (double) s2.getResourceUsage().getCpu()
          / Resources.max(RESOURCE_CALCULATOR, null, minShare2, ONE).getCpu();
      useToWeightRatio1 = s1.getResourceUsage().getCpu() / weight1;
      useToWeightRatio2 = s2.getResourceUsage().getCpu() / weight2;
      int res = 0;
      if (s1Needy && !s2Needy)
        res = -1;
      else if (s2Needy && !s1Needy)
        res = 1;
      else if (s1Needy && s2Needy)
        res = (int) Math.signum(minShareRatio1 - minShareRatio2);
      else
        // Neither schedulable is needy
        res = (int) Math.signum(useToWeightRatio1 - useToWeightRatio2);
      if (res == 0) {
        // Apps are tied in fairness ratio. Break the tie by submit time and job
        // name to get a deterministic ordering, which is useful for unit tests.
        res = (int) Math.signum(s1.getStartTime() - s2.getStartTime());
        if (res == 0)
          res = s1.getName().compareTo(s2.getName());
      }
      return res;
    }
    
    public int bpf(Schedulable s1, Schedulable s2){
      ResourceWeights sharesOfCluster1 = new ResourceWeights();
      ResourceWeights sharesOfCluster2 = new ResourceWeights();
      ResourceType[] resourceOrder1 = new ResourceType[NUM_RESOURCES];
      ResourceType[] resourceOrder2 = new ResourceType[NUM_RESOURCES];

      // Calculate shares of the cluster for each resource both schedulables.
      
      boolean isPrioritized1 = s1.isBursty();
      calculateShares(s1.getResourceUsage(), clusterCapacity, sharesOfCluster1,
          resourceOrder1, s1.getWeights(), s1.getGuaranteeShare(),
          isPrioritized1);
      
      boolean isPrioritized2 = s2.isBursty();
      calculateShares(s2.getResourceUsage(), clusterCapacity, sharesOfCluster2,
          resourceOrder2, s2.getWeights(), s2.getGuaranteeShare(),
          isPrioritized2);

      // A queue is needy for its min share if its dominant resource
      // (with respect to the cluster capacity) is below its configured
      // min share for that resource

      int res = 0;
      res = compareShares(sharesOfCluster1, sharesOfCluster2, resourceOrder1,
          resourceOrder2);

      if (res == 0) {
        // Apps are tied in fairness ratio. Break the tie by submit time.
        res = (int) (s1.getStartTime() - s2.getStartTime());
      }

      return res;
    }
    
    public int drf(Schedulable s1, Schedulable s2) {
      ResourceWeights sharesOfCluster1 = new ResourceWeights();
      ResourceWeights sharesOfCluster2 = new ResourceWeights();
      ResourceWeights sharesOfMinShare1 = new ResourceWeights();
      ResourceWeights sharesOfMinShare2 = new ResourceWeights();
      ResourceType[] resourceOrder1 = new ResourceType[NUM_RESOURCES];
      ResourceType[] resourceOrder2 = new ResourceType[NUM_RESOURCES];
      
      // Calculate shares of the cluster for each resource both schedulables.
      calculateShares(s1.getResourceUsage(),
          clusterCapacity, sharesOfCluster1, resourceOrder1, s1.getWeights());
      calculateShares(s1.getResourceUsage(),
          s1.getMinShare(), sharesOfMinShare1, null, ResourceWeights.NEUTRAL);
      calculateShares(s2.getResourceUsage(),
          clusterCapacity, sharesOfCluster2, resourceOrder2, s2.getWeights());
      calculateShares(s2.getResourceUsage(),
          s2.getMinShare(), sharesOfMinShare2, null, ResourceWeights.NEUTRAL);
      
      // A queue is needy for its min share if its dominant resource
      // (with respect to the cluster capacity) is below its configured min share
      // for that resource
      boolean s1Needy = sharesOfMinShare1.getWeight(resourceOrder1[0]) < 1.0f;
      boolean s2Needy = sharesOfMinShare2.getWeight(resourceOrder2[0]) < 1.0f;
      
      if(s1.isBursty())
        sharesOfCluster1.setWeight(Float.MAX_VALUE);
      if(s2.isBursty())
        sharesOfCluster2.setWeight(Float.MAX_VALUE);
      
      int res = 0;
      if (!s2Needy && !s1Needy) {
        res = compareShares(sharesOfCluster1, sharesOfCluster2,
            resourceOrder1, resourceOrder2);
      } else if (s1Needy && !s2Needy) {
        res = -1;
      } else if (s2Needy && !s1Needy) {
        res = 1;
      } else { // both are needy below min share
        res = compareShares(sharesOfMinShare1, sharesOfMinShare2,
            resourceOrder1, resourceOrder2);
      }
      if (res == 0) {
        // Apps are tied in fairness ratio. Break the tie by submit time.
        res = (int)(s1.getStartTime() - s2.getStartTime());
      }
      return res;
    }
    
    private void calculateShares(Resource resource, Resource pool,
        ResourceWeights shares, ResourceType[] resourceOrder, ResourceWeights weights) {
      shares.setWeight(MEMORY, (float)resource.getMemory() /
          (pool.getMemory() * weights.getWeight(MEMORY)));
      shares.setWeight(CPU, (float)resource.getVirtualCores() /
          (pool.getVirtualCores() * weights.getWeight(CPU)));
      // sort order vector by resource share
      if (resourceOrder != null) {
        if (shares.getWeight(MEMORY) > shares.getWeight(CPU)) {
          resourceOrder[0] = MEMORY;
          resourceOrder[1] = CPU;
        } else  {
          resourceOrder[0] = CPU;
          resourceOrder[1] = MEMORY;
        }
      }
    }
    
    void calculateShares(Resource resource, Resource pool,
        ResourceWeights shares, ResourceType[] resourceOrder,
        ResourceWeights weights, Resource guranteedRes, boolean isPrioritized) { // iglf

      if (!isPrioritized){
        shares.setWeight(MEMORY, (float) resource.getMemory()
            / (pool.getMemory() * weights.getWeight(MEMORY)));
        shares.setWeight(CPU, (float) resource.getVirtualCores()
            / (pool.getVirtualCores() * weights.getWeight(CPU)));
      } else {
        shares.setWeight(MEMORY, 0);
        shares.setWeight(CPU, 0);
        // Implement MAX method.
        if (resource.getMemory() >= guranteedRes.getMemory()
            || resource.getVirtualCores() >= guranteedRes.getVirtualCores()) {
          shares.setWeight(MEMORY, 1);
          shares.setWeight(CPU, 1);
        }
      }
      // sort order vector by resource share
      if (resourceOrder != null) {
        if (shares.getWeight(MEMORY) > shares.getWeight(CPU)) {
          resourceOrder[0] = MEMORY;
          resourceOrder[1] = CPU;
        } else {
          resourceOrder[0] = CPU;
          resourceOrder[1] = MEMORY;
        }
      }
    }

    
    private int compareShares(ResourceWeights shares1, ResourceWeights shares2,
        ResourceType[] resourceOrder1, ResourceType[] resourceOrder2) {
      for (int i = 0; i < resourceOrder1.length; i++) {
        int ret = (int)Math.signum(shares1.getWeight(resourceOrder1[i])
            - shares2.getWeight(resourceOrder2[i]));
        if (ret != 0) {
          return ret;
        }
      }
      return 0;
    }
  }
  
  

  @Override
  public Comparator<Schedulable> getComparator() {
    return comparator;
  }

  @Override
  public Resource getHeadroom(Resource queueFairShare,
                              Resource queueUsage, Resource maxAvailable) {
    int availCpu = Math.max(
        queueFairShare.getCpu() - queueUsage.getCpu(), 0);
    Resource headroom = Resources.createResource(
        maxAvailable.getMemory(),
        Math.min(maxAvailable.getCpu(), availCpu));
    return headroom;
  }

  @Override
  public void computeShares(Collection<? extends Schedulable> schedulables,
      Resource totalResources) {
    for (ResourceType type : ResourceType.values()) {
      ComputeFairShares.computeShares(schedulables, totalResources, type);
    }
  }

  @Override
  public void computeSteadyShares(Collection<? extends FSQueue> queues,
      Resource totalResources) {
    for (ResourceType type : ResourceType.values()) {
      ComputeFairShares.computeSteadyShares(queues, totalResources, type);
    }
  }

  @Override
  public boolean checkIfUsageOverFairShare(Resource usage, Resource fairShare) {
    return Resources.greaterThan(RESOURCE_CALCULATOR, null, usage, fairShare);
  }

  @Override
  public boolean checkIfAMResourceUsageOverLimit(Resource usage, Resource maxAMResource) {
    return usage.getMemory() > maxAMResource.getMemory();
  }

  @Override
  public byte getApplicableDepth() {
    return SchedulingPolicy.DEPTH_ANY;
  }

  private static void log(String msg) {
    if (DEBUG)
      LOG.info(msg);
  }
}
