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

package org.apache.hadoop.mapreduce.v2.app.rm;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.classification.InterfaceAudience.Private;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.mapreduce.MRConfig;
import org.apache.hadoop.mapreduce.MRJobConfig;
import org.apache.hadoop.mapreduce.v2.api.records.TaskAttemptId;
import org.apache.hadoop.mapreduce.v2.app.AppContext;
import org.apache.hadoop.mapreduce.v2.app.client.ClientService;
import org.apache.hadoop.yarn.api.protocolrecords.AllocateRequest;
import org.apache.hadoop.yarn.api.protocolrecords.AllocateResponse;
import org.apache.hadoop.yarn.api.records.ContainerId;
import org.apache.hadoop.yarn.api.records.Priority;
import org.apache.hadoop.yarn.api.records.Resource;
import org.apache.hadoop.yarn.api.records.ResourceBlacklistRequest;
import org.apache.hadoop.yarn.api.records.ResourceRequest;
import org.apache.hadoop.yarn.api.records.ResourceRequest.ResourceRequestComparator;
import org.apache.hadoop.yarn.exceptions.YarnException;
import org.apache.hadoop.yarn.exceptions.YarnRuntimeException;
import org.apache.hadoop.yarn.factories.RecordFactory;
import org.apache.hadoop.yarn.factory.providers.RecordFactoryProvider;

import com.google.common.annotations.VisibleForTesting;

/**
 * Keeps the data structures to send container requests to RM.
 */
public abstract class RMContainerRequestor extends RMCommunicator {

  private static final Log LOG = LogFactory.getLog(RMContainerRequestor.class);
  private static final ResourceRequestComparator RESOURCE_REQUEST_COMPARATOR = new ResourceRequestComparator();

  protected int lastResponseID;
  private Resource availableResources;

  private final RecordFactory recordFactory = RecordFactoryProvider
      .getRecordFactory(null);
  // Key -> Priority
  // Value -> Map
  // Key->ResourceName (e.g., hostname, rackname, *)
  // Value->Map
  // Key->Resource Capability
  // Value->ResourceRequest
  private final Map<Priority, Map<String, Map<Resource, ResourceRequest>>> remoteRequestsTable = new TreeMap<Priority, Map<String, Map<Resource, ResourceRequest>>>();

  // use custom comparator to make sure ResourceRequest objects differing only
  // in
  // numContainers dont end up as duplicates
  private final Set<ResourceRequest> ask = new TreeSet<ResourceRequest>(
      RESOURCE_REQUEST_COMPARATOR);
  private final Set<ContainerId> release = new TreeSet<ContainerId>();
  // pendingRelease holds history or release requests.request is removed only if
  // RM sends completedContainer.
  // How it different from release? --> release is for per allocate() request.
  protected Set<ContainerId> pendingRelease = new TreeSet<ContainerId>();

  private final Map<ResourceRequest, ResourceRequest> requestLimits = new TreeMap<ResourceRequest, ResourceRequest>(
      RESOURCE_REQUEST_COMPARATOR);
  private final Set<ResourceRequest> requestLimitsToUpdate = new TreeSet<ResourceRequest>(
      RESOURCE_REQUEST_COMPARATOR);

  private boolean nodeBlacklistingEnabled;
  private int blacklistDisablePercent;
  private AtomicBoolean ignoreBlacklisting = new AtomicBoolean(false);
  private int blacklistedNodeCount = 0;
  private int lastClusterNmCount = 0;
  private int clusterNmCount = 0;
  private int maxTaskFailuresPerNode;
  private final Map<String, Integer> nodeFailures = new HashMap<String, Integer>();
  private final Set<String> blacklistedNodes = Collections
      .newSetFromMap(new ConcurrentHashMap<String, Boolean>());
  private final Set<String> blacklistAdditions = Collections
      .newSetFromMap(new ConcurrentHashMap<String, Boolean>());
  private final Set<String> blacklistRemovals = Collections
      .newSetFromMap(new ConcurrentHashMap<String, Boolean>());

  public RMContainerRequestor(ClientService clientService, AppContext context) {
    super(clientService, context);

    // emulation <<
    boolean enableSim = getConfig().getBoolean(
        MRJobConfig.TEZ_ENABLE_SIMULATION,
        MRJobConfig.TEZ_ENABLE_SIMULATION_DEFAULT);
    if (enableSim)
      configParams = new ReadRTParams();
    // emulation >>
  }

