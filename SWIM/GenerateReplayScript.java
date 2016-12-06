import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.File;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Random;

import sun.security.util.Length;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.text.SimpleDateFormat;

public class GenerateReplayScript {

  static final int[] MAP_VCORES = { 4, 5, 1, 4, 5, 6, 3, 2, 6, 2, 7, 3, 5, 6, 6,
      4, 4, 5, 6, 1, 6, 2, 3, 4, 5, 4, 3, 6, 6, 6, 6, 7, 4, 6, 4, 5, 4, 4, 6, 4,
      3, 2, 3, 3, 2, 5, 4, 3, 6, 3, 4, 2, 3, 1, 3, 6, 4, 2, 3, 2, 6, 3, 2, 3, 4,
      6, 5, 6, 6, 7, 5, 2, 2, 5, 1, 2, 3, 4, 5, 2, 5, 5, 2, 3, 1, 3, 5, 5, 3, 6,
      5, 2, 5, 5, 3, 3, 4, 2, 4, 4, 1, 5, 6, 6, 1, 1, 3, 2, 1, 5, 1, 5, 3, 4, 4,
      5, 6, 4, 5, 5, 2, 5, 7, 7, 2, 5, 6, 1, 6, 4, 5, 6, 1, 2, 6, 4, 5, 4, 3, 2,
      4, 5, 3, 5, 3, 2, 1, 7, 6, 3, 2, 3, 5, 3, 2, 6, 3, 3, 5, 1, 6, 6, 6, 5, 4,
      2, 3, 2, 5, 1, 6, 4, 3, 7, 3, 2, 6, 3, 2, 3, 3, 3, 3, 6, 2, 3, 2, 2, 4, 4,
      7, 3, 5, 1, 5, 3, 7, 5, 5, 6 };
  static final int[] MAP_MEM = { 3072, 2048, 1024, 1024, 3072, 3072, 2048, 1024,
      2048, 2048, 3072, 3072, 2048, 3072, 2048, 3072, 2048, 2048, 2048, 1024,
      2048, 2048, 3072, 1024, 3072, 2048, 3072, 1024, 3072, 1024, 1024, 2048,
      3072, 2048, 2048, 2048, 2048, 3072, 2048, 1024, 1024, 1024, 2048, 3072,
      2048, 3072, 1024, 1024, 3072, 2048, 2048, 1024, 2048, 3072, 2048, 2048,
      2048, 2048, 2048, 2048, 2048, 1024, 3072, 1024, 2048, 3072, 2048, 2048,
      3072, 1024, 3072, 1024, 2048, 1024, 3072, 2048, 2048, 2048, 3072, 1024,
      2048, 2048, 2048, 2048, 2048, 2048, 1024, 2048, 2048, 3072, 1024, 2048,
      2048, 2048, 2048, 2048, 2048, 2048, 1024, 2048, 3072, 2048, 2048, 1024,
      2048, 2048, 2048, 2048, 2048, 2048, 1024, 3072, 3072, 1024, 1024, 3072,
      2048, 2048, 2048, 1024, 3072, 2048, 1024, 2048, 2048, 1024, 3072, 2048,
      1024, 1024, 2048, 3072, 3072, 1024, 3072, 3072, 2048, 2048, 2048, 1024,
      2048, 2048, 2048, 1024, 2048, 1024, 2048, 1024, 3072, 2048, 2048, 2048,
      2048, 1024, 2048, 2048, 2048, 3072, 3072, 2048, 2048, 1024, 2048, 3072,
      2048, 2048, 3072, 2048, 3072, 2048, 3072, 1024, 3072, 3072, 2048, 2048,
      2048, 2048, 1024, 1024, 2048, 2048, 2048, 1024, 1024, 1024, 1024, 1024,
      2048, 2048, 2048, 2048, 2048, 2048, 3072, 2048, 2048, 2048, 3072, 2048 };
  static final int[] RED_VCORES = { 4, 3, 6, 4, 1, 4, 5, 5, 3, 6, 1, 2, 3, 2, 3,
      4, 3, 6, 4, 5, 3, 3, 1, 1, 4, 5, 5, 6, 2, 4, 3, 2, 3, 5, 4, 6, 2, 4, 3, 6,
      5, 6, 1, 3, 6, 3, 5, 4, 2, 5, 4, 2, 6, 2, 1, 3, 4, 5, 3, 3, 2, 5, 2, 3, 1,
      4, 2, 4, 2, 3, 2, 6, 3, 4, 2, 3, 4, 2, 6, 1, 1, 2, 5, 5, 6, 7, 3, 4, 2, 2,
      3, 4, 6, 5, 1, 6, 4, 1, 4, 6, 1, 4, 2, 6, 6, 7, 4, 3, 3, 4, 5, 3, 4, 2, 6,
      4, 4, 3, 3, 3, 4, 5, 3, 3, 6, 2, 5, 3, 2, 2, 2, 4, 1, 1, 2, 6, 2, 4, 5, 2,
      2, 4, 5, 3, 3, 2, 3, 3, 4, 4, 2, 4, 3, 3, 6, 5, 1, 5, 3, 4, 2, 2, 2, 3, 5,
      5, 1, 3, 5, 4, 7, 6, 4, 3, 1, 3, 5, 4, 3, 3, 5, 4, 5, 5, 2, 5, 2, 3, 2, 6,
      4, 4, 6, 5, 7, 6, 2, 1, 5, 4 };
  static final int[] RED_MEM = { 2048, 7168, 3072, 4096, 2048, 5120, 5120, 4096,
      2048, 7168, 6144, 6144, 5120, 3072, 4096, 5120, 4096, 6144, 3072, 4096,
      3072, 4096, 5120, 2048, 6144, 5120, 3072, 7168, 5120, 3072, 1024, 7168,
      7168, 1024, 3072, 1024, 4096, 2048, 6144, 2048, 5120, 2048, 4096, 3072,
      3072, 4096, 2048, 1024, 6144, 5120, 6144, 5120, 4096, 2048, 5120, 5120,
      2048, 2048, 5120, 7168, 5120, 2048, 3072, 4096, 1024, 3072, 6144, 4096,
      6144, 3072, 4096, 3072, 5120, 4096, 4096, 2048, 3072, 4096, 4096, 3072,
      5120, 3072, 3072, 7168, 1024, 1024, 3072, 6144, 3072, 4096, 3072, 4096,
      3072, 7168, 6144, 5120, 7168, 5120, 2048, 5120, 3072, 3072, 1024, 2048,
      7168, 5120, 2048, 5120, 6144, 4096, 6144, 2048, 4096, 1024, 4096, 5120,
      6144, 6144, 6144, 1024, 3072, 5120, 2048, 5120, 2048, 2048, 6144, 1024,
      3072, 5120, 2048, 2048, 3072, 7168, 4096, 2048, 5120, 6144, 1024, 5120,
      7168, 2048, 5120, 2048, 6144, 5120, 3072, 6144, 6144, 5120, 3072, 4096,
      2048, 6144, 2048, 3072, 3072, 3072, 6144, 2048, 3072, 3072, 3072, 3072,
      3072, 5120, 5120, 6144, 1024, 2048, 3072, 3072, 2048, 2048, 5120, 4096,
      2048, 2048, 6144, 4096, 6144, 2048, 5120, 7168, 4096, 5120, 5120, 4096,
      5120, 1024, 2048, 2048, 2048, 5120, 5120, 4096, 6144, 3072, 2048, 6144 };

