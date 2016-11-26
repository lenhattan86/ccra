package org.apache.tez.dag.profiler;

import java.io.FileWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.tez.dag.api.TezConfiguration;
import org.apache.tez.dag.api.records.DAGProtos.EdgePlan;


/*
 * class which creates a DAG file for simulator
 * from the real query
 * */
public class DAGSimulation {

	DAGProfiler dag_profiler = null;
	
	int idxVertex = 0;
	int num_tasks = 0;
	
	// vertices who finished assigning tasks
	HashMap<String, Boolean> verticesReady = new HashMap<String, Boolean>();
	
	// vertices maps with core info
	HashMap<String, HashMap<Integer, ArrayList<Double>>> tasksInAVertex = 
								new HashMap<String, HashMap<Integer, ArrayList<Double>>>();
	
	// vertex - [# tasks, idx_start, idx_end, current_task]
	HashMap<String, Set<String>> childrenVertices = new HashMap<String, Set<String>>();
	
	// keep track of start/end index for a task in a vertex
	HashMap<String, ArrayList<Integer>> tasksIdsVertex = new HashMap<String, ArrayList<Integer>>();
	
	// keep track for every edge its movement type
	// src_node -> dst_node : data_movement_type
	HashMap<String, HashMap<String, String>> dataMovements = new HashMap<String, HashMap<String, String>>();
	
	static final Log LOG = LogFactory.getLog(DAGSimulation.class);
	
	public DAGSimulation(DAGProfiler dagProfile) {
		
		LOG.info("[Tan] create DAGSimulation");
		
		dag_profiler = dagProfile;
		
		childrenVertices = dagProfile.children;
	}
	

	public void addEntryTasksVertex(String vertexName, int numTasks) {				
		
		LOG.info("[Tan] addEntryTasksVertex");
		
		if ( tasksIdsVertex.get(vertexName) == null ) {
			tasksIdsVertex.put(vertexName, new ArrayList<Integer>());
			
			tasksIdsVertex.get(vertexName).add(numTasks);
			tasksIdsVertex.get(vertexName).add(idxVertex);
			idxVertex += numTasks;
			tasksIdsVertex.get(vertexName).add(idxVertex-1);
			
			num_tasks += numTasks;
			
			int c_task = tasksIdsVertex.get(vertexName).get(1);
			tasksIdsVertex.get(vertexName).add(c_task);
		}
		
		if (tasksInAVertex.get(vertexName) == null) {
			tasksInAVertex.put(vertexName, new HashMap<Integer, ArrayList<Double>>());
			
			for (int i = tasksIdsVertex.get(vertexName).get(1); i <= tasksIdsVertex.get(vertexName).get(2); i++) {
				tasksInAVertex.get(vertexName).put(i, new ArrayList<Double>());
			}
				
		}		
	}
	
	public int computeNumberEdges() {
				
		int num_edges = 0;
		
		for (String vertex : childrenVertices.keySet()) {
			
			int num_nodes_vertex = tasksInAVertex.get(vertex).keySet().size();
			
			for (String vertex_c : childrenVertices.get(vertex)) {
				
				int num_nodes_vertex_c = tasksInAVertex.get(vertex_c).keySet().size();
				num_edges += num_nodes_vertex * num_nodes_vertex_c;
			}			
		}
		
		LOG.info("[Tan] computeNumberEdges:"+num_edges);
		
		return num_edges;
		
	}
	
