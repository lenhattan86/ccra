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

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.Map;

import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.classification.InterfaceAudience.Private;
import org.apache.hadoop.classification.InterfaceStability.Unstable;
import org.apache.hadoop.yarn.api.records.Resource;
import org.apache.hadoop.yarn.server.resourcemanager.resource.ResourceType;
import org.apache.hadoop.yarn.server.resourcemanager.resource.ResourceWeights;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.QueueMetrics;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FSQueue;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.Schedulable;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.SchedulingPolicy;
import org.apache.hadoop.yarn.util.resource.Resources;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.lang.time.DateUtils;
import org.apache.commons.logging.Log;

import static org.apache.hadoop.yarn.server.resourcemanager.resource.ResourceType.*;

/**
 * Makes scheduling decisions by trying to equalize dominant resource usage. A
 * schedulable's dominant resource usage is the largest ratio of resource usage
 * to capacity among the resource types it is using.
 */
@Private
@Unstable
public class SpeedFairPolicy extends SchedulingPolicy {

  public static final String NAME = "SpeedFair";
  private static boolean ENABLE_COMPENSATION = true;

  private InstantaneousGuaranteeComparator comparator = new InstantaneousGuaranteeComparator();
  private static final Log LOG = LogFactory.getLog(SchedulingPolicy.class);

  private static final boolean DEBUG = false;

  @Override
  public String getName() {
    return NAME;
  }

  @Override
  public byte getApplicableDepth() {
    return SchedulingPolicy.DEPTH_ANY;
  }

  @Override
  public Comparator<Schedulable> getComparator() {
    return comparator;
  }

  @Override
  public void computeShares(Collection<? extends Schedulable> schedulables,
      Resource totalResources) {
    periodicSchedule(schedulables, totalResources);
    // for (ResourceType type : ResourceType.values()) {
    // ComputeFairShares.computeSharesIGLF(schedulables, totalResources, type);
    // }
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
    return !Resources.fitsIn(usage, fairShare);
  }

  @Override
  public boolean checkIfAMResourceUsageOverLimit(Resource usage,
      Resource maxAMResource) {
    return !Resources.fitsIn(usage, maxAMResource);
  }

  @Override
  public Resource getHeadroom(Resource queueFairShare, Resource queueUsage,
      Resource maxAvailable) {
    int queueAvailableMemory = Math
        .max(queueFairShare.getMemory() - queueUsage.getMemory(), 0);
    int queueAvailableCPU = Math.max(
        queueFairShare.getVirtualCores() - queueUsage.getVirtualCores(), 0);
    Resource headroom = Resources.createResource(
        Math.min(maxAvailable.getMemory(), queueAvailableMemory),
        Math.min(maxAvailable.getVirtualCores(), queueAvailableCPU));
    return headroom;
  }

  @Override
  public void initialize(Resource clusterCapacity) {
    comparator.setClusterCapacity(clusterCapacity);
  }

