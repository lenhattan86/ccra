package org.apache.tez.examples;
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


import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Hashtable;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.ToolRunner;
import org.apache.hadoop.yarn.api.records.Resource;
import org.apache.tez.client.TezClient;
import org.apache.tez.dag.api.DAG;
import org.apache.tez.dag.api.Edge;
import org.apache.tez.dag.api.EdgeProperty;
import org.apache.tez.dag.api.ProcessorDescriptor;
import org.apache.tez.dag.api.TezConfiguration;
import org.apache.tez.dag.api.UserPayload;
import org.apache.tez.dag.api.Vertex;
import org.apache.tez.dag.api.EdgeProperty.DataMovementType;
import org.apache.tez.dag.api.EdgeProperty.DataSourceType;
import org.apache.tez.dag.api.EdgeProperty.SchedulingType;
import org.apache.tez.emulation.DumpInput;
import org.apache.tez.emulation.DumpOutput;
import org.apache.tez.emulation.DumpProcessor;
import org.apache.tez.emulation.Emulation;
import org.apache.tez.mapreduce.output.MROutput;
import org.apache.tez.mapreduce.processor.SimpleMRProcessor;
import org.apache.tez.runtime.api.ProcessorContext;

import com.google.common.base.Preconditions;

public class DumpJob extends TezExampleBase {

  private static final Logger LOG = LoggerFactory.getLogger(DumpJob.class);

  public static void main(String[] args) throws Exception {
    DumpJob dataGen = new DumpJob();
    int status = ToolRunner.run(new Configuration(), dataGen, args);
    System.exit(status);
  }

  @Override
  protected void printUsage() {
    System.err
        .println("Usage: "
            + "dumpjob <dagId> <queueName>");
    ToolRunner.printGenericCommandUsage(System.err);
  }

  @Override
  protected int runJob(String[] args, TezConfiguration tezConf,
      TezClient tezClient) throws Exception {
    String dagId = args[0];
    String queueName = args[1];
    getConf().set("mapreduce.job.queuename", queueName);
    getConf().set("tez.queue.name", queueName);
    tezConf.set(TezConfiguration.TEZ_QUEUE_NAME, queueName);
    
    
    LOG.info("\t +++ Running ==== "+dagId +" ====");
   
    DAG dag = createDag(tezConf, dagId);
    
    return runDag(dag, isCountersLog(), LOG);
  }

  @Override
  protected int validateArgs(String[] otherArgs) {
    if (otherArgs.length != 2) {
      return 2;
    }
    return 0;
  }

  private DAG createDag(TezConfiguration tezConf, String dagId)
      throws IOException {
    DAG dag = DAG.create(dagId);
    return dag;
  }
  

  public static class GenDataProcessor extends SimpleMRProcessor {

    private static final Logger LOG = LoggerFactory.getLogger(GenDataProcessor.class);

    long streamOutputFileSize;
    long hashOutputFileSize;
    float overlapApprox = 0.2f;

    public GenDataProcessor(ProcessorContext context) {
      super(context);
    }

    public static byte[] createConfiguration(long streamOutputFileSize)
        throws IOException {
      ByteArrayOutputStream bos = new ByteArrayOutputStream();
      DataOutputStream dos = new DataOutputStream(bos);
      dos.writeLong(streamOutputFileSize);
      dos.close();
      bos.close();
      return bos.toByteArray();
    }

    @Override
    public void initialize() throws Exception {
      byte[] payload = getContext().getUserPayload().deepCopyAsArray();
      ByteArrayInputStream bis = new ByteArrayInputStream(payload);
      DataInputStream dis = new DataInputStream(bis);
      streamOutputFileSize = dis.readLong();
      dis.close();
      bis.close();
      LOG.info(getContext().getDAGName()+"."+getContext().getTaskVertexName());
    }

    @Override
    public void run() throws Exception {
    }
  }
}
