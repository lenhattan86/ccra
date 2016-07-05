/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package cpubound;

import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.api.java.tuple.Tuple5;
import org.apache.flink.api.java.utils.ParameterTool;
import org.apache.flink.streaming.api.collector.selector.OutputSelector;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.datastream.IterativeStream;
import org.apache.flink.streaming.api.datastream.SplitStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.SourceFunction;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Random;
import java.util.TimeZone;

/**
 * Example illustrating iterations in Flink streaming.
 * <p>
 * The program sums up random numbers and counts additions it performs to reach
 * a specific threshold in an iterative streaming fashion.
 * </p>
 *
 * <p>
 * This example shows how to use:
 * <ul>
 * <li>streaming iterations,
 * <li>buffer timeout to enhance latency,
 * <li>directed outputs.
 * </ul>
 * </p>
 */
public class IterateExample {

	private static final int BOUND = 1000;
	private static final boolean isDumpCompuation = true;
	private static final double counterBound = 30000; // 10000-> 2 mins,
//	private static final double counterBound = 3000; // 10000-> 2 mins,
	private static final double nLoop = 2*Math.pow(10, 6); // (10, 7) ~ 100% cpu
	private static final String timeStampFile = "cpubound.csv";	

	// *************************************************************************
	// PROGRAM
	// *************************************************************************

	public static void main(String[] args) throws Exception {
		String logFile = timeStampFile;

		// Checking input parameters
		final ParameterTool params = ParameterTool.fromArgs(args);
		System.out.println("Usage: IterateExample --log <path>");
		if (params.has("log"))
			logFile = params.get("log");
		else {
			System.out.println("Usage: IterateExample --log <path>");
			return;
		}
		
		try (FileWriter fw = new FileWriter(logFile, true);
			    BufferedWriter bw = new BufferedWriter(fw);
			    PrintWriter out = new PrintWriter(bw)) {
			out.println(currentTimestamp());
			out.close();
		}

		// set up input for the stream of integer pairs

		// obtain execution environment and set setBufferTimeout to 1 to enable
		// continuous flushing of the output buffers (lowest latency)
		StreamExecutionEnvironment env = StreamExecutionEnvironment
				.getExecutionEnvironment().setBufferTimeout(1);

		// make parameters available in the web interface
		env.getConfig().setGlobalJobParameters(params);

		// create input stream of integer pairs
		DataStream<Tuple2<Integer, Integer>> inputStream;
		inputStream = env.addSource(new RandomFibonacciSource());

		// create an iterative data stream from the input with 1 second timeout
		IterativeStream<Tuple5<Integer, Integer, Integer, Integer, Integer>> it = inputStream
				.map(new InputMap()).iterate(1000);

		// apply the step function to get the next Fibonacci number
		// increment the counter and split the output with the output selector
		SplitStream<Tuple5<Integer, Integer, Integer, Integer, Integer>> step = it
				.map(new Step()).split(new MySelector());

		// close the iteration by selecting the tuples that were directed to the
		// 'iterate' channel in the output selector
		it.closeWith(step.select("iterate"));

		// to produce the final output select the tuples directed to the
		// 'output' channel then get the input pairs that have the greatest
		// iteration counter
		// on a 1 second sliding window
		DataStream<Tuple2<Tuple2<Integer, Integer>, Integer>> numbers = step
				.select("output").map(new OutputMap());

		// emit results
		if (params.has("output")) {
			numbers.writeAsText(params.get("output"));
		} else {
			System.out
					.println("Printing result to stdout. Use --output to specify output path.");
			// numbers.print();
		}

		// execute the program
		env.execute("Streaming Iteration Example");

		System.out.print(currentTimestamp());
	}

	// *************************************************************************
	// USER FUNCTIONS
	// *************************************************************************

