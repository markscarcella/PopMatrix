

class PeopleController {  
  
  String[][] peopleSensors = {
    // UNIT, SENSOR
    {"CB11.PC00.08.ST12", "CB11.00.CR04.East"}, 
    {"CB11.PC00.09.CR01", "CB11.00.CR04.West"}, 
    {"CB11.PC05.23", "CB11.05.CR07"}, 
    {"CB11.PC05.23", "CB11.05.CR09"}, 
    {"CB11.PC02.14.Broadway", "CB11.02.Broadway.East"}, 
    {"CB11.PC02.16.JonesStEast", "CB11.02.JonesSt"}, 
    {"CB11.PC09.28", "CB11.08.CR10"}, 
    {"CB11.PC09.28", "CB11.09.CR12"}, 
    {"CB11.PC09.28", "CB11.09.CR14"}, 
    {"CB11.PC10.30", "CB11.10.CR09"}, 
    {"CB11.PC10.30", "CB11.09.CR11"}, 
    {"CB11.PC00.06.West", "CB11.00.Wattle"}, 
  };

  Table[] peopleIn, peopleOut;
  int nPeople = 0;
  ArrayList<PImage> people;


  PImage[] faces;
  int nFaces = 10; // up to 1000
  
  String urlStartTimestamp, urlEndTimestamp;

  PeopleController(String _urlStartTimestamp, String _urlEndTimestamp) {
    urlStartTimestamp = _urlStartTimestamp;
    urlEndTimestamp = _urlEndTimestamp;
    people = new ArrayList<PImage>();
    loadData();
    loadFaces();
  }
  
  void loadData() {
  for (int i=0; i<peopleSensors.length; i++) {
    try {
      peopleIn[i] = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate="+urlStartTimestamp+"&rToDate="+urlEndTimestamp+"&rFamily=people_sh&rSensor="+peopleSensors[i][0]+"&rSubSensor="+peopleSensors[i][1]+"+In", "csv");
      peopleOut[i] = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate="+urlStartTimestamp+"&rToDate="+urlEndTimestamp+"&rFamily=people_sh&rSensor="+peopleSensors[i][0]+"&rSubSensor="+peopleSensors[i][1]+"+Out", "csv");
    } 
    catch (RuntimeException e) {
      println("Can't load data from "+peopleSensors[i][0]+": "+peopleSensors[i][1]);
      continue;
    }
  }
  }
  
  void loadFaces() {
   
  faces = new PImage[nFaces];
  PImage maskImage = loadImage("mask.png");
  for (int i=0; i<nFaces; i++) {
    faces[i] = loadImage("faces/"+nf(i+1, 6)+".jpg");
    faces[i].mask(maskImage);
  } 
  }
}