	public int computeNumberEdgesAtTaskLevel() {
		
		int num_edges = 0;
		
		List<EdgePlan> edgePlan = null;
		if (dag_profiler.getContext().getCurrentDAG() != null) 
			edgePlan = dag_profiler.getContext().getCurrentDAG().getJobPlan().getEdgeList();
			
		if (edgePlan == null) {
			LOG.info("[Tan] - NO JOB PLAN YET -> CRASH !!!!");
			return -1;
		}
			
			
		for (String vertex : childrenVertices.keySet()) {
			
			int num_nodes_vertex = tasksInAVertex.get(vertex).keySet().size();
			
			for (String vertex_c : childrenVertices.get(vertex)) {
				String dataMovementType = "Nothing";
				
				int num_nodes_vertex_c = tasksInAVertex.get(vertex_c).keySet().size();
				
				for (EdgePlan edge : edgePlan) {
					if (edge.getInputVertexName().equals(vertex) && (edge.getOutputVertexName().equals(vertex_c))) {
						dataMovementType = edge.getDataMovementType().name().trim();
						
						if (!dataMovements.containsKey(vertex))
							dataMovements.put(vertex, new HashMap<String, String>());
						dataMovements.get(vertex).put(vertex_c, dataMovementType);						
						break;
					}						
				}
				
				if (dataMovementType.equals("SCATTER_GATHER")) {
					
					num_edges += Math.max(num_nodes_vertex, num_nodes_vertex_c);
				}
				else if (dataMovementType.equals("BROADCAST")) {
					
					
					num_edges += num_nodes_vertex * num_nodes_vertex_c;
				}
				else if (dataMovementType.equals("ONE_TO_ONE")) {
					num_edges += num_nodes_vertex;
				}
				else {
					LOG.error("[Tan] SHOULD NOT HAPPEN ANYTIME !!!");
				}
			}			
		}
		
		return num_edges;
	}
	
	public void addTaskInformation(String vertexName, 
			double dur, 
			double cpu,
			double mem,
			double in_nw,
			double out_nw,
			double in_st,
			double out_st) {
		
		LOG.info("[Tan] addTaskInformation: "+dur+" "+cpu+" "+mem+" "+in_nw+" "+out_nw+" "+in_st+" "+out_st);
		
		int c_task = -1;
		if ( tasksIdsVertex.get(vertexName) != null ) {
			
			c_task = tasksIdsVertex.get(vertexName).get(3);			
			int l_idx_task = tasksIdsVertex.get(vertexName).get(2);
			
			if (c_task == l_idx_task)
				verticesReady.put(vertexName, true);
			
			if (tasksInAVertex.get(vertexName).get(c_task) != null) {
				
				tasksInAVertex.get(vertexName).get(c_task).add(dur);
				tasksInAVertex.get(vertexName).get(c_task).add(cpu);
				tasksInAVertex.get(vertexName).get(c_task).add(mem);
				tasksInAVertex.get(vertexName).get(c_task).add(in_nw);
				tasksInAVertex.get(vertexName).get(c_task).add(out_nw);
				tasksInAVertex.get(vertexName).get(c_task).add(in_st);
				tasksInAVertex.get(vertexName).get(c_task).add(out_st);
				
				c_task++;
				
				if (c_task > l_idx_task)
					c_task = l_idx_task;					
				
				tasksIdsVertex.get(vertexName).set(3, c_task);								
			}			
		} 
		
		LOG.info("[Tan] verticesRead  ="+verticesReady.keySet().size());
		LOG.info("[Tan] tasksIdsVertex="+tasksIdsVertex.keySet().size());
		
		if (verticesReady.keySet().size() == tasksIdsVertex.keySet().size())
			writeDAGToFile();	
	}	
	
	
	int min(Set<Integer> elems) {
	
		Integer min_elem = Integer.MAX_VALUE;
		
		for (Integer elem : elems) {
			if (elem < min_elem)
				min_elem = elem;
		}		
		return min_elem;
	}
	
	int max(Set<Integer> elems) {
		
		Integer max_elem = Integer.MIN_VALUE;
		
		for (Integer elem : elems) {
			if (elem > max_elem)
				max_elem = elem;
		}		
		return max_elem;
	}
	
