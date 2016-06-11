class ShaderScene extends Scene {
  private PShader shader;
  private PGraphics pg;
  public boolean feedback = false;
  
  public ShaderScene(float duration, String shader_file, PGraphics pg) {
    super(duration);
    this.shader = loadShader(shader_file);
    this.pg = pg;
  }
  
  public ShaderScene(float duration, String shader_file) {
    this(duration, shader_file, g);
  }
  
  public void setup() {
    this.pg.noStroke();
    this.pg.fill(255);
    this.pg.rectMode(CORNER);
    this.pg.shader(this.shader);
  }
  
  public void setExtraUniforms(PGraphics pg, float beats) {}
  
  public void draw(float beats) {
    this.pg.beginDraw();
    if(!this.feedback) {
      this.pg.clear();
    } else {
      this.shader.set("in_image", this.pg);
    }
    
    this.shader.set("iResolution", float(width), float(height));
    this.shader.set("iBeats", beats);
    this.shader.set("iGlobalTime", beatsToSecs(beats));
    this.setExtraUniforms(this.pg, beats);
    this.pg.rect(0, 0, width, height);
    this.pg.endDraw();    
  }
}
