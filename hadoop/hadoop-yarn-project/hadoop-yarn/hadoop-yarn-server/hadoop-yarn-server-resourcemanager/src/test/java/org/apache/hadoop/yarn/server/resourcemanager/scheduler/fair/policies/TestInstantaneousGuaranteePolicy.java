/**
 * Tan N. Le, SUNY Korea, Stony Brook University * 
 */
package org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.policies;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.util.Comparator;

import org.apache.hadoop.yarn.api.records.Resource;
import org.apache.hadoop.yarn.server.resourcemanager.resource.ResourceType;
import org.apache.hadoop.yarn.server.resourcemanager.resource.ResourceWeights;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FakeSchedulable;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.Schedulable;
import org.apache.hadoop.yarn.server.utils.BuilderUtils;
import org.apache.hadoop.yarn.util.resource.Resources;
import org.junit.Test;

/**
 * comparator.compare(sched1, sched2) < 0 means that sched1 should get a
 * container before sched2
 */
public class TestInstantaneousGuaranteePolicy {

  private Comparator<Schedulable> createComparator(int clusterMem,
      int clusterCpu) {
    InstantaneousGuaranteePolicy policy = new InstantaneousGuaranteePolicy();
    policy.initialize(BuilderUtils.newResource(clusterMem, clusterCpu));
    return policy.getComparator();
  }
  
  private Schedulable createSchedulable(int memUsage, int cpuUsage) {
    return createSchedulable(memUsage, cpuUsage, ResourceWeights.NEUTRAL, 0, 0);
  }
  
 
  private Schedulable createSchedulable(int memUsage, int cpuUsage,
      int minMemShare, int minCpuShare) {
    return createSchedulable(memUsage, cpuUsage, ResourceWeights.NEUTRAL,
        minMemShare, minCpuShare);
  }
  
  private Schedulable createSchedulable(int memUsage, int cpuUsage,
      ResourceWeights weights) {
    return createSchedulable(memUsage, cpuUsage, weights, 0, 0);
  }

  
  private Schedulable createSchedulable(int memUsage, int cpuUsage,
      ResourceWeights weights, int minMemShare, int minCpuShare) {
    Resource usage = BuilderUtils.newResource(memUsage, cpuUsage);
    Resource minShare = BuilderUtils.newResource(minMemShare, minCpuShare);
    return new FakeSchedulable(minShare,
        Resources.createResource(Integer.MAX_VALUE, Integer.MAX_VALUE),
        weights, Resources.none(), usage, 0l);
  }
  
  private Schedulable createSchedulable(int memUsage, int cpuUsage,
      ResourceWeights weights, int minMemShare, int minCpuShare, long startTime, float fairPriority) {
    Resource usage = BuilderUtils.newResource(memUsage, cpuUsage);
    Resource minShare = BuilderUtils.newResource(minMemShare, minCpuShare);
    Schedulable sched = new FakeSchedulable(minShare, Resources.createResource(Integer.MAX_VALUE, Integer.MAX_VALUE),
        weights, Resources.none(), usage, startTime, fairPriority);
    return sched;
  }
  
  private Schedulable createSchedulable(int memUsage, int cpuUsage, long startTime, float fairPriority) {
    return createSchedulable(memUsage, cpuUsage, ResourceWeights.NEUTRAL, 0, 0, startTime, fairPriority);
  }
  
  @Test
  public void testSameDominantResource() {
    assertTrue(createComparator(8000, 4).compare(
        createSchedulable(1000, 1),
        createSchedulable(2000, 1)) < 0);
  }
  
  @Test
  public void testDifferentDominantResource() {
    assertTrue(createComparator(8000, 8).compare(
        createSchedulable(4000, 3),
        createSchedulable(2000, 5)) < 0);
  }
  
  @Test
  public void testOneIsNeedy() {
    assertTrue(createComparator(8000, 8).compare(
        createSchedulable(2000, 5, 0, 6),
        createSchedulable(4000, 3, 0, 0)) < 0);
  }
  