	/* write the DAG to file at stage level */
	public void writeDAGToFileStageLevel()
	{
		LOG.info("[Tan] write DAG to file stage level");
		
		String dag_simulation_location = dag_profiler.getContext().getAMConf()
				 .get(TezConfiguration.TEZ_DIR_GRAPHENE_LOGGING_INFO,
					  TezConfiguration.TEZ_DIR_GRAPHENE_LOGGING_INFO_DEFAULT);

		dag_simulation_location += "/simulation/";

		dag_profiler.createDir(dag_simulation_location);
		String location = dag_simulation_location + dag_profiler.dagName + ".sim_stage";
		
		try {
			FileWriter file = new FileWriter(location);
			file.write("#query "+dag_profiler.dagName+"\n");
			file.write("# stages ");
			file.write(tasksInAVertex.keySet().size()+" "+1+"\n");
			for (String vertex : tasksInAVertex.keySet()) {
				String msg = "";
				ArrayList<Double> res_demands = tasksInAVertex.get(vertex).values().iterator().next();
				for (int i=0; i < res_demands.size(); ++i) {
					msg += res_demands.get(i)+" ";
				}
				msg += tasksInAVertex.get(vertex).values().size();
				//msg = tasksIdsVertex.get(vertex).get(0).toString();
				file.write(vertex.split(" ")[0]+vertex.split(" ")[1]+" "+msg+"\n");
			}
						
			file.write("# edges ");
			// count edges
			int num_edges = 0;
			for (String vertex : dataMovements.keySet()) {
				num_edges += dataMovements.get(vertex).keySet().size();
			}
			file.write(num_edges+"\n");
			
			for (String vertex : dataMovements.keySet()) {
				
				for (String vertex_dst : dataMovements.get(vertex).keySet()) {
					String msg = vertex.split(" ")[0]+vertex.split(" ")[1] + " "+vertex_dst.split(" ")[0]+vertex_dst.split(" ")[1]+" ";
					
					String data_type = dataMovements.get(vertex).get(vertex_dst);
					if (data_type.equals("SCATTER_GATHER"))
						msg += "scg";
					else if (data_type.equals("BROADCAST"))
						msg += "ata";
					else if (data_type.equals("ONE_TO_ONE"))
						msg += "oto";
					
					file.write(msg+"\n");
				}
			}
						
			file.close();
			
		} catch (Exception e) {
			e.printStackTrace();
		}	
	}
	
	/* write DAG to file at stage level */
	/*
	public void writeDAGToFileStageLevel() {
		
		LOG.info("[Tan] writeDAGToFileStageLevel");
		
		String dag_simulation_location = dag_profiler.getContext().getAMConf()
													 .get(TezConfiguration.TEZ_DIR_GRAPHENE_LOGGING_INFO,
														  TezConfiguration.TEZ_DIR_GRAPHENE_LOGGING_INFO_DEFAULT);
						
		dag_simulation_location += "/simulation/";
				
		dag_profiler.createDir(dag_simulation_location);
									
		String location = dag_simulation_location + dag_profiler.dagName + "_stage.txt"; 
		
		try {
			FileWriter file = new FileWriter(location);
			file.write("# query "+dag_profiler.dagName+"\n");
			file.write(num_tasks+" "+1+"\n");
			file.write("# tasks\n");
			for (String vertex : tasksInAVertex.keySet()) {
				
				int min_idx = min(tasksInAVertex.get(vertex).keySet());
				int max_idx = max(tasksInAVertex.get(vertex).keySet());
				int num_tasks = tasksInAVertex.get(vertex).keySet().size();
				
				file.write(vertex+" "+min_idx+" "+max_idx+" "+num_tasks+"\n");			
			}
			file.write("# edges\n");
			for (String vertex : childrenVertices.keySet()) {
				for (String vertex_c : childrenVertices.get(vertex)) {
					file.write(vertex+" "+vertex_c+"\n");
				}
			}
			
			
			for (String vertex : tasksInAVertex.keySet()) {
			
				for (Integer task : tasksInAVertex.get(vertex).keySet()) {
					
					String task_entry = "";
					task_entry += task;
					
					for (Double task_e : tasksInAVertex.get(vertex).get(task)) {
						task_entry += " ";
						task_entry += task_e;
					}					
					file.write(task_entry+"\n");
				}
			}
			file.write("# edges\n");
			
			int num_edges = computeNumberEdges();
			file.write(num_edges+"\n");
			
			for (String vertex : childrenVertices.keySet()) {
				
				for (Integer task_id : tasksInAVertex.get(vertex).keySet()) {
					
					for (String vertex_c : childrenVertices.get(vertex)) {
						for (Integer task_id_c : tasksInAVertex.get(vertex_c).keySet())
							file.write(task_id+" "+task_id_c+"\n");
					}
				}
			}
			
			
			file.close();
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
	*/
	
