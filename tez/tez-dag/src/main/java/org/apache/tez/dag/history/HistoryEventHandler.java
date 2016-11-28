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

package org.apache.tez.dag.history;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.service.CompositeService;
import org.apache.tez.common.ReflectionUtils;
import org.apache.tez.dag.api.TezConfiguration;
import org.apache.tez.dag.app.AppContext;
import org.apache.tez.dag.history.events.TaskFinishedEvent;
import org.apache.tez.dag.history.logging.HistoryLoggingService;
import org.apache.tez.dag.history.recovery.RecoveryService;
import org.apache.tez.dag.profiler.ResourceProfile;
import org.apache.tez.dag.records.TezDAGID;
import org.apache.tez.dag.records.TezVertexID;

public class HistoryEventHandler extends CompositeService {

  private static Logger LOG = LoggerFactory.getLogger(HistoryEventHandler.class);

  private final AppContext context;
  private RecoveryService recoveryService;
  private boolean recoveryEnabled;
  private HistoryLoggingService historyLoggingService;

  // emulation <<
  HashMap<String, Integer> taskIdxPerVertex = new HashMap<String, Integer>();
  // emulation >>

  public HistoryEventHandler(AppContext context) {
    super(HistoryEventHandler.class.getName());
    this.context = context;
  }

  @Override
  public void serviceInit(Configuration conf) throws Exception {
    this.recoveryEnabled = context.getAMConf().getBoolean(TezConfiguration.DAG_RECOVERY_ENABLED,
        TezConfiguration.DAG_RECOVERY_ENABLED_DEFAULT);

    String historyServiceClassName = context.getAMConf().get(TezConfiguration.TEZ_HISTORY_LOGGING_SERVICE_CLASS,
        TezConfiguration.TEZ_HISTORY_LOGGING_SERVICE_CLASS_DEFAULT);

    LOG.info("Initializing HistoryEventHandler with" + "recoveryEnabled=" + recoveryEnabled
        + ", historyServiceClassName=" + historyServiceClassName);

    historyLoggingService = ReflectionUtils.createClazzInstance(historyServiceClassName);
    historyLoggingService.setAppContext(context);
    addService(historyLoggingService);

    if (recoveryEnabled) {
      String recoveryServiceClass = conf.get(TezConfiguration.TEZ_AM_RECOVERY_SERVICE_CLASS,
          TezConfiguration.TEZ_AM_RECOVERY_SERVICE_CLASS_DEFAULT);
      recoveryService = ReflectionUtils.createClazzInstance(recoveryServiceClass, new Class[] { AppContext.class },
          new Object[] { context });
      addService(recoveryService);
    }
    super.serviceInit(conf);

  }

  @Override
  public void serviceStart() throws Exception {
    super.serviceStart();
  }

  @Override
  public void serviceStop() throws Exception {
    LOG.info("Stopping HistoryEventHandler");
    super.serviceStop();
  }

