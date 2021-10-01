float allRates = 1.0;
float allPan = 0.0;

SoundController sndCtrl;

void setup() {
  size (300, 300);

  sndCtrl = new SoundController();
}


void draw() {
  background(0);
  // Adjust the gain based on the mouse position of the four quadrants
  // g1 gain temp
  float map1X = map(mouseX, 0, width, 1, 0);
  float map1Y = map(mouseY, 0, height, 1, 0);
  float convert1 = (map1X + map1Y)/2;
  // g2 gain people
  float map2X = map(mouseX, 0, width, 0, 1);
  float map2Y = map(mouseY, 0, height, 1, 0);
  float convert2 = (map2X + map2Y)/2;
  // g3 gain wind
  float map3X = map(mouseX, 0, width, 0, 1);
  float map3Y = map(mouseY, 0, height, 0, 1);
  float convert3 = (map3X + map3Y)/2;

  // set gain //
  // gain vaues mapped before calling method //
  sndCtrl.setGain("temp", convert1);
  sndCtrl.setGain("people", convert2);
  sndCtrl.setGain("wind", convert3);

  // show the text for the quadrants
  textSize(12);
  text("temperature and people", 20, 20);
  text("people & wind", width-100, height-20);
  text("Wind & Temp", 20, height-20);
  text("Mix all", width/2-20, height/2);

  // draw the line to show gain position
  float gainPos = map(allRates, 0, 5, 0, height);
  // light up the line if the gain is at 1
  if (allRates == 1.0)
  {
    stroke(128, 222, 234);
    strokeWeight(2);
  } else
  {
    stroke(0, 0, 100);
    strokeWeight(1);
  }
  line(0, gainPos, width, gainPos);
}

// adjust the speed and pan
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      // increase envelope
      if (allRates < 5)
      {
        allRates += 0.02;
      }
    } else if (keyCode == DOWN) {
      // decrease envelope
      if (allRates > 0)
      {
        allRates -= 0.02;
      }
    }
    if (keyCode == RIGHT) {
      // increase envelope
      if (allPan < 1)
      {
        allPan += 0.1;
      }
    } else if (keyCode == LEFT) {
      // decrease envelope
      if (allPan > -1.0)
      {
        allPan -= 0.1;
      }
    }
  }


  // ******** //
  // set rate //
  // ******** //
  sndCtrl.setRate(allRates);
}