  /*
   * Workload file format constants for field indices
   */
  static final int INTER_JOB_SLEEP_TIME = 2;
  static final int INPUT_DATA_SIZE = 3;
  static final int SHUFFLE_DATA_SIZE = 4;
  static final int OUTPUT_DATA_SIZE = 5;

  static final int NUM_CP_NODES = 8;
  static final int[] failedNodes = {};
  private static final boolean ENABLE_ARRIVAL_TRACES = false;

  private static final int BURSTY_CPU = 3;
  private static final int BURSTY_MEM = 5 * 1024;

  public static boolean isFailed(int node) {
    boolean res = false;
    for (int i = 0; i < failedNodes.length; i++)
      if (node == failedNodes[i])
        return true;
    return res;
  }

  public static String cleanYarnLogFiles(int numComputeNodes) {

    String servers = "ctl ";
    int idx = 0;
    for (int i = 1; i <= numComputeNodes; i++) {
      idx++;
      if (isFailed(idx))
        idx++;
      servers += " cp-" + idx;
    }

    String str = "serverList=\"" + servers + "\" \n";
    str += "for server in $serverList; do  \n";
    str += "    ssh $server \"sudo rm -rf /dev/yarn-logs/* \" & \n";
    str += "done \n";
    str += " \n";

    return str;
  }

  /*
   *
   * Parses a tab separated file into an ArrayList<ArrayList<String>>
   *
   */
  public static long parseFileArrayList(String path,
      ArrayList<ArrayList<String>> data) throws Exception {

    long maxInput = 0;

    BufferedReader input = new BufferedReader(new FileReader(path));
    String s;
    String[] array;
    int rowIndex = 0;
    int columnIndex = 0;
    while (true) {
      if (!input.ready())
        break;
      s = input.readLine();
      array = s.split("\t");
      try {
        columnIndex = 0;
        while (columnIndex < array.length) {
          if (columnIndex == 0) {
            data.add(rowIndex, new ArrayList<String>());
          }
          String value = array[columnIndex];
          data.get(rowIndex).add(value);

          if (Long.parseLong(array[INPUT_DATA_SIZE]) > maxInput) {
            maxInput = Long.parseLong(array[INPUT_DATA_SIZE]);
          }

          columnIndex++;
        }
        rowIndex++;
      } catch (Exception e) {

      }
    }

    return maxInput;

  }