  public static class InstantaneousGuaranteeComparator
      implements Comparator<Schedulable> {

    private static final int NUM_RESOURCES = ResourceType.values().length;

    private Resource clusterCapacity;

    public void setClusterCapacity(Resource clusterCapacity) {
      this.clusterCapacity = clusterCapacity;
    }

    // periodically adjust the resource allocation
    @Override
    public int compare(Schedulable s1, Schedulable s2) {
      ResourceWeights sharesOfCluster1 = new ResourceWeights();
      ResourceWeights sharesOfCluster2 = new ResourceWeights();
      ResourceType[] resourceOrder1 = new ResourceType[NUM_RESOURCES];
      ResourceType[] resourceOrder2 = new ResourceType[NUM_RESOURCES];

      // Calculate shares of the cluster for each resource both schedulables.

      calculateShares(s1.getResourceUsage(), clusterCapacity, sharesOfCluster1,
          resourceOrder1, s1.getWeights(), s1.getGuaranteeShare());

      calculateShares(s2.getResourceUsage(), clusterCapacity, sharesOfCluster2,
          resourceOrder2, s2.getWeights(), s2.getGuaranteeShare());

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
      
/*      if (s1.isLeafQueue()){
        // break the deadlock when
        FSQueue q1 = (FSQueue)s1; FSQueue q2 = (FSQueue)s2;
        if (q1.getNumRunnableApps()>0 && q2.getNumRunnableApps()==0)
          res = -1;
        else if (q1.getNumRunnableApps()==0 && q2.getNumRunnableApps()>0) {
          res = 1;
        }
      }
*/        
      return res;
    }

    /**
     * Calculates and orders a resource's share of a pool in terms of two
     * vectors. The shares vector contains, for each resource, the fraction of
     * the pool that it takes up. The resourceOrder vector contains an ordering
     * of resources by largest share. So if resource=<10 MB, 5 CPU>, and
     * pool=<100 MB, 10 CPU>, shares will be [.1, .5] and resourceOrder will be
     * [CPU, MEMORY].
     */

    void calculateShares(Resource resource, Resource pool,
        ResourceWeights shares, ResourceType[] resourceOrder,
        ResourceWeights weights, Resource guranteedRes) { // iglf

      if (guranteedRes.isEmpty()) {
        shares.setWeight(MEMORY, (float) resource.getMemory()
            / (pool.getMemory() * weights.getWeight(MEMORY)));
        shares.setWeight(CPU, (float) resource.getVirtualCores()
            / (pool.getVirtualCores() * weights.getWeight(CPU)));
      } else {
        shares.setWeight(MEMORY, 1);
        shares.setWeight(CPU, 1);
        if (resource.getMemory() < guranteedRes.getMemory())
          shares.setWeight(MEMORY, 0);
        if (resource.getVirtualCores() < guranteedRes.getVirtualCores())
          shares.setWeight(CPU, 0);
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
        int ret = (int) Math.signum(shares1.getWeight(resourceOrder1[i])
            - shares2.getWeight(resourceOrder2[i]));
        if (ret != 0) {
          return ret;
        }
      }
      return 0;
    }
  }

  /*
   * private static void computeSharesInternalSpeedFair( Collection<? extends
   * Schedulable> allSchedulables, Resource totalResources, ResourceType type,
   * boolean isSteadyShare) {
   * 
   * Collection<Schedulable> flexibleScheds = new ArrayList<Schedulable>(); int
   * takenResourceByFixedShares =
   * ComputeFairShares.handleFixedFairShares(allSchedulables, flexibleScheds,
   * isSteadyShare, type);
   * 
   * if (flexibleScheds.isEmpty()) { return; }
   * 
   * // Find an upper bound on R that we can use in our binary search. We //
   * start at R = 1 and double it until we have either used all the resources //
   * or // we have met all Schedulables' max shares. int totalMaxShare = 0; for
   * (Schedulable sched : flexibleScheds) { int maxShare =
   * ComputeFairShares.getResourceValue(sched.getMaxShare(), type);
   * totalMaxShare = (int) Math.min((long) maxShare + (long) totalMaxShare,
   * Integer.MAX_VALUE); if (totalMaxShare == Integer.MAX_VALUE) { break; } }
   * 
   * int totalResource = Math.max(
   * (ComputeFairShares.getResourceValue(totalResources, type) -
   * takenResourceByFixedShares), 0); totalResource = Math.min(totalMaxShare,
   * totalResource);
   * 
   * int takenResourceBySpeedFair = 0;
   * 
   * 
   * if (unsatisfiedScheds.isEmpty()) { return; }
   * 
   * totalResource = totalResource - takenResourceBySpeedFair;
   * 
   * double rMax = 1.0; while (resourceUsedWithWeightToResourceRatioIGLF(rMax,
   * unsatisfiedScheds, type) < totalResource) { rMax *= 2.0; } // Perform the
   * binary search for up to COMPUTE_FAIR_SHARES_ITERATIONS steps double left =
   * 0; double right = rMax; for (int i = 0; i <
   * ComputeFairShares.COMPUTE_FAIR_SHARES_ITERATIONS; i++) { double mid = (left
   * + right) / 2.0; int plannedResourceUsed =
   * resourceUsedWithWeightToResourceRatioIGLF(mid, unsatisfiedScheds, type); if
   * (plannedResourceUsed == totalResource) { right = mid; break; } else if
   * (plannedResourceUsed < totalResource) { left = mid; } else { right = mid; }
   * } // Set the fair shares based on the value of R we've converged to for
   * (Schedulable sched : unsatisfiedScheds) {
   * ComputeFairShares.setResourceValue(ComputeFairShares.computeShare(sched,
   * right, type), sched.getFairShare(), type); } }
   */

