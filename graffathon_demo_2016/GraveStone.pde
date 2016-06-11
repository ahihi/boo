class GraveStone {
  String textOnStone;
  
  public GraveStone(String textParam) {
    textOnStone = textParam;
  }
  
  public void draw() {
    float graveStoneWidth = 120;
    float graveStoneHeight = 150;
    float graveStoneDepth = 20;
    
    float graveStoneBottomWidth = 1.1 * graveStoneWidth;
    float graveStoneBottomHeight = 20;
    float graveStoneBottomDepth = 1.1 * graveStoneDepth;
    
    pushMatrix();
    fill(120, 100, 100);
    rectMode(CENTER);
    box(graveStoneWidth, graveStoneHeight, graveStoneDepth);
    translate(0, -50, 0);
    rotateZ(radians(45));
    box(0.7*graveStoneWidth, 0.7*graveStoneWidth, graveStoneDepth);
    popMatrix();
    
    pushMatrix();
    translate(0,(graveStoneHeight+graveStoneBottomHeight)/2.0);
    box(graveStoneBottomWidth, graveStoneBottomHeight, graveStoneBottomDepth);
    popMatrix();
    
    pushMatrix();
    fill(0);
    textSize(40);
    textAlign(CENTER);
    scale(0.4);
    text(textOnStone, 0, 10, 25);
    popMatrix();
  }
}