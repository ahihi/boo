class FireScene extends Scene {

  ArrayList<ParticleFire> fires;
  
  public FireScene(float duration) {
    super(duration);
  }
  
  void setup() {
    resetShader();
    noStroke();
    ellipseMode(CENTER);
    fill(255);
    lights();
    
    fires = new ArrayList<ParticleFire>();
    
    int numberOfFiresOnOneSide = 6;
    
    for (int i = 0; i < numberOfFiresOnOneSide; i++) {      
      fires.add(new ParticleFire(0, -width/4, 0.0, 50));
      fires.add(new ParticleFire(0, width/4, 0.0, 50));
    }
  }
  
  void draw(float beats) {
    background(0);
    
    int time = round(beatsToSecs(beats) * 1000.0);
    
    pushMatrix();
    translate(width/2, height/2, -0.5*width);
    
    fill(255);
    ellipse(0,0,100,100);
    
    for (int i = fires.size() - 1; i >= 0; i--) {
      pushMatrix();
      
      float zTranslate = (((int)(i/2) - 3) * 500 + time * 0.5) % (fires.size() * 250);
      
      translate(0, 0, zTranslate);
      fires.get(i).draw(beats);
      
      fill(255);
      rectMode(CENTER);
      rect(0, 0, 30, 200);
      rect(0, -40, 150, 30);
      
      fill(0);
      textSize(10);
      float textWidth = textWidth("Greets");
      text("Greets", -textWidth/2.0, -40 + 5);
      
      popMatrix();
    }
    
    popMatrix();
    
  }
}