
import processing.sound.*;

class InputController {

  AudioIn input;
  Amplitude loudness;
  
  InputController(PApplet parent) {
     input = new AudioIn(parent, 0);
     input.start();
     loudness = new Amplitude(parent);
     loudness.input(input);
  }
}
