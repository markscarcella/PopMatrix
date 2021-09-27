
WindSwirl[] wind;

Table table;


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
  for (int i = 0; i < wind.length; i++) {
    wind[i].display();
    wind[i].move();
  }
  trail(); // function to add trail effect
}

void loadData() {

  // load table data into a Table object called table
  table = loadTable("https://eif-research.feit.uts.edu.au/api/csv/?rFromDate=2021-09-21T23%3A33%3A42&rToDate=2021-09-23T23%3A33%3A42&rFamily=weather&rSensor=WD", "csv");

  // initialise array of WindSwirl objects called wind at the size of the table.
  wind = new WindSwirl[table.getRowCount()];

  // iterate over all the rows in the table
  int rowCount = 0;
  //int[] data = new int[table.getRowCount()];  // declare array
  for (TableRow row : table.rows()) {
    float windDirectData = row.getFloat(1);
    
    //TUNABLE PARAMETERS
    // create new WindSwirl objects out of the data
    wind[rowCount] = new WindSwirl(
      random(width), // x position
      random(height), // y position
      5, // wind width
      5, // wind height
      random(-2, 2), // x speed
      random(1, 3), // y speed
      windDirectData);       // wind data used to change direction of objects


    // increment row count
    rowCount++;
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
  float theta = random(-1, 1);  //angle of rotation of WindSwirls

  WindSwirl(float _xPos, float _yPos, float _swirlWidth, float _swirlHeight, float _xSpeed, float _ySpeed, float _windDirectData) {
    c = color(random(0, 255), random(0, 255), random(0, 255));
    xPos = _xPos;
    yPos = _yPos;
    swirlWidth = _swirlWidth;
    swirlHeight = _swirlHeight;
    ySpeed = _ySpeed;
    xSpeed = _xSpeed;
    windDirectData = _windDirectData;

  }

  void display() {
    pushMatrix();                          
    translate(width/2, height/2);          // centre rotation
    fill(204, 255, 255);    
   // fill(random(0, 255), random(0, 255), random(0, 255)); //rainbow
    pushMatrix();     
    rotate(theta + windDirectData);
    translate(xPos, yPos);                 // centre rotion relative to each object
    ellipse(0, 0, swirlWidth, swirlHeight); // draw wind
    popMatrix();                          
    popMatrix();                           
  
  theta -= 0.01;
  //trying to get theta to go clockwise and anticlockwise
 // if(theta > 0) theta -= 0.02; 
 // if(theta < 0) theta += 0.02;
  
  }

  void move () {
    xPos = xPos + xSpeed;
    yPos = yPos + ySpeed;
    if (xPos > width+swirlHeight) xPos = 0;
    if (xPos < 0) xPos = width;
    if (yPos > height+swirlWidth) yPos = 0;
    if (yPos < 0) yPos = height;
  }
}

void trail () {
  pushStyle();
  translate(width/2, height/2);
  noStroke();
  fill(0, 0, 0, 15);
  rect(0, 0, width, height);
  popStyle();
}
