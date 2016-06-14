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

uniform float sat;
uniform float kick_wave;
uniform float fade;
uniform sampler2D credits;
uniform float credits_wave;

out vec4 out_color;

#define TAU 6.283185307179586
#define PI 3.141592653589793

#define NO_MATERIAL 0
#define HEAD_MATERIAL 1
#define EYE_MATERIAL 2
#define GROUND_MATERIAL 4

#define THRESHOLD 0.001
#define MAX_STEP 1.0
#define MAX_ITERATIONS 256
#define NORMAL_DELTA 0.05
#define MAX_DEPTH 60.0

float scale(float l0, float r0, float l1, float r1, float x) {
	return (x - l0) / (r0 - l0) * (r1 - l1) + l1;
}

vec2 rect2polar(vec2 p) {
    return vec2(atan(p.y, p.x), length(p));
}

vec2 polar2rect(vec2 p) {
    return vec2(cos(p.x) * p.y, sin(p.x) * p.y);
}

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

struct ObjectDistance {
    float distance;
    int material;
};

ObjectDistance distanceUnion(ObjectDistance a, ObjectDistance b) {
    if(a.distance < b.distance) {
        return a;
    } else {
     	return b;
    }
}

ObjectDistance distanceDifference(ObjectDistance b, ObjectDistance a) {
    if(-a.distance > b.distance) {
        a.distance *= -1.0;
        return a;
    } else {
        return b;
    }        
}

ObjectDistance box(vec3 b, int material, vec3 p)
{
  vec3 d = abs(p) - b;
  return ObjectDistance(
      min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)),
      material
  );
}

ObjectDistance sphere(float r, int material, vec3 p) {
  return ObjectDistance(length(p)-r, material);
}

ObjectDistance cylinder(vec2 h, int material, vec3 p)
{
  vec2 d = abs(vec2(length(p.xy), p.z)) - h;
  return ObjectDistance(
      min(max(d.x, d.y), 0.0) + length(max(d, 0.0)),
      material
  );
}

ObjectDistance ground(float y, int material, vec3 p) {
     return ObjectDistance(p.y - y, material);   
}

vec2 rotate(float theta, vec2 p) {
	vec2 polar = vec2(atan(p.y, p.x), length(p));
	polar.x += theta;
	return vec2(polar.y * cos(polar.x), polar.y * sin(polar.x));
}

vec2 shear(float theta, vec2 p) {
	return vec2(p.x - p.y / tan(theta), p.y / sin(theta));
}

vec2 unshear(float theta, vec2 p) {
	float y = p.y * sin(theta);
	float x = p.x + y / tan(theta);
	return vec2(x, y);	
}

vec2 target(float theta, float delta, vec2 p) {
	return unshear(theta, floor(shear(theta, p) + delta) - delta + 0.5);
}

bool perforations(float theta, float rot, float scale, float r, vec2 p0) {
	vec2 p1 = scale * rotate(rot, p0);
	return distance(p1, target(theta, 0.5, p1)) < r;
}

vec3 spooky_wave(vec3 p) {
    vec2 p_polar = rect2polar(p.xz);    
    
    float y_scale = pow(-min(0.0, p.y), 2.0);
    float sine1 = 0.04 * sin(10.0 * p_polar.x + 5.0 * iGlobalTime);
    float sine2 = 0.02 * sin(14.32 * p_polar.x - 4.0 * iGlobalTime);
    vec2 q_polar = vec2(0.0, y_scale * (sine1+sine2)) + p_polar;
    vec2 q = polar2rect(q_polar);
    return vec3(q.x, p.y, q.y);
}

ObjectDistance capsule(vec3 a, vec3 b, float r, int material, vec3 p) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp(dot(pa,ba)/dot(ba,ba), 0.0, 1.0);
    return ObjectDistance(
        length(pa - ba*h) - r,
    	material
    );
}

ObjectDistance body(vec3 p) {
    float h = 4.0;
    float y0 = -0.3*h;
    float r = 0.8;
    ObjectDistance od = capsule(
        vec3(0.0, y0 + 0.5*h - r, 0.0),
        vec3(0.0, y0 - 0.5*h + r, 0.0),
        r, HEAD_MATERIAL, spooky_wave(p)
    );
    
    float box_h = 1.1*0.25*h;
    float box_w = 1.5*r;
    float box_dy = 0.25*h;
    vec3 b = vec3(box_w, box_h, box_w);
    od = distanceDifference(od, box(b, NO_MATERIAL, p + vec3(0.0, -y0+box_dy, 0.0)));
    
    return od;
}

vec3 focus() {
    return vec3(0.0, 0.0, -4.0*iBeats);
}

ObjectDistance ghost(float wave, vec3 p) {
    float wobble_t_rate = 4.0;
    float wobble_s_rate = scale(0.0, 1.0, 4.0, 25.0, wave);
    float wobble_depth = scale(0.0, 1.0, 0.05, 0.02, wave);
    vec3 q = p + vec3(wobble_depth*sin(wobble_t_rate*iGlobalTime + wobble_s_rate*p.y), 0.3, 0.0);
    ObjectDistance od = body(q);
    
    float pad = 0.65;
    float r_eye = 0.12;
    
    float d_eye = 1.0 - r_eye - pad;
    vec3 p_eye = vec3(d_eye, d_eye, -(0.7 - r_eye + 0.05));
    od = distanceDifference(
    	od,
        sphere(r_eye, EYE_MATERIAL, q - p_eye)
    );
    od = distanceDifference(
      	od,
        sphere(r_eye, EYE_MATERIAL, q - p_eye * vec3(-1.0, 1.0, 1.0))
    );
    
    float r_mouth = 0.3;
    od = distanceDifference(
        od,
        sphere(r_mouth, EYE_MATERIAL, q - vec3(0.0, -0.15, -(0.8 - r_mouth + 0.05)))
    );
    
    return od;
}

