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

  timeline = new Timeline(this, "data/sffm-g2.mp3");
  
  timeline.addScene(new ParticleGhostScene(64.0));
  timeline.addScene(new FireScene(64.0));
  timeline.addScene(new SpiderWebScene(64.0));
  timeline.addScene(new MetaballScene(256.0));
  timeline.addScene(new WobblyGhostsScene(256.0));
  timeline.addScene(new ExampleScene(256.0, false));
  
  
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
    float offset = 0.0;
    timeline.song.play(round(offset * 1000.0 * BEAT_DURATION));
  }
  
  timeline.drawScene();
}