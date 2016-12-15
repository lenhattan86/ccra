
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;

public class GenerateProfile {
  public static void main(String[] args) {
//    createProfile("/home/tanle/projects/SpeedFairSim/input_gen/jobs_input_1_3.txt");
    if (args.length < 1){
      System.out.println("usage: java GenerateProfile <filepath>");
      return;
    }
    createProfile(args[0]);
  }
  
  public static void createProfile(String fileName){
  File fr = new File(fileName);

  if (fr.isDirectory() || !fr.exists()) {
    System.out.println("createProfile: File does not exist.");
  } else {
    try {
      BufferedReader br = new BufferedReader(new FileReader(fileName));
      String line;
      String dag_name = "";
      String toWrite = "";
      String fileToWrite = "";
      while ((line = br.readLine()) != null) {
        line = line.trim();
        if (line.startsWith("#")) {
          dag_name = line.split("#")[1];
          dag_name = dag_name.trim();
          toWrite="";
          continue;
        }
        toWrite += line + "\n";
        int numVertices = 0, ddagId = -1;
        String[] args = line.split(" ");
        
        if (args.length < 2) 
          System.out.println("readWorkloadTraces: Incorrect node entry");
        if (args.length >= 2) {
          numVertices = Integer.parseInt(args[0]);
          ddagId = Integer.parseInt(args[1]);
        } 

        fileToWrite = ddagId+".profile";

        for (int i = 0; i < numVertices; ++i) {
          line = br.readLine();
          toWrite += line + "\n";
        }

        int numEdgesBtwStages;
        line = br.readLine();
        toWrite += line + "\n";
        numEdgesBtwStages = Integer.parseInt(line);

        for (int i = 0; i < numEdgesBtwStages; ++i) {
          line = br.readLine();
          toWrite += line + "\n";
        }
        
        FileWriter jobFile = new FileWriter(fileToWrite);
        jobFile.write(toWrite);
        jobFile.close();
      }
      br.close();
    } catch (Exception e) {
      System.err.println("Catch exception: " + e);
      e.printStackTrace();
    }
  }
  }
}