	/**
	 * Generate BOUND number of random integer pairs from the range from 0 to
	 * BOUND/2
	 */
	private static class RandomFibonacciSource implements
			SourceFunction<Tuple2<Integer, Integer>> {
		private static final long serialVersionUID = 1L;
		// private static final double counterBound = Math.pow(2, 20);		

		private Random rnd = new Random();

		private volatile boolean isRunning = true;
		private int counter = 0;

		@Override
		public void run(SourceContext<Tuple2<Integer, Integer>> ctx)
				throws Exception {
			while (isRunning && counter < counterBound) {
				// while (isRunning && counter < BOUND) {
				int first = rnd.nextInt(BOUND / 2 - 1) + 1;
				int second = rnd.nextInt(BOUND / 2 - 1) + 1;
				// int first = BOUND / 4;
				// int second = BOUND * 3/4;

				ctx.collect(new Tuple2<>(first, second));
				counter++;
				// if(counter%100==0)
				// Thread.sleep(1L);
			}
		}

		@Override
		public void cancel() {
			isRunning = false;
		}
	}

	/**
	 * Generate random integer pairs from the range from 0 to BOUND/2
	 */
	private static class FibonacciInputMap implements
			MapFunction<String, Tuple2<Integer, Integer>> {
		private static final long serialVersionUID = 1L;

		@Override
		public Tuple2<Integer, Integer> map(String value) throws Exception {
			String record = value.substring(1, value.length() - 1);
			String[] splitted = record.split(",");
			return new Tuple2<>(Integer.parseInt(splitted[0]),
					Integer.parseInt(splitted[1]));
		}
	}

	/**
	 * Map the inputs so that the next Fibonacci numbers can be calculated while
	 * preserving the original input tuple A counter is attached to the tuple
	 * and incremented in every iteration step
	 */
	public static class InputMap
			implements
			MapFunction<Tuple2<Integer, Integer>, Tuple5<Integer, Integer, Integer, Integer, Integer>> {
		private static final long serialVersionUID = 1L;

		@Override
		public Tuple5<Integer, Integer, Integer, Integer, Integer> map(
				Tuple2<Integer, Integer> value) throws Exception {
			return new Tuple5<>(value.f0, value.f1, value.f0, value.f1, 0);
		}
	}

	/**
	 * Iteration step function that calculates the next Fibonacci number
	 */
	public static class Step
			implements
			MapFunction<Tuple5<Integer, Integer, Integer, Integer, Integer>, Tuple5<Integer, Integer, Integer, Integer, Integer>> {
		private static final long serialVersionUID = 1L;

		@Override
		public Tuple5<Integer, Integer, Integer, Integer, Integer> map(
				Tuple5<Integer, Integer, Integer, Integer, Integer> value)
				throws Exception {
			// We can add some DUMP computation to increase the CPU usage
			if (isDumpCompuation) {
				runDumpCompuation();
			}
			return new Tuple5<>(value.f0, value.f1, value.f3, value.f2
					+ value.f3, ++value.f4);
		}
	}

	/**
	 * OutputSelector testing which tuple needs to be iterated again.
	 */
	public static class MySelector implements
			OutputSelector<Tuple5<Integer, Integer, Integer, Integer, Integer>> {
		private static final long serialVersionUID = 1L;

		@Override
		public Iterable<String> select(
				Tuple5<Integer, Integer, Integer, Integer, Integer> value) {
			List<String> output = new ArrayList<>();
			if (value.f2 < BOUND && value.f3 < BOUND) {
				output.add("iterate");
			} else {
				output.add("output");
			}
			return output;
		}
	}

	/**
	 * Giving back the input pair and the counter
	 */
	public static class OutputMap
			implements
			MapFunction<Tuple5<Integer, Integer, Integer, Integer, Integer>, Tuple2<Tuple2<Integer, Integer>, Integer>> {
		private static final long serialVersionUID = 1L;

		@Override
		public Tuple2<Tuple2<Integer, Integer>, Integer> map(
				Tuple5<Integer, Integer, Integer, Integer, Integer> value)
				throws Exception {
			return new Tuple2<>(new Tuple2<>(value.f0, value.f1), value.f4);
		}
	}

	public static String currentTimestamp() {
		Calendar c = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
		// DateFormat f = DateFormat.getDateTimeInstance(DateFormat.MEDIUM,
		// DateFormat.MEDIUM);
		SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		return f.format(c.getTime());
	}
	
	public static void runDumpCompuation() {
		double sum = 0;
		for (double i = 0; i < nLoop; i++) {
			sum = sum + Math.pow(i, 10);
		}
	}
}
