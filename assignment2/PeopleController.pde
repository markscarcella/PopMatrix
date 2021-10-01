

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

  int x1,x2,y1,y2;

  PeopleController(String _urlStartTimestamp, String _urlEndTimestamp, int _x1, int _y1, int _x2, int _y2) {
    urlStartTimestamp = _urlStartTimestamp;
    urlEndTimestamp = _urlEndTimestamp;
    people = new ArrayList<PImage>();
    x1 = _x1;
    y1 = _y1;
    x2 = _x2;
    y2 = _y2;
    loadData();
    loadFaces();
  }

  void loadData() {
    peopleIn = new Table[peopleSensors.length];
    peopleOut = new Table[peopleSensors.length];
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

  void update(String crntTimestamp) {

    int pIn = 0;
    int pOut = 0;

    for (int i=0; i<peopleSensors.length; i++) { 
      if (peopleIn[i] == null) {
        textSize(10);
        fill(0);
        text("Can't load data from "+peopleSensors[i][0]+": "+peopleSensors[i][1], 10, 10+20*i);
        continue;
      }
      TableRow in = peopleIn[i].findRow(crntTimestamp, 0);
      if (in != null) {
        pIn = in.getInt(1);
        println(crntTimestamp, peopleSensors[i][0], "IN", pIn);
        for (int iIn=0; iIn<pIn; iIn++) {
          people.add(faces[int(random(faces.length-1))]);
        }
      }
      TableRow out = peopleOut[i].findRow(crntTimestamp, 0);
      if (out != null) {
        pOut = out.getInt(1);
        println(crntTimestamp, peopleSensors[i][0], "OUT", pOut);
        for (int iOut=0; iOut<pOut; iOut++) {
          if (people.size() > 0) {
            people.remove(int(random(people.size()-1)));
          }
        }
      }
    }
  }

  void display() {
    if (people.size() == 0) {
      return;
    }
    int[] factors = getClosestFactors(people.size(), 0.05); 
    int nx = factors[1];
    int ny = factors[0];
    float r = min((y2-y1)/ny, (x2-x1)/nx);
    int faceIdx = 0;
    for (int j=0; j<ny; j++) {
      for (int i=0; i<nx; i++) {
        if (faceIdx < people.size()) { //we might have more cells than people
          pushMatrix();
          translate(i*(x2-x1)/nx+x1, j*(y2-y1)/ny+y1);
          try {
            image(people.get(faceIdx), 0, 0, r, r);
          } 
          catch (NullPointerException e) {
            println("Can't find a face at index "+faceIdx);
          }
          popMatrix();
        }
        faceIdx++;
      }
    }
  }

  ArrayList<int[]> getFactors(float n) {
    ArrayList<int []> factors = new ArrayList<int[]>();
    for (int i=0; i<=n/2; i++) {
      if (n%i == 0) {
        int[] factor = {i, int(n/i)};
        factors.add(factor);
      }
    }
    return factors;
  }

  int[] getClosestFactors(float n, float delta) {
    if (n <= 3) {
      int[] result = {1, int(n)};
      return result;
    }
    ArrayList fs = getFactors(n);
    int f1 = 1;
    int f2 = int(n);
    for (int i=0; i< fs.size(); i++) {
      int[] f = (int[])fs.get(i);
      if (abs(f[0] - f[1]) < abs(f1-f2)) {
        f1 = f[0];
        f2 = f[1];
      }
    }
    float ratio = float(f1)/f2;   
    if (f1 == 1 || ratio < float(height)/width-delta || ratio > float(height)/width+delta) {
      return getClosestFactors(n+1, delta);
    }
    int[] result = {f1, f2};
    return result;
  }
}
