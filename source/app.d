import std.stdio;

import Font = razor_font;

import Window = window.window;
import Camera = camera.camera;
import Shader = shader.shader;
import Texture = texture.texture;
import mesh.mesh;
import doml.vector_2d;


//! IMPORTANT: If you did not read the simple tutorial, I highly recommend you go and do that!
//! Only NEW pieces will be explained!
//! https://github.com/jordan4ibanez/RazorFontExampleProject

void main()
{
    Window.initialize();
    Window.setTitle("RazorFont Example Advanced");

    Shader.create("2d", "shaders/2d_vertex.vs", "shaders/2d_fragment.fs");
    Shader.createUniform("2d", "cameraMatrix");
    Shader.createUniform("2d", "objectMatrix");
    Shader.createUniform("2d", "textureSampler");

    Shader.create("3d", "shaders/regular_vertex.vs", "shaders/regular_fragment.fs");
    Shader.createUniform("3d", "cameraMatrix");
    Shader.createUniform("3d", "objectMatrix");
    Shader.createUniform("3d", "textureSampler");

    Font.setRenderTargetAPICallString(
        (string input){
            Texture.addTexture(input);
        }
    );
    Font.setRenderFunc(
        (Font.RazorFontData fontData) {

            string fileLocation = Font.getCurrentFontTextureFileLocation();

            Mesh tempObject = new Mesh()
                .addVertices2d(fontData.vertexPositions)
                .addIndices(fontData.indices)
                .addTextureCoordinates(fontData.textureCoordinates)
                .setTexture(Texture.getTexture(fileLocation))
                .finalize();

            tempObject.render("2d");
            tempObject.cleanUp();
        }
    );


    Font.createFont("example_fonts/totally_original", "mc", true);

    // We're only going to use the mc font this time
    Font.selectFont("mc");
    
    while (!Window.shouldClose()) {

        Window.pollEvents();
        Camera.clearDepthBuffer();
        
        Window.clear(0.9);
        
        Shader.startProgram("2d");
        Font.setCanvasSize(Window.getWidth, Window.getHeight);
        
        Shader.setUniformMatrix4("2d", "cameraMatrix", Camera.updateGuiMatrix());
        Shader.setUniformMatrix4("2d", "objectMatrix", Camera.setGuiObjectMatrix() );
        

        {
            int fontSize = 32;
            string textString = "Hello, I'm your test text :)";

            Font.RazorTextSize textSize = Font.getTextSize(fontSize, textString);

            // Now we're going to move slightly above the center point of the window
            double posX = (Window.getWidth / 2.0) - (textSize.width / 2.0);
            double posY = (Window.getHeight / 2.0) - (textSize.height / 2.0);

            Font.renderToCanvas(posX, posY, fontSize, textString);
        }
        
        Font.render();

        // Update the gl window yada yada
        Window.swapBuffers();
    }

    // Just regular ol opengl cleanup
    Shader.deleteShader("2d");
    Shader.deleteShader("3d");
    Texture.cleanUp();
    Window.destroy();

}