  @Private
  @VisibleForTesting
  static class ContainerRequest {
    final TaskAttemptId attemptID;
    final Resource capability;
    final String[] hosts;
    final String[] racks;
    // final boolean earlierAttemptFailed;
    final Priority priority;
    /**
     * the time when this request object was formed; can be used to avoid
     * aggressive preemption for recently placed requests
     */
    final long requestTimeMs;

    public ContainerRequest(ContainerRequestEvent event, Priority priority) {
      this(event.getAttemptID(), event.getCapability(), event.getHosts(),
          event.getRacks(), priority);
    }

    public ContainerRequest(ContainerRequestEvent event, Priority priority,
        long requestTimeMs) {
      this(event.getAttemptID(), event.getCapability(), event.getHosts(),
          event.getRacks(), priority, requestTimeMs);
    }

    public ContainerRequest(TaskAttemptId attemptID, Resource capability,
        String[] hosts, String[] racks, Priority priority) {
      this(attemptID, capability, hosts, racks, priority,
          System.currentTimeMillis());
    }

    public ContainerRequest(TaskAttemptId attemptID, Resource capability,
        String[] hosts, String[] racks, Priority priority, long requestTimeMs) {
      this.attemptID = attemptID;
      this.capability = capability;
      this.hosts = hosts;
      this.racks = racks;
      this.priority = priority;
      this.requestTimeMs = requestTimeMs;
    }

    public String toString() {
      StringBuilder sb = new StringBuilder();
      sb.append("AttemptId[").append(attemptID).append("]");
      sb.append("Capability[").append(capability).append("]");
      sb.append("Priority[").append(priority).append("]");
      return sb.toString();
    }
  }

  @Override
  protected void serviceInit(Configuration conf) throws Exception {
    super.serviceInit(conf);

    // emulation <<
    boolean enableSim = conf.getBoolean(MRJobConfig.TEZ_ENABLE_SIMULATION,
        MRJobConfig.TEZ_ENABLE_SIMULATION_DEFAULT);
    if (enableSim) {
      jobName = conf.get(MRJobConfig.JOB_NAME);

      // take task profiles from gridmix workload
      // RESALLOC
      mapTaskProfile.setMapDuration(300); // 5 min
      redTaskProfile.setRedDuration(300); // 1 min

      mapTaskProfile.setTaskCpuUsage(
          Integer.parseInt(conf.get("mapreduce.map.cpu", "5")));
      mapTaskProfile.setTaskMemUsage(
          Integer.parseInt(conf.get("mapreduce.map.mem", "4000")));
      mapTaskProfile.setTaskInNetworkBwUsage(
          Integer.parseInt(conf.get("mapreduce.map.in_nw", "10")));
      mapTaskProfile.setTaskOutNetworkBwUsage(
          Integer.parseInt(conf.get("mapreduce.map.out_nw", "0")));
      mapTaskProfile.setTaskInStorageBwUsage(
          Integer.parseInt(conf.get("mapreduce.map.in_st", "10")));
      mapTaskProfile.setTaskOutStorageBwUsage(
          Integer.parseInt(conf.get("mapreduce.map.out_st", "10")));

      redTaskProfile.setTaskCpuUsage(
          Integer.parseInt(conf.get("mapreduce.red.cpu", "5")));
      redTaskProfile.setTaskMemUsage(
          Integer.parseInt(conf.get("mapreduce.red.mem", "4000")));
      redTaskProfile.setTaskInNetworkBwUsage(
          Integer.parseInt(conf.get("mapreduce.red.in_nw", "50")));
      redTaskProfile.setTaskOutNetworkBwUsage(
          Integer.parseInt(conf.get("mapreduce.red.out_nw", "20")));
      redTaskProfile.setTaskInStorageBwUsage(
          Integer.parseInt(conf.get("mapreduce.red.in_st", "20")));
      redTaskProfile.setTaskOutStorageBwUsage(
          Integer.parseInt(conf.get("mapreduce.red.out_st", "10")));

      LOG.info("mapTaskProfile=" + mapTaskProfile);
      LOG.info("redTaskProfile=" + redTaskProfile);

      // END RESALLOC

      /*
       * try {
       * 
       * // TODO - make it fancy on dynamic updates
       * mapTaskProfile.setMapDuration(300); // 5 min
       * redTaskProfile.setRedDuration(300); // 1 min
       * 
       * configParams.retrieveJobProfile(jobName);
       * 
       * } catch (NoSuchFieldException e) {
       * LOG.info("Unable to get profile for; " + jobName +
       * " ; using defaults"); configParams.retrieveDefaultProfile(); }
       */
    }
    // emulation >>

    nodeBlacklistingEnabled = conf
        .getBoolean(MRJobConfig.MR_AM_JOB_NODE_BLACKLISTING_ENABLE, true);
    LOG.info("nodeBlacklistingEnabled:" + nodeBlacklistingEnabled);
    maxTaskFailuresPerNode = conf
        .getInt(MRJobConfig.MAX_TASK_FAILURES_PER_TRACKER, 3);
    blacklistDisablePercent = conf.getInt(
        MRJobConfig.MR_AM_IGNORE_BLACKLISTING_BLACKLISTED_NODE_PERECENT,
        MRJobConfig.DEFAULT_MR_AM_IGNORE_BLACKLISTING_BLACKLISTED_NODE_PERCENT);
    LOG.info("maxTaskFailuresPerNode is " + maxTaskFailuresPerNode);
    if (blacklistDisablePercent < -1 || blacklistDisablePercent > 100) {
      throw new YarnRuntimeException(
          "Invalid blacklistDisablePercent: " + blacklistDisablePercent
              + ". Should be an integer between 0 and 100 or -1 to disabled");
    }
    LOG.info("blacklistDisablePercent is " + blacklistDisablePercent);
  }

