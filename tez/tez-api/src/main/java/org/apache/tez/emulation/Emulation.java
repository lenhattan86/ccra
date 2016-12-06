package org.apache.tez.emulation;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.util.BitSet;
import java.util.EnumSet;
import java.util.Hashtable;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.yarn.api.records.Resource;
import org.apache.tez.common.TezUtils;
import org.apache.tez.dag.api.DAG;
import org.apache.tez.dag.api.DataSourceDescriptor;
import org.apache.tez.dag.api.Edge;
import org.apache.tez.dag.api.EdgeProperty;
import org.apache.tez.dag.api.InputDescriptor;
import org.apache.tez.dag.api.InputInitializerDescriptor;
import org.apache.tez.dag.api.ProcessorDescriptor;
import org.apache.tez.dag.api.TezConfiguration;
import org.apache.tez.dag.api.UserPayload;
import org.apache.tez.dag.api.Vertex;


import org.apache.tez.dag.api.EdgeProperty.DataMovementType;
import org.apache.tez.dag.api.EdgeProperty.DataSourceType;
import org.apache.tez.dag.api.EdgeProperty.SchedulingType;
import org.apache.tez.dag.api.event.VertexState;
import org.apache.tez.dag.api.event.VertexStateUpdate;
import org.apache.tez.runtime.api.Event;
import org.apache.tez.runtime.api.InputInitializer;
import org.apache.tez.runtime.api.InputInitializerContext;
import org.apache.tez.runtime.api.events.InputInitializerEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Preconditions;

public class Emulation {

  static final Log LOG = LogFactory.getLog(Emulation.class);
//  static final Logger LOG = LoggerFactory.getLogger(Emulation.class);
  
  private final int NUM_DIMENSIONS = 2;
  private int[] nodeCapacities = { 1024 * 2, 2 };
  private double scaleResource = 1.0;
  
  public static List<DAG> dags;
  public static boolean loaded  = false;
  
  public Emulation(TezConfiguration conf){
    nodeCapacities[0] = conf.getInt(TezConfiguration.TEZ_NODE_CAPACITY_MEM,
        TezConfiguration.TEZ_NODE_CAPACITY_MEM_DEFAULT);
    nodeCapacities[1] = conf.getInt(TezConfiguration.TEZ_NODE_CAPACITY_VCORES,
        TezConfiguration.TEZ_NODE_CAPACITY_VCORES_DEFAULT);
    
    scaleResource = conf.getDouble(TezConfiguration.TEZ_RESOURCE_SCALE_DOWN,
        TezConfiguration.TEZ_RESOURCE_SCALE_DOWN_DEFAULT);
    
    boolean isSingleNode = conf.getBoolean(TezConfiguration.TEZ_RESOURCE_SINGLE_NODE,
        TezConfiguration.TEZ_RESOURCE_SINGLE_NODE_DEFAULT);
    
    if(isSingleNode){
      nodeCapacities[0] = nodeCapacities[0]- 1024;
      nodeCapacities[1] = nodeCapacities[1] - 1;
    }
    
    if(!isLoaded()){ //TODO: this one does not work.
      dags = readWorkloadTraces(conf);
      loaded = true;
    }
//    LOG.info("NODE capacity: "+nodeCapacities[0]+","+nodeCapacities[1]);
  }
  
  public synchronized boolean isLoaded(){
    return loaded;
  }

  public static Resource setResource(double[] resources, int[] nodeCapacities, double scaleResource) {
    
    if (resources == null)
      return null;
    Resource res = Resource.newInstance(0, 0);
    for (int type = 0; type < resources.length; type++) {
      int val = (int) (resources[type] * nodeCapacities[type] / scaleResource);
      switch (type) {
      case 0:
        res.setMemory(val);
        break;
      case 1:
        res.setVirtualCores(val);
        break;
      case 2:
        res.setInNetwork(val);
        break;
      case 3:
        res.setOutNetwork(val);
        break;
      case 4:
        res.setInStorage(val);
        break;
      case 5:
        res.setOutStorage(val);
        break;
      default:
        break;
      }
    }

    return res;
  }
  
  public static byte[] createConfiguration(long taskDuration)
      throws IOException {
    ByteArrayOutputStream bos = new ByteArrayOutputStream();
    DataOutputStream dos = new DataOutputStream(bos);
    dos.writeLong(taskDuration);
    dos.close();
    bos.close();
    return bos.toByteArray();
  }
  
