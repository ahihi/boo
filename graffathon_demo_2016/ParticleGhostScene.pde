class ParticleGhostScene extends Scene {
  
  ParticleGhost bigGhost;
  
  public ParticleGhostScene(float duration) {
    super(duration);
  }
  
  void setup() {
    resetShader();
    noStroke();
    ellipseMode(CENTER);
    fill(255);
    
    bigGhost = new ParticleGhost(0, 0, 0, 200);
  }
  
  void draw(float beats) {
    background(0);
    
    int time = round(beatsToSecs(beats) * 1000.0);
    
    pushMatrix();

    translate(width/2, height/2, -0.5*width);
    scale(min(6.0, time * 0.0001));

    bigGhost.draw(beats);
    
    popMatrix();
  }
}