  protected AllocateResponse makeRemoteRequest()
      throws YarnException, IOException {
    applyRequestLimits();

    // emulation <<
    boolean enableSim = getConfig().getBoolean(
        MRJobConfig.TEZ_ENABLE_SIMULATION,
        MRJobConfig.TEZ_ENABLE_SIMULATION_DEFAULT);
    if (enableSim) {
      // update the ask capabilities

      // instrumentation

      long size_overhead_ask = 0;
      for (ResourceRequest resReq : ask) {

        size_overhead_ask += 40;
         LOG.info("app="+getJob().getName()+" prio="+ resReq.getPriority().getPriority()+" num_cont="+resReq.getNumContainers());
        // synchronized (requested_maps) {

        if (requested_maps == -1)
          requested_maps = getJob().getTotalMaps();
        resReq.getCapability().setRemMapTasksToSched(requested_maps);
        // LOG.info("requested_maps="+requested_maps+" on
        // ask="+resReq.getCapability().getRemMapTasksToSched());
        // }

        // synchronized (requested_reds) {

        if (requested_reds == -1)
          requested_reds = getJob().getTotalReduces();
        resReq.getCapability().setRemRedTasksToSched(requested_reds);
        // LOG.info("requested_reds="+requested_reds+" on
        // ask="+resReq.getCapability().getRemRedTasksToSched());
        // }

        resReq.getCapability()
            .setMapTaskDuration(mapTaskProfile.getMapDuration());
        resReq.getCapability()
            .setRedTaskDuration(redTaskProfile.getRedDuration());
        /*
         * LOG.info("map_dur="+resReq.getCapability().getMapTaskDuration()+
         * " red_dur="+resReq.getCapability().getRedTaskDuration());
         */
        if (resReq.getCapability().isMapResource()) {
          // LOG.info("update profile for MAP");
          resReq.getCapability().setCpu(mapTaskProfile.getTaskCpuUsage());
          resReq.getCapability().setVMem(mapTaskProfile.getTaskMemUsage());
          resReq.getCapability()
              .setInNetwork(mapTaskProfile.getTaskInNetworkUsage());
          resReq.getCapability()
              .setOutNetwork(mapTaskProfile.getTaskOutNetworkUsage());
          resReq.getCapability()
              .setInStorage(mapTaskProfile.getTaskInStorageUsage());
          resReq.getCapability()
              .setOutStorage(mapTaskProfile.getTaskOutStorageUsage());

          resReq.getCapability().setCpuOther(redTaskProfile.getTaskCpuUsage());
          resReq.getCapability().setVMemOther(redTaskProfile.getTaskMemUsage());
          resReq.getCapability()
              .setInNetworkOther(redTaskProfile.getTaskInNetworkUsage());
          resReq.getCapability()
              .setOutNetworkOther(redTaskProfile.getTaskOutNetworkUsage());
          resReq.getCapability()
              .setInStorageOther(redTaskProfile.getTaskInStorageUsage());
          resReq.getCapability()
              .setOutStorageOther(redTaskProfile.getTaskOutStorageUsage());
          // LOG.info("map_cap="+resReq.getCapability());

        } else {
          // LOG.info("update profile for REDUCE");
          resReq.getCapability().setCpu(redTaskProfile.getTaskCpuUsage());
          resReq.getCapability().setVMem(redTaskProfile.getTaskMemUsage());
          resReq.getCapability()
              .setInNetwork(redTaskProfile.getTaskInNetworkUsage());
          resReq.getCapability()
              .setOutNetwork(redTaskProfile.getTaskOutNetworkUsage());
          resReq.getCapability()
              .setInStorage(redTaskProfile.getTaskInStorageUsage());
          resReq.getCapability()
              .setOutStorage(redTaskProfile.getTaskOutStorageUsage());

          resReq.getCapability().setCpuOther(mapTaskProfile.getTaskCpuUsage());
          resReq.getCapability().setVMemOther(mapTaskProfile.getTaskMemUsage());
          resReq.getCapability()
              .setInNetworkOther(mapTaskProfile.getTaskInNetworkUsage());
          resReq.getCapability()
              .setOutNetworkOther(mapTaskProfile.getTaskOutNetworkUsage());
          resReq.getCapability()
              .setInStorageOther(mapTaskProfile.getTaskInStorageUsage());
          resReq.getCapability()
              .setOutStorageOther(mapTaskProfile.getTaskOutStorageUsage());
          // LOG.info("red_cap="+resReq.getCapability());
        }
      }
    }
    // emulation >>

    ResourceBlacklistRequest blacklistRequest = ResourceBlacklistRequest
        .newInstance(new ArrayList<String>(blacklistAdditions),
            new ArrayList<String>(blacklistRemovals));
    AllocateRequest allocateRequest = AllocateRequest.newInstance(
        lastResponseID, super.getApplicationProgress(),
        new ArrayList<ResourceRequest>(ask),
        new ArrayList<ContainerId>(release), blacklistRequest);
    AllocateResponse allocateResponse = scheduler.allocate(allocateRequest);
    lastResponseID = allocateResponse.getResponseId();
    availableResources = allocateResponse.getAvailableResources();
    lastClusterNmCount = clusterNmCount;
    clusterNmCount = allocateResponse.getNumClusterNodes();
    int numCompletedContainers = allocateResponse
        .getCompletedContainersStatuses().size();

    if (ask.size() > 0 || release.size() > 0) {
      LOG.info("getResources() for " + applicationId + ":" + " ask="
          + ask.size() + " release= " + release.size() + " newContainers="
          + allocateResponse.getAllocatedContainers().size()
          + " finishedContainers=" + numCompletedContainers + " resourcelimit="
          + availableResources + " knownNMs=" + clusterNmCount);
    }

    ask.clear();
    release.clear();

    if (numCompletedContainers > 0) {
      // re-send limited requests when a container completes to trigger asking
      // for more containers
      requestLimitsToUpdate.addAll(requestLimits.keySet());
    }

    if (blacklistAdditions.size() > 0 || blacklistRemovals.size() > 0) {
      LOG.info("Update the blacklist for " + applicationId
          + ": blacklistAdditions=" + blacklistAdditions.size()
          + " blacklistRemovals=" + blacklistRemovals.size());
    }
    blacklistAdditions.clear();
    blacklistRemovals.clear();
    return allocateResponse;
  }

