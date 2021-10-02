import java.util.Date;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.text.*;

SoundController sc;
PeopleController pc;
WeatherController wc;
InputController ic;

String startTimestamp = "2020-12-08 05:00:00";
String endTimestamp = "2020-12-31 05:00:00";
String crntTimestamp = "";
String urlStartTimestamp = "";
String urlEndTimestamp = "";
SimpleDateFormat timestampFormat;
SimpleDateFormat urlTimestampFormat;
Date dateStart;
Date dateEnd;
Calendar calendar;

int updateTimer = 0;
int updateTime = 1000; //update time in ms

PImage building;
PImage logo;
color bg;

float blendAmt = 0;

void setup() {
  size(1200, 800);
  frameRate(30);
  rectMode(CORNER);
  ellipseMode(CENTER);
  textSize(20);
  textAlign(CENTER);
  background(255);
  noStroke();

  // load images
  building = loadImage("building_black.png");
  logo = loadImage("logo_greenglow.png");

  // setup calendars, dates and times
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

  // setup controllers
  ic = new InputController(this);  
  sc = new SoundController();
  pc = new PeopleController(urlStartTimestamp, urlEndTimestamp, 120, 320, 1020, height-50);
  wc = new WeatherController(urlStartTimestamp, urlEndTimestamp, 1000, 20);
  
  // start the timer
  updateTimer = millis();
}

void draw() {  
  
  if (millis() - updateTimer > updateTime) {

    // update everything
    pc.update(crntTimestamp);
    wc.update(crntTimestamp);
    sc.setGain("people",map(pc.nPeople,0,300,0,1));
    sc.setGain("wind",map(wc.windSpeed,0,15,0,1));
    sc.setGain("temperature",map(wc.temperature,15,35,0,1));
    blendAmt += PI/24; // cycle between colours every hour
  
    // add 5 minutes and update timestamp
    calendar.add(Calendar.MINUTE, 5);
    crntTimestamp = timestampFormat.format(calendar.getTime());
    if (crntTimestamp.compareTo(endTimestamp) == 0) {
      crntTimestamp = startTimestamp;
      calendar.setTime(dateStart);
    }
    
    // reset timer
    updateTimer = millis();
  }
  
  color from = color(255, 0, 0, 10);
  color to = color(0, 0, 255, 10);
  color interA = lerpColor(from, to, abs(sin(blendAmt)));
  fill(interA);
  rect(0, 0, width, height);

  // display wind
  wc.display();
  
  // add the building shape
  image(building, 0, 0);
  // add the logo        
  image(logo, 900, 210);
  
  // display people
  pc.display();

  if (keyPressed) {
   if (key == ' ') {
    updateTime = int(map(ic.loudness.analyze(),0,0.3,1000,10));
    sc.setRate(map(updateTime,10,1000,1.5,1)); 
   }  
   else if (key == 'i') {
    fill(255); //we need to set a variable to be able to change the colour of the text relative to the colour of the building
    rect(0,0, width, 80);
    fill(0);
    text("Date & Time", 0.1*width, 30);
    text(crntTimestamp, 0.1*width, 60);
    text("People inside", 0.3*width, 30);
    text(pc.people.size(), 0.3*width, 60);
    text("Wind Speed", 0.5*width, 30);
    text(int(wc.windSpeed)+" km/h", 0.5*width, 60);
    text("Wind Direction", 0.7*width, 30);
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
    text(int(wc.windDirection)+"° ("+windDir+")", 0.7*width, 60);
    text("Temperature", 0.9*width, 30);
    text(int(wc.temperature)+"°C", 0.9*width, 60);
   } 
  }
  else {
    fill(255,255,255,100);
    text("Press i for info...", 0.1*width, 30);
  }
  fill(255,255,255,200);
  text("Hold space and sing to speed up time...", 0.5*width, height - 20);
}

void keyReleased() {
   if (key == ' ') {
      updateTime = 1000; 
   }
}
