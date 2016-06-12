class Particle {
  float size;
  float x;
  float y;
  PVector velocity;
  PVector acceleration;
  
  float lifeTime = 100.0;
  float lifeTimeMax = 100.0;
  
  float redStart = 255.0;
  float greenStart = 255.0;
  float blueStart = 255.0;
  float redEnd = 255.0;
  float greenEnd = 255.0;
  float blueEnd = 255.0;
  
  public Particle(float xParam, float yParam, float sizeParam) {
    x = xParam;
    y = yParam;
    size = sizeParam;
    
    float velocityX = randomGaussian() * 0.3;
    float velocityY = randomGaussian() * 0.3;
    velocity = new PVector(velocityX, velocityY);
    
    acceleration = new PVector(0, 0);
  }
  
  public Particle(float xParam,
                    float yParam,
                    float sizeParam,
                    float redStartParam,
                    float greenStartParam,
                    float blueStartParam,
                    float redEndParam,
                    float greenEndParam,
                    float blueEndParam) {
    this(xParam, yParam, sizeParam);
    
    redStart = redStartParam;
    greenStart = greenStartParam;
    blueStart = blueStartParam;
    
    redEnd = redEndParam;
    greenEnd = greenEndParam;
    blueEnd = blueEndParam;
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
    float lifeTimePercentage = lifeTime/lifeTimeMax;
    float red = lifeTimePercentage * redStart + (1.0 - lifeTimePercentage) * redEnd;
    float green = lifeTimePercentage * greenStart + (1.0 - lifeTimePercentage) * greenEnd;
    float blue = lifeTimePercentage * blueStart + (1.0 - lifeTimePercentage) * blueEnd;
    
    fill(red, green, blue, lifeTime);
    
    ellipse(x, y, size * (lifeTime / 100.0), size * (lifeTime / 100.0));
  }

  boolean isDead() {
    if (lifeTime <= 0.0) {
      return true;
    }
    
    return false;
  }
}