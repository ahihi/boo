class ParticleGhostScene extends Scene {
  
  class Particle {
    float size = 200.0;
    float x;
    float y;
    PVector velocity;
    PVector acceleration;
    
    float lifeTime = 100.0;
    
    public Particle(float xParam, float yParam) {
      x = xParam;
      y = yParam;
      
      float velocityX = randomGaussian() * 0.3;
      float velocityY = randomGaussian() * 0.3;
      velocity = new PVector(velocityX, velocityY);
      
      acceleration = new PVector(0, 0);
    }
    
    void run() {
      update();
      render();
    }
    
    void applyForce(PVector force) {
      acceleration.add(force);
    }
  
    // Method to update location
    void update() {
      velocity.add(acceleration);
      x += velocity.x;
      y += velocity.y;
      
      lifeTime -= 1.0;
      
      // reset acceleration:
      acceleration.x = 0;
      acceleration.y = 0;
    }
  
    void render() {
      fill(255, lifeTime);
      ellipse(x, y, size * (lifeTime / 100.0), size * (lifeTime / 100.0));
    }
  
    boolean isDead() {
      if (lifeTime <= 0.0) {
        return true;
      }
      
      return false;
    }
  }
  
  class ParticleSystem {
    float originX;
    float originY;
    
    int numberOfParticles;
    ArrayList<Particle> particles;
    
    public ParticleSystem(int numberOfParticlesParam,
                          float originXParam,
                          float originYParam) {
      originX = originXParam;
      originY = originYParam;
      
      particles = new ArrayList<Particle>();
      numberOfParticles = numberOfParticlesParam;
      
      for (int i = 0; i < numberOfParticles; i++) {
        particles.add(new Particle(originX, originY));
      }
    }
    
    void run() {
      for (int i = particles.size() - 1; i >= 0; i--) {
        Particle particle = particles.get(i);
        particle.run();
        if (particle.isDead()) {
          particles.remove(i);
        }
      }
    }
    
    void applyForce(PVector force) {
      for (Particle particle: particles) {
        particle.applyForce(force);
      }
    }  
  
    void addParticle() {
      particles.add(new Particle(originX, originY));
    }
    
    void translate(float dx, float dy) {  
      originX = dx;
      originY = dy;
    }
  }
  
  ParticleSystem particleSystem;
  
  public ParticleGhostScene(float duration) {
    super(duration);
  }
  
  void setup() {
    resetShader();
    noStroke();
    ellipseMode(CENTER);
    fill(255);
    
    particleSystem = new ParticleSystem(0, 0, 0);
  }
  
  void draw(float beats) {
    background(0);
    
    int time = round(beatsToSecs(beats) * 1000.0);
    
    pushMatrix();

    translate(width/2, height/2, -0.5*width);
    scale(min(6.0, time * 0.0001));

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