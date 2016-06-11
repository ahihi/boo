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
out vec4 out_color;

#define TAU 6.283185307179586
#define PI 3.141592653589793

#define DURATION 32.0
#define CORNERS 6

#define NO_MATERIAL 0
#define HEAD_MATERIAL 1
#define EYE_MATERIAL 2
#define TUNNEL_MATERIAL 4

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

// Eyes

#define UNIT 1.3

vec2 shear(float theta, vec2 p) {
	return vec2(p.x - p.y / tan(theta), p.y / sin(theta));
}

vec2 unshear(float theta, vec2 p) {
	float y = p.y * sin(theta);
	float x = p.x + y / tan(theta);
	return vec2(x, y);	
}

float rand(vec2 p){
	return fract(sin(dot(p.xy, vec2(1.3295, 4.12))) * 493022.1);
}

float timestep(float duration, float t) {
	return floor(t / duration) * duration;
}

vec3 eyes(float t, vec2 coord) {
	vec2 p0 = 2.0*(coord - 0.5 * iResolution.xy) / iResolution.xx;
	
	float unit = UNIT;
	float d_step0 = 1.1544 * unit;
	float d_step1 = 1.823 * unit;
	float d_step2 = 2.32 * unit;
	float d_step3 = 2.9757 * unit;
	float d_step4 = 1.21 * unit;
	float d_step5 = 0.93354 * unit;
	
	float t_step0 = timestep(d_step0, t);
	vec2 p0_rot = polar2rect(rect2polar(p0) + vec2(scale(0.0, 1.0, 0.0, TAU, rand(vec2(0.0, sqrt(t_step0)))), 0.0));
	vec2 p0_step = p0_rot + vec2(
		scale(0.0, 1.0, -1.0, 1.0, rand(vec2(t_step0, 0.0))),
		scale(0.0, 1.0, -1.0, 1.0, rand(vec2(0.0, t_step0)))
	);
	float theta = TAU/4.0 + scale(0.0, 1.0, -1.0, 1.0, rand(vec2(0.0, timestep(d_step1, t))));

	float k_p1 = scale(0.0, 1.0, 2.0, 5.0, rand(vec2(timestep(d_step2, t), 0.0)));
	vec2 p1 = k_p1 * (p0_step /*+ 0.125*/);
		
	vec2 p2 = shear(theta, p1);
	
	float d_move = 0.4;
	vec2 p_c = floor(p2) + 0.5 + scale(0.0, 1.0, -d_move, d_move, rand(vec2(timestep(d_step3, t), 0.0)));
	vec2 p3 = unshear(theta, p_c);
		
	float radius = scale(0.0, 1.0, 0.3, 0.6, rand(vec2(-42.0, timestep(0.21 * unit, t))));//0.25;
	float rings = floor(scale(0.0, 1.0, 1.0, 4.0, rand(vec2(0.0, timestep(d_step4, t)))));
	float dist = distance(p3, p1);
	float ring_i = floor(dist/radius * rings);
	float ring_i2 = floor(dist / radius * 2.0 * rings);
	float ring_pos = fract(dist / radius * rings);
	float ring_pos2 = fract(dist / radius * 2.0 * rings);
	float r_pupil = radius / scale(0.0, 1.0, 1.5, 2.0, rand(vec2(timestep(0.322*unit, t), 0.0)));
	
	bool in_pupil = dist < r_pupil;
	bool in_iris = dist < radius;
	
	float bright = 1.0 - 0.75 * ring_i/rings * radius;
	float k_light = scale(0.0, 1.0, 0.76, 1.25, rand(vec2(-42.0, timestep(0.267*unit, t))));
	float light = k_light * bright * scale(0.0, 1.0, 0.5, 1.0, ring_pos);
	vec3 color = vec3(light, light, light);
	if(in_pupil) {
		color = vec3(0.0, 0.0, 0.0);
	} else if(in_iris) {
		vec3 iris0 = vec3(
			scale(-1.0, 1.0, 0.2, 0.96, sin(timestep(0.2*unit, 0.6654*t))),
			scale(0.0, 1.0, 0.0, 0.6, rand(floor(p2) * vec2(timestep(0.33*unit, .5*t + 53.0*floor(p2.x+p2.y)), -3211.1))),
			scale(-1.0, 1.0, 0.1, 0.7, sin(timestep(0.115*unit, 0.533*t)))
		);

		vec3 iris1 = iris0 * 0.7;
		
		color = mix(iris0, iris1, ring_pos2);
	}
	color *= scale(0.0, 1.0, 0.3, 1.0, rand(floor(p2) + vec2(timestep(1.0*unit, t), 0.1222)));
	
	return color;
}