  private ArrayList<String> printQueueList(
      Collection<? extends Schedulable> allQueues) {
    ArrayList<String> list = new ArrayList<String>();
    for (Schedulable sched : allQueues) {
      list.add(sched.getName());
    }
    return list;
  }

  private static int resourceUsedWithWeightToResourceRatioIGLF(double w2rRatio,
      Collection<? extends Schedulable> schedulables, ResourceType type) {
    int resourcesTaken = 0;
    for (Schedulable sched : schedulables) {
      int share = computeShareIGLF(sched, w2rRatio, type);
      resourcesTaken += share;
    }
    return resourcesTaken;
  }

  private static int computeShareIGLF(Schedulable sched, double w2rRatio,
      ResourceType type) {

    float fairPriority = sched.getFairPriority();

    double share = sched.getWeights().getWeight(type) * w2rRatio * fairPriority;
    share = Math.min(share,
        ComputeFairShares.getResourceValue(sched.getMaxShare(), type));
    return (int) share;
  }

  private void periodicSchedule(
      Collection<? extends Schedulable> allSchedulables,
      Resource totalResources) {

    ArrayList<Schedulable> flexibleScheds = new ArrayList<Schedulable>();
    handleFixedFairShares(allSchedulables, flexibleScheds, totalResources);

    if (flexibleScheds.isEmpty()) {
      return;
    }

    ArrayList<Schedulable> bestEffortQueues = new ArrayList<Schedulable>();
    ArrayList<Schedulable> admittedBurstyQueues = new ArrayList<Schedulable>();
    ArrayList<Schedulable> admittedBatchQueues = new ArrayList<Schedulable>();

    updateQueueStatus(flexibleScheds, admittedBurstyQueues, admittedBatchQueues,
        bestEffortQueues);
    admit(bestEffortQueues, admittedBurstyQueues, admittedBatchQueues,
        totalResources);

    allocate(allSchedulables, admittedBurstyQueues, admittedBatchQueues,
        totalResources);

    if (bestEffortQueues.isEmpty()) {
      return;
    }
    allocateSpareResource(bestEffortQueues);
  }

  private void updateQueueStatus(ArrayList<Schedulable> allQueues,
      ArrayList<Schedulable> admittedBurstyQueues,
      ArrayList<Schedulable> admittedBatchQueues,
      ArrayList<Schedulable> bestEffortQueues) {

    for (Schedulable sched : allQueues) {
      if (sched.isLeafQueue()) {
        FSQueue queue = (FSQueue) sched;
        if (queue.isAdmitted()) {
          if (queue.isBursty())
            admittedBurstyQueues.add(sched);
          else if (queue.isBatch()) {
            admittedBatchQueues.add(sched);
          }
        } else {
          if (queue.isBursty() || queue.isBatch())
            bestEffortQueues.add(sched);
        }
      }
    }
    Collections.sort(bestEffortQueues, new QueueComparator());
  }

  public class QueueComparator implements Comparator<Schedulable> {

