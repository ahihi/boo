uniform float iGlobalTime;
uniform vec2 iResolution;
out vec4 out_color;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv.x*=iResolution.x/iResolution.y;
	
	float t = iGlobalTime + 400.0;
	vec2 origin = vec2((0.5*cos(t))/4.0+1.0, (0.5*sin(t))/4.0+0.5);
	float distanceFromOrigin = distance(uv, origin) - t*.05;
	
	fragColor = vec4(0.3*sin(distanceFromOrigin*0.09*t+0.2),0.0,0.3*sin(distanceFromOrigin*0.09*t),1.0);
}

void main() {
    vec4 fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    vec2 fragCoord = gl_FragCoord.xy;
    mainImage(fragColor, fragCoord);
    out_color = fragColor;
}