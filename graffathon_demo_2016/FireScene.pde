class FireScene extends Scene {

  ArrayList<ParticleFire> fires;
  String[] greets;
  PFont font;
  
  public FireScene(float duration) {
    super(duration);
    
    fires = new ArrayList<ParticleFire>();
    
    int numberOfFiresOnOneSide = 6;
    
    for (int i = 0; i < numberOfFiresOnOneSide; i++) {      
      fires.add(new ParticleFire(0, -width/4, 0.0, 50));
      fires.add(new ParticleFire(0, width/4, 0.0, 50));
    }
    
    this.greets = new String[] {
      "Greets",
      "Peisik",
      "REN",
      "Epoch",
      "pants^2",
      "Paraguay",
      "Mercury",
      "firebug",
      "sooda",
      "shieni",
      "DOT"
      // TODO
    };
    
    this.font = loadFont("CharisSIL-72.vlw");
  }
  
  void setup() {
    resetShader();
    noStroke();
    ellipseMode(CENTER);
    fill(255);
    lights();    
    textFont(this.font);
  }
  
  void draw(float beats) {
    float rate = 0.5;
    
    background(0);
    
    int time = round(beatsToSecs(beats) * 1000.0);
    
    pushMatrix();
    translate(width/2, height/2, 0.0/*-0.5*width*/);
    
    fill(255);
    ellipse(0,0,100,100);
    
    for (int i = fires.size() - 1; i >= 0; i--) {
      pushMatrix();
      
      //float zTranslate = (((int)(i/2) - 3) * 500 + time * 0.5) % (fires.size() * 250);
      float zTranslate = (((int)(i/2) - 3) * 500 + beats * rate * 500.0 + 345.0) % (fires.size() * 250);
      
      translate(0, 0, zTranslate);
      fires.get(i).draw(beats);
      
      fill(255);
      rectMode(CENTER);
      rect(0, 0, 30, 200);
      rect(0, -40, 150, 30);
      
      fill(0);
      textSize(10);
      
      int text_i = floor(rate * beats);
      String greet_text = text_i < this.greets.length
        ? this.greets[text_i].toUpperCase()
        : "";
      
      float textWidth = textWidth(greet_text);
      text(greet_text, -textWidth/2.0, -40 + 5);
      
      popMatrix();
    }
    
    popMatrix();
    
  }
}