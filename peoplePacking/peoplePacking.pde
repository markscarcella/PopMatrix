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

String[] windDirectionSensor = {"weather","WD"};
String[] windSpeedSensor = {"weather","IWS"};

String startTimestamp = "2020-12-01 05:00:00";
String endTimestamp = "2020-12-31 05:00:00";

String crntTimestamp = "";
String urlStartTimestamp = "";
String urlEndTimestamp = "";
SimpleDateFormat timestampFormat;
SimpleDateFormat urlTimestampFormat;
Date dateStart;
Date dateEnd;
Calendar peopleCalendar;
Calendar windCalendar;

PImage[] faces;
int nFaces = 20; // up to 1000

int updateTimer = 0;
int updateTime = 500; //update time in ms

PImage building;
PImage logo;
color bg;

int nSwirls = 1000;
WindSwirl[] wind;
Table windDirection;
Table windSpeed;
int windMinOffset = 3;
int windSecOffset = 14;
String crntWindTimestamp;
float wd, ws;

void setup() {
 size(1200, 800);
 frameRate(120);
 rectMode(CORNER);
 //colorMode(HSB, height, height, height);
 
  //pg = createGraphics(1200, 800);
  building = loadImage("building_white.png");
  logo = loadImage("logo.png");
  
  ellipseMode(CENTER);
  background(255);
  //frameRate(30.0);

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

  peopleCalendar = Calendar.getInstance();

  peopleCalendar.setTime(dateEnd);
  urlEndTimestamp = urlTimestampFormat.format(peopleCalendar.getTime());

  peopleCalendar.setTime(dateStart);
  urlStartTimestamp = urlTimestampFormat.format(peopleCalendar.getTime());
  crntTimestamp = timestampFormat.format(peopleCalendar.getTime());  
  
  windCalendar = Calendar.getInstance();
  windCalendar.setTime(dateStart);
  windCalendar.add(Calendar.MINUTE, windMinOffset);
  windCalendar.add(Calendar.SECOND, windSecOffset);
  crntWindTimestamp = timestampFormat.format(windCalendar.getTime());
  
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
  windDirection = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate="+urlStartTimestamp+"&rToDate="+urlEndTimestamp+"&rFamily="+windDirectionSensor[0]+"&rSensor="+windDirectionSensor[1], "csv");
  for (int i=0; i<windDirection.getRowCount(); i++) {
    Date windDirTime = new Date();
    String windTimestamp = windDirection.getString(i,0);
    try {
      windDirTime = timestampFormat.parse(windTimestamp);
    } catch (ParseException e) {
    e.printStackTrace();    
    }
    // map timestamps to nearest 5 minutes
    windCalendar.setTime(windDirTime);
    int unroundedMinutes = windCalendar.get(Calendar.MINUTE);
    int mod = unroundedMinutes % 5;
    windCalendar.add(Calendar.MINUTE, mod < 3 ? -mod : (5-mod));
    windCalendar.set(Calendar.SECOND,0);
    windDirection.setString(i,0,timestampFormat.format(windCalendar.getTime()));

  }
    
  windSpeed = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate="+urlStartTimestamp+"&rToDate="+urlEndTimestamp+"&rFamily="+windSpeedSensor[0]+"&rSensor="+windSpeedSensor[1], "csv");
  for (int i=0; i<windSpeed.getRowCount(); i++) {
    Date windSpeedTime = new Date();
    String windTimestamp = windDirection.getString(i,0);
    try {
      windSpeedTime = timestampFormat.parse(windTimestamp);
    } catch (ParseException e) {
    e.printStackTrace();    
    }
    
    // map timestamps to nearest 5 minutes
    windCalendar.setTime(windSpeedTime);
    int unroundedMinutes = windCalendar.get(Calendar.MINUTE);
    int mod = unroundedMinutes % 5;
    windCalendar.add(Calendar.MINUTE, mod < 3 ? -mod : (5-mod));
    windCalendar.set(Calendar.SECOND,0);
    windSpeed.setString(i,0,timestampFormat.format(windCalendar.getTime()));

  }
  wind = new WindSwirl[nSwirls];
  for (int i=0; i<nSwirls; i++) {    
    wind[i] = new WindSwirl(
      random(width), // x position
      random(height), // y position
      20, // wind width
      20, // wind height
      0, // x speed
      0, // y speed
      0); // wind data used to change direction of objects
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

  // loading message
  textSize(28);
  String loadText = "Loading, please wait";
  float tW = textWidth(loadText);
  fill(0);
  text(loadText, width/2-tW/2, height/2);
  
  noStroke();
  int x1 = 120;
  int y1 = 320;
  int x2 = 1020;
  int y2 = height-20;
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
    
    
      TableRow windDir = windDirection.findRow(crntTimestamp,0);
      if (windDir != null) {
        wd = windDir.getFloat(1);
      }
      TableRow windSp = windSpeed.findRow(crntTimestamp,0);
      if (windSp != null) {
        ws = windSp.getFloat(1); 
    
    }

    peopleCalendar.add(Calendar.MINUTE, 5);
 //   windCalendar.add(Calendar.MINUTE, 5);
    crntTimestamp = timestampFormat.format(peopleCalendar.getTime());
    if (crntTimestamp.compareTo(endTimestamp) == 0) {
      crntTimestamp = startTimestamp;
      peopleCalendar.setTime(dateStart);
      
      //windCalendar.setTime(dateStart);
      //windCalendar.add(Calendar.MINUTE, windMinOffset);
      //windCalendar.add(Calendar.SECOND, windSecOffset);
      //crntWindTimestamp = timestampFormat.format(windCalendar.getTime());
    }

    updateTimer = millis();
  }
        
    println(wd);
    for (int i = 0; i < wind.length; i++) {
      //if (wd > 180) {
      //  wind[i].windDirectData = 0.01;
      //} else {
      //  wind[i].windDirectData = -0.01;
      //}
      wind[i].windDirectData = map(wd,0,360,-0.01,0.01);
      wind[i].xSpeed = ws;
      wind[i].ySpeed = 0;
      wind[i].move();
      wind[i].display();
    }
    //trail(); // function to add trail effect

  
  //bg = color(map(mouseY,0,height,0,100), height,height);
  
  //fill(255,255,255,10);
  //rect(0, 0, width, height);
  
  
  //fill(height);
  //noStroke();
  // draw the things in the background here
  //for (int i = 0; i < 5; i++)
  //{
  //  ellipse(random(width), random(height), 60, 60);
  //}
  
  // add the building shape
  //tint(bg);
  image(building,0,0);
  // add the logo
  //noTint();
  image(logo,900,210);
  
    //pack2();
    pack2(x1,y1,x2,y2);
  //-------
  // text("Press i for Info", width/2, height/2);
  
   if (keyPressed) {
   if (key == 'i') {
    textSize(20);
    fill(0); //we need to set a variable to be able to change the colour of the text relative to the colour of the building
    text("Date & Time:", 170, height-50);
    text(crntTimestamp, 120, height-20);
    text("People inside:", width-300, height-50);
    text(people.size(), width-240, height-20);
    text("Wind Speed:", width/2-150, height-50);
    text(ws, width/2-120, height-20);
    text("Wind Direction:", width/2+50, height-50);
    text(wd, width/2+80, height-20);
    }
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


class WindSwirl {
  color c;
  float xPos;
  float yPos;
  float swirlWidth;
  float swirlHeight;
  float ySpeed;
  float xSpeed;
  float windDirectData;
  float theta = random(-1, 1);  //angle of rotation of WindSwirls
  float xRot;
  float yRot;
  
  WindSwirl(float _xPos, float _yPos, float _swirlWidth, float _swirlHeight, float _xSpeed, float _ySpeed, float _windDirectData) {
    c = color(0, 0, random(0, 255));
    xPos = _xPos;
    yPos = _yPos;
    swirlWidth = _swirlWidth;
    swirlHeight = _swirlHeight;
    ySpeed = _ySpeed;
    xSpeed = _xSpeed;
    windDirectData = _windDirectData;
    xRot = xPos+random(0,100);
    yRot = yPos+random(0,100);
  }

  void display() {
    pushMatrix();                          
    translate(xRot,yRot);
    rotate(theta);
    fill(255,255,255);
    fill(c);
    ellipse(xPos-xRot, yPos-yRot, swirlWidth, swirlHeight); // draw wind     
    popMatrix();  
    theta += windDirectData * xSpeed;
  
    //theta = windDirectData;
  //trying to get theta to go clockwise and anticlockwise
 // if(theta > 0) theta -= 0.02; 
 // if(theta < 0) theta += 0.02;
  
  }

  void move () {
    //xPos = xPos + xSpeed;
    //yPos = yPos + ySpeed;
    if (xPos > width+swirlHeight) xPos = 0;
    if (xPos < 0) xPos = width;
    if (yPos > height+swirlWidth) yPos = 0;
    if (yPos < 0) yPos = height;
  }
}

void trail () {
  pushMatrix();
  pushStyle();
  translate(0, 0);
  noStroke();
  fill(255, 255, 255, 10);
  rect(0, 0, width, height);
  popStyle();
  popMatrix();
}
