class WobblyGhostsScene extends Scene {
  public PGraphics pg;
  public ShaderScene initialScene;
  
  public WobblyGhostsScene(float duration) {
    super(duration);
    this.pg = createGraphics(width, height, P3D);
    this.initialScene = new ShaderScene(duration, "wobbly-ghosts.frag", this.pg);
    this.initialScene.feedback = true;
  }
  
  public void setup() {
    this.initialScene.setup();
    noLights();
    camera();
    perspective();
  }
  
  public void draw(float beats) {
    float halfway = 0.5*this.duration;
    float ghosting = 0.0;
    float eyeing = 0.0;
    if(beats < halfway) {
      ghosting = scale(0.0, halfway, 0.0, 1.0, beats);
    } else {
      ghosting = scale(halfway, this.duration, 1.0, 0.0, beats);
      eyeing = scale(halfway, this.duration, 0.0, 1.0, beats);
    }
    
    this.initialScene.shader.set("ghosting", ghosting);
    this.initialScene.shader.set("eyeing", eyeing);
    this.initialScene.draw(beats);
        
    image(this.pg, 0, 0);    
  }
}
