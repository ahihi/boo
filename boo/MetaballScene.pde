class MetaballScene extends Scene {
  public PShader metaballShader;
  
  public MetaballScene(float duration) {
    super(duration);
    
    metaballShader = loadShader("metaball_striped.glsl");
    shader(metaballShader);
  }
  
  void setup() {
    resetShader();
    textSize(32);
    noStroke();
    fill(255);
    rectMode(CENTER);
    
    camera();
    perspective();
    noLights();
  }
  
  void draw(float beats) {
    clear();
    pushMatrix();

    translate(width/2, height/2, 0);
    
    shader(metaballShader);
    metaballShader.set("iResolution", float(width), float(height));
    metaballShader.set("iGlobalTime", beatsToSecs(beats));
    rect(0, 0, width, height);
    
    popMatrix();
  }
}