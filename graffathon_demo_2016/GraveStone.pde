class GraveStone {
  String textOnStone;
  PImage image;
  
  public GraveStone(String textParam) {
    textOnStone = textParam;
    image = loadImage("gravestone.png");
  }
  
  public void draw() {
    float graveStoneWidth = 120;
    float graveStoneHeight = 150;
    float graveStoneDepth = 20;
    
    float graveStoneBottomWidth = 1.1 * graveStoneWidth;
    float graveStoneBottomHeight = 20;
    float graveStoneBottomDepth = 1.1 * graveStoneDepth;
    
    pushMatrix();
    
    rotateX(radians(-5));
    
    beginShape(QUADS);
    texture(image);
    
    //// main part:

    // +Z "front" face
    vertex(-graveStoneWidth/2.0, -graveStoneHeight/2.0, graveStoneDepth/2.0, 0, 0);
    vertex( graveStoneWidth/2.0, -graveStoneHeight/2.0, graveStoneDepth/2.0, 480, 0);
    vertex( graveStoneWidth/2.0,  graveStoneHeight/2.0, graveStoneDepth/2.0, 480, 640);
    vertex(-graveStoneWidth/2.0,  graveStoneHeight/2.0, graveStoneDepth/2.0, 0, 640);
  
    // -Y "top" face
    vertex(-graveStoneWidth/2.0, -graveStoneHeight/2.0, -graveStoneDepth/2.0, 0, 0);
    vertex( graveStoneWidth/2.0, -graveStoneHeight/2.0, -graveStoneDepth/2.0, 480, 0);
    vertex( graveStoneWidth/2.0, -graveStoneHeight/2.0,  graveStoneDepth/2.0, 480, 640/(graveStoneHeight/graveStoneDepth));
    vertex(-graveStoneWidth/2.0, -graveStoneHeight/2.0,  graveStoneDepth/2.0, 0, 640/(graveStoneHeight/graveStoneDepth));
  
    // +X "right" face
    vertex( graveStoneWidth/2.0, -graveStoneHeight/2.0,  graveStoneDepth/2.0, 0, 0);
    vertex( graveStoneWidth/2.0, -graveStoneHeight/2.0, -graveStoneDepth/2.0, 480/(graveStoneWidth/graveStoneDepth), 0);
    vertex( graveStoneWidth/2.0,  graveStoneHeight/2.0, -graveStoneDepth/2.0, 480/(graveStoneWidth/graveStoneDepth), 640);
    vertex( graveStoneWidth/2.0,  graveStoneHeight/2.0,  graveStoneDepth/2.0, 0, 640);
  
    // -X "left" face
    vertex(-graveStoneWidth/2.0, -graveStoneHeight/2.0, -graveStoneDepth/2.0, 0, 0);
    vertex(-graveStoneWidth/2.0, -graveStoneHeight/2.0,  graveStoneDepth/2.0, 480/(graveStoneWidth/graveStoneDepth), 0);
    vertex(-graveStoneWidth/2.0,  graveStoneHeight/2.0,  graveStoneDepth/2.0, 480/(graveStoneWidth/graveStoneDepth), 640);
    vertex(-graveStoneWidth/2.0,  graveStoneHeight/2.0, -graveStoneDepth/2.0, 0, 640);
    
    
    //// bottom part:
    
    float offsetY = graveStoneHeight/2.0;

    // +Z "front" face
    vertex(-graveStoneBottomWidth/2.0, -graveStoneBottomHeight/2.0 + offsetY, graveStoneBottomDepth/2.0, 0, 0);
    vertex( graveStoneBottomWidth/2.0, -graveStoneBottomHeight/2.0 + offsetY, graveStoneBottomDepth/2.0, 480, 0);
    vertex( graveStoneBottomWidth/2.0,  graveStoneBottomHeight/2.0 + offsetY, graveStoneBottomDepth/2.0, 480, 640);
    vertex(-graveStoneBottomWidth/2.0,  graveStoneBottomHeight/2.0 + offsetY, graveStoneBottomDepth/2.0, 0, 640);
  
    // -Y "top" face
    vertex(-graveStoneBottomWidth/2.0, -graveStoneBottomHeight/2.0 + offsetY, -graveStoneBottomDepth/2.0, 0, 0);
    vertex( graveStoneBottomWidth/2.0, -graveStoneBottomHeight/2.0 + offsetY, -graveStoneBottomDepth/2.0, 480, 0);
    vertex( graveStoneBottomWidth/2.0, -graveStoneBottomHeight/2.0 + offsetY,  graveStoneBottomDepth/2.0, 480, 640/(graveStoneBottomHeight/graveStoneBottomDepth));
    vertex(-graveStoneBottomWidth/2.0, -graveStoneBottomHeight/2.0 + offsetY,  graveStoneBottomDepth/2.0, 0, 640/(graveStoneBottomHeight/graveStoneBottomDepth));
  
    // +X "right" face
    vertex( graveStoneBottomWidth/2.0, -graveStoneBottomHeight/2.0 + offsetY,  graveStoneBottomDepth/2.0, 0, 0);
    vertex( graveStoneBottomWidth/2.0, -graveStoneBottomHeight/2.0 + offsetY, -graveStoneBottomDepth/2.0, 480/(graveStoneBottomWidth/graveStoneBottomDepth), 0);
    vertex( graveStoneBottomWidth/2.0,  graveStoneBottomHeight/2.0 + offsetY, -graveStoneBottomDepth/2.0, 480/(graveStoneBottomWidth/graveStoneBottomDepth), 640);
    vertex( graveStoneBottomWidth/2.0,  graveStoneBottomHeight/2.0 + offsetY,  graveStoneBottomDepth/2.0, 0, 640);
  
    // -X "left" face
    vertex(-graveStoneBottomWidth/2.0, -graveStoneBottomHeight/2.0 + offsetY, -graveStoneBottomDepth/2.0, 0, 0);
    vertex(-graveStoneBottomWidth/2.0, -graveStoneBottomHeight/2.0 + offsetY,  graveStoneBottomDepth/2.0, 480/(graveStoneBottomWidth/graveStoneBottomDepth), 0);
    vertex(-graveStoneBottomWidth/2.0,  graveStoneBottomHeight/2.0 + offsetY,  graveStoneBottomDepth/2.0, 480/(graveStoneBottomWidth/graveStoneBottomDepth), 640);
    vertex(-graveStoneBottomWidth/2.0,  graveStoneBottomHeight/2.0 + offsetY, -graveStoneBottomDepth/2.0, 0, 640);
     
    
    //// top part:
    
    offsetY = -graveStoneHeight/2.0;
    float topWidth = 0.8 * graveStoneWidth;
    float topHeight = 0.25 * graveStoneHeight;
    
    // +Z "front" face
    vertex(0.0, -topHeight + offsetY, graveStoneDepth/2.0, 480/2, 0);
    vertex( topWidth/2.0, offsetY, graveStoneDepth/2.0, 480, 640/(topWidth/graveStoneDepth));
    vertex( -topWidth/2.0, offsetY, graveStoneDepth/2.0, 0, 640/(topWidth/graveStoneDepth));
  
    // +X "right" face
    vertex( topWidth/2.0, offsetY,  graveStoneDepth/2.0, 0, 0);
    vertex( topWidth/2.0, offsetY, -graveStoneDepth/2.0, 480/(topWidth/graveStoneDepth), 0);
    vertex( 0, -topHeight + offsetY, -graveStoneDepth/2.0, 480/(topWidth/graveStoneDepth), 640);
    vertex( 0, -topHeight + offsetY,  graveStoneDepth/2.0, 0, 640);
  
    // -X "left" face
    vertex(-topWidth/2.0, offsetY, graveStoneDepth/2.0, 0, 0);
    vertex(-topWidth/2.0, offsetY, -graveStoneDepth/2.0, 480/(graveStoneWidth/graveStoneDepth), 0);
    vertex(0, -topHeight + offsetY,  -graveStoneDepth/2.0, 480/(graveStoneWidth/graveStoneDepth), 640);
    vertex(0, -topHeight + offsetY, graveStoneDepth/2.0, 0, 640);
    
    endShape();
    
    popMatrix();
    
    pushMatrix();
    fill(0);
    textSize(40);
    textAlign(CENTER);
    scale(0.4);
    text(textOnStone, 0, 10, 40);
    popMatrix();
  }
}