    @Override
    public int compare(Schedulable sched1, Schedulable sched2) {
      int res = 0;
      if (!sched1.isLeafQueue() || !sched2.isLeafQueue())
        return 0;
      else {
        FSQueue queue1 = (FSQueue) sched1;
        FSQueue queue2 = (FSQueue) sched2;
        if (queue1.getStartTime() > queue2.getStartTime()) {
          res = 1;
        } else if (queue1.getStartTime() < queue2.getStartTime()) {
          res = -1;
        }

        if (res != 0)
          return res;

        if (queue1.isBursty() && queue2.isBatch()) {
          res = 1;
        } else if (queue1.isBatch() && queue2.isBursty()) {
          res = -1;
        }
      }

      return res;
    }

  }

  private void admit(Collection<Schedulable> bestEffortQueues,
      Collection<Schedulable> admittedBurstyQueues,
      Collection<Schedulable> admittedBatchQueues, Resource totalResource) {

    Collection<Schedulable> newBestEffortQueues = new ArrayList<Schedulable>();
    // TODO sort all queues based on arrival time

    for (Schedulable sched : bestEffortQueues) {
      if (sched.isLeafQueue()) {
        FSQueue queue = (FSQueue) sched;
        if (queue.isBursty()) {
          boolean condition1 = resGuarateeCond(queue, admittedBurstyQueues,
              admittedBatchQueues, totalResource);
          boolean condition2 = resFairnessCond(queue,
              admittedBurstyQueues.size(), admittedBatchQueues.size(),
              totalResource);
          if (condition1 && condition2) {
            queue.setAdmitted(true);
            admittedBurstyQueues.add(queue);
          }
        } else {
          boolean condition1 = condFairness4Batch(queue, admittedBurstyQueues,
              admittedBatchQueues, totalResource);
          if (condition1) {
            queue.setAdmitted(true);
            admittedBatchQueues.add(queue);
          }
        }

        if (!queue.isAdmitted())
          newBestEffortQueues.add(queue);
      }
    }

    bestEffortQueues = newBestEffortQueues;
  }

  private boolean condFairness4Batch(FSQueue newBatchQueue,
      Collection<Schedulable> admittedBurstyQueues,
      Collection<Schedulable> admittedBatchQueues, Resource capacity) {
    boolean condition = true;
    for (Schedulable sched : admittedBurstyQueues) {
      if (sched.isLeafQueue()) {
        FSQueue A = (FSQueue) sched;
        Resource alpha = A.getAlpha();
        Resource lhs = Resources.multiply(alpha,
            A.getStage1Duration() / DateUtils.MILLIS_PER_SECOND);
        Resource rhs = Resources.multiply(capacity,
            A.getPeriod() / DateUtils.MILLIS_PER_SECOND);
        double denom = Math.max(
            admittedBurstyQueues.size() + admittedBatchQueues.size() + 1,
            Double.MIN_VALUE);
        Resources.multiply(rhs, 1 / denom);
        condition = Resources.fitsIn(lhs, rhs);
        if (!condition) {
          log(newBatchQueue + " condFairness4Batch: " + condition + " lhs: "
              + lhs + " rhs: " + rhs);
          break;
        }

      }
    }

    return condition;
  }

  private boolean resGuarateeCond(FSQueue newBusrtyQueue,
      Collection<Schedulable> admittedBurstyQueues,
      Collection<Schedulable> admittedBatchQueues, Resource capacity) {
    boolean result = true;
    long now = System.currentTimeMillis();
    for (long t = 0; t < newBusrtyQueue.getPeriod(); t += newBusrtyQueue
        .getScheduler().getConf().getUpdateInterval()) {
      long time = now + t;
      Resource burstyRes = Resource.newInstance(0, 0);
      for (Schedulable sched : admittedBurstyQueues) {
        FSQueue queue = (FSQueue) sched;
        burstyRes = Resources.add(burstyRes,
            getIdealGuaranteeResUsage(time, queue, admittedBurstyQueues.size(),
                admittedBatchQueues.size(), capacity));
        // //TODO:
        // burstyRes = Resources.add(burstyRes, queue.getAlpha());
      }
      Resource alpha = newBusrtyQueue.getAlpha();
      result = Resources.fitsIn(alpha, Resources.subtract(capacity, burstyRes));
      if (!result) {
        log(newBusrtyQueue.getName() + " resGuarateeCond: " + result + "alpha: "
            + alpha + " remaining: " + Resources.subtract(capacity, burstyRes));
        break;
      }
    }
    return result;
  }

