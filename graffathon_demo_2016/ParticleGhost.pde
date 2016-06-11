class ParticleGhost {
  float origonX;
  float origonY;
  float size;
  int amountOfParticles;
  ParticleSystem particleSystem;
  
  public ParticleGhost(int amountOfParticlesParam, float origonXParam, float origonYParam, float sizeParam) {
    resetShader();
    noStroke();
    ellipseMode(CENTER);
    fill(255);
    
    origonX = origonXParam;
    origonY = origonYParam;
    size = sizeParam;
    amountOfParticles = amountOfParticlesParam;
    
    particleSystem = new ParticleSystem(amountOfParticlesParam, origonXParam, origonYParam, size);
  }
  
  public void draw(float beats) {
    int time = round(beatsToSecs(beats) * 1000.0);
    
    pushMatrix();
    
    // big ghost
    float currentX = particleSystem.originX;
    float currentY = particleSystem.originY;
    float newX = (400.0 * cos(time*0.001) - 200.0);
    float newY = (200.0 * sin(2 * time*0.001) - 100.0)/2.0;
    particleSystem.translate(newX, newY);
    particleSystem.applyForce(new PVector((currentX - newX) * 0.01, (currentY - newY) * 0.01));
    particleSystem.run();
    
    particleSystem.addParticle();
    
    fill(150, 0, 0);
    
    // eyes:
    float leftEyeX = particleSystem.originX - 30.0;
    float leftEyeY = particleSystem.originY - 10.0;
    
    float rightEyeX = particleSystem.originX + 30.0;
    float rightEyeY = particleSystem.originY - 10.0;
    
    // eye vertical line:
    float eyebrowWidth = 5.0;
    float eyebrowHeight = 50.0;
    float rectangleRoundness = 7;
    rect(leftEyeX - eyebrowWidth/2.0, particleSystem.originY - 25.0, eyebrowWidth, eyebrowHeight, rectangleRoundness);
    rect(rightEyeX - eyebrowWidth/2.0, particleSystem.originY - 25.0, eyebrowWidth, eyebrowHeight, rectangleRoundness);
    
    fill(50, 0, 0);
    // eyes:
    ellipse(leftEyeX, leftEyeY, 30.0, 10.0);
    ellipse(rightEyeX, rightEyeY, 30.0, 10.0);
    
    // mouth;
    ellipse(particleSystem.originX, particleSystem.originY + 30.0, 30.0, 30.0 * sin(beats) + 15.0);
    
    popMatrix();
  }
  
  
}