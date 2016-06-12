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

uniform sampler2D in_image;
uniform sampler2D in_image1;
out vec4 out_color;

vec2 pow(vec2 v, float e) {
  return vec2(pow(v.x, e), pow(v.y, e));
}

void main() {
    vec2 fragCoord = gl_FragCoord.xy;
    
    vec2 tex_coord = (pow(fragCoord / iResolution.xy * 2.0 - 1.0, 1.0) + 1.0) / 2.0;
    
    vec3 tex_color = texture(in_image, tex_coord).xyz;
    vec3 tex_color1 = texture(in_image1, tex_coord).xyz;
    float blend = 0.91;
    vec3 raw_color = blend * tex_color + (1.0-blend) * tex_color1;
    
    out_color = vec4(raw_color, 1.0);
}