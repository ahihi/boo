class CreditsScene extends Scene {
  private ShaderScene ghostScene;
  private PFont font;
  private String text1;
  private String text2;
  private float margin;
  
  public CreditsScene(float duration) {
    super(duration);
    this.ghostScene = new ShaderScene(duration, "credits-ghost.frag");
    this.font = loadFont("CharisSIL-72.vlw");
    this.text1 = "CODE\nahihi & Lumian";
    this.text2 = "MUSIC\nahihi";
    this.margin = 0.2*width;
  }
  
  public void setup() {
    this.ghostScene.setup();
    textFont(this.font);
    textSize(0.03 * width);
    textAlign(CENTER);
  }
  
  public void draw(float beats) {
    float b_credits_begin = 0.0;
    float b_credits_peak = 16.0;
    float b_credits_out_begin = 24.0;
    float b_credits_out_end = 48.0;
    
    float credits_wave = 0.0;
    if(b_credits_begin <= beats) {
      if(beats < b_credits_peak) {
        credits_wave = scale(b_credits_begin, b_credits_peak, 0.0, 1.0, beats);
      } else if(beats < b_credits_out_begin) {
        credits_wave = 1.0;
      } else if(beats < b_credits_out_end) {
        credits_wave = scale(b_credits_out_begin, b_credits_out_end, 1.0, 0.0, beats);
      } else {
        credits_wave = 0.0;
      }
    }
    credits_wave = pow(credits_wave, 2.0);
    
    float b_sat_begin = 0.0;
    float b_sat_end = 32.0;
    
    float sat_wave = 0.0;
    if(b_sat_begin <= beats) {
      if(beats < b_sat_end) {
        sat_wave = scale(b_sat_begin, b_sat_end, 0.0, 1.0, beats);
      } else {
        sat_wave = 1.0;
      }
    }
    sat_wave = pow(sat_wave, 2.0);
    
    float kick_wave = 0.0;
    float beat4 = beats % 4.0;
    if(1.0 <= beat4 && beat4 < 2.0) {
      kick_wave = 1.0 - beats % 1.0;
    }
    
    float b_fade = 32.0;
    
    float fade = 0.0;
    if(b_fade <= beats) {
      fade = scale(b_fade, this.duration, 0.0, 1.0, beats);
    }
    fade = pow(fade, 2.0);
    
    hint(DISABLE_DEPTH_TEST);
    fill(255);
    shader(this.ghostScene.shader);
    this.ghostScene.shader.set("sat", sat_wave);
    this.ghostScene.shader.set("kick_wave", kick_wave);
    this.ghostScene.shader.set("fade", fade);
    this.ghostScene.draw(beats);
    resetShader();
    
    fill(255, 255.0*credits_wave);
    float heightOffset = -0.01*height;
    float width1 = textWidth(this.text1);
    text(this.text1, margin + 0.0*width1, 0.5*height + heightOffset);
    
    float width2 = textWidth(this.text2);
    text(this.text2, width - margin - 0.0*width2, 0.5*height + heightOffset);
    
    hint(ENABLE_DEPTH_TEST);
  }
}