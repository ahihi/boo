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

uniform float progress;

out vec4 out_color;

#define PI 3.141592653589793
#define TAU 6.283185307179586

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 p0 = 2.0*(0.5 * iResolution.xy - fragCoord.xy) / iResolution.xx;
	float angle0 = atan(p0.y, p0.x);
	float turn0 = (angle0 + PI) / TAU;
	float radius0 = sqrt(p0.x*p0.x + p0.y*p0.y);
	
  float section = floor(pow(radius0*1000.0, 0.6) - iGlobalTime*2.0);
  float turn = turn0 + 0.04 * sin(1.3*(-iGlobalTime + 0.3*section));
  
  float segments = 14.0;
  float segment_angle = 1.0/segments;
  vec3 color = (mod(turn, 2.0*segment_angle) < segment_angle)
    ? mix(vec3(0.69, 0.21, 0.21), vec3(0.55), progress)
    : mix(vec3(0.49, 0.19, 0.19), vec3(0.45), progress);
      
  fragColor = vec4(color, 1.0);
}

void main() {
  vec4 fragColor = vec4(0.0, 0.0, 0.0, 1.0);
  vec2 fragCoord = gl_FragCoord.xy;
  mainImage(fragColor, fragCoord);
  gl_FragColor = fragColor;
}