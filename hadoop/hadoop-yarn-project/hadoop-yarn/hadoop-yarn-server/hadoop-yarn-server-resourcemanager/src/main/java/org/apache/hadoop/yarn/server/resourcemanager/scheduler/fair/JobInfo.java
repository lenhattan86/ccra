package org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;


public class JobInfo {
  
  public String jobId;
  public long totalDemand = 0;
  public long demand = 0;
  public long deadline = 0;
  public long processingTime = 0;

  public JobInfo(String jId, long tDemand, long demand, long pTime,
      long dline) {
    this.jobId = jId;
    this.totalDemand = tDemand;
    this.demand = demand;
    this.processingTime = pTime;
    this.deadline = dline;
  }

  @Override
  public String toString() {
    return "jobId:" + this.jobId + " totalDemand: " + this.totalDemand
        + " demand:" + this.demand + " pTime:" + this.processingTime + " dline:"
        + this.deadline;
  }
  
  
  public static HashMap<String, JobInfo> readFile(String filepath){
    HashMap<String, JobInfo> map = new HashMap<>();
    
    File file = new File(filepath);
    try {
      BufferedReader br = new BufferedReader(new FileReader(file));
      String line = br.readLine(); // remove the first line.
      while((line=br.readLine())!=null){
        line = line.trim();
        if(line.isEmpty()){
          System.out.println("[job info] File is ended with empty line.");
          break;
        }
        
        String[] arr = line.split(",");
        String jobId = arr[0].trim();
        long totalDemand = Long.parseLong(arr[1].trim());
        long demand = Long.parseLong(arr[2].trim());
        long processingtime = Long.parseLong(arr[3].trim());
        long deadline = Long.parseLong(arr[4].trim());
        map.put(jobId, new JobInfo(jobId, totalDemand, demand, processingtime, deadline));
      }
    } catch (FileNotFoundException e) {
      e.printStackTrace();
    } catch (IOException e) {
      e.printStackTrace();
    }
    
    return map;
  }
}