  private void applyRequestLimits() {
    Iterator<ResourceRequest> iter = requestLimits.values().iterator();
    while (iter.hasNext()) {
      ResourceRequest reqLimit = iter.next();
      int limit = reqLimit.getNumContainers();
      Map<String, Map<Resource, ResourceRequest>> remoteRequests = remoteRequestsTable
          .get(reqLimit.getPriority());
      Map<Resource, ResourceRequest> reqMap = (remoteRequests != null)
          ? remoteRequests.get(ResourceRequest.ANY) : null;
      ResourceRequest req = (reqMap != null)
          ? reqMap.get(reqLimit.getCapability()) : null;
      if (req == null) {
        continue;
      }
      // update an existing ask or send a new one if updating
      if (ask.remove(req) || requestLimitsToUpdate.contains(req)) {
        ResourceRequest newReq = req.getNumContainers() > limit ? reqLimit
            : req;
        ask.add(newReq);
        LOG.info("Applying ask limit of " + newReq.getNumContainers()
            + " for priority:" + reqLimit.getPriority() + " and capability:"
            + reqLimit.getCapability());
      }
      if (limit == Integer.MAX_VALUE) {
        iter.remove();
      }
    }
    requestLimitsToUpdate.clear();
  }

  protected void addOutstandingRequestOnResync() {
    for (Map<String, Map<Resource, ResourceRequest>> rr : remoteRequestsTable
        .values()) {
      for (Map<Resource, ResourceRequest> capabalities : rr.values()) {
        for (ResourceRequest request : capabalities.values()) {
          addResourceRequestToAsk(request);
        }
      }
    }
    if (!ignoreBlacklisting.get()) {
      blacklistAdditions.addAll(blacklistedNodes);
    }
    if (!pendingRelease.isEmpty()) {
      release.addAll(pendingRelease);
    }
    requestLimitsToUpdate.addAll(requestLimits.keySet());
  }

