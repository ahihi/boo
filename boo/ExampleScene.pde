class ExampleScene extends Scene {
  public boolean green;
  
  public ExampleScene(float duration, boolean green) {
    super(duration);
    this.green = green;
  }
  
  void setup() {
    resetShader();
    textSize(32);
    noStroke();
    fill(255);
    
    camera();
    perspective();
    noLights();
  }
  
  void draw(float beats) {
    if(this.green) {
      background(0, 255, 0);      
    } else {
      background(255, 0, 0);
    }
    text("" + beats, 10, 0.5 * height);
  }
}