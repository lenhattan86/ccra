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

package org.apache.tez.emulation;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.nio.ByteBuffer;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.tez.runtime.api.TaskFailureType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.tez.common.TezUtils;
import org.apache.tez.dag.api.ProcessorDescriptor;
import org.apache.tez.dag.api.TezConfiguration;
import org.apache.tez.dag.api.UserPayload;
import org.apache.tez.runtime.api.AbstractLogicalIOProcessor;
import org.apache.tez.runtime.api.Event;
import org.apache.tez.runtime.api.LogicalInput;
import org.apache.tez.runtime.api.LogicalOutput;
import org.apache.tez.runtime.api.ProcessorContext;

import com.google.common.base.Charsets;
import com.google.common.collect.Sets;

/**
 * LogicalIOProcessor used to write tests. Supports fault injection through
 * configuration. The configuration is post-fixed by the name of the vertex for
 * this processor. The fault injection executes in the run() method. The
 * processor first sleeps for a specified interval. Then checks if it needs to
 * fail. It fails and exits if configured to do so. If not, then it calls
 * doRead() on all inputs to let them fail.
 */
public class DumpProcessor extends AbstractLogicalIOProcessor {
//  private static final Logger LOG = LoggerFactory
//      .getLogger(DumpProcessor.class);
  static final Log LOG = LogFactory.getLog(DumpProcessor.class);
  long taskDuration = 0;
  
  public DumpProcessor(ProcessorContext context) {
    super(context);
  }

  public static ProcessorDescriptor getProcDesc(UserPayload payload) {
    ProcessorDescriptor pd = ProcessorDescriptor.create(DumpProcessor.class.getName()).setUserPayload(
        payload == null ? UserPayload.create(null) : payload);
    return pd;
  }
  
  void throwException(String msg) {
    RuntimeException e = new RuntimeException(msg);
    getContext().reportFailure(TaskFailureType.NON_FATAL, e , msg);
    throw e;
  }

  public static String getVertexConfName(String confName, String vertexName) {
    return confName + "." + vertexName;
  }
  
  public static String getVertexConfName(String confName, String vertexName,
      int taskIndex) {
    return confName + "." + vertexName + "." + String.valueOf(taskIndex);
  }
  
  @Override
  public void initialize() throws Exception {
    byte[] payload = getContext().getUserPayload().deepCopyAsArray();
    ByteArrayInputStream bis = new ByteArrayInputStream(payload);
    DataInputStream dis = new DataInputStream(bis);
    this.taskDuration = dis.readLong();
    dis.close();
    bis.close();
  }

  @Override
  public void handleEvents(List<Event> processorEvents) {
  }

  @Override
  public void close() throws Exception {
  }

  @Override
  public void run(Map<String, LogicalInput> inputs,
      Map<String, LogicalOutput> outputs) throws Exception {
    Thread.sleep(taskDuration);
  }
  
  private static void spin(long seconds) {
    long sleepTime = seconds*1000000000L; // convert to nanoseconds
    long startTime = System.nanoTime();
    while ((System.nanoTime() - startTime) < sleepTime) {}
  }
}
