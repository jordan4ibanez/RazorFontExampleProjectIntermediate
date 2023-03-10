#version 410 core

// Frag is for tri texture mapping.
// This shader is a bit fancier

in vec2 outputTextureCoordinate;
in vec4 newColoring;

out vec4 fragColor;

uniform sampler2D textureSampler;


void main() {

    // Store what the pixel would have been colored and alphad on the vertex position
    vec4 pixelColor = texture(textureSampler, outputTextureCoordinate);
    
    // If the alpha of the text is less than the set alpha, use the set alpha
    // We do this because gl can't tell the difference between blank space and 
    // text space.
    float alpha = newColoring.w < pixelColor.w ? newColoring.w : pixelColor.w;

    //! This is a new component in the shader, this allows multilayer 1d (z axis) manual manipulation of
    //! The current pixel buffer
    if (alpha <= 0.0) {
        discard;
    }

    // Now we must colorize the rgba while also keeping the original alpha
    vec4 rgba = vec4 (newColoring.x, newColoring.y, newColoring.z, alpha);
    
    // newColoring
    fragColor = rgba;
}