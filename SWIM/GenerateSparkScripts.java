import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.File;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.text.SimpleDateFormat;

public class GenerateSparkScripts {

	/*
	 * Workload file format constants for field indices
	 */
	static final int INTER_JOB_SLEEP_TIME = 2;
	static final int INPUT_DATA_SIZE = 3;
	static final int SHUFFLE_DATA_SIZE = 4;
	static final int OUTPUT_DATA_SIZE = 5;

	/*
	 *
	 * Parses a tab separated file into an ArrayList<ArrayList<String>>
	 *
	 */
	public static long parseFileArrayList(String path, ArrayList<ArrayList<String>> data) throws Exception {

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
		input.close();

		return maxInput;

	}

	/*
	 *
	 * Prints the necessary shell scripts
	 *
	 */
	public static void printOutput(String hostName, ArrayList<ArrayList<String>> workloadData, int clusterSizeRaw,
			int clusterSizeWorkload, String scriptDirPath, String workloadOutputDir, String sparkCommand,
			String pathToWorkGenJar, String classname, int executorMemory, int executorCore, String appParameters, String queueName)
			throws Exception {

		if (workloadData.size() > 0) {

			String toWrite = "";

			FileWriter runSparkJobs = new FileWriter(scriptDirPath + "/interactives.sh");
			FileWriter run = new FileWriter(scriptDirPath + "/exec.sh");

			toWrite = "#!/bin/bash\n";
			run.write(toWrite.toCharArray(), 0, toWrite.length());
			toWrite = "rm -r " + workloadOutputDir + "\n";
			run.write(toWrite.toCharArray(), 0, toWrite.length());
			toWrite = "mkdir " + workloadOutputDir + "\n";
			run.write(toWrite.toCharArray(), 0, toWrite.length());

			System.out.println();
			System.out.println(workloadData.size() + " jobs in the workload.");
			System.out.println("Generating scripts ... please wait ... ");
			System.out.println();
			
			boolean enable_spark = false;
			if (false) {
  			int numOfJobs = workloadData.size();
  			numOfJobs = 4;
  			numOfJobs = numOfJobs/2;
  
  			int written = 0;
  			for (int i = 0; i < numOfJobs; i++) {
  //				long sleep = Long.parseLong(workloadData.get(i).get(INTER_JOB_SLEEP_TIME));
  				long sleep = 240;
  
  				// write inputPath to separate file to get around ARG_MAX limit
  				// for large clusters
  
  				FileWriter runFile = new FileWriter(scriptDirPath + "/run-interactive-" + i + ".sh");
  				
  				toWrite = "  echo \"- run Interactive job " + i + " \" \n";
  				runFile.write(toWrite.toCharArray(), 0, toWrite.length());
  				
  				toWrite = "FULL_COMMAND=\"" + printSparkCommand(sparkCommand, classname, executorMemory, executorCore,
  						pathToWorkGenJar, appParameters, queueName) + "\"";
  				runFile.write(toWrite.toCharArray(), 0, toWrite.length());
  
  				toWrite = "\n(TIMEFORMAT='%R'; time $FULL_COMMAND 2>" + workloadOutputDir + "/interactive-" + i + ".log) 2> "
  						+ workloadOutputDir + "/interactive-" + i + ".time";
  				runFile.write(toWrite.toCharArray(), 0, toWrite.length());
  
  				runFile.close();
  
  				// works for linux type systems only
  				Runtime.getRuntime().exec("chmod +x " + scriptDirPath + "/run-interactive-" + i + ".sh");
  				
  				toWrite ="date --rfc-3339=seconds >> "+workloadOutputDir+"/interactives.csv\n";
  				runSparkJobs.write(toWrite.toCharArray(), 0, toWrite.length());
  //				toWrite = "./run-interactive-" + i + ".sh &  interactives=\"$interactives $!\" \n";
  				toWrite = "./run-interactive-" + i + ".sh \n";
  				runSparkJobs.write(toWrite.toCharArray(), 0, toWrite.length());
  
  				toWrite = "sleep " + sleep + "\n";
  				runSparkJobs.write(toWrite.toCharArray(), 0, toWrite.length());
  				written++;
  
  			}
  			System.out.println(written + " jobs written ... done.");
  			System.out.println();
  			
  	     toWrite = "wait $interactives \n";
  	      runSparkJobs.write(toWrite.toCharArray(), 0, toWrite.length());
			} else {
			  System.out.println("Do NOT use Spark jobs");
			}
			
			toWrite = "\npython ../get_yarn_queue_info.py --master " + hostName
					+ " --interval 1 --file "+workloadOutputDir+"/yarnUsedResources.csv & pythonScript=$! \n";
			run.write(toWrite.toCharArray(), 0, toWrite.length());
			
			toWrite = "./batches-all.sh & runBatches=$! \n";
			run.write(toWrite.toCharArray(), 0, toWrite.length());
			
//			toWrite = "sleep 30 \n";
//			run.write(toWrite.toCharArray(), 0, toWrite.length());	
			
			if (enable_spark) {
  			toWrite = "./interactives.sh & runInteractives=$! \n";
  			run.write(toWrite.toCharArray(), 0, toWrite.length());
			} else {
  			toWrite = "./interactives-all.sh & runInteractives=$! \n";
        run.write(toWrite.toCharArray(), 0, toWrite.length());
			}
			
			//toWrite = "wait $runBatches \n";
			toWrite = "wait $runInteractives; sleep 10 \n";
			run.write(toWrite.toCharArray(), 0, toWrite.length());

//			toWrite = "cat " + workloadOutputDir + "/interactive-*.time > " + workloadOutputDir + "/allJobs.time";
//			run.write(toWrite.toCharArray(), 0, toWrite.length());

			toWrite = "\n kill $pythonScript";
			run.write(toWrite.toCharArray(), 0, toWrite.length());
			
//			toWrite = "\n kill $runInteractives";
//			run.write(toWrite.toCharArray(), 0, toWrite.length());
			
			runSparkJobs.close();
			run.close();

			// works for linux type systems only
			Runtime.getRuntime().exec("chmod +x " + scriptDirPath + "/interactives.sh");
			Runtime.getRuntime().exec("chmod +x " + scriptDirPath + "/exec.sh");

		}

	}

