uniform vec2 iResolution;
uniform float iGlobalTime;
out vec4 out_color;

vec3 getBallColorAtCurrentPixel(vec2 pos, float size, vec2 uv) {
	float distanceToBall=length(uv - pos) / size; //current pixels' distance to ball's center
	distanceToBall = min(max((1.0 - distanceToBall), 0.0), 1.0); // values will be 0.0..1.0, invert color
	distanceToBall = min(distanceToBall, size/0.1);
    distanceToBall *= distanceToBall;
	return vec3(distanceToBall);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy; // uv vector knows the coordinates of the current pixel
	uv.x *= iResolution.x / iResolution.y; // fix resolution
	vec3 color = vec3(0.0, 0.0, 0.0);
    
    // generate balls:
	for(float i = 0.; i < 25.; i++){
		vec2 ballPosition = vec2(0.5 + 0.5 * sin(0.5*iGlobalTime+i) + 0.1 * i,
                                 0.5 + 0.45 * cos(0.3*iGlobalTime + sin(i) + 0.54 * i));		
		float ballSize = 0.3;
		color += getBallColorAtCurrentPixel(ballPosition, ballSize, uv);
	}
	
    // add colors (otherwise the metaballs would be white), colors change by time
	color *= vec3(0.7 + 0.1 * sin(2.0 * iGlobalTime * uv.x * uv.y),
					0.3 + 0.1 * sin(4.0 * iGlobalTime * uv.y),
					0.1*cos(uv)) - vec3(sin(0.1 * iGlobalTime),
					0.0,
					0.0);
	
    // set color for the current pixel:
	fragColor = vec4(color * 2.0, 1.0);
}


void main() {
    vec4 fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    vec2 fragCoord = gl_FragCoord.xy;
    mainImage(fragColor, fragCoord);
    out_color = fragColor;
}