  private List<DAG> readWorkloadTraces(TezConfiguration conf) {
    List<DAG> dagList = new LinkedList<DAG>();
//    LOG.info("[Tan] readWorkloadTraces");
    String traceFile = TezConfiguration.TEZ_WORKLOAD_TRACE_PATH_DEFAULT;
    if (conf!=null)
      traceFile = conf.get(TezConfiguration.TEZ_WORKLOAD_TRACE_PATH,
        TezConfiguration.TEZ_WORKLOAD_TRACE_PATH_DEFAULT);

    LOG.info("[Tan] readWorkloadTraces() traceFile=" + traceFile);

    File fr = new File(traceFile);

    if (fr.isDirectory() || !fr.exists()) {
      LOG.info("[Tan] profile not found; remains with default resource profile");
    } else {
      try {
        BufferedReader br = new BufferedReader(new FileReader(traceFile));
        String line;
        int dagsReadSoFar = 0;
        String dag_name = "";

        while ((line = br.readLine()) != null) {
          line = line.trim();
          if (line.startsWith("#")) {
            dag_name = line.split("#")[1];
            dag_name = dag_name.trim();
            continue;
          }

          int numVertices = 0, ddagId = -1, arrival = 0;
          int vIdxStart, vIdxEnd;

          String[] args = line.split(" ");
          if (args.length <= 2) LOG.info("readWorkloadTraces: Incorrect node entry");

          dagsReadSoFar += 1;
          String queueName = "default";
          if (args.length >= 2) {
            numVertices = Integer.parseInt(args[0]);
            ddagId = Integer.parseInt(args[1]);
            if (args.length >= 3) {
              arrival = Integer.parseInt(args[2]);
            }
            if (args.length >= 4) {
              queueName = args[3].trim();
            }
//            // assert (numVertices > 0);
//            // assert (ddagId >= 0);
          } else if (args.length == 1) {
            numVertices = Integer.parseInt(line);
            ddagId = dagsReadSoFar;
//            // assert (numVertices > 0);
//            // assert (ddagId >= 0);
          }

          // StageDag dag = new StageDag(ddagId, arrival);
          DAG dag = DAG.create("" + ddagId);
          // dag.numStages = numStages;
          // dag.dagName = dag_name;
          // dag.setQueueName(queueName);

          List<Vertex> vertices = new LinkedList<Vertex>();
          for (int i = 0; i < numVertices; ++i) {
            String lline = br.readLine();
            args = lline.split(" ");

            int numTasks;
            String vertexName;
            double durV;
            vertexName = args[0];
            // assert (vertexName.length() > 0);

            durV = Double.parseDouble(args[1]);
            // assert (durV >= 0);
            double[] resources = new double[NUM_DIMENSIONS];
            for (int j = 0; j < NUM_DIMENSIONS; j++) {
              double res = Double.parseDouble(args[j + 2]);
//              // assert (res >= 0 && res <= 1);
              resources[j] = res;
            }

            Resource taskResource = setResource(resources, nodeCapacities, scaleResource);

            numTasks = Integer.parseInt(args[args.length - 1]);
            numTasks = (int)(numTasks*scaleResource);
//            // assert (numTasks >= 0);
            String key = ddagId+"."+vertexName;
            UserPayload payload = UserPayload.create(ByteBuffer.wrap(createConfiguration((long) durV*1000)));
            Vertex v = Vertex.create(vertexName, DumpProcessor.getProcDesc(payload), numTasks, taskResource);
            
//            Vertex v = Vertex.create(vertexName, ProcessorDescriptor.create(
//                SleepProcessor.class.getName())
//                .setUserPayload(new SleepProcessor.SleepProcessorConfig(100000).toUserPayload()), 1)
//                .addDataSource("input1",
//                    DataSourceDescriptor
//                        .create(InputDescriptor.create(MultiAttemptDAG.NoOpInput.class.getName()),
//                            InputInitializerDescriptor.create(InputInitializerForTest.class.getName()),
//                            null));
            
            
            String arrivalStr = args[args.length - 2];
            dag.addVertex(v);
            vertices.add(v);
//            LOG.info("readWorldloadTrace: DAG:"+dag.getName() + " addVertex:"+vertices.get(vertices.size()-1).getName());
          }

          // dag.vertexToStage = new HashMap<Integer, String>();
          // for (Stage stage : dag.stages.values())
          // for (int i = stage.vids.begin; i <= stage.vids.end; i++)
          // dag.vertexToStage.put(i, stage.name);

          int numEdgesBtwStages;
          line = br.readLine();
          numEdgesBtwStages = Integer.parseInt(line);
          // assert (numEdgesBtwStages >= 0);
          // dag.numEdgesBtwStages = numEdgesBtwStages;

          for (int i = 0; i < numEdgesBtwStages; ++i) {
            args = br.readLine().split(" ");
            // assert (args.length == 3) : "Incorrect entry for edge description; [stage_src stage_dst comm_type]";

            String stage_src = args[0], stage_dst = args[1], comm_pattern = args[2];
            // assert (stage_src.length() > 0);
            // assert (stage_dst.length() > 0);
            // assert (comm_pattern.length() > 0);

            // dag.populateParentsAndChildrenStructure(stage_src, stage_dst,
            // comm_pattern);
            Vertex srcVertex = findVertex(vertices, stage_src);
            Vertex dstVertex = findVertex(vertices, stage_dst);
//            LOG.info("readWorldloadTrace: Edge:"+ srcVertex.getName() + " --> " + dstVertex.getName());
            UserPayload payload = UserPayload.create(null);
            dag.addEdge(Edge.create(srcVertex, dstVertex,
                EdgeProperty.create(DataMovementType.SCATTER_GATHER, DataSourceType.PERSISTED,
                    SchedulingType.SEQUENTIAL, DumpOutput.getOutputDesc(payload), DumpInput.getInputDesc(payload))));
          }

          dagList.add(dag);
        }
        br.close();
      } catch (Exception e) {
        System.err.println("Catch exception: " + e);
        e.printStackTrace();
      }
    }
    return dagList;
  }

