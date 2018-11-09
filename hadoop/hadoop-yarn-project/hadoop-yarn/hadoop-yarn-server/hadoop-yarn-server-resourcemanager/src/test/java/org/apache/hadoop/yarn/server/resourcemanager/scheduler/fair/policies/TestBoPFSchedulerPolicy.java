/**
 * Tan N. Le, SUNY Korea, Stony Brook University * 
 */
package org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.policies;

import static org.junit.Assert.assertTrue;

import java.util.Comparator;

import org.apache.hadoop.yarn.api.records.Resource;
import org.apache.hadoop.yarn.server.resourcemanager.resource.ResourceWeights;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FSLeafQueue;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FSQueue;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FakeSchedulable;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.Schedulable;
import org.apache.hadoop.yarn.server.utils.BuilderUtils;
import org.apache.hadoop.yarn.util.resource.Resources;
import org.junit.Test;

/**
 * comparator.compare(sched1, sched2) < 0 means that sched1 should get a
 * container before sched2
 */
public class TestBoPFSchedulerPolicy {

  private Comparator<Schedulable> createComparator(int clusterMem,
      int clusterCpu) {
    BoPFSchedulerPolicy policy = new BoPFSchedulerPolicy();
    policy.initialize(BuilderUtils.newResource(clusterMem, clusterCpu));
    return policy.getComparator();
  }
  
  private BoPFSchedulerPolicy createPolicy(int clusterMem,
      int clusterCpu) {
    BoPFSchedulerPolicy policy = new BoPFSchedulerPolicy();
    policy.initialize(BuilderUtils.newResource(clusterMem, clusterCpu));
    return policy;
  }
  
  private Schedulable createSchedulable(int memUsage, int cpuUsage) {
    return createSchedulable(memUsage, cpuUsage, ResourceWeights.NEUTRAL, 0, 0);
  }
  
  private Schedulable createSchedulableWithMinReq(int memUsage, int cpuUsage, int minMemReq, int minCpuReq) {
    return createSchedulable(memUsage, cpuUsage, ResourceWeights.NEUTRAL, 0, 0, minMemReq, minCpuReq);
  }
  

  private Schedulable createSchedulable(int memUsage, int cpuUsage,
      int minMemReq, int minCpuReq) {
    return createSchedulable(memUsage, cpuUsage, ResourceWeights.NEUTRAL,
        minMemReq, minCpuReq);
  }
  
  private Schedulable createSchedulable(int memUsage, int cpuUsage,
      ResourceWeights weights, int minMemReq, int minCpuReq) {
    Resource usage = BuilderUtils.newResource(memUsage, cpuUsage);
    Resource minReq = BuilderUtils.newResource(minMemReq, minCpuReq);
    return new FakeSchedulable(Resources.createResource(0, 0),
        Resources.createResource(Integer.MAX_VALUE, Integer.MAX_VALUE),
        weights, Resources.none(), usage, 0l, minReq);
  }
  
  private Schedulable createSchedulable(int memUsage, int cpuUsage,
      ResourceWeights weights, int minMemShare, int minCpuShare, int minMemReq, int minCPUReq) {
    Resource usage = BuilderUtils.newResource(memUsage, cpuUsage);
    Resource minShare = BuilderUtils.newResource(minMemShare, minCpuShare);
    Resource minReq = BuilderUtils.newResource(minMemReq, minCPUReq);
    return new FakeSchedulable(minShare,
        Resources.createResource(Integer.MAX_VALUE, Integer.MAX_VALUE),
        weights, Resources.none(), usage, 0l, minReq);
  }
  
  private Schedulable createSchedulable(int memUsage, int cpuUsage,
      ResourceWeights weights, int minMemShare, int minCpuShare, long startTime, int minMemReq, int minCPUReq) {
    Resource usage = BuilderUtils.newResource(memUsage, cpuUsage);
    Resource minShare = BuilderUtils.newResource(minMemShare, minCpuShare);
    Resource minReq = BuilderUtils.newResource(minMemReq, minCPUReq);
    Schedulable sched = new FakeSchedulable(minShare, Resources.createResource(Integer.MAX_VALUE, Integer.MAX_VALUE),
        weights, Resources.none(), usage, startTime);
    return sched;
  }
  
  private Schedulable createSchedulable(int memUsage, int cpuUsage,
      ResourceWeights weights, int minMemShare, int minCpuShare, long startTime, int minMemReq, int minCPUReq, long stage1Duration, long period) {
    Resource usage = BuilderUtils.newResource(memUsage, cpuUsage);
    Resource minShare = BuilderUtils.newResource(minMemShare, minCpuShare);
    Resource minReq = BuilderUtils.newResource(minMemReq, minCPUReq);
    Schedulable sched = new FakeSchedulable(minShare, Resources.createResource(Integer.MAX_VALUE, Integer.MAX_VALUE),
        weights, Resources.none(), usage, startTime);
    return sched;
  }
  
  private FSQueue createFSQueue(int minMemReq, int minCPUReq, long stage1Duration, long period) {
    Resource minReq = BuilderUtils.newResource(minMemReq, minCPUReq);
    FSQueue queue = new FSLeafQueue("bursty0");
    queue.setStage1Period(stage1Duration);
    queue.setPeriod(period);
    queue.setAlpha(minReq);
    return (FSQueue) queue;
  }
  
  
  private Schedulable createSchedulable(int memUsage, int cpuUsage, long startTime) {
    return createSchedulable(memUsage, cpuUsage, ResourceWeights.NEUTRAL, 0, 0, startTime, 0, 0);
  }
  
  @Test
  public void testDump() {
    assertTrue(true);
  }
}