  @Test
  public void testBothAreNeedy() {
    assertTrue(createComparator(8000, 100).compare(
        // dominant share is 2000/8000
        createSchedulable(2000, 5),
        // dominant share is 4000/8000
        createSchedulable(4000, 3)) < 0);
    assertTrue(createComparator(8000, 100).compare(
        // dominant min share is 2/3
        createSchedulable(2000, 5, 3000, 6),
        // dominant min share is 4/5
        createSchedulable(4000, 3, 5000, 4)) < 0);
  }
  
  @Test
  public void testEvenWeightsSameDominantResource() {
    assertTrue(createComparator(8000, 8).compare(
        createSchedulable(3000, 1, new ResourceWeights(2.0f)),
        createSchedulable(2000, 1)) < 0);
    assertTrue(createComparator(8000, 8).compare(
        createSchedulable(1000, 3, new ResourceWeights(2.0f)),
        createSchedulable(1000, 2)) < 0);
  }
  
  @Test
  public void testEvenWeightsDifferentDominantResource() {
    assertTrue(createComparator(8000, 8).compare(
        createSchedulable(1000, 3, new ResourceWeights(2.0f)),
        createSchedulable(2000, 1)) < 0);
    assertTrue(createComparator(8000, 8).compare(
        createSchedulable(3000, 1, new ResourceWeights(2.0f)),
        createSchedulable(1000, 2)) < 0);
  }
  
  @Test
  public void testUnevenWeightsSameDominantResource() {
    assertTrue(createComparator(8000, 8).compare(
        createSchedulable(3000, 1, new ResourceWeights(2.0f, 1.0f)),
        createSchedulable(2000, 1)) < 0);
    assertTrue(createComparator(8000, 8).compare(
        createSchedulable(1000, 3, new ResourceWeights(1.0f, 2.0f)),
        createSchedulable(1000, 2)) < 0);
  }
  
  @Test
  public void testUnevenWeightsDifferentDominantResource() {
    assertTrue(createComparator(8000, 8).compare(
        createSchedulable(1000, 3, new ResourceWeights(1.0f, 2.0f)),
        createSchedulable(2000, 1)) < 0);
    assertTrue(createComparator(8000, 8).compare(
        createSchedulable(3000, 1, new ResourceWeights(2.0f, 1.0f)),
        createSchedulable(1000, 2)) < 0);
  }
  
  @Test
  public void testCalculateShares() {
    Resource used = Resources.createResource(10, 5);
    Resource capacity = Resources.createResource(100, 10);
    ResourceType[] resourceOrder = new ResourceType[2];
    ResourceWeights shares = new ResourceWeights();
    InstantaneousGuaranteePolicy.InstantaneousGuaranteeComparator comparator =
        new InstantaneousGuaranteePolicy.InstantaneousGuaranteeComparator();
    comparator.calculateShares(used, capacity, shares, resourceOrder,
        ResourceWeights.NEUTRAL, 1.0f);
    
    assertEquals(.1, shares.getWeight(ResourceType.MEMORY), .00001);
    assertEquals(.5, shares.getWeight(ResourceType.CPU), .00001);
    assertEquals(ResourceType.CPU, resourceOrder[0]);
    assertEquals(ResourceType.MEMORY, resourceOrder[1]);
  }
  
  @Test
  public void testCalculateSharesFixedHighPriority() {
    Resource used = Resources.createResource(10, 5);
    Resource capacity = Resources.createResource(100, 10);
    ResourceType[] resourceOrder = new ResourceType[2];
    ResourceWeights shares = new ResourceWeights();
    float fixedPriority = 3;
    InstantaneousGuaranteePolicy.InstantaneousGuaranteeComparator comparator =
        new InstantaneousGuaranteePolicy.InstantaneousGuaranteeComparator();
    comparator.calculateShares(used, capacity, shares, resourceOrder,
        ResourceWeights.NEUTRAL, fixedPriority);
    
    System.out.println(shares.getWeight(ResourceType.MEMORY));
    
    assertEquals(.1/fixedPriority, shares.getWeight(ResourceType.MEMORY), .00001); //TODO: why?
    assertEquals(.5/fixedPriority, shares.getWeight(ResourceType.CPU), .00001);
    assertEquals(ResourceType.CPU, resourceOrder[0]);
    assertEquals(ResourceType.MEMORY, resourceOrder[1]);
  }
}
