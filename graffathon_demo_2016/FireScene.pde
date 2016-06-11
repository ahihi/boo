class FireScene extends Scene {

  ArrayList<ParticleFire> fires;
  ArrayList<GraveStone> graveStones;
  ArrayList<String> greets;
  
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
    graveStones = new ArrayList<GraveStone>();
    greets = new ArrayList<String>();
    
    int numberOfFiresOnOneSide = 6;
    
    for (int i = 0; i < numberOfFiresOnOneSide; i++) {      
      fires.add(new ParticleFire(0, -width/4, 0.0, 50));
      fires.add(new ParticleFire(0, width/4, 0.0, 50));
    }
    
    greets.add("1 LLLLL");
    greets.add("2 PPPPP");
    greets.add("3 777777");
    greets.add("4 222222");
    greets.add("5 AAAAAA");
    greets.add("6 MMMMMM");
    
    for (int i = 0; i < greets.size(); i++) {
      graveStones.add(new GraveStone(greets.get(i)));
    }
  }
  
  void draw(float beats) {
    background(0);
    
    int time = round(beatsToSecs(beats) * 1000.0);
    
    pushMatrix();
    translate(width/2, height/2, -0.5*width);
    
    for (int i = fires.size() - 1; i >= 0; i--) {
      pushMatrix();
      
      float zTranslate = (((int)(i/2) - 3) * 500 + time * 0.5) % (fires.size() * 250);
      
      translate(0, 0, zTranslate);
      fires.get(i).draw(beats);
      
      popMatrix();
    }
    
    
    for (int i = graveStones.size() - 1; i >= 0; i--) {
      pushMatrix();
  
      float zTranslate = - i * 500 + time * 0.5;//(((int)i - graveStones.size()) * 500 + time * 0.5) % (graveStones.size() * 250);
      
      translate(0, 0, zTranslate);
      graveStones.get(i).draw();
      
      popMatrix();
    }
    
    popMatrix();
    
  }
}