  private static DAG findDag(List<DAG> dags, String dagName) {
    for (DAG d : dags) {
      if (d.getName().equals(dagName))
        return d;
    }
    return null;
  }

  private static Vertex findVertex(List<Vertex> vertices, String vertexName) {
    for (Vertex v : vertices) {
      if (v.getName().equals(vertexName))
        return v;
    }
    return null;
  }

  private DAG creatDAG(String dagName) {
    DAG dag = DAG.create(dagName);
    return dag;
  }

  // emulation <<
  public DAG createDAGFromTrace(String dagName) throws Exception {
//    List<DAG> dags = this.readWorkloadTraces(conf);
    if(dags.isEmpty())
      return null;
    
    DAG encodedDag = findDag(dags, dagName);
    
    /*if (encodedDag==null){
      encodedDag=dags.get(0);
      encodedDag.setName(dagName);
    }*/
    
    return encodedDag;
  }

  public DAG creatSimpleDAG(DAG dag, TezConfiguration conf) throws Exception {
    String name = dag.getName();
    UserPayload payload = UserPayload.create(null);
    int TEZ_SIMPLE_DAG_NUM_TASKS_DEFAULT = 2;
    String TEZ_SIMPLE_DAG_NUM_TASKS = "tez.simple-test-dag.num-tasks";
    Resource defaultResource = Resource.newInstance(100, 0);

    int taskCount = TEZ_SIMPLE_DAG_NUM_TASKS_DEFAULT;
    if (conf != null) {
      taskCount = conf.getInt(TEZ_SIMPLE_DAG_NUM_TASKS, TEZ_SIMPLE_DAG_NUM_TASKS_DEFAULT);
      payload = TezUtils.createUserPayloadFromConf(conf);
    }
    DAG encodedDag = DAG.create(name);

    Vertex v1 = Vertex.create("v1", SimpleProcessor.getProcDesc(payload), taskCount, defaultResource);
    Vertex v2 = Vertex.create("v2", SimpleProcessor.getProcDesc(payload), taskCount, defaultResource);
    Vertex v3 = Vertex.create("v3", SimpleProcessor.getProcDesc(payload), taskCount, defaultResource);
    Vertex v4 = Vertex.create("v4", SimpleProcessor.getProcDesc(payload), taskCount, defaultResource);
    Vertex v5 = Vertex.create("v5", SimpleProcessor.getProcDesc(payload), taskCount, defaultResource);
    Vertex v6 = Vertex.create("v6", SimpleProcessor.getProcDesc(payload), taskCount, defaultResource);

    // add vertex not in the topological order, since we are using this dag for
    // testing vertex topological order
    encodedDag.addVertex(v4).addVertex(v5).addVertex(v6).addVertex(v1).addVertex(v2).addVertex(v3)
        .addEdge(Edge.create(v1, v3,
            EdgeProperty.create(DataMovementType.SCATTER_GATHER, DataSourceType.PERSISTED, SchedulingType.SEQUENTIAL,
                SimpleOutput.getOutputDesc(payload), SimpleInput.getInputDesc(payload))))
        .addEdge(Edge.create(v2, v3,
            EdgeProperty.create(DataMovementType.SCATTER_GATHER, DataSourceType.PERSISTED, SchedulingType.SEQUENTIAL,
                SimpleOutput.getOutputDesc(payload), SimpleInput.getInputDesc(payload))))
        .addEdge(Edge.create(v3, v4,
            EdgeProperty.create(DataMovementType.SCATTER_GATHER, DataSourceType.PERSISTED, SchedulingType.SEQUENTIAL,
                SimpleOutput.getOutputDesc(payload), SimpleInput.getInputDesc(payload))))
        .addEdge(Edge.create(v3, v5,
            EdgeProperty.create(DataMovementType.SCATTER_GATHER, DataSourceType.PERSISTED, SchedulingType.SEQUENTIAL,
                SimpleOutput.getOutputDesc(payload), SimpleInput.getInputDesc(payload))))
        .addEdge(Edge.create(v4, v6,
            EdgeProperty.create(DataMovementType.SCATTER_GATHER, DataSourceType.PERSISTED, SchedulingType.SEQUENTIAL,
                SimpleOutput.getOutputDesc(payload), SimpleInput.getInputDesc(payload))))
        .addEdge(Edge.create(v5, v6, EdgeProperty.create(DataMovementType.SCATTER_GATHER, DataSourceType.PERSISTED,
            SchedulingType.SEQUENTIAL, SimpleOutput.getOutputDesc(payload), SimpleInput.getInputDesc(payload))));

    return encodedDag;
  }
  
