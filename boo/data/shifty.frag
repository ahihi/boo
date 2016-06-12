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

uniform float progress_sd;
uniform float progress_noise;
uniform float progress_roll;
uniform float disrupt_wave;

out vec4 out_color;

#define PI 3.141592653589793
#define TAU 6.283185307179586

float scale(float l0, float r0, float l1, float r1, float x) {
	return (x - l0) / (r0 - l0) * (r1 - l1) + l1;
}

vec2 rect2polar(vec2 p) {
    return vec2(atan(p.y, p.x), length(p));
}

vec2 polar2rect(vec2 p) {
    return vec2(cos(p.x) * p.y, sin(p.x) * p.y);
}

float inv_pow(float b, float e) {
  return 1.0 - pow(1.0 - b, e);
}

float rand(vec2 n) { 
  return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 p0 = 2.0*(0.5 * iResolution.xy - fragCoord.xy) / iResolution.xx;
  p0 += polar2rect(vec2(16.0*iBeats, 0.25*disrupt_wave));
	float angle0 = atan(p0.y, p0.x);
	float turn0 = (angle0 + PI) / TAU;
	float radius0 = sqrt(p0.x*p0.x + p0.y*p0.y);
	
  float section = floor(pow(radius0*1000.0, 0.6) - iGlobalTime*2.0);
  float turn = turn0 + 0.04 * sin(1.3*(-iGlobalTime + 0.3*section));
  
  float segments = 14.0;
  float segment_angle = 1.0/segments;
  float pulse_bd = inv_pow(fract(0.25*iBeats), 12.0);
  float pulse_hh = iBeats >= 16.0
    ? inv_pow(fract(0.5*iBeats), 4.0)
    : 1.0;
  vec3 color = (mod(turn, 2.0*segment_angle) < segment_angle)
    ? mix(
      vec3(scale(0.0, 1.0, 1.4, 1.0, pulse_hh)) * vec3(0.69, 0.21, 0.21),
      vec3(scale(0.0, 1.0, 0.65, 0.55, pulse_hh)),
      progress_sd
    )
    : mix(
      vec3(scale(0.0, 1.0, 0.2, 1.0, pulse_bd)) * vec3(0.49, 0.19, 0.19),
      vec3(scale(0.0, 1.0, 0.35, 0.45, pulse_bd)),
      progress_sd
    );
  
  color *= 1.0 - progress_noise * rand(fragCoord + vec2(0.0, iBeats*99.0));
  color = mix(color, vec3(0.0), progress_roll);
  
  fragColor = vec4(color, 1.0);
}

void main() {
  vec4 fragColor = vec4(0.0, 0.0, 0.0, 1.0);
  vec2 fragCoord = gl_FragCoord.xy;
  mainImage(fragColor, fragCoord);
  gl_FragColor = fragColor;
}