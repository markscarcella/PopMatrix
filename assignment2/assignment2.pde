import java.util.Date;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.text.*;

SoundController sc;
PeopleController pc;
WeatherController wc;

int nc, nf, nx, ny;

String startTimestamp = "2020-12-08 05:00:00";
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

int updateTimer = 0;
int updateTime = 100; //update time in ms

PImage building;
PImage logo;
color bg;

float blendAmt = 0;

void setup() {
  size(1200, 800);
  frameRate(120);
  rectMode(CORNER);
  //colorMode(HSB, height, height, height);
  
  //sc = new SoundController();
  //  sc.setGain("wind",0);
  //  sc.setGain("people",0);
  //  sc.setGain("temperature",0);
    
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

  //int x1 = 120;
  //int y1 = 320;
  //int x2 = 1020;
  //int y2 = height-20;
  pc = new PeopleController(urlStartTimestamp, urlEndTimestamp, 120, 320, 1020, height-20);
  wc = new WeatherController(urlStartTimestamp, urlEndTimestamp, 1000, 20);
  
  updateTimer = millis();
}

void draw() {  
  //fill(153, 204, map(wc.temperature, 15,35,0,255), 10);
  //float green = map(wc.temperature, 25, 35 ,255, 153);
  //fill(255, green, 153, 10);
  color from = color(204, 102, 0, 10);
  color to = color(0, 102, 153, 10);
  color interA = lerpColor(from, to, blendAmt);
  fill(interA);
  blendAmt += 0.01;
  println(blendAmt);
  noStroke();
  rect(0, 0, width, height);
  
  if (millis() - updateTimer > updateTime) {
    
    // update everything
    pc.update(crntTimestamp);
    wc.update(crntTimestamp);
    //sc.setGain("people",map(pc.people.size(),0,200,0,1));
    //sc.setGain("wind",map(wc.windSpeed,0,25,0,1));

    // add 5 minutes and update timestamp
    peopleCalendar.add(Calendar.MINUTE, 5);
    crntTimestamp = timestampFormat.format(peopleCalendar.getTime());
    if (crntTimestamp.compareTo(endTimestamp) == 0) {
      crntTimestamp = startTimestamp;
      peopleCalendar.setTime(dateStart);
    }
    
    // reset timer
    updateTimer = millis();
  }
  
  //sc.setRate(map(updateTime,100,2000,1.5,1));
  //updateTime = int(map(mouseY,0,height,100,2000));
  
  // display wind
  wc.display();
  
  // add the building shape
  //tint(bg);
  image(building, 0, 0);
  // add the logo
  //noTint();
  image(logo, 900, 210);
  
  // display people
  pc.display();

  if (keyPressed) {
   if (key == 'i') {
    textSize(20);
    fill(255); //we need to set a variable to be able to change the colour of the text relative to the colour of the building
    rect(0,height-80,width, height-80);
    fill(0);
    text("Date & Time:", 170, height-50);
    text(crntTimestamp, 120, height-20);
    text("People inside:", width-300, height-50);
    text(pc.people.size(), width-240, height-20);
    text("Wind Speed:", width/2-150, height-50);
    text(int(wc.windSpeed)+" km/h", width/2-120, height-20);
    text("Wind Direction:", width/2+50, height-50);
    
    String windDir = "";
    
    if (wc.windDirection > 315 && wc.windDirection < 45) {
       windDir = "E";
    } 
    else if (wc.windDirection > 45 && wc.windDirection < 135) {
       windDir = "S"; 
    }
    else if (wc.windDirection > 135 && wc.windDirection < 225) {
       windDir = "W"; 
    }
    else if (wc.windDirection > 225 && wc.windDirection < 315) {
       windDir = "N"; 
    }
    text(int(wc.windDirection)+"° ("+windDir+")", width/2+80, height-20);
    text(int(wc.temperature)+"°C", width-80, height-20);

   }
  }
}
