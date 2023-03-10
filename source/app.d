import std.stdio;

import Font = razor_font.razor_font;

import Window  = window.window;
import Camera  = camera.camera;
import Shader  = shader.shader;
import Texture = texture.texture;
import Math    = doml.math;
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
                // Note here: We added a new layout storage element into our Mesh class!
                .addColors(fontData.colors) 
                .setTexture(Texture.getTexture(fileLocation))
                .finalize();

            tempObject.render("2d");
            tempObject.cleanUp();
        }
    );


    Font.createFont("example_fonts/totally_original", "mc", true);

    // We're only going to use the mc font this time
    Font.selectFont("mc");

    // You'll find out what this is for later!
    double theBeach = 0.0;
    
    while (!Window.shouldClose()) {

        Window.pollEvents();
        Camera.clearDepthBuffer();
        
        Window.clear(0.9);
        
        Shader.startProgram("2d");
        Font.setCanvasSize(Window.getWidth, Window.getHeight);
        
        Shader.setUniformMatrix4("2d", "cameraMatrix", Camera.updateGuiMatrix());
        Shader.setUniformMatrix4("2d", "objectMatrix", Camera.setGuiObjectMatrix() );


        {
            // So you can set the letter collors before
            Font.setColorChar(0, 1,0,0,0.5);
            Font.setColorChar(1, 0,1,0);
            Font.setColorChar(2, 0,0,1);
            
            int fontSize = 32;
            string textString = "Hello, I'm your test text :)";

            // And after
            Font.setColorChar(3, 0.5,0.5,0.5);

            /**
            Let's do something REALLY fancy!
            
            Let's set the second l and o to a blue to white blend
            */

            Font.setColorPoints(4,/*Left points*/[0.,0,1,1],[0.,0,1,1], /*Right points*/[1.,1,1,1],[1.,1,1,1]);
            Font.setColorPoints(5,/*Left points*/[0.,0,1,1],[0.,0,1,1], /*Right points*/[1.,1,1,1],[1.,1,1,1]);

            /**
            Now let's get even crazier! Let's do primary colors on the first 3,
            and yellow on the last one, I'm going to use the super verbose version of setColorPoints.
            It's overloaded :D
            */
            Font.setColorPoints(
                6,
                1,0,0,1,
                0,1,0,1,
                0,0,1,1,
                1,1,0,1,
            );

            /**
            Looks kinda like a mat4 opengl and vulkan matrix. :P

            So this one just uses pcgRandom to make some crazy colors. Pretty standard. :D

            This is targeting (I'm)

            So you can see that the range func does an inclusive start, exclusive end
            just like you're used to in D
            
            */

            Font.setColorRange(7,9, Math.random(),Math.random(),Math.random(),1);

            /**

            So now, straight to the insane asylum. Let's animate this text with colors!

            It's almost spring at the time of writing this, and I want to go fishing.

            So let's make this look like the waves of the ocean.
            */
            {
                import delta_time;

                calculateDelta();

                theBeach += getDelta();
                
                if (theBeach > Math.PI) {
                    theBeach -= Math.PI;
                }

                double waterFlow = Math.cos(theBeach);

                writeln(waterFlow);

            }




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