class ParticleFire {
  float origonX;
  float origonY;
  int amountOfParticles;
  ParticleSystem particleSystem;
  
  public ParticleFire(int amountOfParticlesParam, float origonXParam, float origonYParam, float size) {
    resetShader();
    noStroke();
    ellipseMode(CENTER);
    
    origonX = origonXParam;
    origonY = origonYParam;
    amountOfParticles = amountOfParticlesParam;
    
    particleSystem = new ParticleSystem(amountOfParticlesParam, origonXParam, origonYParam, size, 250.0, 150, 0.0, 150, 150, 0.0);
  }
  
  public void translate(float x, float y) {
    origonX = x;
    origonY = y;
    
    particleSystem.translate(x, y);
  }
  
  public void draw(float beats) {
    
    int time = round(beatsToSecs(beats) * 1000.0);
    
    pushMatrix();

    particleSystem.applyForce(new PVector(0.0, - (0.15 * sin(time) + 0.1)));
    particleSystem.run();
    
    particleSystem.addParticle();
    
    popMatrix();
  }
  
  
}