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
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.yarn.api.records.ApplicationId;
import org.apache.hadoop.yarn.api.records.Resource;
import org.apache.hadoop.yarn.server.resourcemanager.resource.ResourceType;
import org.apache.hadoop.yarn.server.resourcemanager.rmapp.RMApp;
import org.apache.hadoop.yarn.server.resourcemanager.rmapp.RMAppMetrics;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.Queue;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FSQueue;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.Schedulable;
import org.apache.hadoop.yarn.util.Apps;

import com.sun.research.ws.wadl.Application;

/**
 * Contains logic for computing the fair shares. A {@link Schedulable}'s fair share is
 * {@link Resource} it is entitled to, independent of the current demands and allocations on the
 * cluster. A {@link Schedulable} whose resource consumption lies at or below its fair share will
 * never have its containers preempted.
 */
public class ComputeFairShares {

  private static final int COMPUTE_FAIR_SHARES_ITERATIONS = 25;

  private static final Log LOG = LogFactory.getLog(ComputeFairShares.class);

  /**
   * Compute fair share of the given schedulables.Fair share is an allocation of shares considering
   * only active schedulables ie schedulables which have running apps.
   * 
   * @param schedulables
   * @param totalResources
   * @param type
   */
  public static void computeShares(Collection<? extends Schedulable> schedulables, Resource totalResources,
      ResourceType type) {
    computeSharesInternal(schedulables, totalResources, type, false);
  }

  public static void computeSharesIGLF(Collection<? extends Schedulable> schedulables, Resource totalResources,
      ResourceType type) {
    computeSharesInternalSpeedFair(schedulables, totalResources, type, false);
  }

  /**
   * Compute the steady fair share of the given queues. The steady fair share is an allocation of
   * shares considering all queues, i.e., active and inactive.
   *
   * @param queues
   * @param totalResources
   * @param type
   */
  public static void computeSteadyShares(Collection<? extends FSQueue> queues, Resource totalResources,
      ResourceType type) {
    computeSharesInternal(queues, totalResources, type, true);
  }

