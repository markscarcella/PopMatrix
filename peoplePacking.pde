import java.util.Date;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.text.*;

int nc, nf, nx, ny;

Table[] peopleIn, peopleOut;
int nPeople = 0;
ArrayList<PImage> people;

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
String startTimestamp = "2020-12-01 05:00:00";
String endTimestamp = "2020-12-31 05:00:00";

String crntTimestamp = "";
String urlStartTimestamp = "";
String urlEndTimestamp = "";
SimpleDateFormat timestampFormat;
SimpleDateFormat urlTimestampFormat;
Date dateStart;
Date dateEnd;
Calendar calendar;

PImage[] faces;
int nFaces = 100; // up to 1000

int updateTimer = 0;
int updateTime = 1000; //update time in ms

void setup() {
  size(500, 400);
  ellipseMode(CENTER);
  background(255);
  frameRate(2.0);

  timestampFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
  urlTimestampFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH'%3A'mm");
  dateStart = new Date();
  dateEnd = new Date();
  try {
    dateStart = timestampFormat.parse(startTimestamp);
    dateEnd = timestampFormat.parse(endTimestamp);
  } 
  catch (ParseException e) {
    e.printStackTrace();
  }

  calendar = Calendar.getInstance();

  calendar.setTime(dateEnd);
  urlEndTimestamp = urlTimestampFormat.format(calendar.getTime());

  calendar.setTime(dateStart);
  urlStartTimestamp = urlTimestampFormat.format(calendar.getTime());
  crntTimestamp = timestampFormat.format(calendar.getTime());  

  peopleIn = new Table[peopleSensors.length];
  peopleOut = new Table[peopleSensors.length];

  for (int i=0; i<peopleSensors.length; i++) {
    try {
      peopleIn[i] = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate="+urlStartTimestamp+"&rToDate="+urlEndTimestamp+"&rFamily=people_sh&rSensor="+peopleSensors[i][0]+"&rSubSensor="+peopleSensors[i][1]+"+In", "csv");
      peopleOut[i] = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate="+urlStartTimestamp+"&rToDate="+urlEndTimestamp+"&rFamily=people_sh&rSensor="+peopleSensors[i][0]+"&rSubSensor="+peopleSensors[i][1]+"+Out", "csv");
    } 
    catch (RuntimeException e) {
      println("Can't load data from "+peopleSensors[i][0]+": "+peopleSensors[i][1]+" for period "+startTimestamp+" to "+endTimestamp);
      continue;
    }
  }

  people = new ArrayList<PImage>();
  faces = new PImage[nFaces];
  PImage maskImage = loadImage("mask.png");
  for (int i=0; i<nFaces; i++) {
    faces[i] = loadImage("faces/"+nf(i+1,6)+".jpg");
    faces[i].mask(maskImage);
  }
  
  updateTimer = millis();
}

void draw() {
  fill(255,255,255,10);
  noStroke();
  int x1 = 100;
  int y1 = 100;
  int x2 = 400;
  int y2 = 300;
  rect(0, 0, width, height);
  //rect(x1, y1, width-x2, height-y2);

  if (millis() - updateTimer > updateTime) {
        
    int pIn = 0;
    int pOut = 0;
  
    for (int i=0; i<peopleSensors.length; i++) { 
      if (peopleIn[i] == null) {
        textSize(10);
        fill(0);
        text("Can't load data from "+peopleSensors[i][0]+": "+peopleSensors[i][1]+" for period "+startTimestamp+" to "+endTimestamp, 10, 10+20*i);
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
    //nPeople = max(0, nPeople + pIn - pOut);
  
    fill(0, 0, 255);
    //pack2();
    pack2(x1,y1,x2,y2);
  
    textSize(20);
    fill(0);
    text(crntTimestamp, 10, height-20);
    text(people.size(), width-40, height-20);
  
    calendar.add(Calendar.MINUTE, 5);
    crntTimestamp = timestampFormat.format(calendar.getTime());
    if (crntTimestamp.compareTo(endTimestamp) == 0) {
      crntTimestamp = startTimestamp;
      calendar.setTime(dateStart);
    }
    updateTimer = millis();
  }
}

void pack(float n) {
  if (n == 0) {
    return;
  }
  int nx = ceil(sqrt(n));
  int ny = ceil(n/nx);
  float r = min(height/ny, width/nx);
  int nd = 0;
  for (int i=0; i<ny; i++) {
    for (int j=0; j<nx; j++) {
      if (nd < n) {
        pushMatrix();
        translate(j*width/nx, i*height/ny);
        fill(50, 100, 150);
        ellipse((width/nx)/2, (height/ny)/2, r, r);
        popMatrix();
        nd++;
      }
    }
  }
}

void pack2(int x1, int y1, int x2, int y2) {
  if (people.size() == 0) {
    return;
  }
  int[] fs = getClosestFactors(people.size(), 0.05); 
  int nx = fs[1];
  int ny = fs[0];
  float r = min((y2-y1)/ny, (x2-x1)/nx);
  int faceIdx = 0;
  //println(n,nx,ny);
  for (int j=0; j<ny; j++) {
    for (int i=0; i<nx; i++) {
      if (faceIdx < people.size()) { //we might have more cells than people
        pushMatrix();
        translate(i*(x2-x1)/nx+x1, j*(y2-y1)/ny+y1);
        //ellipse((width/nx)/2, (height/ny)/2, r,r);
        try {
          image(people.get(faceIdx), 0, 0, r, r);
        } catch (NullPointerException e) {
          println("Can't find a face at index "+faceIdx);
        }
        
        popMatrix();
      }
      faceIdx++;
       // nd++;
      //}
    }
  }
}

void pack2() {
  if (people.size() == 0) {
    return;
  }
  int[] fs = getClosestFactors(people.size(), 0.05); 
  int nx = fs[1];
  int ny = fs[0];
  float r = min(height/ny, width/nx);
  int faceIdx = 0;
  //println(n,nx,ny);
  for (int j=0; j<ny; j++) {
    for (int i=0; i<nx; i++) {
      if (faceIdx < people.size()) { //we might have more cells than people
        pushMatrix();
        translate(i*width/nx, j*height/ny);
        //ellipse((width/nx)/2, (height/ny)/2, r,r);
        try {
          image(people.get(faceIdx), 0, 0, r, r);
        } catch (NullPointerException e) {
          println("Can't find a face...");
        }
        
        popMatrix();
      }
      faceIdx++;
       // nd++;
      //}
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