	/*
	 *
	 * Computes the size of a SequenceFile with the given number of records. We
	 * assume the following 96 byte header:
	 *
	 * 4 bytes (magic header prefix) ... key class name: 35 bytes for
	 * "org.apache.hadoop.io.BytesWritable" (34 characters + one-byte length)
	 * ... value class name: 35 bytes for "org.apache.hadoop.io.BytesWritable" 1
	 * byte boolean (is each record value compressed?) 1 byte boolean (is the
	 * file block compressed?) bytes for metadata: in our case, there is no
	 * metadata, and we get 4 bytes of zeros 16 bytes of sync
	 *
	 * The SequenceFile writer places a periodic marker after writing a minimum
	 * of 2000 bytes; the marker also falls at a record boundary. Therefore,
	 * unless the serialized record size is a factor of 2000, more than 2000
	 * bytes will be written between markers. In the code below, we refer to
	 * this distance as the "markerSpacing".
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

		int numRecordsBetweenMarkers = (int) Math.ceil(SeqFileMarkerMinSpacing / (SeqFileRecordSizeSerialized * 1.0));
		int markerSpacing = numRecordsBetweenMarkers * SeqFileRecordSizeSerialized;
		int numMarkers = (int) Math.floor((totalSize * 1.0) / (markerSpacing * 1.0));

		totalSize += numMarkers * SeqFileMarkerSize;

		return totalSize;
	}

	/*
	 *
	 * Computes the amount of data a SequenceFile would hold in an HDFS block of
	 * the given size. First, we estimate the number of records which will fit
	 * by inverting seqFileSize(), then we decrease until we fit within the
	 * block.
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
	 * Focusing on the Left-Hand Side, we'd like to avoid multiplying (totalSize
	 * - header) * markerSpacing as it may be a very large number. We re-write
	 * as follows:
	 *
	 * (totalSize - header) * markerSpacing - markerSize * header = (totalSize -
	 * header - markerSize * header / markerSpacing) * markerSpacing
	 *
	 */