  // May be incorrect if there's multiple NodeManagers running on a single host.
  // knownNodeCount is based on node managers, not hosts. blacklisting is
  // currently based on hosts.
  protected void computeIgnoreBlacklisting() {
    if (!nodeBlacklistingEnabled) {
      return;
    }
    if (blacklistDisablePercent != -1
        && (blacklistedNodeCount != blacklistedNodes.size()
            || clusterNmCount != lastClusterNmCount)) {
      blacklistedNodeCount = blacklistedNodes.size();
      if (clusterNmCount == 0) {
        LOG.info("KnownNode Count at 0. Not computing ignoreBlacklisting");
        return;
      }
      int val = (int) ((float) blacklistedNodes.size() / clusterNmCount * 100);
      if (val >= blacklistDisablePercent) {
        if (ignoreBlacklisting.compareAndSet(false, true)) {
          LOG.info("Ignore blacklisting set to true. Known: " + clusterNmCount
              + ", Blacklisted: " + blacklistedNodeCount + ", " + val + "%");
          // notify RM to ignore all the blacklisted nodes
          blacklistAdditions.clear();
          blacklistRemovals.addAll(blacklistedNodes);
        }
      } else {
        if (ignoreBlacklisting.compareAndSet(true, false)) {
          LOG.info("Ignore blacklisting set to false. Known: " + clusterNmCount
              + ", Blacklisted: " + blacklistedNodeCount + ", " + val + "%");
          // notify RM of all the blacklisted nodes
          blacklistAdditions.addAll(blacklistedNodes);
          blacklistRemovals.clear();
        }
      }
    }
  }

  protected void containerFailedOnHost(String hostName) {
    if (!nodeBlacklistingEnabled) {
      return;
    }
    if (blacklistedNodes.contains(hostName)) {
      if (LOG.isDebugEnabled()) {
        LOG.debug("Host " + hostName + " is already blacklisted.");
      }
      return; // already blacklisted
    }
    Integer failures = nodeFailures.remove(hostName);
    failures = failures == null ? Integer.valueOf(0) : failures;
    failures++;
    LOG.info(failures + " failures on node " + hostName);
    if (failures >= maxTaskFailuresPerNode) {
      blacklistedNodes.add(hostName);
      if (!ignoreBlacklisting.get()) {
        blacklistAdditions.add(hostName);
      }
      // Even if blacklisting is ignored, continue to remove the host from
      // the request table. The RM may have additional nodes it can allocate on.
      LOG.info("Blacklisted host " + hostName);

      // remove all the requests corresponding to this hostname
      for (Map<String, Map<Resource, ResourceRequest>> remoteRequests : remoteRequestsTable
          .values()) {
        // remove from host if no pending allocations
        boolean foundAll = true;
        Map<Resource, ResourceRequest> reqMap = remoteRequests.get(hostName);
        if (reqMap != null) {
          for (ResourceRequest req : reqMap.values()) {
            if (!ask.remove(req)) {
              foundAll = false;
              // if ask already sent to RM, we can try and overwrite it if
              // possible.
              // send a new ask to RM with numContainers
              // specified for the blacklisted host to be 0.
              ResourceRequest zeroedRequest = ResourceRequest.newInstance(
                  req.getPriority(), req.getResourceName(), req.getCapability(),
                  req.getNumContainers(), req.getRelaxLocality());

              zeroedRequest.setNumContainers(0);
              // to be sent to RM on next heartbeat
              addResourceRequestToAsk(zeroedRequest);
            }
          }
          // if all requests were still in ask queue
          // we can remove this request
          if (foundAll) {
            remoteRequests.remove(hostName);
          }
        }
        // TODO handling of rack blacklisting
        // Removing from rack should be dependent on no. of failures within the
        // rack
        // Blacklisting a rack on the basis of a single node's blacklisting
        // may be overly aggressive.
        // Node failures could be co-related with other failures on the same
        // rack
        // but we probably need a better approach at trying to decide how and
        // when
        // to blacklist a rack
      }
    } else {
      nodeFailures.put(hostName, failures);
    }
  }