vec4 multi_eyes(vec2 fragCoord) {
	float t_0 = 0.7 * iGlobalTime;
	float t_1 = t_0 + UNIT*1.7;
	float mod_offset = 0.0;
	float mod0 = fract(iGlobalTime / UNIT);
	float mod_t = scale(-1.0, 1.0, 0.3, 0.7, sin(5.55 * iGlobalTime));
	
	vec3 color = eyes(t_0, fragCoord);
	if(rand(fragCoord.xy + vec2(0.0, timestep(0.125 * UNIT, iGlobalTime))) < mod_t) {
		color = eyes(t_1, fragCoord);	
	}
	
	return vec4(color, 1.0);
}

// End eyes

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

ObjectDistance tunnel(int n, float radius, vec3 p) {
    float segment_angle = TAU / float(n);
    
    vec2 polar = rect2polar(p.xz);
    float segment = floor(polar.x / segment_angle);
    
    vec2 p_rot = polar2rect(polar - vec2((segment + 0.5)*segment_angle, 0.0));
    float dist = radius - p_rot.x;
        
    return ObjectDistance(dist, TUNNEL_MATERIAL);
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
    return vec3(0.0, 8.0*iGlobalTime, 0.0);
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
    
    //od = ground(-1.0, GROUND_MATERIAL, p);
    od = tunnel(CORNERS, 4.0, p);
    
    vec3 q = p;
    q.y -= 1.0;
        
    int n_ghosts = 3;
    for(int i = 0; i < n_ghosts; i++) {
        float rot = float(i)/float(n_ghosts) * TAU;
        vec2 q_rot_xz = polar2rect(rect2polar(q.xz) + vec2(rot, 0.0));
        vec3 q_rot = vec3(q_rot_xz.x, q.y, q_rot_xz.y);
        
        vec2 trans_xz = polar2rect(vec2(rot, 2.0));
        
        float wave1 = sin(iBeats * TAU/3.0 + 0.25*TAU + rot);
        vec3 q2 = q_rot + vec3(0.0, 0.5*wave1, -2.0);
        float wave2 = pow(scale(
            -1.0, 1.0, 0.0, 1.0,
            sin(0.25 * iBeats * TAU)
        ), 51.0);
        
        od = distanceUnion(
            od,
            ghost(wave2, q2)
        );
    }
    
            
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
    
    vec2 camXZ = polar2rect(vec2(-TAU/4.0 + 0.3 * iGlobalTime, 3.0));
    
    float cam_r = 3.0;
    float cam_theta = iBeats * TAU / CORNERS;
    
    vec2 cam_pos_xz_polar = vec2(cam_theta, cam_r);
    vec2 cam_pos_xz = polar2rect(cam_pos_xz_polar);
    
    vec3 camPos = focus() + vec3(cam_pos_xz.x, 2.0, cam_pos_xz.y);
        
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
        } else if(mr.material == TUNNEL_MATERIAL) {
            vec2 end_polar = TAU - rect2polar(rayEnd.xz);
            float s_proj = 2.0;
            vec2 p_proj = vec2(
                fract(float(CORNERS) * end_polar.x / TAU) * s_proj * 90.0,
                rayEnd.y * s_proj * 20.0
            );
            
            float i_16th = 0.25 * floor(fract(iBeats) * 4.0);
            float ramp_16th = 1.0 - fract(iBeats*4.0);
            
            vec3 color0 = 0.2 + vec3(0.5 * i_16th * ramp_16th, 0.0, 0.0);
            
            baseColor = color0 + 0.5 * multi_eyes(p_proj).xyz;
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

        vec3 lightPos = camPos + vec3(0.0, 4.0, 0.0);
        
        float ambient = 0.2;
        float diffuse = max(0.0, dot(normal, normalize(lightPos - rayEnd)));
        float specular = (is_specular ? 1.0 : 0.0) * pow(diffuse, 16.0);

        color = ((ambient + diffuse) * baseColor + specular) * (1.0 - mr.length * 0.01);
    }
            
    fragColor = vec4(color, 1.0);
}

void main() {
    vec4 fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    vec2 fragCoord = gl_FragCoord.xy;
    mainImage(fragColor, fragCoord);
    
    vec3 tex_color = texture(in_image, fragCoord / iResolution.xy).xyz;
    float blend = min(0.99, pow(iBeats / DURATION, 0.5));
    vec3 raw_color = blend * tex_color + (1.0-blend) * fragColor.xyz;
    out_color = vec4(raw_color, 1.0);
}