  /**
   * Used by events that are critical for recovery DAG Submission/finished and
   * any commit related activites are critical events In short, any events that
   * are instances of SummaryEvent
   * 
   * @param event
   *          History event
   * @throws IOException
   */
  public void handleCriticalEvent(DAGHistoryEvent event) throws IOException {
    TezDAGID dagId = event.getDagID();
    String dagIdStr = "N/A";
    if (dagId != null) {
      dagIdStr = dagId.toString();
    }

    if (LOG.isDebugEnabled()) {
      LOG.debug("Handling history event" + ", eventType=" + event.getHistoryEvent().getEventType());
    }
    if (recoveryEnabled && event.getHistoryEvent().isRecoveryEvent()) {
      recoveryService.handle(event);
    }
    if (event.getHistoryEvent().isHistoryEvent()) {
      historyLoggingService.handle(event);
    }

    // TODO at some point we should look at removing this once
    // there is a UI in place
    LOG.info("[HISTORY]" + "[DAG:" + dagIdStr + "]" + "[Event:" + event.getHistoryEvent().getEventType().name() + "]"
        + ": " + event.getHistoryEvent().toString());

    // emulation <<
    /*
     * capture the execution time for tasks
     */

    boolean dag_exec_log_enabled = context.getAMConf().getBoolean(
        TezConfiguration.TEZ_GRAPHENE_EXEC_LOGGING_INFO_ENABLED,
        TezConfiguration.TEZ_GRAPHENE_EXEC_LOGGING_INFO_ENABLED_DEFAULT);
    if (!dag_exec_log_enabled)
      return;

    String dag_exec_location = context.getAMConf().get(TezConfiguration.TEZ_DIR_GRAPHENE_LOGGING_INFO,
        TezConfiguration.TEZ_DIR_GRAPHENE_LOGGING_INFO_DEFAULT);

    dag_exec_location += "/exec/";

    if (event.getHistoryEvent().getEventType().name().equals("TASK_FINISHED")) {

      // create profile directory if does not exists
      createDir(dag_exec_location);

      String location = dag_exec_location + dagIdStr + ".exe";
      FileWriter file = new FileWriter(location, true);

      TaskFinishedEvent eventFinished = (TaskFinishedEvent) event.getHistoryEvent();

      String vertexName = "";
      TezVertexID vertexID = eventFinished.getTaskID().getVertexID();
      vertexName = this.context.getCurrentDAG().getVertex(vertexID).getName();

      if (taskIdxPerVertex.get(vertexName) == null)
        taskIdxPerVertex.put(vertexName, 1);
      else {
        int count = taskIdxPerVertex.get(vertexName);
        taskIdxPerVertex.put(vertexName, count + 1);
      }

      String dagName = "";
      ResourceProfile actualResProfile = null;
      if (context.getCurrentDAG() != null) {
        actualResProfile = context.getCurrentDAG().getProfile().getVertexTaskResourceRequirements(vertexName);
        dagName = context.getCurrentDAG().getProfile().getDAGName();
      }

      boolean node_local = event.getHistoryEvent().toString().contains("DATA_LOCAL_TASKS") ? true : false;

      if (actualResProfile != null) {
        double duration = actualResProfile.getDuration();
        double cpu = actualResProfile.getCpuUsage();
        double mem = actualResProfile.getMemUsage();
        double in_nw = actualResProfile.getInNetworkUsage();
        double out_nw = actualResProfile.getOutNetworkUsage();
        double in_st = actualResProfile.getInStorageUsage();
        double out_st = actualResProfile.getOutStorageUsage();
        // if (node_local) {
        // in_nw = 0; out_nw = 0.1;
        // }
        // else {
        // out_st = 0; out_nw = 0.1;
        // }

        file.write(vertexName + "_" + taskIdxPerVertex.get(vertexName) + "," + eventFinished.getStartTime() + ","
            + eventFinished.getFinishTime() + "," + duration + "," + cpu + "," + mem + "," + in_nw + "," + out_nw + ","
            + in_st + "," + out_st + "," + node_local + "," + dagName + "\n");
      } else
        file.write(vertexName + "_" + taskIdxPerVertex.get(vertexName) + "," + eventFinished.getStartTime() + ","
            + eventFinished.getFinishTime() + "\n");

      file.flush();
      file.close();
    }
    // emulation >>
  }

  // emulation <<
  public void createDir(String location) {

    File dir = new File(location);
    if (!dir.exists()) {
      LOG.info(" creating directory: " + location);
      dir.mkdirs();
    }

  }
  // emulation >>
  
  public void handle(DAGHistoryEvent event) {
    try {
      handleCriticalEvent(event);
    } catch (IOException e) {
      LOG.warn("Failed to handle recovery event" + ", eventType=" + event.getHistoryEvent().getEventType(), e);
    }
  }

  public boolean hasRecoveryFailed() {
    if (recoveryEnabled) {
      return recoveryService.hasRecoveryFailed();
    } else {
      return false;
    }
  }

}
