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
  }
  
  public void draw(float beats) {
    this.initialScene.draw(beats);
    
    image(this.pg, 0, 0);    
  }
}
