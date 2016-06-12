class FireScene extends Scene {

  ArrayList<ParticleFire> fires;
  ArrayList<GraveStone> graveStones;
  String[] greets;
  PFont font;
  PShader cloudShader;
  
  public FireScene(float duration) {
    super(duration);
    
    fires = new ArrayList<ParticleFire>();
    graveStones = new ArrayList<GraveStone>();
        
    this.greets = new String[] {
      "Greets",
      "Paraguay",
      "Peisik",
      "REN",
      "Epoch",
      "Mercury",
      "pants^2",
      "Kitai",
      "shieni",
      "msqrt",
      "sooda",
      "shaiggon",
      "firebug",
      "Silphid & genie",
      "DOT",
      "Graffathon\n10.-12.6.2016"
    };
    
    for (int i = 0; i < greets.length; i++) {
      graveStones.add(new GraveStone(greets[i]));
    }
    
    int numberOfFiresOnOneSide = this.greets.length;
    
    for (int i = 0; i < numberOfFiresOnOneSide; i++) {      
      fires.add(new ParticleFire(0, -width/4, 0.0, 50));
      fires.add(new ParticleFire(0, width/4, 0.0, 50));
    }
    
    this.font = loadFont("CharisSIL-72.vlw");
  }
  
  void setup() {
    resetShader();
    noStroke();
    ellipseMode(CENTER);
    fill(255);
    lights();    
    textFont(this.font);
    
    cloudShader = loadShader("clouds.glsl");
    cloudShader.set("iResolution", (float)width, (float)height);
  }
  
  void draw(float beats) {
    float rate = 0.5;
    
    background(0);
    
    int time = round(beatsToSecs(beats) * 1000.0);
    
    hint(ENABLE_DEPTH_TEST);
    pushMatrix();
    translate(width/2, height/2, 0.0/*-0.5*width*/);
        
    for (int i = graveStones.size() - 1; i >= 0; i--) {
      float zTranslate = - i * 500 + (beats + 1.25) * rate * 500.0;
      
      ParticleFire fire1 = fires.get(2*i);
      ParticleFire fire2 = fires.get(2*i+1);
      
      pushMatrix();
            
      translate(0, 0, zTranslate);
      
      fire1.draw(beats);
      fire2.draw(beats);
      
      popMatrix();
      
      
      pushMatrix();
        
      translate(0, 0, zTranslate);
      
      graveStones.get(i).draw();
            
      popMatrix();
    }
    
    popMatrix();
    
    // clouds:
    hint(DISABLE_DEPTH_TEST);
    pushMatrix();
    translate(width/2, height/2, 0);
    float cloudsFade = 0.0;
    cloudShader.set("iBeats", beats);
    cloudShader.set("iGlobalTime", time * 0.001);
    cloudShader.set("iFade", cloudsFade);
    
    shader(cloudShader);
    fill(100, 100, 100, 0.7);
    rectMode(CENTER);
    rect(0, 0, width, height);
    resetShader();
    popMatrix();
  }
}