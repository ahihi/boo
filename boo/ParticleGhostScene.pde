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
    noiseShader = loadShader("noise.glsl");
    noiseShader.set("iResolution", width, height);
  }
  
  void draw(float beats) {
    background(0);
    
    int time = round(beatsToSecs(beats) * 1000.0);
    
    pushMatrix();

    translate(width/2, height/2, -0.5*width);
    scale(min(6.0, time * 0.0001));

    bigGhost.draw(beats);
    
    popMatrix();
    
    pushMatrix();
    translate(width/2, height/2, -0.5*width);
    noiseShader.set("iGlobalTime", time*0.001);
    shader(noiseShader);
    fill(255, 255, 255, 100);
    rectMode(CENTER);
    rect(0, 0, width, height);
    resetShader();
    popMatrix();
  }
}