	public void writeDAGToFile() {
		
		//LOG.info("[Tan] -- writeDAGToFile --");
		
		String dag_simulation_location = dag_profiler.getContext().getAMConf()
													 .get(TezConfiguration.TEZ_DIR_GRAPHENE_LOGGING_INFO,
														  TezConfiguration.TEZ_DIR_GRAPHENE_LOGGING_INFO_DEFAULT);
						
		dag_simulation_location += "/simulation/";
				
		dag_profiler.createDir(dag_simulation_location);
									
		String location = dag_simulation_location + dag_profiler.dagName + ".sim"; 
		
		try {
			FileWriter file = new FileWriter(location);
			
			// write antet with number of vertices and info per vertex
			// helping to decode which task from which vertex it is											
			file.write("# query "+dag_profiler.dagName+"\n");
			for (String vertex : tasksIdsVertex.keySet()) {
				file.write("# profile:"+vertex+";"+tasksIdsVertex.get(vertex).get(1)+";"+tasksIdsVertex.get(vertex).get(2)+"\n");
			}
			file.write(num_tasks+" "+1+"\n");
			file.write("# tasks\n");
			for (String vertex : tasksInAVertex.keySet()) {
			
				for (Integer task : tasksInAVertex.get(vertex).keySet()) {
					
					String task_entry = "";
					task_entry += task;
					
					for (Double task_e : tasksInAVertex.get(vertex).get(task)) {
						task_entry += " ";
						task_entry += task_e;
					}					
					file.write(task_entry+"\n");
				}
			}
			file.write("# edges\n");
			
			int num_edges = computeNumberEdgesAtTaskLevel();
			file.write(num_edges+"\n");
			
			//LOG.info("[Tan] - NUMBER OF EDGES = "+num_edges);
			
			// now write the actual edges //
			int num_edges_real = 0;
			for (String vertex : childrenVertices.keySet()) {
				
				//LOG.info("VERTEX_START="+vertex);
				int idx_start_vertex = tasksIdsVertex.get(vertex).get(1);
				int idx_end_vertex   = tasksIdsVertex.get(vertex).get(2);
				int num_tasks_vertex = idx_end_vertex - idx_start_vertex + 1;
								
				for (String vertex_c : childrenVertices.get(vertex)) {
					
					//LOG.info("VERTEX_END="+vertex_c);
					String dataMovementType = dataMovements.get(vertex).get(vertex_c);
				
					int idx_start_vertex_c = tasksIdsVertex.get(vertex_c).get(1);
					int idx_end_vertex_c   = tasksIdsVertex.get(vertex_c).get(2);
					int num_tasks_vertex_c = idx_end_vertex_c - idx_start_vertex_c + 1;
					
					if (dataMovementType.equals("BROADCAST")) {
						
						//LOG.info("[COMMUNICATION_PATTERN] BROADCAST");
						for (int i=idx_start_vertex; i <= idx_end_vertex; i++)
							for (int j=idx_start_vertex_c; j <= idx_end_vertex_c; j++) {
								file.write(i+" "+j+"\n");
								//LOG.info("Add vertex between: "+i+"->"+j);
								num_edges_real++;
							}
					}
					else if (dataMovementType.equals("ONE_TO_ONE")) {
						// for every edge in source add one to destination
						//LOG.info("[COMMUNICATION_PATTERN] ONE_TO_ONE");
						for (int i=0; i < num_tasks_vertex; i++) {
							
							int task_idx_src = i+idx_start_vertex;
							
							int task_idx_dst = i % num_tasks_vertex_c;
							task_idx_dst += idx_start_vertex_c;							
							file.write(task_idx_src+" "+task_idx_dst+"\n");
							//LOG.info("Add vertex between: "+task_idx_src+"->"+task_idx_dst);
							num_edges_real++;
						}						
					}
					else if (dataMovementType.equals("SCATTER_GATHER")) {
						
						//LOG.info("[COMMUNICATION_PATTERN] SCATTER_GATHER");
						if (num_tasks_vertex == num_tasks_vertex_c) {
							
							//LOG.info("[COMMUNICATION_PATTERN] num_tasks_vertex("+num_tasks_vertex+") == num_tasks_vertex_c("+num_tasks_vertex_c+")");
							for (int i=0; i < num_tasks_vertex; i++) {
								file.write((i+idx_start_vertex)+" "+(i+idx_start_vertex_c)+"\n");
								//LOG.info("Add vertex between: "+(i+idx_start_vertex)+"->"+(i+idx_start_vertex_c));
								num_edges_real++;
							}
							
						}
						else if (num_tasks_vertex < num_tasks_vertex_c) {
							
							//LOG.info("[COMMUNICATION_PATTERN] num_tasks_vertex("+num_tasks_vertex+") < num_tasks_vertex_c("+num_tasks_vertex_c+")");
							int range_task_p = num_tasks_vertex_c / num_tasks_vertex;
							int index_c = idx_start_vertex_c;
							for (int i=0; i < num_tasks_vertex-1; i++) {
								
								int task_idx_p = i+idx_start_vertex;
								// every parent task points to a range of child tasks
								for (int j=0; j < range_task_p; j++) {
									
									int task_idx_c = j+index_c;
									file.write(task_idx_p+" "+task_idx_c+"\n");
									//LOG.info("Add vertex between: "+task_idx_p+"->"+task_idx_c);
									num_edges_real++;
								}
								index_c += range_task_p;								
							}
							
							// for last guy point to last group till end
							int task_idx_p = idx_end_vertex;
							for (int j=index_c; j <= idx_end_vertex_c; j++) {
								file.write(task_idx_p+" "+j+"\n");
								//LOG.info("Add vertex between: "+task_idx_p+"->"+j);
								num_edges_real++;
							}
							
						}
						else if (num_tasks_vertex > num_tasks_vertex_c) {
							
							//LOG.info("[COMMUNICATION_PATTERN] num_tasks_vertex("+num_tasks_vertex+") > num_tasks_vertex_c("+num_tasks_vertex_c+")");
							int range_task_p = num_tasks_vertex / num_tasks_vertex_c;
							int index_p = idx_start_vertex;
							for (int i=0; i < num_tasks_vertex_c; i++) {
								
								int idx_vertex_c = idx_start_vertex_c + i;
								for (int j=0; j < range_task_p; j++) {
									
									int idx_vertex_p = j + index_p;
									file.write(idx_vertex_p+" "+idx_vertex_c+"\n");
									//LOG.info("Add vertex between: "+idx_vertex_p+"->"+idx_vertex_c);
									num_edges_real++;
								}
								index_p += range_task_p;
							}
							
							// for the last guys in parent point to last node
							for (int i=index_p; i <= idx_end_vertex; i++) {
								file.write(i+" "+idx_end_vertex_c+"\n");
								//LOG.info("Add vertex between: "+i+"->"+idx_end_vertex_c);
								num_edges_real++;
							}
							
						}						
					}					
				}				
			}
			
			//LOG.info("EDGES_NUM="+num_edges+" EDGES_REAL="+num_edges_real);
			// OLD CODE //
			/*
			for (String vertex : childrenVertices.keySet()) {
				
				for (Integer task_id : tasksInAVertex.get(vertex).keySet()) {
					
					for (String vertex_c : childrenVertices.get(vertex)) {
						for (Integer task_id_c : tasksInAVertex.get(vertex_c).keySet())
							file.write(task_id+" "+task_id_c+"\n");
					}
				}
			}
			*/
			// OLD CODE //
						
			file.close();
			
			// write DAG details
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
