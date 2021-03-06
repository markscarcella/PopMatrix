import java.util.Date;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.text.*;

ControlP5 cp5;

SoundController sc;
PeopleController pc;
WeatherController wc;
InputController ic;
DatePicker dp;

String startTimestamp = "2020-12-08 00:00:00";
String endTimestamp = "2020-12-31 00:00:00";
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

PImage building_dawn, building_day, building_evening, building_night;
PImage logo;
color bg;

color[] bgColour;
int bgIdx = 0;
float bgBlend = 0;

void setup() {
  size(1200, 800);
  frameRate(30);
  rectMode(CORNER);
  ellipseMode(CENTER);
  textSize(20);
  textAlign(CENTER);
  background(255);
  noStroke();

  cp5 = new ControlP5(this);

  // set background colours for each hour
  bgColour = new color[] {
    color(14, 14, 14,50), //12-1 
    color(14, 14, 14,50), //1-2
    color(14, 14, 14,50), 
    color(14, 14, 14,50), 
    color(8, 8, 72,50), 
    color(12, 12, 140,50), 
    color(207, 223, 255,50), 
    color(207, 223, 255,50), 
    color(219, 246, 253,50), 
    color(219, 246, 253,50), 
    color(219, 246, 253,50), 
    color(219, 246, 253,50), 
    color(54, 170, 198,50), 
    color(54, 170, 198,50), 
    color(254, 144, 67,50), 
    color(254, 144, 67,50), 
    color(255, 116, 18,50), 
    color(255, 116, 18,50), 
    color(42, 2, 83,50), 
    color(14, 14, 14,50), 
    color(14, 14, 14,50), 
    color(14, 14, 14,50), 
    color(14, 14, 14,50), 
    color(14, 14, 14,50), 
    color(14, 14, 14,50), 
  };

  // load images
  building_dawn = loadImage("building_dawn.png");
  building_day = loadImage("building_day.png");
  building_evening = loadImage("building_evening.png");
  building_night = loadImage("building_night.png");

  logo = loadImage("logo_greenglow.png");

  // setup calendars, dates and times
  timestampFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
  urlTimestampFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH'%3A'mm");
  // moved into a function for reuse
  setCalendar(startTimestamp, endTimestamp);

  // setup controllers
  ic = new InputController(this);  
  sc = new SoundController();
  //pc = new PeopleController(urlStartTimestamp, urlEndTimestamp, 120, 320, 1020, height-50);
  pc = new PeopleController(urlStartTimestamp, urlEndTimestamp, width/5, height/2, 4*width/5, height-50);
  wc = new WeatherController(urlStartTimestamp, urlEndTimestamp, 1000, 20);
  // date picker
  dp = new DatePicker(0, 80);
  cp5.hide();

  // start the timer
  updateTimer = millis();
}

void draw() {  

  if (millis() - updateTimer > updateTime) {

    // update everything
    pc.update(crntTimestamp);
    wc.update(crntTimestamp);
    sc.setGain("people", map(pc.nPeople, 0, 300, 0, 1));
    sc.setGain("wind", map(wc.windSpeed, 0, 15, 0, 1));
    sc.setGain("temperature", map(wc.temperature, 15, 35, 0, 1));
    sc.setRate(1000./updateTime);

    bgBlend += 1./12;
    if (bgBlend > 1) {
      bgBlend = 1./12;
      bgIdx = (bgIdx+1)%bgColour.length;
    }

    // add 5 minutes and update timestamp
    calendar.add(Calendar.MINUTE, 5);
    crntTimestamp = timestampFormat.format(calendar.getTime());
    println(crntTimestamp, endTimestamp);
    if (crntTimestamp.compareTo(endTimestamp) == 0) {
      crntTimestamp = startTimestamp;
      calendar.setTime(dateStart);
    }

    // reset timer
    updateTimer = millis();
  }

  color from = bgColour[bgIdx];
  color to = bgColour[(bgIdx+1)%bgColour.length];
  color blend = lerpColor(from, to, bgBlend);
  fill(blend);
  rect(0, 0, width, height);

  // display wind
  wc.display();

  // add the building shape
  if (bgIdx < 5 || bgIdx >= 19) {
    image(building_night, 0, 0);
  } else if (bgIdx < 6) {
    image(building_dawn, 0, 0);
  } else if (bgIdx < 16) {
    image(building_day, 0, 0);
  } else if (bgIdx < 19) {
    image(building_evening, 0, 0);
  }
  // add the logo        
  //image(logo, 900, 210);

  // display people
  pc.display();

  if (keyPressed) {
    textSize(20);
    textAlign(CENTER);
    if (key == 'f') {
      updateTime = 100;
    }
    else if (key == ' ') {
      updateTime = int(map(ic.loudness.analyze(), 0, 0.5, 1000, 10));
      if (updateTime < 10) {
        updateTime = 10;
      }
      sc.setRate(map(updateTime, 10, 1000, 1.5, 1)); 
      fill(255, 255, 255, 100);
      text("Time going at "+int(100000./updateTime)+"%", 0.5*width, height - 20);
    } else if (key == 'i') {
      fill(255); 
      rect(0, 0, width, 80);
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
      } else if (wc.windDirection > 45 && wc.windDirection < 135) {
        windDir = "S";
      } else if (wc.windDirection > 135 && wc.windDirection < 225) {
        windDir = "W";
      } else if (wc.windDirection > 225 && wc.windDirection < 315) {
        windDir = "N";
      }
      text(int(wc.windDirection)+"?? ("+windDir+")", 0.7*width, 60);
      text("Temperature", 0.9*width, 30);
      text(int(wc.temperature)+"??C", 0.9*width, 60);
      // show the date picker
      cp5.show();
    }
  } else {
    fill(0, 0, 0, 100);
    text("Hold i for info...", 0.1*width, 30);
    fill(255, 255, 255, 100);
    text("Hold f to fast forward, or hold space to sing to speed up time...", 0.5*width, height - 20);
  }
}

void keyReleased() {
  if (key == ' ' || key == 'f') {
    updateTime = 1000;
  }
  // hide the date picker after letting go of the i key
  if (key == 'i') {
    cp5.hide();
  }
}

//
void setCalendar(String start, String end)
{
  dateStart = new Date();
  dateEnd = new Date();
  try {
    dateStart = timestampFormat.parse(start);
    dateEnd = timestampFormat.parse(end);
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
  
  //pc = new PeopleController(urlStartTimestamp, urlEndTimestamp, 120, 320, 1020, height-50);
  pc = new PeopleController(urlStartTimestamp, urlEndTimestamp, width/5, height/2, 4*width/5, height-50);
  wc = new WeatherController(urlStartTimestamp, urlEndTimestamp, 1000, 20);
}

// capture the set date click event
// this throws an exception on start not sure why
void controlEvent(ControlEvent theEvent) {
  println("got a control event from controller with id "+theEvent.getController().getId());

  if (theEvent.isFrom(cp5.getController("loadDate"))) {
    startTimestamp = dp.date[2]+"-"+dp.date[1]+"-"+dp.date[0]+" 00:00:00";
    endTimestamp = dp.date[2]+"-"+dp.date[1]+"-"+dp.date[0]+" 23:55:00";

    println(startTimestamp);

    setCalendar(startTimestamp, endTimestamp);
    bgIdx = 0;
  }
}
