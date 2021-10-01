import beads.*;
import java.util.Arrays;

class SoundController {
  AudioContext ac;
  Panner p1, p2, p3;
  Gain g1, g2, g3;
  
  Envelope rate1, rate2, rate3;
  float allRates = 1.0;
  float allPan = 0.0;

  float temp = 25.0;
  float windSpeed = 5.0;
  float people = 0.0;
  
  String path = "/Volumes/GoogleDrive-111619245810311207262/My Drive/2021/IM/Assignment2/PopMatrix/assignment2/data/music/";

  SoundController() {
    ac = new AudioContext();

    loadSounds();
  }

  void loadSounds() {

    String file1 = path+"01_temperature_Piano Loop.wav";
    SamplePlayer player1 = new SamplePlayer(ac, SampleManager.sample(file1));

    String file2 = path+"School_Ambience_01.mp3";
    SamplePlayer player2 = new SamplePlayer(ac, SampleManager.sample(file2));

    String file3 = path+"03_wind_Strings Solo Loop.wav";
    SamplePlayer player3 = new SamplePlayer(ac, SampleManager.sample(file3));

    // set the envelope rates
    rate1 = new Envelope(ac, allRates);
    rate2 = new Envelope(ac, allRates);
    rate3 = new Envelope(ac, allRates);

    player1.setRate(rate1);
    player2.setRate(rate2);
    player3.setRate(rate3);

    // enable looping
    player1.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    player2.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    player3.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);

    // set up panners
    p1 = new Panner(ac, allPan);
    p2 = new Panner(ac, allPan); 
    p3 = new Panner(ac, allPan);

    // set up gain
    g1 = new Gain(ac, 2, 0.1);
    g2 = new Gain(ac, 2, 0.2);
    g3 = new Gain(ac, 2, 0.1);

    p1.addInput(player1);
    p2.addInput(player2);
    p3.addInput(player3);

    g1.addInput(p1);
    g2.addInput(p2);
    g3.addInput(p3);

    Gain masterGain = new Gain(ac, 2, 1);
    masterGain.addInput(g1);
    masterGain.addInput(g2);
    masterGain.addInput(g3);
    
    ac.out.addInput(masterGain);
    
    ac.start();
  }
  
  void setGain(String type, float data)
  {
    // data should be mapped before calling this method
    // gain can be 0 to 1
    switch(type)
    {
      case "temp":
        g1.setGain(abs(data));
      break;
      case "people":
        g2.setGain(abs(data));
      break;
      case "wind":
        g3.setGain(abs(data));
      break;
    }
  }
  
  void setRate(float speed)
  {
    // 1.0 is natural speed
    allRates = speed;
    
    rate1.setValue(allRates);
    rate2.setValue(allRates);
    rate3.setValue(allRates);
  }
}
