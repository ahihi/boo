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
  private ShaderScene shiftyScene;
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
    this.shiftyScene = new ShaderScene(this.duration, "shifty.frag", this.pg);
    this.shiftyScene.beginAndEnd = false;
    this.spiderShader = loadShader("cube-spider.frag", "cube-spider.vert");
  }
  
  public void setup() {
    this.pg.noStroke();
  }
  
  public void draw(float beats) {
    float legStart = 0.5 * this.duration;
    float legEnd = legStart + 1.0;
    float legProgress = max(0.0, min(1.0, scale(legStart, legEnd, 0.0, 1.0, beats)));
    
    float b_snares = 32.0;
    float b_disrupt_start = b_snares + 9.0;
    float b_disrupt_low = b_disrupt_start + 3.0;
    float b_disrupt_end = b_disrupt_low + 4.0;
    float b_hihats = b_disrupt_end;
    float b_noise = b_hihats + 8.0;
    float b_roll = b_noise + 6.0;
    
    float disrupt_wave = 0.0;
    if(b_disrupt_start <= beats && beats < b_disrupt_low) {
      disrupt_wave = scale(b_disrupt_start, b_disrupt_low, 0.0, 1.0, beats);
    } else if(b_disrupt_low <= beats && beats < b_disrupt_end) {
      disrupt_wave = scale(b_disrupt_low, b_disrupt_end, 1.0, 0.0, beats);
    }
    disrupt_wave = sin_in_out(disrupt_wave, 2.0);
    
    float progress_hh = max(0.0, min(1.0, scale(b_hihats, b_hihats + 1.0, 0.0, 1.0, beats)));
    
    float progress_noise = max(0.0, min(1.0, scale(b_noise, this.duration, 0.0, 1.0, beats)));
    float progress_roll = max(0.0, min(1.0, scale(b_roll, this.duration, 0.0, 1.0, beats)));
    
    this.pg.beginDraw();
    
    //this.pg.clear();
    
    this.shiftyScene.setup();
    this.pg.hint(DISABLE_DEPTH_TEST);
    this.shiftyScene.shader.set("progress_sd", legProgress);
    this.shiftyScene.shader.set("progress_noise", progress_noise);
    this.shiftyScene.shader.set("progress_roll", progress_roll);
    this.shiftyScene.shader.set("disrupt_wave", disrupt_wave);
    this.shiftyScene.draw(beats);
    
    this.pg.hint(ENABLE_DEPTH_TEST);
    float z_wave = pow(max(0.0, min(1.0, scale(b_hihats, b_hihats + 16.0, 0.0, 1.0, beats))), 2.0);
    this.pg.camera(
      this.boxCenter.x, this.boxCenter.y, this.boxCenter.z + 2.0*this.boxRadius,
      this.boxCenter.x, this.boxCenter.y, this.boxCenter.z,
      0.0, -1.0, 0.0
    );
    float aspect = (float)width/height;
    this.pg.perspective(
      PI/5, aspect,
      this.boxCenter.z + this.boxRadius, this.boxCenter.z - this.boxRadius
    );
    
    this.pg.fill(64);
        
    this.pg.ambientLight(64, 64, 64);
    
    this.pg.pointLight(
      255, 255, 255,
      this.boxCenter.x, this.boxCenter.y - this.boxRadius, this.boxCenter.z + this.boxRadius
    );
    
    this.pg.lightFalloff(1, 0, 0);
    this.pg.lightSpecular(0, 0, 0);
    
    float minTransY = -this.boxRadius*2.0;
    float maxTransY = this.boxCenter.y;
    
    float baseY;
    if(beats < b_snares) {
      baseY = scale(
        0.0, this.duration,
        minTransY, maxTransY,
        2.0*beats
      );
    } else {
      baseY = maxTransY;
    }
                
    for(Spider spider : this.spiders) {
      float transY = baseY + spider.trans.y;
      
      float x_sign = spider.trans.x < 0.0 ? -1.0 : 1.0;
      float x_move = 2.0*x_sign * z_wave;
      float z_move = 4.0*z_wave;
      
      // String
      
      this.pg.stroke(255);
      
      float lineX = this.boxCenter.x - spider.trans.x - x_move;
      float lineZ = this.boxCenter.z + spider.trans.z + z_move;
      this.pg.line(
        lineX, -minTransY, lineZ,
        lineX, -transY, lineZ
      );
    
      this.pg.noStroke();

      this.pg.pushMatrix();      
      
      // Cube      
      
      this.pg.translate(-spider.trans.x - x_move, -transY, spider.trans.z + z_move);
      this.pg.rotateY(0.25*PI * sin(beats + spider.rotPhase));
      //box(2.0*spiderRadius);
      this.spiderBox(2.0*spiderRadius, legProgress, progress_hh, beats);
      
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
          
            this.pg.pushMatrix();
          
            this.pg.translate(
              xSign * this.spiderRadius,
              -this.spiderRadius,
              legTransZ
            );
            this.pg.rotateZ(-xSign * (0.125*PI + 0.2 * sin(beats * PI + legPhase)));
            this.pg.rotateY(xSign * legFan);
            this.pg.box(
              legProgress * xSign * 2.0*this.legLength,
              this.legRadius,
              this.legRadius
            );
          
            this.pg.popMatrix();
          }
        }
      }
      
      this.pg.popMatrix();
    }
        
    this.pg.endDraw();
  }
  
  private void spiderBox(float side, float eyeProgress, float progress_hh, float beats) {
    float halfSide = 0.5*side;
    
    this.pg.shader(this.spiderShader);

    this.spiderShader.set("eyeProgress", eyeProgress);
    this.spiderShader.set("progress_hh", progress_hh);
    this.spiderShader.set("iBeats", beats);

    this.spiderShader.set("eye", true);
    this.pg.beginShape(QUADS);
        
    // +Z "front" face
    this.pg.vertex(-halfSide, -halfSide,  halfSide, 0, 0);
    this.pg.vertex( halfSide, -halfSide,  halfSide, 1, 0);
    this.pg.vertex( halfSide,  halfSide,  halfSide, 1, 1);
    this.pg.vertex(-halfSide,  halfSide,  halfSide, 0, 1);

    this.pg.endShape();
    
    this.pg.shader(this.spiderShader);
    
    this.spiderShader.set("eye", false);
    this.pg.beginShape(QUADS);

    // -Z "back" face
    this.pg.vertex( halfSide, -halfSide, -halfSide, 0, 0);
    this.pg.vertex(-halfSide, -halfSide, -halfSide, 1, 0);
    this.pg.vertex(-halfSide,  halfSide, -halfSide, 1, 1);
    this.pg.vertex( halfSide,  halfSide, -halfSide, 0, 1);
    
    // +Y "bottom" face
    this.pg.vertex(-halfSide,  halfSide,  halfSide, 0, 0);
    this.pg.vertex( halfSide,  halfSide,  halfSide, 1, 0);
    this.pg.vertex( halfSide,  halfSide, -halfSide, 1, 1);
    this.pg.vertex(-halfSide,  halfSide, -halfSide, 0, 1);

    // -Y "top" face
    this.pg.vertex(-halfSide, -halfSide, -halfSide, 0, 0);
    this.pg.vertex( halfSide, -halfSide, -halfSide, 1, 0);
    this.pg.vertex( halfSide, -halfSide,  halfSide, 1, 1);
    this.pg.vertex(-halfSide, -halfSide,  halfSide, 0, 1);

    // +X "right" face
    this.pg.vertex( halfSide, -halfSide,  halfSide, 0, 0);
    this.pg.vertex( halfSide, -halfSide, -halfSide, 1, 0);
    this.pg.vertex( halfSide,  halfSide, -halfSide, 1, 1);
    this.pg.vertex( halfSide,  halfSide,  halfSide, 0, 1);

    // -X "left" face
    this.pg.vertex(-halfSide, -halfSide, -halfSide, 0, 0);
    this.pg.vertex(-halfSide, -halfSide,  halfSide, 1, 0);
    this.pg.vertex(-halfSide,  halfSide,  halfSide, 1, 1);
    this.pg.vertex(-halfSide,  halfSide, -halfSide, 0, 1);

    this.pg.endShape();
    
    this.pg.resetShader();
  }
}