  public static void printTezBatchUsingTraces(ArrayList<String> dagIds,
      String scriptDirPath, String workloadOutputDir, String hadoopCommand,
      String pathToWorkGenJar, int numBatchJob, int NUM_QUEUES)
      throws Exception {
    Random rand = new Random();
    if (dagIds.size() > 0) {
      long maxInput = 0;
      String toWrite = "";

      FileWriter runAllJobs = new FileWriter(scriptDirPath + "/batches-all.sh");

      toWrite = "#!/bin/bash\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
      // toWrite = "rm -r " + workloadOutputDir + "\n";
      // runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
      toWrite = "mkdir " + workloadOutputDir + "\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());

      int written = 0;

      if (numBatchJob < 0)
        numBatchJob = dagIds.size();

      for (int i = 0; i < numBatchJob; i++) {
        FileWriter runFile = new FileWriter(
            scriptDirPath + "/run-batch-" + i + ".sh");

        int queueIdx = i % NUM_QUEUES;
        toWrite = "cd ~/ \n";
        runFile.write(toWrite.toCharArray(), 0, toWrite.length());
        
        toWrite = "" + hadoopCommand + " jar " + pathToWorkGenJar + " "
            + dagIds.get(i) + " batch" + queueIdx + " >> " + workloadOutputDir
            + "/batch-" + i + ".txt 2>> " + workloadOutputDir + "/batch-" + i
            + ".txt ";

        toWrite += " & " + " batch" + i + "=$!  \n";
        runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        toWrite = "wait $batch" + i + " \n";
        runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        runFile.close();

        // works for linux type systems only
        Runtime.getRuntime()
            .exec("chmod +x " + scriptDirPath + "/run-batch-" + i + ".sh");

        toWrite = "./run-batch-" + i + ".sh &\n";
        runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());

        written++;
      }

      System.out.println(written + " jobs written ... done.");
      System.out.println();

      runAllJobs.close();

      // works for linux type systems only
      Runtime.getRuntime()
          .exec("chmod +x " + scriptDirPath + "/batches-all.sh");
    }
  }

  public static void printTezBurstyJobs(ArrayList<String> dagIds,
      String scriptDirPath, String workloadOutputDir, String hadoopCommand,
      String pathToWorkGenJar, int arrivalPeriod, int numInteractiveJobs,
      int NUM_QUEUES) throws Exception {

    if (dagIds.size() > 0) {

      long maxInput = 0;
      String toWrite = "";

      FileWriter runAllJobs = new FileWriter(
          scriptDirPath + "/interactives-all.sh");

      toWrite = "#!/bin/bash\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
      toWrite = "mkdir " + workloadOutputDir + "\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());

      System.out.println();
      System.out.println(dagIds.size() + " jobs in the workload.");
      System.out.println("Generating scripts ... please wait ... ");
      System.out.println();

      int written = 0;

      if (numInteractiveJobs < 0)
        numInteractiveJobs = dagIds.size();

      for (int i = 0; i < numInteractiveJobs; i++) {

        FileWriter runFile = new FileWriter(
            scriptDirPath + "/run-interactive-" + i + ".sh");
        
        toWrite = "cd ~/ \n";
        runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        for (int k = 0; k < NUM_QUEUES; k++) {
          int idx = i * NUM_QUEUES;
          toWrite = "" + hadoopCommand + " jar " +pathToWorkGenJar+  " "
              + dagIds.get(idx + k) + " bursty" + k + " >> " + workloadOutputDir
              + "/interactive-" + i + "_" + k + ".txt 2>> " + workloadOutputDir
              + "/interactive-" + i + "_" + k + ".txt ";

          toWrite += " & " + " interactive" + i + "=\"$interactive" + i
              + " $!\" " + " \n";
          runFile.write(toWrite.toCharArray(), 0, toWrite.length());
        }

        toWrite = "wait $interactive" + i + " \n";
        runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        runFile.close();

        // works for linux type systems only
        Runtime.getRuntime().exec(
            "chmod +x " + scriptDirPath + "/run-interactive-" + i + ".sh");

        toWrite = "./run-interactive-" + i + ".sh &\n";
        runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());

        if (i < numInteractiveJobs - 1) {
          toWrite = "sleep " + arrivalPeriod + "\n";
          runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
        }
        written++;
      }
      
      toWrite = "lastInteractive=$! ; \n wait $lastInteractive " + arrivalPeriod + "\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());

      System.out.println(written + " jobs written ... done.");
      System.out.println();

      runAllJobs.close();

      // works for linux type systems only
      Runtime.getRuntime()
          .exec("chmod +x " + scriptDirPath + "/interactives-all.sh");
    }
  }

  /*
   * 
   * 
   * /*
   *
   * Prints the necessary shell scripts
   *
   */
  public static void printMRBatchUsingTraces(
      ArrayList<ArrayList<String>> workloadData, int clusterSizeRaw,
      int clusterSizeWorkload, int inputPartitionSize, int inputPartitionCount,
      String scriptDirPath, String hdfsInputDir, String hdfsOutputPrefix,
      long totalDataPerReduce, String workloadOutputDir, String hadoopCommand,
      String pathToWorkGenJar, String pathToWorkGenConf, int numBatchJob,
      int NUM_QUEUES, int numMaps) throws Exception {

    Random rand = new Random();

    if (workloadData.size() > 0) {

      long maxInput = 0;
      String toWrite = "";

      FileWriter runAllJobs = new FileWriter(scriptDirPath + "/batches-all.sh");

      toWrite = "#!/bin/bash\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
      // toWrite = "rm -r " + workloadOutputDir + "\n";
      // runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
      toWrite = "mkdir " + workloadOutputDir + "\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());

      System.out.println();
      System.out.println(workloadData.size() + " jobs in the workload.");
      System.out.println("Generating scripts ... please wait ... ");
      System.out.println();

      int written = 0;

      if (numBatchJob < 0)
        numBatchJob = workloadData.size();

      for (int i = 0; i < numBatchJob; i++) {

        long sleep = Long
            .parseLong(workloadData.get(i).get(INTER_JOB_SLEEP_TIME));
        long input = Long.parseLong(workloadData.get(i).get(INPUT_DATA_SIZE));
        long shuffle = Long
            .parseLong(workloadData.get(i).get(SHUFFLE_DATA_SIZE));
        long output = Long.parseLong(workloadData.get(i).get(OUTPUT_DATA_SIZE));

        // Logic to scale sleep time such that smaller cluster = fewer
        // jobs
        // Currently not done
        //
        // sleep = sleep * clusterSizeRaw / clusterSizeWorkload;

        input = input * clusterSizeWorkload / clusterSizeRaw;
        shuffle = shuffle * clusterSizeWorkload / clusterSizeRaw;
        output = output * clusterSizeWorkload / clusterSizeRaw;

        if (input > maxInput)
          maxInput = input;
        if (input < maxSeqFile(67108864))
          input = maxSeqFile(67108864); // 64 MB minimum size

        if (shuffle < 1024)
          shuffle = 1024;
        if (output < 1024)
          output = 1024;

        ArrayList<Integer> inputPartitionSamples = new ArrayList<Integer>();
        long inputCopy = input;
        java.util.Random rng = new java.util.Random();
        int tryPartitionSample = rng.nextInt(inputPartitionCount);
        while (inputCopy > 0) {
          boolean alreadySampled = true;
          while (alreadySampled) {
            if (inputPartitionSamples.size() >= inputPartitionCount) {
              System.err.println();
              System.err.println("ERROR!");
              System.err.println("Not enough partitions for input size of "
                  + input + " bytes.");
              System.err.println("Happened on job number " + i + ".");
              System.err.println(
                  "Input partition size is " + inputPartitionSize + " bytes.");
              System.err.println(
                  "Number of partitions is " + inputPartitionCount + ".");
              System.err.println("Total data size is "
                  + (((long) inputPartitionSize) * ((long) inputPartitionCount))
                  + " bytes < " + input + " bytes.");
              System.err.println("Need to generate a larger input data set.");
              System.err.println();
              throw new Exception(
                  "Input data set not large enough. Need to generate a larger data set.");
              // if exception thrown here, input set not large
              // enough - generate bigger input set
            }
            alreadySampled = false;
          }
          inputPartitionSamples.add(new Integer(tryPartitionSample));
          tryPartitionSample = (tryPartitionSample + 1) % inputPartitionCount;
          inputCopy -= inputPartitionSize;
        }

        FileWriter inputPathFile = new FileWriter(
            scriptDirPath + "/inputPath-batch-" + i + ".txt");
        String inputPath = "";
        for (int j = 0; j < inputPartitionSamples.size(); j++) {
          inputPath = (hdfsInputDir + "/part-"
              + String.format("%05d", inputPartitionSamples.get(j)));
          if (j != (inputPartitionSamples.size() - 1))
            inputPath += ",";
          inputPathFile.write(inputPath.toCharArray(), 0, inputPath.length());
        }
        inputPathFile.close();

        // write inputPath to separate file to get around ARG_MAX limit
        // for large clusters

        inputPath = "inputPath-batch-" + i + ".txt";

        String outputPath = hdfsOutputPrefix + "-" + i;

        float SIRatio = ((float) shuffle) / ((float) input);
        float OSRatio = ((float) output) / ((float) shuffle);

        long numReduces = -1;

        FileWriter runFile = new FileWriter(
            scriptDirPath + "/run-batch-" + i + ".sh");
        // toWrite = "" + hadoopCommand + " fs -rm -r " + outputPath +
        // "\n";
        // runFile.write(toWrite.toCharArray(), 0, toWrite.length());
        int queueIdx = i % NUM_QUEUES;
        if (totalDataPerReduce > 0) {
          numReduces = Math
              .round((shuffle + output) / ((double) totalDataPerReduce));
          if (numReduces < 1)
            numReduces = 1;
          if (numReduces > clusterSizeWorkload)
            numReduces = clusterSizeWorkload / 5;
          toWrite = "" + hadoopCommand + " jar " + pathToWorkGenJar
              + " org.apache.hadoop.examples.WorkGen -conf " + pathToWorkGenConf
              + " " + "-m " + numMaps + " " + "-r " + numReduces + " "
              + inputPath + " " + outputPath + " -queue " + "batch" + queueIdx
              + " -map.vcores " + MAP_VCORES[i] + " -red.vcores "
              + RED_VCORES[i] + " -map.memory " + MAP_MEM[i] + " -red.memory "
              + RED_MEM[i] + " " + SIRatio + " " + OSRatio + " >> "
              + workloadOutputDir + "/batch-" + i + ".txt 2>> "
              + workloadOutputDir + "/batch-" + i + ".txt ";
        } else {
          toWrite = "" + hadoopCommand + " jar " + pathToWorkGenJar
              + " org.apache.hadoop.examples.WorkGen -conf " + pathToWorkGenConf
              + " " + "-m " + numMaps + " " + inputPath + " " + outputPath
              + " -queue " + "batch" + queueIdx + " -map.vcores "
              + MAP_VCORES[i] + " -red.vcores " + RED_VCORES[i]
              + " -map.memory " + MAP_MEM[i] + " -red.memory "
              + RED_MEM[queueIdx] + " " + SIRatio + " " + OSRatio + " >> "
              + workloadOutputDir + "/batch-" + queueIdx + ".txt 2>> "
              + workloadOutputDir + "/batch-" + queueIdx + ".txt ";
        }

        toWrite += " & " + " batch" + i + "=$!  \n";
        runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        toWrite = "wait $batch" + i + " \n";
        runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        toWrite = hadoopCommand + " fs -rm -r " + outputPath + "\n";
        runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        toWrite = "# inputSize " + input + "\n";
        runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        runFile.close();

        // works for linux type systems only
        Runtime.getRuntime()
            .exec("chmod +x " + scriptDirPath + "/run-batch-" + i + ".sh");

        toWrite = "./run-batch-" + i + ".sh &\n";
        runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
        if (ENABLE_ARRIVAL_TRACES) {
          toWrite = "sleep " + sleep + "\n"; // TODO: use the code for arrival
                                             // times from traces.
          runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
        }

        written++;

      }

      System.out.println(written + " jobs written ... done.");
      System.out.println();

      toWrite = "# max input " + maxInput + "\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
      toWrite = "# inputPartitionSize " + inputPartitionSize + "\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
      toWrite = "# inputPartitionCount " + inputPartitionCount + "\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());

      runAllJobs.close();

      // works for linux type systems only
      Runtime.getRuntime()
          .exec("chmod +x " + scriptDirPath + "/batches-all.sh");

    }

  }

  public static void printMRBurstyJobs(
      ArrayList<ArrayList<String>> workloadData, int clusterSizeRaw,
      int clusterSizeWorkload, int inputPartitionSize, int inputPartitionCount,
      String scriptDirPath, String hdfsInputDir, String hdfsOutputPrefix,
      long totalDataPerReduce, String workloadOutputDir, String hadoopCommand,
      String pathToWorkGenJar, String pathToWorkGenConf, int arrivalPeriod,
      int numInteractiveJobs, int NUM_QUEUES, int numMaps) throws Exception {

    hdfsOutputPrefix += "Int";

    if (workloadData.size() > 0) {

      long maxInput = 0;
      String toWrite = "";

      FileWriter runAllJobs = new FileWriter(
          scriptDirPath + "/interactives-all.sh");

      toWrite = "#!/bin/bash\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
      toWrite = "mkdir " + workloadOutputDir + "\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());

      System.out.println();
      System.out.println(workloadData.size() + " jobs in the workload.");
      System.out.println("Generating scripts ... please wait ... ");
      System.out.println();

      int written = 0;

      // TODO should get the average.
      long input = Long.parseLong(workloadData.get(0).get(INPUT_DATA_SIZE));
      long shuffle = Long.parseLong(workloadData.get(0).get(SHUFFLE_DATA_SIZE));
      long output = Long.parseLong(workloadData.get(0).get(OUTPUT_DATA_SIZE));

      if (numInteractiveJobs < 0)
        numInteractiveJobs = workloadData.size();

      for (int i = 0; i < numInteractiveJobs; i++) {

        // Logic to scale sleep time such that smaller cluster = fewer
        // jobs
        // Currently not done
        //
        // sleep = sleep * clusterSizeRaw / clusterSizeWorkload;

        input = input * clusterSizeWorkload / clusterSizeRaw;
        shuffle = shuffle * clusterSizeWorkload / clusterSizeRaw;
        output = output * clusterSizeWorkload / clusterSizeRaw;

        if (input > maxInput)
          maxInput = input;
        if (input < maxSeqFile(67108864))
          input = maxSeqFile(67108864); // 64 MB minimum size

        if (shuffle < 1024)
          shuffle = 1024;
        if (output < 1024)
          output = 1024;

        ArrayList<Integer> inputPartitionSamples = new ArrayList<Integer>();
        long inputCopy = input;
        java.util.Random rng = new java.util.Random();
        int tryPartitionSample = rng.nextInt(inputPartitionCount);
        while (inputCopy > 0) {
          boolean alreadySampled = true;
          while (alreadySampled) {
            if (inputPartitionSamples.size() >= inputPartitionCount) {
              System.err.println();
              System.err.println("ERROR!");
              System.err.println("Not enough partitions for input size of "
                  + input + " bytes.");
              System.err.println("Happened on job number " + i + ".");
              System.err.println(
                  "Input partition size is " + inputPartitionSize + " bytes.");
              System.err.println(
                  "Number of partitions is " + inputPartitionCount + ".");
              System.err.println("Total data size is "
                  + (((long) inputPartitionSize) * ((long) inputPartitionCount))
                  + " bytes < " + input + " bytes.");
              System.err.println("Need to generate a larger input data set.");
              System.err.println();
              throw new Exception(
                  "Input data set not large enough. Need to generate a larger data set.");
              // if exception thrown here, input set not large
              // enough - generate bigger input set
            }
            alreadySampled = false;
          }
          inputPartitionSamples.add(new Integer(tryPartitionSample));
          tryPartitionSample = (tryPartitionSample + 1) % inputPartitionCount;
          inputCopy -= inputPartitionSize;
        }

        FileWriter inputPathFile = new FileWriter(
            scriptDirPath + "/inputPath-interactive-" + i + ".txt");
        String inputPath = "";
        for (int j = 0; j < inputPartitionSamples.size(); j++) {
          inputPath = (hdfsInputDir + "/part-"
              + String.format("%05d", inputPartitionSamples.get(j)));
          if (j != (inputPartitionSamples.size() - 1))
            inputPath += ",";
          inputPathFile.write(inputPath.toCharArray(), 0, inputPath.length());
        }
        inputPathFile.close();

        // write inputPath to separate file to get around ARG_MAX limit
        // for large clusters

        inputPath = "inputPath-interactive-" + i + ".txt";

        String outputPath = hdfsOutputPrefix + "-" + i;

        float SIRatio = ((float) shuffle) / ((float) input);
        float OSRatio = ((float) output) / ((float) shuffle);

        long numReduces = -1;

        FileWriter runFile = new FileWriter(
            scriptDirPath + "/run-interactive-" + i + ".sh");
        // toWrite = "" + hadoopCommand + " fs -rm -r " + outputPath +
        // "\n";
        // runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        for (int k = 0; k < NUM_QUEUES; k++) {
          int idx = i * NUM_QUEUES;
          String mOutputPath = outputPath + k;
          if (totalDataPerReduce > 0) {
            numReduces = Math
                .round((shuffle + output) / ((double) totalDataPerReduce));
            if (numReduces < 1)
              numReduces = 1;
            if (numReduces > clusterSizeWorkload)
              numReduces = clusterSizeWorkload / 5;
            toWrite = "" + hadoopCommand + " jar " + pathToWorkGenJar
                + " org.apache.hadoop.examples.WorkGen -conf "
                + pathToWorkGenConf + " " + "-m " + numMaps + " " + "-r "
                + numReduces + " " + inputPath + " " + mOutputPath + " -queue "
                // + "interactive" + k + " -map.vcores " + MAP_VCORES[idx + k] +
                // " -red.vcores " + RED_VCORES[idx + k]
                + "bursty" + k + " -map.vcores " + BURSTY_CPU + " -red.vcores "
                + BURSTY_CPU
                // + " -map.memory " + MAP_MEM[idx + k] + " -red.memory " +
                // RED_MEM[idx + k] + " " + SIRatio + " "
                + " -map.memory " + BURSTY_MEM + " -red.memory " + BURSTY_MEM
                + " " + SIRatio + " " + OSRatio + " >> " + workloadOutputDir
                + "/interactive-" + i + "_" + k + ".txt 2>> "
                + workloadOutputDir + "/interactive-" + i + "_" + k + ".txt ";
          } else {
            toWrite = "" + hadoopCommand + " jar " + pathToWorkGenJar
                + " org.apache.hadoop.examples.WorkGen -conf "
                + pathToWorkGenConf + " " + "-m " + numMaps + " " + inputPath
                + " " + mOutputPath + " -queue " + "bursty" + k
                // + " -map.vcores " + MAP_VCORES[idx + k] + " -red.vcores " +
                // RED_VCORES[idx + k] + " -map.memory "
                + " -map.vcores " + BURSTY_CPU + " -red.vcores " + BURSTY_CPU
                + " -map.memory "
                // + MAP_MEM[idx + k] + " -red.memory " + RED_MEM[idx + k] + " "
                // + SIRatio + " " + OSRatio + " >> "
                + BURSTY_MEM + " -red.memory " + BURSTY_MEM + " " + SIRatio
                + " " + OSRatio + " >> " + workloadOutputDir + "/interactive-"
                + i + "_" + k + ".txt 2>> " + workloadOutputDir
                + "/interactive-" + i + "_" + k + ".txt ";
          }

          // int randomNum = new Random().nextInt(6) + 5;
          // toWrite = "sleep " + randomNum + " ; " + toWrite;

          toWrite += " & " + " interactive" + i + "=\"$interactive" + i
              + " $!\" " + " \n";
          runFile.write(toWrite.toCharArray(), 0, toWrite.length());
        }

        toWrite = "wait $interactive" + i + " \n";
        runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        for (int k = 0; k < NUM_QUEUES; k++) {
          String mOutputPath = outputPath + k;
          toWrite = hadoopCommand + " fs -rm -r " + mOutputPath + "\n";
          runFile.write(toWrite.toCharArray(), 0, toWrite.length());
        }
        // String mOutputPath = outputPath + NUM_QUEUES;
        // toWrite = hadoopCommand + " fs -rm -r " + mOutputPath + "\n";
        // runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        // toWrite = "" + hadoopCommand + " fs -rm -r " + outputPath +
        // "\n";
        // runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        toWrite = "# inputSize " + input + "\n";
        runFile.write(toWrite.toCharArray(), 0, toWrite.length());

        runFile.close();

        // works for linux type systems only
        Runtime.getRuntime().exec(
            "chmod +x " + scriptDirPath + "/run-interactive-" + i + ".sh");

        toWrite = "./run-interactive-" + i + ".sh &\n";
        runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());

        if (i < numInteractiveJobs - 1) {
          toWrite = "sleep " + arrivalPeriod + "\n";
          runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
        }
        written++;
      }

      System.out.println(written + " jobs written ... done.");
      System.out.println();

      toWrite = "# max input " + maxInput + "\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
      toWrite = "# inputPartitionSize " + inputPartitionSize + "\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());
      toWrite = "# inputPartitionCount " + inputPartitionCount + "\n";
      runAllJobs.write(toWrite.toCharArray(), 0, toWrite.length());

      runAllJobs.close();

      // works for linux type systems only
      Runtime.getRuntime()
          .exec("chmod +x " + scriptDirPath + "/interactives-all.sh");
    }
  }

  /*
   *
   * Computes the size of a SequenceFile with the given number of records. We
   * assume the following 96 byte header:
   *
   * 4 bytes (magic header prefix) ... key class name: 35 bytes for
   * "org.apache.hadoop.io.BytesWritable" (34 characters + one-byte length) ...
   * value class name: 35 bytes for "org.apache.hadoop.io.BytesWritable" 1 byte
   * boolean (is each record value compressed?) 1 byte boolean (is the file
   * block compressed?) bytes for metadata: in our case, there is no metadata,
   * and we get 4 bytes of zeros 16 bytes of sync
   *
   * The SequenceFile writer places a periodic marker after writing a minimum of
   * 2000 bytes; the marker also falls at a record boundary. Therefore, unless
   * the serialized record size is a factor of 2000, more than 2000 bytes will
   * be written between markers. In the code below, we refer to this distance as
   * the "markerSpacing".
   *
   * The SequenceFile writer can be found in:
   * hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/io/
   * SequenceFile.java
   *
   * There are informative constants at the top of the SequenceFile class, and
   * the heart of the writer is the append() method of the Writer class.
   *
   */

  static final int SeqFileHeaderSize = 96;
  static final int SeqFileRecordSizeUsable = 100; // max_key + max_value
  static final int SeqFileRecordSizeSerialized = 116; // usable + 4 ints
  static final int SeqFileMarkerSize = 20;
  static final double SeqFileMarkerMinSpacing = 2000.0;

  private static int seqFileSize(int numRecords) {
    int totalSize = SeqFileHeaderSize;

    int recordTotal = numRecords * SeqFileRecordSizeSerialized;
    totalSize += recordTotal;

    int numRecordsBetweenMarkers = (int) Math
        .ceil(SeqFileMarkerMinSpacing / (SeqFileRecordSizeSerialized * 1.0));
    int markerSpacing = numRecordsBetweenMarkers * SeqFileRecordSizeSerialized;
    int numMarkers = (int) Math
        .floor((totalSize * 1.0) / (markerSpacing * 1.0));

    totalSize += numMarkers * SeqFileMarkerSize;

    return totalSize;
  }

  /*
   *
   * Computes the amount of data a SequenceFile would hold in an HDFS block of
   * the given size. First, we estimate the number of records which will fit by
   * inverting seqFileSize(), then we decrease until we fit within the block.
   *
   * To compute the inverse, we start with a simplified form of the equation
   * computed by seqFileSize(), using X for the number of records:
   *
   * totalSize = header + X * serialized + markerSize * (header + X *
   * serialized) / markerSpacing
   * 
   * using some algebra:
   *
   * (totalSize - header) * markerSpacing
   *
   * = X * serialized * markerSpacing + markerSize * (header + X * serialized)
   *
   *
   * (totalSize - header) * markerSpacing - markerSize * header
   *
   * = X * serialized * markerSpacing + markerSize * X * serialized
   *
   * = (markerSpacing + markerSize) * X * serialized
   *
   * We now have a Right-Hand Side which looks easy to deal with!
   *
   * Focusing on the Left-Hand Side, we'd like to avoid multiplying (totalSize -
   * header) * markerSpacing as it may be a very large number. We re-write as
   * follows:
   *
   * (totalSize - header) * markerSpacing - markerSize * header = (totalSize -
   * header - markerSize * header / markerSpacing) * markerSpacing
   *
   */

  public static int maxSeqFile(int blockSize) {

    // First, compute some values we will need. Same as in seqFileSize()
    int numRecordsBetweenMarkers = (int) Math
        .ceil(SeqFileMarkerMinSpacing / (SeqFileRecordSizeSerialized * 1.0));
    double markerSpacing = numRecordsBetweenMarkers
        * SeqFileRecordSizeSerialized * 1.0;

    // Calculate the Left-Hand Side we wrote in the comment above
    double est = blockSize - SeqFileHeaderSize
        - (SeqFileMarkerSize * SeqFileHeaderSize * 1.0) / markerSpacing;
    est *= markerSpacing;

    // Now, divide the constants from the Right-Hand Side we found above
    est /= (markerSpacing + SeqFileMarkerSize * 1.0);
    est /= (SeqFileRecordSizeSerialized * 1.0);

    // Can't have a fractional number of records!
    int numRecords = (int) Math.ceil(est);

    // Check if we over-estimated
    while (seqFileSize(numRecords) > blockSize) {
      numRecords--;
    }

    return (numRecords * SeqFileRecordSizeUsable);
  }

  /*
   *
   * Read in command line arguments etc.
   *
   */
  public static void main(String args[]) throws Exception {

    boolean IS_TEZ = true;

    // variables

    ArrayList<ArrayList<String>> workloadData = new ArrayList<ArrayList<String>>();

    // read command line arguments

    String fileWorkloadPath = null;
    int clusterSizeRaw = 0;
    int clusterSizeWorkload = 0;
    int hdfsBlockSize = 0;
    int inputPartitionCount = 0;
    String scriptDirPath = null;
    String hdfsInputDir = null;
    String hdfsOutputPrefix = null;
    long totalDataPerReduce = 0;
    String workloadOutputDir = null;
    String hadoopCommand = null;
    String pathToWorkGenJar = null;
    String pathToWorkGenConf = null;

    if (args.length < 10) {

      System.out.println();
      System.out.println("Insufficient arguments.");
      System.out.println();
      System.out.println("Usage: ");
      System.out.println();
      System.out.println("java GenerateReplayScript");
      System.out.println("  [path to synthetic workload file]");
      System.out
          .println("  [number of machines in the original production cluster]");
      System.out.println(
          "  [number of machines in the cluster where the workload will be run]");
      System.out.println("  [size of each input partition in bytes]");
      System.out.println("  [number of input partitions]");
      System.out.println("  [output directory for the scripts]");
      System.out.println("  [HDFS directory for the input data]");
      System.out.println("  [amount of data per reduce task in bytes]");
      System.out.println("  [directory for the workload output files]");
      System.out.println("  [hadoop command on your system]");
      System.out.println("  [path to WorkGen.jar]");
      System.out.println("  [path to workGenKeyValue_conf.xsl]");
      System.out.println("\n Load default parameters");

      if (!IS_TEZ) {
        fileWorkloadPath = "FB-2009_samples_24_times_1hr_0_first200.tsv";
        clusterSizeRaw = 600;
        clusterSizeWorkload = NUM_CP_NODES; // TODO: change this to the number
                                            // of servers for real test cases.
        hdfsBlockSize = 67108864;
        inputPartitionCount = 40; // 10 - number of input partitions in HDFS
        scriptDirPath = "scriptsTest";
        hdfsInputDir = "workGenInput";
        hdfsOutputPrefix = "workGenOutputTest";
        totalDataPerReduce = 67108864;
        workloadOutputDir = "workGenLogs";
        hadoopCommand = "~/hadoop/bin/hadoop";
        pathToWorkGenJar = "../WorkGen.jar";
        pathToWorkGenConf = "users/tanle/hadoop/conf/workGenKeyValue_conf.xsl";
      } else {
        fileWorkloadPath = "FB-2009_samples_24_times_1hr_0_first200.tsv";
        clusterSizeRaw = 600;
        clusterSizeWorkload = NUM_CP_NODES; // TODO: change this to the number
                                            // of servers for real test cases.
        hdfsBlockSize = 67108864;
        inputPartitionCount = 40; // 10 - number of input partitions in HDFS
        scriptDirPath = "scriptsTest";
        hdfsInputDir = "workGenInput";
        hdfsOutputPrefix = "workGenOutputTest";
        totalDataPerReduce = 67108864;
        String outputPrefix="~/SWIM/scriptsTest/";
        workloadOutputDir = outputPrefix+"workGenLogs";
        hadoopCommand = "~/hadoop/bin/hadoop";
        pathToWorkGenJar = "~/hadoop/tez_jars/tez-examples-0.8.4.jar dumpjob ";
        pathToWorkGenConf = "users/tanle/hadoop/conf/workGenKeyValue_conf.xsl";
      }

    } else {
      fileWorkloadPath = args[0];

      clusterSizeRaw = Integer.parseInt(args[1]);
      clusterSizeWorkload = Integer.parseInt(args[2]);
      hdfsBlockSize = Integer.parseInt(args[3]);
      inputPartitionCount = Integer.parseInt(args[4]);
      scriptDirPath = args[5];
      hdfsInputDir = args[6];
      hdfsOutputPrefix = args[7];
      totalDataPerReduce = Long.parseLong(args[8]);
      workloadOutputDir = args[9];
      hadoopCommand = args[10];
      pathToWorkGenJar = args[11];
      pathToWorkGenConf = args[12];

    }

    // parse data

    long maxInput = parseFileArrayList(fileWorkloadPath, workloadData);

    // check if maxInput fits within input data size to be generated

    long maxInputNeeded = maxInput * clusterSizeWorkload / clusterSizeRaw;

    int inputPartitionSize = maxSeqFile(hdfsBlockSize);
    long totalInput = ((long) inputPartitionSize)
        * ((long) inputPartitionCount);

    if (maxInputNeeded > totalInput) {

      System.err.println();
      System.err.println("ERROR!");
      System.err.println("Not enough partitions for max needed input size of "
          + maxInputNeeded + " bytes.");
      System.err.println("HDFS block size is " + hdfsBlockSize + " bytes.");
      System.err
          .println("Input partition size is " + inputPartitionSize + " bytes.");
      System.err
          .println("Number of partitions is " + inputPartitionCount + ".");
      System.err.println("Total actual input data size is " + totalInput
          + " bytes < " + maxInputNeeded + " bytes.");
      System.err.println("Need to generate a larger input data set.");
      System.err.println();

      throw new Exception(
          "Input data set not large enough. Need to generate a larger data set.");

    } else {
      System.err.println();
      System.err.println("Max needed input size " + maxInputNeeded + " bytes.");
      System.err.println("Actual input size is " + totalInput + " bytes >= "
          + maxInputNeeded + " bytes.");
      System.err.println("All is good.");
      System.err.println();
    }

    // make scriptDirPath directory if it doesn't exist

    File d = new File(scriptDirPath);
    if (d.exists()) {
      // if (d.isDirectory()) {
      // System.err.println("Warning! About to overwrite existing scripts
      // in: " + scriptDirPath);
      // System.err.print("Ok to continue? [y/n] ");
      // BufferedReader in = new BufferedReader(new
      // InputStreamReader(System.in));
      // String s = in.readLine();
      // if (s == null || s.length() < 1 || s.toLowerCase().charAt(0) !=
      // 'y') {
      // throw new Exception("Declined overwrite of existing directory");
      // }
      // } else {
      // throw new Exception(scriptDirPath + " is a file.");
      // }
    } else {
      d.mkdirs();
    }

    // print shell scripts
    if (!IS_TEZ) {
      int burstyAppNum = 15;
      printMRBatchUsingTraces(workloadData, clusterSizeRaw, clusterSizeWorkload,
          inputPartitionSize, inputPartitionCount, scriptDirPath, hdfsInputDir,
          hdfsOutputPrefix, totalDataPerReduce, workloadOutputDir,
          hadoopCommand, pathToWorkGenJar, pathToWorkGenConf, burstyAppNum * 6,
          3, (int) (256 * 0.8)); // should try with 6

      printMRBurstyJobs(workloadData, clusterSizeRaw, clusterSizeWorkload,
          inputPartitionSize, inputPartitionCount, scriptDirPath, hdfsInputDir,
          hdfsOutputPrefix, totalDataPerReduce, workloadOutputDir,
          hadoopCommand, pathToWorkGenJar, pathToWorkGenConf, 100, burstyAppNum,
          1, (int) (256 * 0.9));
    } else {
      int numOfBatchQueues = 3;
      int burstyAppNum = 2;
      int batchAppNum = burstyAppNum * numOfBatchQueues * 2;
      int batchAppStartId = 100000;
      ArrayList<String> batchIds = new ArrayList<String>();
      ArrayList<String> burstyIds = new ArrayList<String>();
      
      for (int i = 0; i < batchAppNum; i++)
        batchIds.add(String.valueOf(i + batchAppStartId));

      for (int i = 0; i < burstyAppNum; i++)
        burstyIds.add(String.valueOf(i));

      printTezBatchUsingTraces(batchIds, scriptDirPath, workloadOutputDir,
          hadoopCommand, pathToWorkGenJar, batchAppNum, numOfBatchQueues);

      printTezBurstyJobs(burstyIds, scriptDirPath, workloadOutputDir,
          hadoopCommand, pathToWorkGenJar, 500, burstyAppNum, 1);
    }

    System.out.println("Parameter values for randomwriter_conf.xsl:");
    System.out.println("test.randomwrite.total_bytes: " + totalInput);
    System.out.println("test.randomwrite.bytes_per_map: " + inputPartitionSize);

  }
}
