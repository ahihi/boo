import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

abstract class Scene {
  public float duration; // scene duration in beats
  
  public Scene(float duration) {
      this.duration = duration;
  }
  
  public void setup() {}
  public void draw(float beats) {}
}

class Timeline {
  public Minim minim;
  public AudioPlayer song;
  public int currentScene; // index of current scene
  public float currentStartTime;
  public float currentEndTime;
  public ArrayList<Scene> scenes;
  
  public Timeline(Object processing, String songPath) {
    this.minim = new Minim(processing);
    this.song = minim.loadFile(songPath);

    this.currentScene = -1;
    this.scenes = new ArrayList<Scene>();
  }
  
  public void addScene(Scene scene) {
    this.scenes.add(scene);
  }
  
  public void drawScene() {
    float beats = 0.001 * (song.position() + POSITION_OFFSET * 1000.0) / BEAT_DURATION;

    Scene scene = null;
    boolean sceneChanged = false;
    
    if(this.currentScene >= 0 && this.currentStartTime <= beats && beats < this.currentEndTime) {
      scene = this.scenes.get(this.currentScene);
    }
    
    boolean terminated = false;
    float accumStartTime = 0.0;
    for(int i = 0; i < this.scenes.size(); i++) {
      scene = this.scenes.get(i);
      float endTime = accumStartTime + scene.duration;
      if(accumStartTime <= beats && beats < endTime) {
          terminated = true;
          sceneChanged = i != this.currentScene;
          
          this.currentScene = i;
          this.currentStartTime = accumStartTime;
          this.currentEndTime = endTime;
          
          break;
      }
      accumStartTime += scene.duration;
    }
    
    if(!terminated) {
      this.currentScene = -1;      
    }
    
    if(this.currentScene < 0) {
      background(0);
      return; 
    }
    
    if(sceneChanged) {
      // Scene changed, set up the new one
      scene.setup();
    }
    
    scene.draw(beats - this.currentStartTime);
  }
}

float scale(float l0, float r0, float l1, float r1, float x) {
	return (x - l0) / (r0 - l0) * (r1 - l1) + l1;
}

float sin_in_out(float wave) {
  return (sin(wave * PI - 0.5*PI) + 1.0) * 0.5;
}

float sin_in_out(float wave, float exponent) {
  float sine = sin(wave * PI - 0.5*PI);
  float sign = sine < 0.0 ? -1.0 : 1.0;
  return (sign * pow(abs(sine), exponent) + 1.0) * 0.5;
}

float inv_pow(float b, float e) {
  return 1.0 - pow(1.0-b, e);
}

float beatsToSecs(float beats) {
  return beats * BEAT_DURATION;
}

// Constants
float TEMPO = 76.5; // beats/minute
float BEAT_DURATION = 60.0 / TEMPO; // seconds 
float POSITION_OFFSET = -0.25*BEAT_DURATION; // seconds
int SKIP_DURATION = round(4.0 * 1000.0 * BEAT_DURATION); // milliseconds
float PREDELAY_DURATION = 0.0; // seconds

// Global state
Timeline timeline;
boolean predelay = true; // are we still in the pre-delay period?

void setup() {
  fullScreen(P3D);
  //size(720, 405, P3D);
  //size(1920, 1080, P3D);

  timeline = new Timeline(this, "data/sffm-g2.mp3");
  timeline.addScene(new SpiderWebScene(32.0));
  timeline.addScene(new CubeSpidersScene(64.0));
  timeline.addScene(new ParticleGhostScene(32.0 + 2.0));
  timeline.addScene(new WobblyGhostsScene(64.0));
  timeline.addScene(new MetaballScene(32.0));
  timeline.addScene(new FireScene(32.0));
  timeline.addScene(new ExampleScene(32.0, false));
  timeline.addScene(new CreditsScene(64.0));
  
  frameRate(60);
  background(0);
  fill(255);
  smooth();
}

void keyPressed() {
  if(predelay) {
    return;
  }
  
  if(key == CODED) {
    // Left/right arrow keys: seek song
    boolean isLeft = keyCode == LEFT;
    boolean isRight = keyCode == RIGHT;
    if(isLeft || isRight) {
      timeline.song.skip((isLeft ? -1 : 1) * SKIP_DURATION);  
    }
  } else if(key == ' ') {
    // Space: play/pause
    if(timeline.song.isPlaying()) {
      timeline.song.pause();
    } else {
      timeline.song.play();
    }
  } /*else if(key == ENTER) {
    // Enter: spit out the current position (for syncing)
    println("" + getBeats() + " b / " + getSeconds() + " s");
  }*/
}

void draw() {
  if(predelay) {
    if(0.001 * millis() < PREDELAY_DURATION) {
      return;      
    }
    
    // Predelay ended, start the song
    predelay = false;
    float offset = 0.0//;32.0 + 64.0 + 34.0 + 64.0 + 32.0;// + 32.0 + 32.0;
    timeline.song.play(round(offset * 1000.0 * BEAT_DURATION));
  }
  
  timeline.drawScene();
}