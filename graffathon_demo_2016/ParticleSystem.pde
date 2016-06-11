class ParticleSystem {
  float originX;
  float originY;
  float size;
  
  float redStart = 255.0;
  float greenStart = 255.0;
  float blueStart = 255.0;
  float redEnd = 255.0;
  float greenEnd = 255.0;
  float blueEnd = 255.0;
  
  int numberOfParticles;
  ArrayList<Particle> particles;
  
  public ParticleSystem(int numberOfParticlesParam,
                        float originXParam,
                        float originYParam,
                        float sizeParam) {
    originX = originXParam;
    originY = originYParam;
    size = sizeParam;
    
    particles = new ArrayList<Particle>();
    numberOfParticles = numberOfParticlesParam;
    
    for (int i = 0; i < numberOfParticles; i++) {
      particles.add(new Particle(originX, originY, size));
    }
  }
  
    public ParticleSystem(int numberOfParticlesParam,
                        float originXParam,
                        float originYParam,
                        float sizeParam,
                        float redStartParam,
                        float greenStartParam,
                        float blueStartParam,
                        float redEndParam,
                        float greenEndParam,
                        float blueEndParam) {
    this(numberOfParticlesParam, originXParam, originYParam, sizeParam);
    
    redStart = redStartParam;
    greenStart = greenStartParam;
    blueStart = blueStartParam;
    
    redEnd = redEndParam;
    greenEnd = greenEndParam;
    blueEnd = blueEndParam;
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
    particles.add(new Particle(originX, originY, size, redStart, greenStart, blueStart, redEnd, greenEnd, blueEnd));
  }
  
  void translate(float x, float y) {  
    originX = x;
    originY = y;
  }
}