ObjectDistance sceneDistance(vec3 p) {    
	ObjectDistance od;
    
    p -= focus();
    
    float h = -2.1;
    
    od = ground(h, GROUND_MATERIAL, p);
    od = distanceUnion(od, ground(h, GROUND_MATERIAL, p * vec3(1.0, -1.0, 1.0)));
    
    vec3 q = p;
    q.y -= 0.5;

    od = distanceUnion(
        od,
        ghost(0.0, q)
    );    
            
    return od;
}

struct MarchResult {
    float length;
    float distance;
    int material;
    int iterations;
};
    
MarchResult march(vec3 origin, vec3 direction) {
    MarchResult result = MarchResult(0.0, 0.0, NO_MATERIAL, 0);
    for(int i = 0; i < MAX_ITERATIONS; i++) {
	    ObjectDistance sd = sceneDistance(origin + direction * result.length);
        result.distance = sd.distance;
        result.material = sd.material;
        result.iterations++;
        
        if(result.distance < THRESHOLD || result.length > MAX_DEPTH) {
            break;
        }
        
        result.length += min(MAX_STEP, result.distance * (1.0 - 0.5*THRESHOLD));
    }

    if(result.length > MAX_DEPTH) {
        result.material = NO_MATERIAL;
    }
    
    return result;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 pxPos = 2.0*(0.5 * iResolution.xy - fragCoord.xy) / iResolution.xx;    
  
  float cam_r = 4.0;
  float cam_theta = TAU/32.0*sin(iBeats) - 0.25*TAU;
  
  vec2 cam_pos_xz_polar = vec2(cam_theta, cam_r);
  vec2 cam_pos_xz = polar2rect(cam_pos_xz_polar);
  
  vec3 camPos = focus() + vec3(cam_pos_xz.x, 0.0, cam_pos_xz.y);
      
  vec3 camLook = focus();
  
  vec3 camUp = vec3(0.0, 1.0, 0.0); 
  vec3 camForward = normalize(camLook - camPos);
  vec3 camLeft = normalize(cross(camUp, camForward));
  vec3 camUp2 = cross(camForward, camLeft);
  vec3 camPosForward = camPos + camForward;
  vec3 screenPos = camPosForward - pxPos.x * camLeft - pxPos.y * camUp2;
  vec3 rayForward = normalize(screenPos - camPos);
  
  MarchResult mr = march(camPos, rayForward);
  	
  vec3 rayEnd = camPos + mr.length * rayForward;
  vec3 color;
  
  if(mr.material == NO_MATERIAL) {
    vec3 sky_color = vec3(0.14, 0.14, 0.26);
    float sky_mix = clamp(5.0*rayForward.y, 0.0, 1.0);
    color = mix(vec3(0.0), sky_color, sky_mix);
  } else {
    vec3 baseColor;
    
    bool is_specular = true;
    if(mr.material == HEAD_MATERIAL) {
      baseColor = vec3(0.9);
      is_specular = false;
    } else if(mr.material == EYE_MATERIAL) {
      baseColor = vec3(0.1);
      is_specular = false;
    } else if(mr.material == GROUND_MATERIAL) {
      vec2 end_polar = TAU - rect2polar(rayEnd.xz);
      
      float r = scale(-1.0, 1.0, 0.1, 0.5, sin(0.5 * iBeats * TAU - 0.25*TAU));
      bool perfo = perforations(TAU/6.0, 0.0, 1.0, r, rayEnd.xz);
      float k_v = scale(0.0, 1.0, 0.2, 1.0, sat);
      vec3 hsv = rgb2hsv(vec3(1.0, 0.0, 0.0)) * vec3(1.0, sat, k_v);
      vec3 color0 = perfo
        ? vec3(0.0)
        : mix(
          hsv2rgb(hsv + vec3(mod(iBeats/128.0*TAU, TAU), 0.0, 0.0)),
          vec3(1.0),
          pow(kick_wave, 2.0)
        );
      
      baseColor = color0;
    }
    
    float deltaTwice = 2.0 * NORMAL_DELTA;
    vec3 dx = vec3(NORMAL_DELTA, 0.0, 0.0);
    vec3 dy = vec3(0.0, NORMAL_DELTA, 0.0);
    vec3 dz = vec3(0.0, 0.0, NORMAL_DELTA);
    vec3 normal = normalize(vec3(
      (sceneDistance(rayEnd + dx).distance) / NORMAL_DELTA,
      (sceneDistance(rayEnd + dy).distance) / NORMAL_DELTA,
      (sceneDistance(rayEnd + dz).distance) / NORMAL_DELTA
    ));

    vec3 lightPos = camPos + vec3(0.0, 0.0, 0.0);
    
    float ambient = 0.2;
    float diffuse = max(0.0, dot(normal, normalize(lightPos - rayEnd)));
    float specular = (is_specular ? 1.0 : 0.0) * pow(diffuse, 16.0);

    color = ((ambient + diffuse) * baseColor + specular) * (1.0 - mr.length * 0.01);
  }
  
  color = mix(color, vec3(0.0), fade);
          
  fragColor = vec4(color, 1.0);
}

void main() {
    vec4 fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    vec2 fragCoord = gl_FragCoord.xy;
    mainImage(fragColor, fragCoord);
    
    vec4 credits_color = texture(credits, gl_FragCoord.xy/iResolution);
    vec3 raw_color = mix(fragColor.xyz, credits_color.xyz, credits_color.w * credits_wave);
    out_color = vec4(raw_color, 1.0);
}