	public static String printSparkCommand(String sparkCommand, String classname, int executorMemory, int executorCore,
			String jar, String appParameters, String queueName) {
		return sparkCommand + " --master yarn --class " + classname + " --deploy-mode cluster --driver-memory "
				+ executorMemory + "M --executor-memory " + executorMemory + "M --executor-cores " + executorCore
				+ " --queue " + queueName + " " + jar + " " + appParameters;
	}
	
	public static int maxSeqFile(int blockSize) {

		// First, compute some values we will need. Same as in seqFileSize()
		int numRecordsBetweenMarkers = (int) Math.ceil(SeqFileMarkerMinSpacing / (SeqFileRecordSizeSerialized * 1.0));
		double markerSpacing = numRecordsBetweenMarkers * SeqFileRecordSizeSerialized * 1.0;

		// Calculate the Left-Hand Side we wrote in the comment above
		double est = blockSize - SeqFileHeaderSize - (SeqFileMarkerSize * SeqFileHeaderSize * 1.0) / markerSpacing;
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

		ArrayList<ArrayList<String>> workloadData = new ArrayList<ArrayList<String>>();
		
		String hostName = "nm.yarn-perf.yarnrm-pg0.wisc.cloudlab.us";
//		String hostName = "nm.yarn-drf.yarnrm-pg0.wisc.cloudlab.us";

		String fileWorkloadPath = "FB-2009_samples_24_times_1hr_0_first200.tsv";
		
		
		int clusterSizeRaw = 600;
		int clusterSizeWorkload = 4;
		String scriptDirPath = "scriptsTest";
		String workloadOutputDir = "workGenLogs";
		String sparkCommand = "/users/tanle/spark/bin/spark-submit ";
		String pathToWorkGenJar = "/users/tanle/spark/examples/jars/spark-examples*.jar";
		String appParameters = " 100000";
		String classname = "org.apache.spark.examples.SparkPi";
		int executorMemory = 2048 - 384;
		int executorCore = 1;
		String queueName = "interactive";

		if (args.length < 10) {
			System.out.println();
			System.out.println("Insufficient arguments.");
			System.out.println();
			System.out.println("Usage: ");
			System.out.println();
			System.out.println("java GenerateSparkScript");
			System.out.println(" [the host name of the resource manager node]");
			System.out.println(" [path to file with workload info]");
			System.out.println(" [number of machines in the original production cluster]");
			System.out.println(" [number of machines in the cluster on which the workload will be run]");
			System.out.println(" [output directory for the scripts]");
			System.out.println(" [directory for the workload output files]");
			System.out.println(" [hadoop command on your system]");
			System.out.println(" [path to WorkGen.jar]");
			System.out.println(" [path to workGenKeyValue_conf.xsl]");
			System.out.println(" [application parameters]");
			System.out.println(" [queue name]");
			System.out.println();
			// return;
		} else {
			// read command line arguments
			fileWorkloadPath = args[0];
			clusterSizeRaw = Integer.parseInt(args[1]);
			clusterSizeWorkload = Integer.parseInt(args[2]);
			workloadOutputDir = args[3];
			sparkCommand = args[4];
			pathToWorkGenJar = args[5];
			queueName = args[6];
		}

		// parse data
		long maxInput = parseFileArrayList(fileWorkloadPath, workloadData);

		// check if maxInput fits within input data size to be generated
		long maxInputNeeded = maxInput * clusterSizeWorkload / clusterSizeRaw;

		// make scriptDirPath directory if it doesn't exist

		File d = new File(scriptDirPath);
		if (d.exists()) {
//			if (d.isDirectory()) {
//				System.err.println("Warning! About to overwrite e xisting scripts in: " + scriptDirPath);
//				System.err.print("Ok to continue? [y/n] ");
//				BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
//				String s = in.readLine();
//				if (s == null || s.length() < 1 || s.toLowerCase().charAt(0) != 'y') {
//					throw new Exception("Declined overwrite of existing directory");
//				}
//			} else {
//				throw new Exception(scriptDirPath + " is a file.");
//			}
		} else {
			d.mkdirs();
		}

		// print shell scripts

		printOutput(hostName, workloadData, clusterSizeRaw, clusterSizeWorkload, scriptDirPath, workloadOutputDir, sparkCommand,
				pathToWorkGenJar, classname, executorMemory, executorCore, appParameters, queueName);

	}
}
