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
    float beats = 0.001 * song.position() / BEAT_DURATION;

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

// Scenes

class ExampleScene extends Scene {
  public boolean green;
  
  public ExampleScene(float duration, boolean green) {
    super(duration);
    this.green = green;
  }
  
  void setup() {
    resetShader();
    textSize(32);
    noStroke();
    fill(255);    
  }
  
  void draw(float beats) {
    if(this.green) {
      background(0, 255, 0);      
    } else {
      background(255, 0, 0);
    }
    text("" + beats, 10, 0.5 * height);
  }
}

class ParticleGhostScene extends Scene {
  
  class Particle {
    float size = 200.0;
    float x;
    float y;
    PVector velocity;
    PVector acceleration;
    
    float lifeTime = 100.0;
    
    public Particle(float xParam, float yParam) {
      x = xParam;
      y = yParam;
      
      float velocityX = randomGaussian() * 0.3;
      float velocityY = randomGaussian() * 0.3;
      velocity = new PVector(velocityX, velocityY);
      
      acceleration = new PVector(0, 0);
    }
    
    void run() {
      update();
      render();
    }
    
    void applyForce(PVector force) {
      acceleration.add(force);
    }
  
    // Method to update location
    void update() {
      velocity.add(acceleration);
      x += velocity.x;
      y += velocity.y;
      
      lifeTime -= 1.0;
      
      // reset acceleration:
      acceleration.x = 0;
      acceleration.y = 0;
    }
  
    void render() {
      fill(255, lifeTime);
      ellipse(x, y, size * (lifeTime / 100.0), size * (lifeTime / 100.0));
    }
  
    boolean isDead() {
      if (lifeTime <= 0.0) {
        return true;
      }
      
      return false;
    }
  }
  
  class ParticleSystem {
    float originX;
    float originY;
    
    int numberOfParticles;
    ArrayList<Particle> particles;
    
    public ParticleSystem(int numberOfParticlesParam,
                          float originXParam,
                          float originYParam) {
      originX = originXParam;
      originY = originYParam;
      
      particles = new ArrayList<Particle>();
      numberOfParticles = numberOfParticlesParam;
      
      for (int i = 0; i < numberOfParticles; i++) {
        particles.add(new Particle(originX, originY));
      }
    }
    
    void run() {
      for (int i = particles.size() - 1; i >= 0; i--) {
        Particle particle = particles.get(i);
        particle.run();
        if (particle.isDead()) {
          particles.remove(i);
        }
      }
    }
    
    void applyForce(PVector force) {
      for (Particle particle: particles) {
        particle.applyForce(force);
      }
    }  
  
    void addParticle() {
      particles.add(new Particle(originX, originY));
    }
    
    void translate(float dx, float dy) {  
      originX = dx;
      originY = dy;
    }
  }
  
  ParticleSystem particleSystem;
  
  public ParticleGhostScene(float duration) {
    super(duration);
  }
  
  void setup() {
    resetShader();
    noStroke();
    ellipseMode(CENTER);
    fill(255);
    
    particleSystem = new ParticleSystem(0, 0, 0);
  }
  