  protected Resource getAvailableResources() {
    return availableResources;
  }

  protected void addContainerReq(ContainerRequest req) {
    // Create resource requests
    for (String host : req.hosts) {
      // Data-local
      if (!isNodeBlacklisted(host)) {
        addResourceRequest(req.priority, host, req.capability);
      }
    }

    // Nothing Rack-local for now
    for (String rack : req.racks) {
      addResourceRequest(req.priority, rack, req.capability);
    }

    // Off-switch
    addResourceRequest(req.priority, ResourceRequest.ANY, req.capability);
  }

  protected void decContainerReq(ContainerRequest req) {
    // Update resource requests
    for (String hostName : req.hosts) {
      decResourceRequest(req.priority, hostName, req.capability);
    }

    for (String rack : req.racks) {
      decResourceRequest(req.priority, rack, req.capability);
    }

    decResourceRequest(req.priority, ResourceRequest.ANY, req.capability);
  }

  private void addResourceRequest(Priority priority, String resourceName,
      Resource capability) {
    Map<String, Map<Resource, ResourceRequest>> remoteRequests = this.remoteRequestsTable
        .get(priority);
    if (remoteRequests == null) {
      remoteRequests = new HashMap<String, Map<Resource, ResourceRequest>>();
      this.remoteRequestsTable.put(priority, remoteRequests);
      if (LOG.isDebugEnabled()) {
        LOG.debug("Added priority=" + priority);
      }
    }
    Map<Resource, ResourceRequest> reqMap = remoteRequests.get(resourceName);
    if (reqMap == null) {
      reqMap = new HashMap<Resource, ResourceRequest>();
      remoteRequests.put(resourceName, reqMap);
    }
    ResourceRequest remoteRequest = reqMap.get(capability);
    if (remoteRequest == null) {
      remoteRequest = recordFactory.newRecordInstance(ResourceRequest.class);
      remoteRequest.setPriority(priority);
      remoteRequest.setResourceName(resourceName);
      remoteRequest.setCapability(capability);
      remoteRequest.setNumContainers(0);
      reqMap.put(capability, remoteRequest);
    }
    remoteRequest.setNumContainers(remoteRequest.getNumContainers() + 1);

    // Note this down for next interaction with ResourceManager
    addResourceRequestToAsk(remoteRequest);
    if (LOG.isDebugEnabled()) {
      LOG.debug("addResourceRequest:" + " applicationId="
          + applicationId.getId() + " priority=" + priority.getPriority()
          + " resourceName=" + resourceName + " numContainers="
          + remoteRequest.getNumContainers() + " #asks=" + ask.size());
    }
  }

  private void decResourceRequest(Priority priority, String resourceName,
      Resource capability) {
    Map<String, Map<Resource, ResourceRequest>> remoteRequests = this.remoteRequestsTable
        .get(priority);
    Map<Resource, ResourceRequest> reqMap = remoteRequests.get(resourceName);
    if (reqMap == null) {
      // as we modify the resource requests by filtering out blacklisted hosts
      // when they are added, this value may be null when being
      // decremented
      if (LOG.isDebugEnabled()) {
        LOG.debug("Not decrementing resource as " + resourceName
            + " is not present in request table");
      }
      return;
    }
    ResourceRequest remoteRequest = reqMap.get(capability);

    if (LOG.isDebugEnabled()) {
      LOG.debug("BEFORE decResourceRequest:" + " applicationId="
          + applicationId.getId() + " priority=" + priority.getPriority()
          + " resourceName=" + resourceName + " numContainers="
          + remoteRequest.getNumContainers() + " #asks=" + ask.size());
    }

    if (remoteRequest.getNumContainers() > 0) {
      // based on blacklisting comments above we can end up decrementing more
      // than requested. so guard for that.
      remoteRequest.setNumContainers(remoteRequest.getNumContainers() - 1);
    }

    if (remoteRequest.getNumContainers() == 0) {
      reqMap.remove(capability);
      if (reqMap.size() == 0) {
        remoteRequests.remove(resourceName);
      }
      if (remoteRequests.size() == 0) {
        remoteRequestsTable.remove(priority);
      }
    }

    // send the updated resource request to RM
    // send 0 container count requests also to cancel previous requests
    addResourceRequestToAsk(remoteRequest);

    if (LOG.isDebugEnabled()) {
      LOG.info("AFTER decResourceRequest:" + " applicationId="
          + applicationId.getId() + " priority=" + priority.getPriority()
          + " resourceName=" + resourceName + " numContainers="
          + remoteRequest.getNumContainers() + " #asks=" + ask.size());
    }
  }