  private Resource getIdealGuaranteeResUsage(long time, FSQueue burstyQueue,
      int numAdmittedBursty, int numAdmittedBatch, Resource capacity) {
    Resource res = Resource.newInstance(0, 0);
    Resource alpha = burstyQueue.getAlpha();
    double period = burstyQueue.getPeriod() / DateUtils.MILLIS_PER_SECOND;
    double stage1Duration = burstyQueue.getStage1Duration()
        / DateUtils.MILLIS_PER_SECOND;
    Resource guaranteedRes = Resources.multiply(alpha, period);
    double lasting = (time - burstyQueue.getStartTime()) % stage1Duration;
    boolean inStage1 = lasting <= stage1Duration;
    if (inStage1)
      res = alpha;
    else {
      if (period - stage1Duration > 0) {
        Resource nom = Resources.multiply(capacity,
            period / ((double) (numAdmittedBursty + numAdmittedBatch)));
        nom = Resources.subtract(nom, guaranteedRes);
        Resource beta = Resources.multiply(nom,
            1.0 / ((double) (period - stage1Duration)));
        res = beta;
      }
    }
    return res;
  }

  public boolean resFairnessCond(FSQueue newQueue, int admittedBurstyQueuesSize,
      int admittedBatchQueuesSize, Resource capacity) {
    // TODO add time dimension
    Resource alpha = newQueue.getAlpha();
    Resource lhs = Resources.multiply(alpha,
        newQueue.getStage1Duration() / DateUtils.MILLIS_PER_SECOND);
    Resource rhs = Resources.multiply(capacity,
        newQueue.getPeriod() / DateUtils.MILLIS_PER_SECOND);
    double denom = admittedBurstyQueuesSize + admittedBatchQueuesSize + 1;
    rhs = Resources.multiply(rhs, (1.0 / denom));
    boolean result = Resources.fitsIn(lhs, rhs);
    if (!result) {
      log(newQueue.getName() + " resFairnessCond: " + result + " lhs: " + lhs
          + " rhs: " + rhs + " capacity: " + capacity);
    }
    return result;
  }

  private void allocate(Collection<? extends Schedulable> allQueues,
      Collection<? extends Schedulable> admittedBurstyQueues,
      Collection<? extends Schedulable> admittedBatchQueues,
      Resource totalResources) {
    for (ResourceType type : ResourceType.values()) {

      int totalMaxShare = 0;
      for (Schedulable sched : allQueues) {
        int maxShare = ComputeFairShares.getResourceValue(sched.getMaxShare(),
            type);
        totalMaxShare = (int) Math.min((long) maxShare + (long) totalMaxShare,
            Integer.MAX_VALUE);
        if (totalMaxShare == Integer.MAX_VALUE) {
          break;
        }
      }

      int totalResource = Math
          .max((ComputeFairShares.getResourceValue(totalResources, type)), 0);
      totalResource = Math.min(totalMaxShare, totalResource);

      int takenResourceBySpeedFair = guaranteeServiceRate(admittedBurstyQueues,
          admittedBatchQueues.size(), type, totalResource);

      if (admittedBatchQueues.isEmpty()) {
        return;
      }

      // DRF for admittedBatchQueues
      totalResource = totalResource - takenResourceBySpeedFair;

      drf(admittedBatchQueues, totalResource, type);

    }
  }