  /**
   * Given a set of Schedulables and a number of slots, compute their weighted fair shares. The min
   * and max shares and of the Schedulables are assumed to be set beforehand. We compute the fairest
   * possible allocation of shares to the Schedulables that respects their min and max shares.
   * <p>
   * To understand what this method does, we must first define what weighted fair sharing means in
   * the presence of min and max shares. If there were no minimum or maximum shares, then weighted
   * fair sharing would be achieved if the ratio of slotsAssigned / weight was equal for each
   * Schedulable and all slots were assigned. Minimum and maximum shares add a further twist - Some
   * Schedulables may have a min share higher than their assigned share or a max share lower than
   * their assigned share.
   * <p>
   * To deal with these possibilities, we define an assignment of slots as being fair if there
   * exists a ratio R such that: Schedulables S where S.minShare {@literal >} R * S.weight are given
   * share S.minShare - Schedulables S where S.maxShare {@literal <} R * S.weight are given
   * S.maxShare - All other Schedulables S are assigned share R * S.weight - The sum of all the
   * shares is totalSlots.
   * <p>
   * We call R the weight-to-slots ratio because it converts a Schedulable's weight to the number of
   * slots it is assigned.
   * <p>
   * We compute a fair allocation by finding a suitable weight-to-slot ratio R. To do this, we use
   * binary search. Given a ratio R, we compute the number of slots that would be used in total with
   * this ratio (the sum of the shares computed using the conditions above). If this number of slots
   * is less than totalSlots, then R is too small and more slots could be assigned. If the number of
   * slots is more than totalSlots, then R is too large.
   * <p>
   * We begin the binary search with a lower bound on R of 0 (which means that all Schedulables are
   * only given their minShare) and an upper bound computed to be large enough that too many slots
   * are given (by doubling R until we use more than totalResources resources). The helper method
   * resourceUsedWithWeightToResourceRatio computes the total resources used with a given value of
   * R.
   * <p>
   * The running time of this algorithm is linear in the number of Schedulables, because
   * resourceUsedWithWeightToResourceRatio is linear-time and the number of iterations of binary
   * search is a constant (dependent on desired precision).
   */
  private static void computeSharesInternal(Collection<? extends Schedulable> allSchedulables, Resource totalResources,
      ResourceType type, boolean isSteadyShare) {

    Collection<Schedulable> schedulables = new ArrayList<Schedulable>();
    int takenResources = handleFixedFairShares(allSchedulables, schedulables, isSteadyShare, type);

    if (schedulables.isEmpty()) {
      return;
    }
    // Find an upper bound on R that we can use in our binary search. We
    // start
    // at R = 1 and double it until we have either used all the resources or
    // we
    // have met all Schedulables' max shares.
    int totalMaxShare = 0;
    for (Schedulable sched : schedulables) {
      int maxShare = getResourceValue(sched.getMaxShare(), type);
      totalMaxShare = (int) Math.min((long) maxShare + (long) totalMaxShare, Integer.MAX_VALUE);
      if (totalMaxShare == Integer.MAX_VALUE) {
        break;
      }
    }

    int totalResource = Math.max((getResourceValue(totalResources, type) - takenResources), 0);
    totalResource = Math.min(totalMaxShare, totalResource);

    double rMax = 1.0;
    while (resourceUsedWithWeightToResourceRatio(rMax, schedulables, type) < totalResource) {
      rMax *= 2.0;
    }
    // Perform the binary search for up to COMPUTE_FAIR_SHARES_ITERATIONS
    // steps
    double left = 0;
    double right = rMax;
    for (int i = 0; i < COMPUTE_FAIR_SHARES_ITERATIONS; i++) {
      double mid = (left + right) / 2.0;
      int plannedResourceUsed = resourceUsedWithWeightToResourceRatio(mid, schedulables, type);
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
    for (Schedulable sched : schedulables) {
      if (isSteadyShare) {
        setResourceValue(computeShare(sched, right, type), ((FSQueue) sched).getSteadyFairShare(), type);
      } else {
        setResourceValue(computeShare(sched, right, type), sched.getFairShare(), type);
        LOG.info("sched: " + sched.getName() + " resource: " + sched.getResourceUsage());
      }
    }
  }

  private static void computeSharesInternalSpeedFair(Collection<? extends Schedulable> allSchedulables,
      Resource totalResources, ResourceType type, boolean isSteadyShare) {

    Collection<Schedulable> schedulables = new ArrayList<Schedulable>();
    int takenResources = handleFixedFairShares(allSchedulables, schedulables, isSteadyShare, type);

    if (schedulables.isEmpty()) {
      return;
    }

//    setPriorityBasedOnAggregatedResource(schedulables);

    // Find an upper bound on R that we can use in our binary search. We
    // start at R = 1 and double it until we have either used all the resources or
    // we have met all Schedulables' max shares.
    int totalMaxShare = 0;
    for (Schedulable sched : schedulables) {
      int maxShare = getResourceValue(sched.getMaxShare(), type);
      totalMaxShare = (int) Math.min((long) maxShare + (long) totalMaxShare, Integer.MAX_VALUE);
      if (totalMaxShare == Integer.MAX_VALUE) {
        break;
      }
    }

    // int minReqResource = resourceUsedByMinReq(schedulables, type);
    int minReqResource = 0; 
    Map<String, Resource> minReqMap = new LinkedHashMap<String, Resource>();
    for (Schedulable sched : schedulables) {
      if (sched.isLeafQueue()) {
        FSQueue queue = (FSQueue) sched;
        minReqResource += getResourceValue(sched.getMinReq(), type);
        minReqMap.put(sched.getName(), sched.getMinReq());
      } else {
        minReqMap.put(sched.getName(), Resource.newInstance(0, 0));
      }
    }

    int totalResource = Math.max((getResourceValue(totalResources, type) - takenResources - minReqResource), 0);
    totalResource = Math.min(totalMaxShare, totalResource);

    double rMax = 1.0;
    while (resourceUsedWithWeightToResourceRatioIGLF(rMax, schedulables, type) < totalResource) {
      rMax *= 2.0;
    }
    // Perform the binary search for up to COMPUTE_FAIR_SHARES_ITERATIONS steps
    double left = 0;
    double right = rMax;
    for (int i = 0; i < COMPUTE_FAIR_SHARES_ITERATIONS; i++) {
      double mid = (left + right) / 2.0;
      int plannedResourceUsed = resourceUsedWithWeightToResourceRatioIGLF(mid, schedulables, type);
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
    for (Schedulable sched : schedulables) {
      if (isSteadyShare) {
        setResourceValue(computeShareIGLF(sched, right, type), ((FSQueue) sched).getSteadyFairShare(),
            minReqMap.get(sched.getName()), type);
      } else {
        setResourceValue(computeShareIGLF(sched, right, type), sched.getFairShare(), minReqMap.get(sched.getName()),
            type);
      }
    }
  }

  /**
   * Compute the resources that would be used given a weight-to-resource ratio w2rRatio, for use in
   * the computeFairShares algorithm as described in #
   */
  private static int resourceUsedWithWeightToResourceRatio(double w2rRatio,
      Collection<? extends Schedulable> schedulables, ResourceType type) {
    int resourcesTaken = 0;
    for (Schedulable sched : schedulables) {
      int share = computeShare(sched, w2rRatio, type);
      resourcesTaken += share;
    }
    return resourcesTaken;
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

  /**
   * Compute the resources assigned to a Schedulable given a particular weight-to-resource ratio
   * w2rRatio.
   */
  private static int computeShare(Schedulable sched, double w2rRatio, ResourceType type) {
    double share = sched.getWeights().getWeight(type) * w2rRatio;
    share = Math.max(share, getResourceValue(sched.getMinShare(), type));
    share = Math.min(share, getResourceValue(sched.getMaxShare(), type));
    return (int) share;
  }

  private static int computeShareIGLF(Schedulable sched, double w2rRatio, ResourceType type) {

    float fairPriority = sched.getFairPriority();

    double share = sched.getWeights().getWeight(type) * w2rRatio * fairPriority;
    share = Math.min(share, getResourceValue(sched.getMaxShare(), type));
    return (int) share;
  }

//  private static void setPriorityOverTime(Schedulable sched) {
//    float iglfPriority = Schedulable.DEFAULT_FAIR_PRIORITY;
//    long startTime = sched.getStartTime();
//
//    if (sched.getName().equals("root.interactive") && startTime > 0) {
//      ArrayList<Long> durations = new ArrayList<>();
//      ArrayList<Float> priorities = new ArrayList<Float>();
//
//      durations.add(new Long((long) (Schedulable.HIGH_PRIORITY_DURATION)));
//      priorities.add(sched.getFairPriority());
//
//      // (Schedulable.HIGH_PRIORITY_DURATION)));
//      // priorities.add(new Float(1));
//
//      long lasted = (System.currentTimeMillis() - startTime);
//      long timeInterval = 0;
//
//      for (int i = 0; i < durations.size(); i++) {
//        if (lasted >= timeInterval) {
//          iglfPriority = priorities.get(i);
//        }
//        timeInterval += durations.get(i);
//      }
//      if (lasted >= timeInterval) { // no guarantee, return back to normal
//        iglfPriority = Schedulable.DEFAULT_FAIR_PRIORITY;
//      }
//    }
//
//    sched.setFairPriority(iglfPriority);
//  }

  private static void setPriorityBasedOnAggregatedResource(Collection<? extends Schedulable> allSchedulables) {
    for (Schedulable sched : allSchedulables) {
      String temp = sched.getName();
      if (temp.startsWith(ApplicationId.appIdStrPrefix)) {
        RMApp rmApp = sched.getRMContext().getRMApps().get(Apps.toAppID(temp));
        RMAppMetrics appMetrics = rmApp == null ? null : rmApp.getRMAppMetrics();
        long aggregatedVcoreSeconds = appMetrics.getVcoreSeconds();
        FSQueue queue = (FSQueue) sched.getParentQueue();

        if (queue.getQueueName().startsWith("root.interactive")) {
          if (aggregatedVcoreSeconds < Schedulable.DEFAULT_BUGDET) {
            queue.setFairPriority(5);
          } else {
            queue.setFairPriority(1);
          }
        }
      }
    }
  }

  /**
   * Helper method to handle Schedulabes with fixed fairshares. Returns the resources taken by fixed
   * fairshare schedulables, and adds the remaining to the passed nonFixedSchedulables.
   */
  private static int handleFixedFairShares(Collection<? extends Schedulable> schedulables,
      Collection<Schedulable> nonFixedSchedulables, boolean isSteadyShare, ResourceType type) {
    int totalResource = 0;

    for (Schedulable sched : schedulables) {
      int fixedShare = getFairShareIfFixed(sched, isSteadyShare, type);
      if (fixedShare < 0) {
        nonFixedSchedulables.add(sched);
      } else {
        setResourceValue(fixedShare, isSteadyShare ? ((FSQueue) sched).getSteadyFairShare() : sched.getFairShare(),
            type);
        totalResource = (int) Math.min((long) totalResource + (long) fixedShare, Integer.MAX_VALUE);
      }
    }
    return totalResource;
  }

  /**
   * Get the fairshare for the {@link SgetResourceValuechedulable} if it is fixed, -1 otherwise.
   *
   * The fairshare is fixed if either the maxShare is 0, weight is 0, or the Schedulable is not
   * active for instantaneous fairshare.
   */
  private static int getFairShareIfFixed(Schedulable sched, boolean isSteadyShare, ResourceType type) {

    // Check if maxShare is 0
    if (getResourceValue(sched.getMaxShare(), type) <= 0) {
      return 0;
    }

    // For instantaneous fairshares, check if queue is active
    if (!isSteadyShare && (sched instanceof FSQueue) && !((FSQueue) sched).isActive()) {
      return 0;
    }

    // Check if weight is 0
    if (sched.getWeights().getWeight(type) <= 0) {
      int minShare = getResourceValue(sched.getMinShare(), type);
      return (minShare <= 0) ? 0 : minShare;
    }

    return -1;
  }

  private static int getResourceValue(Resource resource, ResourceType type) {
    switch (type) {
    case MEMORY:
      return resource.getMemory();
    case CPU:
      return resource.getVirtualCores();
    default:
      throw new IllegalArgumentException("Invalid resource");
    }
  }

  private static void setResourceValue(int val, Resource resource, ResourceType type) {
    switch (type) {
    case MEMORY:
      resource.setMemory(val);
      break;
    case CPU:
      resource.setVirtualCores(val);
      break;
    default:
      throw new IllegalArgumentException("Invalid resource");
    }
  }

  private static void setResourceValue(int val, Resource resource, Resource minReq, ResourceType type) {
    switch (type) {
    case MEMORY:
      resource.setMemory(val + minReq.getMemory());
      break;
    case CPU:
      resource.setVirtualCores(val + minReq.getVirtualCores());
      break;
    default:
      throw new IllegalArgumentException("Invalid resource");
    }
  }
}