  private void addResourceRequestToAsk(ResourceRequest remoteRequest) {
    // because objects inside the resource map can be deleted ask can end up
    // containing an object that matches new resource object but with different
    // numContainers. So existing values must be replaced explicitly
    ask.remove(remoteRequest);
    ask.add(remoteRequest);
  }

  protected void release(ContainerId containerId) {
    release.add(containerId);
  }

  protected boolean isNodeBlacklisted(String hostname) {
    if (!nodeBlacklistingEnabled || ignoreBlacklisting.get()) {
      return false;
    }
    return blacklistedNodes.contains(hostname);
  }

  protected ContainerRequest getFilteredContainerRequest(
      ContainerRequest orig) {
    ArrayList<String> newHosts = new ArrayList<String>();
    for (String host : orig.hosts) {
      if (!isNodeBlacklisted(host)) {
        newHosts.add(host);
      }
    }
    String[] hosts = newHosts.toArray(new String[newHosts.size()]);
    ContainerRequest newReq = new ContainerRequest(orig.attemptID,
        orig.capability, hosts, orig.racks, orig.priority);
    return newReq;
  }

  protected void setRequestLimit(Priority priority, Resource capability,
      int limit) {
    if (limit < 0) {
      limit = Integer.MAX_VALUE;
    }
    ResourceRequest newReqLimit = ResourceRequest.newInstance(priority,
        ResourceRequest.ANY, capability, limit);
    ResourceRequest oldReqLimit = requestLimits.put(newReqLimit, newReqLimit);
    if (oldReqLimit == null || oldReqLimit.getNumContainers() < limit) {
      requestLimitsToUpdate.add(newReqLimit);
    }
  }

  public Set<String> getBlacklistedNodes() {
    return blacklistedNodes;
  }

  // emulation <<
  /*
   * protected Vector<Integer> bit_vector_map = null; protected Vector<Integer>
   * bit_vector_red = null;
   */
  protected Integer requested_maps = -1;
  protected Integer requested_reds = -1;

  private ReadRTParams configParams = null;
  protected String jobName = null;

  // [map_dur(s), red_dur(s),
  // cpu(%),vmem(MB),in_nw(MB/s),out_nw(MB/s),in_st(MB/s),out_st(MB/s)]
  TaskProfile mapTaskProfile = new TaskProfile(Integer.MAX_VALUE,
      Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE,
      Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE,
      Integer.MAX_VALUE);
  TaskProfile redTaskProfile = new TaskProfile(Integer.MAX_VALUE,
      Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE,
      Integer.MAX_VALUE, Integer.MAX_VALUE, Integer.MAX_VALUE,
      Integer.MAX_VALUE);

  protected double mapInputSize = 0;
  protected String addressRT = null;
  protected int portRT = -1;

  protected String loggingDir = null;
  protected boolean isRTService = false;
  protected boolean isLoggingEnabled = false;
  protected boolean enabledResAlloc = false;

  class ReadRTParams extends Configuration {
    private final String RT_CONF = "rsrc-site.xml";

    private final String RT_ENABLED = "rsrc.monitoring.enabled";
    private final boolean RT_DEF_ENABLED = false;
    private final String RT_SCHED_ENABLED = "rsrc.scheduling.enabled";
    private final boolean RT_DEF_SCHED_ENABLED = false;
    public static final String RSRC_TRACKER_ADDR = "rsrc.monitoring.resource-tracker.address";
    public static final String RSRC_DEF_TRACKER_ADDR = "127.0.0.1:63000";
    public static final String RSRC_TRACKER_LOGGING_ENABLE = "rsrc.monitoring.resource-tracker.logging.enable";
    public static final boolean RSRC_TRACKER_LOGGING_ENABLE_DEF_VAL = false;

    public static final String RSRC_TRACKER_LOGGING_DIR = "rsrc.monitoring.resource-tracker.logging.dir";
    public static final String RSRC_TRACKER_LOGGING_DIR_DEF_VAL = "/home/rgrandl/intern_project/logs/";

