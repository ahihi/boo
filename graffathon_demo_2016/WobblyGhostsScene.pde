class WobblyGhostsScene extends Scene {
  public PShader shader;
  
  public WobblyGhostsScene(float duration) {
    super(duration);
    this.shader = loadShader("wobbly-ghosts.frag");
    shader(this.shader);
  }
  
  public void setup() {
    fill(255);
    rectMode(CORNER);
  }
  
  public void draw(float beats) {
    clear();
    shader(this.shader);
    this.shader.set("iResolution", float(width), float(height));
    this.shader.set("iBeats", beats);
    this.shader.set("iGlobalTime", beatsToSecs(beats));
    rect(0, 0, width, height);
  }
}