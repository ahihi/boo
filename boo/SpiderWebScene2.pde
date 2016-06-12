public class SpiderWebScene2 extends Scene {
  public int corners;
  public int layers;
  public float outerLayerRadius;
  public PGraphics pg;
  public PGraphics pg1;
  public ShaderScene shaderScene;
  
  public SpiderWebScene2(float duration) {
    super(duration);
    
    this.corners = 6;
    this.layers = 60;
    this.outerLayerRadius = 1.4;
    
    this.pg = createGraphics(width, height, P3D);
    this.pg1 = createGraphics(width, height, P3D);
    this.shaderScene = new ShaderScene(this.duration, "web2.frag", this.pg1);
    this.shaderScene.feedback = true;
  }
  
  public void setup() {    
    camera();
    perspective();
    noLights();
  }

  public void draw(float beats) {
    this.pg.beginDraw();
        
    this.pg.smooth();
    this.pg.clear();
    this.pg.stroke(200);
    this.pg.noFill();
    
    float rotation = beats / this.duration / this.corners * 2.0 * PI;
    
    float r = this.outerLayerRadius * height;
    float alpha = PI / this.corners;
    float beta = fmod(rotation, alpha * 2.0);
    float s = r * cos(alpha - beta) / cos(alpha);
    
    float scale = s / r;
    
    for(int i = this.layers - 1; i >= 0; i--) {
      float r1 = r / pow(scale, i);
      drawPoly(0.5*width, 0.5*height, r1, rotation * (i + 1));
    }
    
    this.pg.endDraw();
    
    //this.pg1.beginDraw();
    
    this.shaderScene.setup();
    this.shaderScene.shader.set("in_image1", pg);
    this.shaderScene.draw(beats);
    
    //this.pg1.endDraw();
    
    clear();
    image(pg1, 0, 0);
  }
  
  float fmod(float a, float b) {
      return a - floor(a/b) * b;
  }
  
  void drawPoly(float x, float y, float cornerRadius, float rotation) {
      this.pg.beginShape();
      for(int i = 0; i < this.corners; i++) {
          float angle = rotation + i * 2.0*PI/this.corners;
          float vx = x + cornerRadius * cos(angle);
          float vy = y + cornerRadius * sin(angle);
          this.pg.vertex(vx, vy, vx, vy);
      }
      this.pg.endShape(CLOSE);
  }
}