    private final String MAPRED_CONF = "mapred-site.xml";
    private final String HDFS_CONF = "hdfs-site.xml";
    private final String HDFS_BLOCK_SIZE = "dfs.blocksize";
    private final double HDFS_DEF_BLOCK_SIZE = 67108864;

    private final String TASK_PROFILE_CONF = "task-profiles-site.xml";

    ReadRTParams() {
      addDefaultResource(RT_CONF);
      addDefaultResource(HDFS_CONF);
      addDefaultResource(TASK_PROFILE_CONF);
      isRTService = false; // getBoolean(RT_ENABLED, RT_DEF_ENABLED);
      isLoggingEnabled = getBoolean(RSRC_TRACKER_LOGGING_ENABLE,
          RSRC_TRACKER_LOGGING_ENABLE_DEF_VAL);
      loggingDir = get(RSRC_TRACKER_LOGGING_DIR,
          RSRC_TRACKER_LOGGING_DIR_DEF_VAL);
      enabledResAlloc = getBoolean(RT_SCHED_ENABLED, RT_DEF_SCHED_ENABLED);
      if (isRTService) {
        String addr = get(RSRC_TRACKER_ADDR, RSRC_DEF_TRACKER_ADDR);
        addressRT = addr.split(":")[0];
        portRT = Integer.parseInt(addr.split(":")[1]);
      }

      mapInputSize = getDouble(HDFS_BLOCK_SIZE, HDFS_DEF_BLOCK_SIZE);
      mapInputSize /= 1048576; // to have MBs
    };

    // TODO - make it customizable from file
    public void retrieveDefaultProfile() {
      mapTaskProfile.setMapDuration(300); // 5 min
      mapTaskProfile.setTaskCpuUsage(5);
      mapTaskProfile.setTaskMemUsage(4000);
      mapTaskProfile.setTaskInNetworkBwUsage(10);
      mapTaskProfile.setTaskOutNetworkBwUsage(0);
      mapTaskProfile.setTaskInStorageBwUsage(10);
      mapTaskProfile.setTaskOutStorageBwUsage(10);

      redTaskProfile.setRedDuration(300); // 5 min
      redTaskProfile.setTaskCpuUsage(5);
      redTaskProfile.setTaskMemUsage(4000);
      redTaskProfile.setTaskInNetworkBwUsage(50);
      redTaskProfile.setTaskOutNetworkBwUsage(20);
      redTaskProfile.setTaskInStorageBwUsage(20);
      redTaskProfile.setTaskOutStorageBwUsage(10);
    }

    public void retrieveJobProfile(String jobName) throws NoSuchFieldException {
      final String MAP_TASK_PROFILE = "profile." + jobName + ".map.profile";
      final String RED_TASK_PROFILE = "profile." + jobName + ".reduce.profile";

      String map_profile = get(MAP_TASK_PROFILE, null);
      if (map_profile == null)
        throw new NoSuchFieldException(
            "Map profile for " + jobName + " does not exist !");
      String[] map_vals = map_profile.split(",");
      mapTaskProfile.setTaskCpuUsage(Integer.parseInt(map_vals[0]));
      mapTaskProfile.setTaskMemUsage(Integer.parseInt(map_vals[1]));
      mapTaskProfile.setTaskInNetworkBwUsage(Integer.parseInt(map_vals[2]));
      mapTaskProfile.setTaskOutNetworkBwUsage(Integer.parseInt(map_vals[3]));
      mapTaskProfile.setTaskInStorageBwUsage(Integer.parseInt(map_vals[4]));
      mapTaskProfile.setTaskOutStorageBwUsage(Integer.parseInt(map_vals[5]));

      String red_profile = get(RED_TASK_PROFILE, null);
      if (red_profile == null)
        throw new NoSuchFieldException(
            "Reduce profile for " + jobName + " does not exist !");
      String[] red_vals = red_profile.split(",");
      redTaskProfile.setTaskCpuUsage(Integer.parseInt(red_vals[0]));
      redTaskProfile.setTaskMemUsage(Integer.parseInt(red_vals[1]));
      redTaskProfile.setTaskInNetworkBwUsage(Integer.parseInt(red_vals[2]));
      redTaskProfile.setTaskOutNetworkBwUsage(Integer.parseInt(red_vals[3]));
      redTaskProfile.setTaskInStorageBwUsage(Integer.parseInt(red_vals[4]));
      redTaskProfile.setTaskOutStorageBwUsage(Integer.parseInt(red_vals[5]));
    }
  }

  // emulation >>
}
