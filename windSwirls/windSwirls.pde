
WindSwirl[] wind;
int nSwirls = 10;

Table windDirTable;
Table windSpeedTable;
Table windGustTable;

int rowIdx = 0;

void setup() {
  size(1000, 600);
  pixelDensity(2);
  noStroke();
  rectMode(CENTER);
  loadData();
}

// draw function
void draw() {
  // display and move WindSwirl object for each row in the data table
  TableRow windDirRow = windDirTable.getRow(rowIdx);
  float windDir = windDirRow.getFloat(1);
  
  TableRow windSpeedRow = windSpeedTable.getRow(rowIdx);
  float windSpeed = windSpeedRow.getFloat(1);
  
  TableRow windGustRow = windGustTable.getRow(rowIdx);
  float windGust = windGustRow.getFloat(1);
  
  for (int i = 0; i < wind.length; i++) {
    wind[i].windDirectData = radians(windDir);//map(windDir,0,360,-PI,PI);//
    wind[i].windGust = map(windGust,0,25,-20,20);
    wind[i].xSpeed = map(windSpeed,0,30,0,5);
    wind[i].ySpeed = 0;
    wind[i].move();
    wind[i].display();
  }
  trail(); // function to add trail effect
  
  rowIdx = (rowIdx+1)%windDirTable.getRowCount();
}

void loadData() {

  // load table data into a Table object called table
  windDirTable = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-09-29T07%3A06%3A52&rToDate=2021-10-01T07%3A06%3A52&rFamily=weather&rSensor=WD", "csv");
  windSpeedTable = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-09-29T07%3A06%3A52&rToDate=2021-10-01T07%3A06%3A52&rFamily=weather&rSensor=IWS", "csv");
  windGustTable = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-09-29T07%3A06%3A52&rToDate=2021-10-01T07%3A06%3A52&rFamily=weather&rSensor=PW", "csv");

  // initialise array of WindSwirl objects called wind at the size of the table.
  
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
  float windGust;
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
    //ellipse(0, 0, 10, 10); // draw wind

    //fill(204, 255, 255);    
    //pushMatrix(); 
    rotate(theta);
    //translate(xPos, yPos);                 // centre rotion relative to each object
    fill(255,255,255);
    fill(c);
    ellipse(xPos-xRot, yPos-yRot, swirlWidth, swirlHeight); // draw wind


    //popMatrix();                          
    popMatrix();                           
  
  theta = windDirectData;
  //trying to get theta to go clockwise and anticlockwise
 // if(theta > 0) theta -= 0.02; 
 // if(theta < 0) theta += 0.02;
  
  }

  void move () {
    //xPos += xSpeed;//sin(windDirectData);
    //yPos += random(-10,10);
    if (xPos > width+swirlHeight) xPos = 0;
    if (xPos < 0) xPos = width;
    if (yPos > height+swirlWidth) yPos = 0;
    if (yPos < 0) yPos = height;
    //theta -= 0.01;
  }
}

void trail () {
  pushStyle();
  translate(width/2, height/2);
  noStroke();
  fill(255, 255, 255, 10);
  rect(0, 0, width, height);
  popStyle();
}