  private void drf(Collection<? extends Schedulable> admittedBatchQueues,
      int totalResource, ResourceType type) {
    double rMax = 1.0;
    while (resourceUsedWithWeightToResourceRatioIGLF(rMax, admittedBatchQueues,
        type) < totalResource) {
      rMax *= 2.0;
    }
    // Perform the binary search for up to COMPUTE_FAIR_SHARES_ITERATIONS steps
    double left = 0;
    double right = rMax;
    for (int i = 0; i < ComputeFairShares.COMPUTE_FAIR_SHARES_ITERATIONS; i++) {
      double mid = (left + right) / 2.0;
      int plannedResourceUsed = resourceUsedWithWeightToResourceRatioIGLF(mid,
          admittedBatchQueues, type);
      if (plannedResourceUsed == totalResource) {
        right = mid;
        break;
      } else if (plannedResourceUsed < totalResource) {
        left = mid;
      } else {
        right = mid;
      }
    }
    // Set the fair shares based on the value of R we've converged to
    for (Schedulable sched : admittedBatchQueues) {
      ComputeFairShares.setResourceValue(
          ComputeFairShares.computeShare(sched, right, type),
          sched.getFairShare(), type);
    }
  }

  private void allocateSpareResource(Collection<Schedulable> bestEffortQueues) {
    // TODO Auto-generated method stub
  }

  private void handleFixedFairShares(
      Collection<? extends Schedulable> allSchedulables,
      Collection<Schedulable> flexibleScheds, Resource totalResources) {
    // TODO: handle fixed shares
    for (Schedulable sched : allSchedulables)
      flexibleScheds.add(sched);
  }

  private static int guaranteeServiceRate(
      Collection<? extends Schedulable> admittedBurstyQueues,
      int numAdmittedBatch, ResourceType type, int maxResource) {

    int numAdmittedBursty = admittedBurstyQueues.size();
    int minReqResource = 0;
    int takenByBursty = 0;
    int remainingRes = maxResource;

    for (Schedulable sched : admittedBurstyQueues) {
      if (sched.isLeafQueue()) {
        FSQueue queue = (FSQueue) sched;
        // TODO recompute the resource rate for both steps
        int alpha = ComputeFairShares.getResourceValue(sched.getAlpha(), type);
        int guaranteedShare = 0;
        long stage1Duration = (long) queue.getStage1Duration()
            / DateUtils.MILLIS_PER_SECOND;
        long period = queue.getPeriod() / DateUtils.MILLIS_PER_SECOND;
        long lasted = queue.lastedInPeriod();
        
        if (ENABLE_COMPENSATION) {
          long receivedRes = getAggregateResouce(queue.getMetrics(), type);
          long stage1Res = alpha * stage1Duration;
          if (receivedRes<stage1Res)
            guaranteedShare = alpha;
          else{
            if (period > lasted) {
              float tmp = (maxResource * period
                  / ((float) (numAdmittedBursty + numAdmittedBatch))
                  - receivedRes) / (period - lasted);
              guaranteedShare = (int) Math.max(tmp, 0);
              guaranteedShare = (int) Math.min(guaranteedShare, maxResource);
            }
          }
        } else {
          if (queue.isDuringSpeedupDuration())
            guaranteedShare = (int) alpha;
          else {
            if (period > stage1Duration) {
              float tmp = (maxResource * period
                  / ((float) (numAdmittedBursty + numAdmittedBatch))
                  - alpha * stage1Duration) / (period - stage1Duration);
              guaranteedShare = (int) Math.max(tmp, 0);
              guaranteedShare = (int) Math.min(guaranteedShare, maxResource);
            }
          }
        }
        
        if (guaranteedShare <= remainingRes && guaranteedShare >= 0) {
          minReqResource += guaranteedShare;
          remainingRes = maxResource - guaranteedShare;
          ComputeFairShares.setResourceValue(guaranteedShare,
              sched.getFairShare(), type);
          queue.setGuaranteeShare(guaranteedShare, type);
        }
        
        takenByBursty += ComputeFairShares.getResourceValue(sched.getResourceUsage(), type);
      }
    }
    
    return Math.min(minReqResource, takenByBursty);
  }

private static long getAggregateResouce(QueueMetrics metrics, ResourceType type){
  if (type.equals(ResourceType.MEMORY))
    return (long) metrics.getMemorySeconds();
  else
    return (long) metrics.getVcoreSeconds();
}

  private void log(String msg) {
    if (DEBUG)
      LOG.info(msg);
  }

}
