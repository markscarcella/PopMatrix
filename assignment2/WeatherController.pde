import java.util.Date;
import java.util.Calendar;
import java.util.GregorianCalendar; 

class WeatherController {
  String urlStartTimestamp, urlEndTimestamp;


  String[] windDirectionSensor = {"weather", "WD"};
  String[] windSpeedSensor = {"weather", "IWS"};
  String[] temperatureSensor = {"weather", "AT"};

  Table windDirectionData, windSpeedData, temperatureData;

  Wind[] wind;
  int nParticles;
  float windDirection;
  float windSpeed;
  float temperature;


  WeatherController(String _urlStartTimestamp, String _urlEndTimestamp, int nParticles, int windSize) {
    urlStartTimestamp = _urlStartTimestamp;
    urlEndTimestamp = _urlEndTimestamp;

    wind = new Wind[nParticles];
    for (int i=0; i<nParticles; i++) {    
      wind[i] = new Wind(
        random(width), // x position
        random(height/2), // y position
        windSize, // wind width
        color(0, 0, random(0, 255))
        );
    }

    loadData();
  }

  void loadData() {

    windDirectionData = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate="+urlStartTimestamp+"&rToDate="+urlEndTimestamp+"&rFamily="+windDirectionSensor[0]+"&rSensor="+windDirectionSensor[1], "csv");
    windSpeedData = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate="+urlStartTimestamp+"&rToDate="+urlEndTimestamp+"&rFamily="+windSpeedSensor[0]+"&rSensor="+windSpeedSensor[1], "csv");
    temperatureData = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate="+urlStartTimestamp+"&rToDate="+urlEndTimestamp+"&rFamily="+temperatureSensor[0]+"&rSensor="+temperatureSensor[1], "csv");

    SimpleDateFormat timestampFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    Calendar weatherCalendar = Calendar.getInstance();

    // remap windDirection timestamps to the 0,5,10,15,...
    for (int i=0; i<windDirectionData.getRowCount(); i++) {
      Date windDirTime = new Date();
      String windTimestamp = windDirectionData.getString(i, 0);
      try {
        windDirTime = timestampFormat.parse(windTimestamp);
      } 
      catch (ParseException e) {
        e.printStackTrace();
      }
      weatherCalendar.setTime(windDirTime);
      int unroundedMinutes = weatherCalendar.get(Calendar.MINUTE);
      int mod = unroundedMinutes % 5;
      weatherCalendar.add(Calendar.MINUTE, mod < 3 ? -mod : (5-mod));
      weatherCalendar.set(Calendar.SECOND, 0);
      windDirectionData.setString(i, 0, timestampFormat.format(weatherCalendar.getTime()));
    }

    // remap windSpeed timestamps to the 0,5,10,15,...
    for (int i=0; i<windSpeedData.getRowCount(); i++) {
      Date windSpeedTime = new Date();
      String windTimestamp = windDirectionData.getString(i, 0);
      try {
        windSpeedTime = timestampFormat.parse(windTimestamp);
      } 
      catch (ParseException e) {
        e.printStackTrace();
      }
      weatherCalendar.setTime(windSpeedTime);
      int unroundedMinutes = weatherCalendar.get(Calendar.MINUTE);
      int mod = unroundedMinutes % 5;
      weatherCalendar.add(Calendar.MINUTE, mod < 3 ? -mod : (5-mod));
      weatherCalendar.set(Calendar.SECOND, 0);
      windSpeedData.setString(i, 0, timestampFormat.format(weatherCalendar.getTime()));
    }

    // remap windSpeed timestamps to the 0,5,10,15,...
    for (int i=0; i<temperatureData.getRowCount(); i++) {
      Date temperatureTime = new Date();
      String temperatureTimestamp = temperatureData.getString(i, 0);
      try {
        temperatureTime = timestampFormat.parse(temperatureTimestamp);
      } 
      catch (ParseException e) {
        e.printStackTrace();
      }
      weatherCalendar.setTime(temperatureTime);
      int unroundedMinutes = weatherCalendar.get(Calendar.MINUTE);
      int mod = unroundedMinutes % 5;
      weatherCalendar.add(Calendar.MINUTE, mod < 3 ? -mod : (5-mod));
      weatherCalendar.set(Calendar.SECOND, 0);
      temperatureData.setString(i, 0, timestampFormat.format(weatherCalendar.getTime()));
    }
  }

  void update (String crntTimestamp) {

    TableRow windDirectionRow = windDirectionData.findRow(crntTimestamp, 0);
    if (windDirectionRow != null) {
      windDirection = windDirectionRow.getFloat(1);
    }
    TableRow windSpeedRow = windSpeedData.findRow(crntTimestamp, 0);
    if (windSpeedRow != null) {
      windSpeed = windSpeedRow.getFloat(1);
    }

    TableRow temperatureRow = temperatureData.findRow(crntTimestamp, 0);
    if (temperatureRow != null) {
      temperature = temperatureRow.getFloat(1);
    }
    
    for (int i=0; i<wind.length; i++) {
      wind[i].update(windDirection, windSpeed, temperature);
    }
  }

  void display() {
    for (int i=0; i<wind.length; i++) {
      wind[i].display();
    }
  }
}

class Wind {
  color c;
  float xPos;
  float yPos;
  float windSize;
  float theta;
  float xRot;
  float yRot;
  float windDirection;
  float windSpeed;

  Wind(float _xPos, float _yPos, float _windSize, color _c) {
    c = _c;
    xPos = _xPos;
    yPos = _yPos;
    windSize = _windSize;
    xRot = xPos+random(0, 100);
    yRot = yPos+random(0, 100);
  }

  void update(float _windDirection, float _windSpeed, float _temperature) {
    windDirection = map(_windDirection, 0, 360, -0.01, 0.01);
    windSpeed = map(_windSpeed, 0, 20, 0, 100);
    c = color(255,255,map(_temperature, 35, 15, 0, 200)+random(50));
  }

  void display() {
    pushMatrix();                          
    translate(xRot, yRot);
    rotate(theta);
    fill(255, 255, 255);
    fill(c);
    ellipse(xPos-xRot, yPos-yRot, windSize, windSize); // draw wind     
    popMatrix();  
    theta += windDirection * windSpeed;

    if (xPos > width+windSize) xPos = 0;
    if (xPos < 0) xPos = width;
    if (yPos > height+windSize) yPos = 0;
    if (yPos < 0) yPos = height;
  }
}
