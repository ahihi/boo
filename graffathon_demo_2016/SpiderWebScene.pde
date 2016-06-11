class SpiderWebScene extends Scene {
  public int amountOfSectors;
  public int sizeOfWeb = 10;
  public float distanceBetween = 100;
  public PVector origin;
  public float sectorLength;
  
  public SpiderWebScene(float duration) {
    super(duration);
    
    amountOfSectors = 18;
    origin = new PVector(0, 0);
    sectorLength = 2.0 * width;
  }
  
  void setup() {
    resetShader();
    noStroke();
    fill(255);    
  }
  
  void draw(float beats) {
    background(0);
    
    int time = round(beatsToSecs(beats) * 1000.0);
    
    pushMatrix();

    translate(width/2, height/2, -0.5*width);
    
    stroke(126);
    fill(255);
    
    for (int i = 0; i < amountOfSectors; i++) {
      pushMatrix();
      rotateZ(radians(i * 360/amountOfSectors));

      line(origin.x, origin.y, origin.x, origin.y + sectorLength);

      popMatrix();
    }
    
    float speed = beats * amountOfSectors;
    
    float currentMaxDistance = distanceBetween * (1 + (int)(speed / amountOfSectors));
    
    for (int currentDistance = 0; currentDistance <= currentMaxDistance; currentDistance += distanceBetween) {
      for (int i = 0; i < speed - amountOfSectors * ((int)(currentDistance/distanceBetween) - 1); i++) {
      
        pushMatrix();
        
        scale(0.01 * (sin(beats) * cos(beats) + cos(beats*2.0)) + 1);
        
        rotateZ(radians(i * 360/amountOfSectors + (0.5 * 360/amountOfSectors) - 180));
        translate(0, currentDistance);
        
        line(origin.x - currentDistance * sin(radians(0.5 * 360/amountOfSectors)), origin.y, origin.x + currentDistance * sin(radians(0.5 * 360/amountOfSectors)), origin.y);
        
        popMatrix();
      }
    }
    
    popMatrix();
  }
}