  void draw(float beats) {
    background(0);
    
    int time = round(beatsToSecs(beats) * 1000.0);
    
    pushMatrix();

    translate(width/2, height/2, -0.5*width);
    scale(min(6.0, time * 0.0001));

    // big ghost
    float currentX = particleSystem.originX;
    float currentY = particleSystem.originY;
    float newX = (400.0 * cos(time*0.001) - 200.0);
    float newY = (200.0 * sin(2 * time*0.001) - 100.0)/2.0;
    particleSystem.translate(newX, newY);
    particleSystem.applyForce(new PVector((currentX - newX) * 0.01, (currentY - newY) * 0.01));
    particleSystem.run();
    
    particleSystem.addParticle();
    
    fill(150, 0, 0);
    
    // eyes:
    float leftEyeX = particleSystem.originX - 30.0;
    float leftEyeY = particleSystem.originY - 10.0;
    
    float rightEyeX = particleSystem.originX + 30.0;
    float rightEyeY = particleSystem.originY - 10.0;
    
    // eye vertical line:
    float eyebrowWidth = 5.0;
    float eyebrowHeight = 50.0;
    float rectangleRoundness = 7;
    rect(leftEyeX - eyebrowWidth/2.0, particleSystem.originY - 25.0, eyebrowWidth, eyebrowHeight, rectangleRoundness);
    rect(rightEyeX - eyebrowWidth/2.0, particleSystem.originY - 25.0, eyebrowWidth, eyebrowHeight, rectangleRoundness);
    
    fill(50, 0, 0);
    // eyes:
    ellipse(leftEyeX, leftEyeY, 30.0, 10.0);
    ellipse(rightEyeX, rightEyeY, 30.0, 10.0);
    
    // mouth;
    ellipse(particleSystem.originX, particleSystem.originY + 30.0, 30.0, 30.0 * sin(beats) + 15.0);
    
    
    popMatrix();
  }
}


class SpiderWebScene extends Scene {
  public int amountOfSectors;
  public int sizeOfWeb = 10;
  public float distanceBetween = 100;
  public PVector origin;
  public float sectorLength;
  
  public SpiderWebScene(float duration) {
    super(duration);
    
    amountOfSectors = 18;
    origin = new PVector(0, 0);
    sectorLength = 2.0 * width;
  }
  
  void setup() {
    resetShader();
    noStroke();
    fill(255);    
  }
  
  void draw(float beats) {
    background(0);
    
    int time = round(beatsToSecs(beats) * 1000.0);
    
    pushMatrix();

    translate(width/2, height/2, -0.5*width);
    
    stroke(126);
    fill(255);
    
    for (int i = 0; i < amountOfSectors; i++) {
      pushMatrix();
      rotateZ(radians(i * 360/amountOfSectors));

      line(origin.x, origin.y, origin.x, origin.y + sectorLength);

      popMatrix();
    }
    
    float speed = beats * amountOfSectors;
    
    float currentMaxDistance = distanceBetween * (1 + (int)(speed / amountOfSectors));
    
    for (int currentDistance = 0; currentDistance <= currentMaxDistance; currentDistance += distanceBetween) {
      for (int i = 0; i < speed - amountOfSectors * ((int)(currentDistance/distanceBetween) - 1); i++) {
      
        pushMatrix();
        
        scale(0.01 * (sin(beats) * cos(beats) + cos(beats*2.0)) + 1);
        
        rotateZ(radians(i * 360/amountOfSectors + (0.5 * 360/amountOfSectors) - 180));
        translate(0, currentDistance);
        
        line(origin.x - currentDistance * sin(radians(0.5 * 360/amountOfSectors)), origin.y, origin.x + currentDistance * sin(radians(0.5 * 360/amountOfSectors)), origin.y);
        
        popMatrix();
      }
    }
    
    popMatrix();
  }
}

// Constants
int CANVAS_WIDTH = width;
int CANVAS_HEIGHT = height;
float ASPECT_RATIO = (float)width/height;
float TEMPO = 76.5; // beats/minute
float BEAT_DURATION = 60.0 / TEMPO; // seconds 
int SKIP_DURATION = round(4.0 * 1000.0 * BEAT_DURATION); // milliseconds
float PREDELAY_DURATION = 0.0; // seconds

// Global state
Timeline timeline;
boolean predelay = true; // are we still in the pre-delay period?

void setup() {
  fullScreen(P3D);

  timeline = new Timeline(this, "data/sffm-g2.mp3");
  timeline.addScene(new SpiderWebScene(64.0));
  timeline.addScene(new ParticleGhostScene(64.0));
  timeline.addScene(new ExampleScene(64.0, false));
  
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