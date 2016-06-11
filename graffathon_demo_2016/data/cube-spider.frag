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

in vec4 vertColor;
in vec4 vertTexCoord;

out vec4 out_color;

#define EYE_WIDTH 0.7
#define EYE_HEIGHT 0.4
#define IRIS_RADIUS 0.38
#define PUPIL_RADIUS_MIN 0.2
#define PUPIL_RADIUS_MAX 0.3

void main() {
    vec3 color0 = vertColor.xyz;
    
    if(eye) {
      vec2 p_tex = vertTexCoord.xy * vec2(2.0) - vec2(1.0);
      
      if(length(p_tex / vec2(EYE_WIDTH, eyeProgress * EYE_HEIGHT)) < 1.0) {    
        if(length(p_tex) < mix(PUPIL_RADIUS_MIN, PUPIL_RADIUS_MAX, fract(iBeats))) {
          color0 = vec3(0.0);
        } else if(length(p_tex) < IRIS_RADIUS) {
          color0 = mix(
            vec3(1.0, 0.0, 0.0),
            vec3(0.5),
            fract(iBeats)
          );
        } else {
          color0 = vec3(1.0);
        }
      }
    }
    
    vec3 color = color0;
    out_color = vec4(color, vertColor.w);
}