  private static final String VERTEX_WITH_INITIALIZER_NAME = "VertexWithInitializer";
  private static final String EVENT_GENERATING_VERTEX_NAME = "EventGeneratingVertex";
  
  public static class InputInitializerForTest extends InputInitializer {

    private final ReentrantLock lock = new ReentrantLock();
    private final Condition condition = lock.newCondition();
    private final BitSet eventsSeen = new BitSet();

    public InputInitializerForTest(
        InputInitializerContext initializerContext) {
      super(initializerContext);
      getContext().registerForVertexStateUpdates(EVENT_GENERATING_VERTEX_NAME, EnumSet.of(
          VertexState.SUCCEEDED));
    }

    @Override
    public List<Event> initialize() throws Exception {
      lock.lock();
      try {
        condition.await();
      } finally {
        lock.unlock();
      }
      return null;
    }


    @Override
    public void handleInputInitializerEvent(List<InputInitializerEvent> events) throws Exception {
      lock.lock();
      try {
        for (InputInitializerEvent event : events) {
          Preconditions.checkArgument(
              event.getSourceVertexName().equals(EVENT_GENERATING_VERTEX_NAME));
          int index = event.getUserPayload().getInt(0);
          Preconditions.checkState(!eventsSeen.get(index));
          eventsSeen.set(index);
        }
      } finally {
        lock.unlock();
      }
    }

    @Override
    public void onVertexStateUpdated(VertexStateUpdate stateUpdate) {
      lock.lock();
      try {
        Preconditions.checkArgument(stateUpdate.getVertexState() == VertexState.SUCCEEDED);
        if (eventsSeen.cardinality() ==
            getContext().getVertexNumTasks(EVENT_GENERATING_VERTEX_NAME)) {
          condition.signal();
        } else {
          throw new IllegalStateException(
              "Received VertexState SUCCEEDED before receiving all InputInitializerEvents");
        }
      } finally {
        lock.unlock();
      }
    }
  }
}

