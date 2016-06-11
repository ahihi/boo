class CubeSpidersScene extends Scene {
  private final float LEGS_PER_SIDE = 4;
  
  private PVector boxCenter;  
  private float boxRadius;
  private float spiderRadius;
  private float legLength;
  private float legRadius;
  private float legZFactor;
  private float legFanFactor;
  
  class Spider {
    PVector trans;
    float rotPhase;
    
    Spider(PVector trans, float rotPhase) {
      this.trans = trans;
      this.rotPhase = rotPhase;
    }
  }
  
  private Spider[] spiders;
  
  private PGraphics pg;
  private PShader spiderShader;
  
  public CubeSpidersScene(float duration) {
    super(duration);
    
    this.boxCenter = new PVector(0.0, 0.0, 0.0);
    this.boxRadius = 1.0;
    this.spiderRadius = 0.2;
    this.legLength = 0.3;
    this.legRadius = 0.03;
    this.legZFactor = 1.0;
    this.legFanFactor = 0.7;
    
    this.spiders = new Spider[] {
      new Spider(
        new PVector(-1.7, -0.2, -2.1),
        0.3 * PI
      ),
      new Spider(
        new PVector(-0.5, -0.4, -0.5),
        1.4 * PI
      ),
      new Spider(
        new PVector(0.4, -0.7, -1.7),
        0.5 * PI
      ),
      new Spider(
        new PVector(0.9, -0.3, -0.35),
        0.0
      )
    };
    
    float ySum = 0.0;
    for(Spider spider : this.spiders) {
      ySum += spider.trans.y;
    }
    
    for(Spider spider : this.spiders) {
      spider.trans.y -= ySum / this.spiders.length;
    }
    
    this.pg = g;
    this.spiderShader = loadShader("cube-spider.frag", "cube-spider.vert");
  }
  
  public void setup() {
    camera(
      this.boxCenter.x, this.boxCenter.y, this.boxCenter.z + 2.0*this.boxRadius,
      this.boxCenter.x, this.boxCenter.y, this.boxCenter.z,
      0.0, -1.0, 0.0
    );
    float aspect = (float)width/height;
    perspective(
      PI/5, aspect,
      this.boxCenter.z + this.boxRadius, this.boxCenter.z - this.boxRadius
    );
    
    noStroke();
    fill(64, 64, 64);
    //noFill();
  }
  
  public void draw(float beats) {
    clear();
    
    ambientLight(64, 64, 64);
    
    pointLight(
      255, 255, 255,
      this.boxCenter.x, this.boxCenter.y - this.boxRadius, this.boxCenter.z + this.boxRadius
    );
    
    lightFalloff(1, 0, 0);
    lightSpecular(0, 0, 0);
    
    float minTransY = -this.boxRadius*2.0;
    float maxTransY = -minTransY;
    
    float baseY = scale(
      0.0, this.duration,
      minTransY, maxTransY,
      beats
    );
    
    float legStart = 0.5 * this.duration;
    float legEnd = legStart + 1.0;
    float legProgress = max(0.0, min(1.0, scale(legStart, legEnd, 0.0, 1.0, beats)));
    
    for(Spider spider : this.spiders) {
      float transY = baseY + spider.trans.y;
      
      // String
      
      stroke(255);
      
      float lineX = this.boxCenter.x - spider.trans.x;
      float lineZ = this.boxCenter.z + spider.trans.z;
      line(
        lineX, -minTransY, lineZ,
        lineX, -transY, lineZ
      );
    
      noStroke();

      pushMatrix();      
      
      // Cube      
      
      translate(-spider.trans.x, -transY, spider.trans.z);
      rotateY(0.25*PI * sin(beats + spider.rotPhase));
      //box(2.0*spiderRadius);
      this.spiderBox(2.0*spiderRadius, legProgress, beats);
      
      // Legs
      
      if(legProgress > 0.0) {
        for(int i = 0; i < LEGS_PER_SIDE; i++) {
          // i goes from front to back
      
          float legTransZ = scale(
            0.0, (float)(LEGS_PER_SIDE-1),
            this.legZFactor * this.spiderRadius, -this.legZFactor * this.spiderRadius,
            float(i)
          );
          float legFan = scale(
            0.0, (float)(LEGS_PER_SIDE-1),
            -this.legFanFactor * 0.25*PI, this.legFanFactor * 0.25*PI,
            float(i)
          );
          
          float legPhase = (float)i / LEGS_PER_SIDE * 2.0 * PI;
            
          for(int j = 0; j < 2; j++) {
            float xSign = j < 1 ? 1.0 : -1.0;
          
            pushMatrix();
          
            translate(
              xSign * this.spiderRadius,
              -this.spiderRadius,
              legTransZ
            );
            rotateZ(-xSign * (0.125*PI + 0.2 * sin(beats * PI + legPhase)));
            rotateY(xSign * legFan);
            box(
              legProgress * xSign * 2.0*this.legLength,
              this.legRadius,
              this.legRadius
            );
          
            popMatrix();
          }
        }
      }
      
      popMatrix();
    }
  }
  
  private void spiderBox(float side, float eyeProgress, float beats) {
    float halfSide = 0.5*side;
    
    shader(this.spiderShader);

    this.spiderShader.set("eyeProgress", eyeProgress);
    this.spiderShader.set("iBeats", beats);

    this.spiderShader.set("eye", true);
    beginShape(QUADS);
        
    // +Z "front" face
    vertex(-halfSide, -halfSide,  halfSide, 0, 0);
    vertex( halfSide, -halfSide,  halfSide, 1, 0);
    vertex( halfSide,  halfSide,  halfSide, 1, 1);
    vertex(-halfSide,  halfSide,  halfSide, 0, 1);

    endShape();
    
    shader(this.spiderShader);
    
    this.spiderShader.set("eye", false);
    beginShape(QUADS);

    // -Z "back" face
    vertex( halfSide, -halfSide, -halfSide, 0, 0);
    vertex(-halfSide, -halfSide, -halfSide, 1, 0);
    vertex(-halfSide,  halfSide, -halfSide, 1, 1);
    vertex( halfSide,  halfSide, -halfSide, 0, 1);
    
    // +Y "bottom" face
    vertex(-halfSide,  halfSide,  halfSide, 0, 0);
    vertex( halfSide,  halfSide,  halfSide, 1, 0);
    vertex( halfSide,  halfSide, -halfSide, 1, 1);
    vertex(-halfSide,  halfSide, -halfSide, 0, 1);

    // -Y "top" face
    vertex(-halfSide, -halfSide, -halfSide, 0, 0);
    vertex( halfSide, -halfSide, -halfSide, 1, 0);
    vertex( halfSide, -halfSide,  halfSide, 1, 1);
    vertex(-halfSide, -halfSide,  halfSide, 0, 1);

    // +X "right" face
    vertex( halfSide, -halfSide,  halfSide, 0, 0);
    vertex( halfSide, -halfSide, -halfSide, 1, 0);
    vertex( halfSide,  halfSide, -halfSide, 1, 1);
    vertex( halfSide,  halfSide,  halfSide, 0, 1);

    // -X "left" face
    vertex(-halfSide, -halfSide, -halfSide, 0, 0);
    vertex(-halfSide, -halfSide,  halfSide, 1, 0);
    vertex(-halfSide,  halfSide,  halfSide, 1, 1);
    vertex(-halfSide,  halfSide, -halfSide, 0, 1);

    endShape();  
    
    resetShader();
  }
}