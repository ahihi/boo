#version 150

#define PROCESSING_LIGHT_SHADER

uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;

uniform vec4 lightPosition;

in vec4 vertex;
in vec4 color;
in vec2 texCoord;
in vec3 normal;

out vec4 vertColor;
out vec4 vertTexCoord;

void main() {
  gl_Position = transform * vertex;    
  vec3 ecVertex = vec3(modelview * vertex);  
  vec3 ecNormal = normalize(normalMatrix * normal);

  vec3 direction = normalize(lightPosition.xyz - ecVertex);    
  float intensity = max(0.0, dot(direction, ecNormal));
  vertColor = vec4(intensity, intensity, intensity, 1) * color;             
  
  gl_Position = transform * vertex;

  vec2 coord = vec2(1.0 - texCoord.x, texCoord.y);
  vertTexCoord = texMatrix * vec4(coord, 1.0, 1.0);
}
