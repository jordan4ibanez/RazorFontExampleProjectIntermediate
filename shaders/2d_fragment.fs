#version 410 core

// Frag is for tri texture mapping.
// This is just your standard old glsl shader.

in vec2 outputTextureCoordinate;
in vec4 newColoring;

out vec4 fragColor;

uniform sampler2D textureSampler;


void main() {

    // Store what the pixel would have been colored and alphad on the vertex position
    vec4 pixelColor = texture(textureSampler, outputTextureCoordinate);
    
    // Now we must colorize the rgba while also keeping the original alpha
    vec4 rgba = vec4 (newColoring.x, newColoring.y, newColoring.z, pixelColor.w);
    
    // newColoring
    fragColor = rgba;
}