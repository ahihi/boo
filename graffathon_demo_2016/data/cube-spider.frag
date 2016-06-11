#version 150

//#define VARJOKUUNTELIJA
#ifdef VARJOKUUNTELIJA
uniform vec2 u_resolution;
uniform float u_time;
#define iResolution u_resolution
#define iGlobalTime u_time
#define iBeats iGlobalTime
#else
uniform vec2 iResolution;
uniform float iGlobalTime;
uniform float iBeats;
#endif

uniform bool eye;
uniform float eyeProgress;
uniform float progress_hh;

in vec4 vertColor;
in vec4 vertTexCoord;

out vec4 out_color;

#define EYE_WIDTH 0.7
#define EYE_HEIGHT 0.4
#define IRIS_RADIUS 0.38
#define PUPIL_RADIUS_MIN 0.2
#define PUPIL_RADIUS_MAX 0.3
#define SMALL_EYE_SCALE 0.4

bool draw_eye(float progress, float pulse, vec2 p, out vec3 color) {
  if(length(p / vec2(EYE_WIDTH, progress * EYE_HEIGHT)) < 1.0) {    
    if(length(p) < mix(PUPIL_RADIUS_MIN, PUPIL_RADIUS_MAX, pulse)) {
      color = vec3(0.0);
    } else if(length(p) < IRIS_RADIUS) {
      color = mix(
        vec3(1.0, 0.0, 0.0),
        vec3(0.5),
        pulse
      );
    } else {
      color = vec3(1.0);
    }
    return true;
  } else {
    return false;
  }
}

void main() {
    vec3 color0 = vertColor.xyz;
    
    vec2 p_tex = vertTexCoord.xy * vec2(2.0) - vec2(1.0);
    float pulse = fract(0.5*iBeats);
    float pulse_hh = fract(iBeats + 0.5);

    if(eye) {
      if(!draw_eye(eyeProgress, pulse, p_tex, color0)) {
        color0 = vertColor.xyz;
      }
    }
    
    for(int i = -1; i < 2; i += 2) {
      for(int j = -1; j < 2; j += 2) {
        vec3 color0_orig = color0;
        vec2 p = p_tex / SMALL_EYE_SCALE + vec2(i, j)*0.6/SMALL_EYE_SCALE;
        if(!draw_eye(progress_hh, pulse_hh, p, color0)) {
          color0 = color0_orig;
        }
      }
    }
    
    vec3 color = color0;
    out_color = vec4(color, vertColor.w);
}
