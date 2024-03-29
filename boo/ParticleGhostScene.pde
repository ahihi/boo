class ParticleGhostScene extends Scene {
  
  ParticleGhost bigGhost;
  PShader noiseShader;
  
  public ParticleGhostScene(float duration) {
    super(duration);
  }
  
  void setup() {
    resetShader();
    camera();
    perspective();
    noStroke();
    ellipseMode(CENTER);
    fill(255);
    
    camera();
    perspective();
    noLights();
    
    bigGhost = new ParticleGhost(0, 0, 0, 200);
    noiseShader = loadShader("hypno.glsl");
    noiseShader.set("iResolution", width, height);
  }
  
  void draw(float beats) {
    clear();
    
    int time = round(beatsToSecs(beats) * 1000.0);
    
    
    pushMatrix();
    translate(width/2, height/2, -10);
    scale(1.0);
    
    fill(10, 10, 10, 0.1);
    rectMode(CENTER);
    shader(noiseShader);
    noiseShader.set("iGlobalTime", 0.5*beats);
    noiseShader.set("iResolution", float(width), float(height));
    
    rect(0, 0, width, height);
    resetShader();
    popMatrix();
    
    pushMatrix();

    translate(width/2, height/2, 0);
    scale(min(6.0, time * 0.0001));

    bigGhost.draw(beats);
    
    
    popMatrix();
  }
}