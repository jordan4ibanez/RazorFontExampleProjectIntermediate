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

            Font.RazorTextSize textSize = Font.getTextSize(fontSize, textString);

            // Now we're going to move slightly above the center point of the window
            double posX = (Window.getWidth / 2.0) - (textSize.width / 2.0);
            double posY = (Window.getHeight / 2.0) - (textSize.height / 2.0);

            Font.renderToCanvas(posX, posY, fontSize, textString);

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
                    theBeach -= Math.PI2;
                }

                /*
                So you know how we rendered to the canvas before hand?

                Well, now we have the amount of characters currently on
                the canvas, so we can work backwards from that with ease!

                You could also use this to set up the next word in a multi-render
                to canvas to do some even crazier stuff :)

                Keep in mind, your typewriter arm is already above what would be the next character
                in the row without a carriage return.
                -1 shifts it onto the last currently rendered character.
                */
                const currentIndex = Font.getCurrentCharacterIndex() - 10;

                for (int i = currentIndex; i < currentIndex + 10; i++) {

                    // We want this to be a smooth flowing animation loop
                    // So we're gonna use some fancy math
                    const double left = theBeach + cast(double)i;
                    const double right = left + 2.5; // This is what I'm talking about below.

                    double waterFlowLeft  = (Math.sin(left)  / 2.0) + 0.5;
                    double waterFlowRight = (Math.sin(right) / 2.0) + 0.5;

                    /**
                    So what we're doing here is basically creating a fixed,
                    smooth loop of data that's equal to an oscillating wave
                    form on a 2d plotter. We're starting from the left point
                    of that (data + index) to get somewhere on that data stream.
                    That's the left side done, so the easiest way to make this 
                    look ultra smooth is to just poll half way to the right to make
                    the compression of the data form get automatically mapped by opengl
                    into emulating the foam of a wave at the beach.

                    I left a little comment up above where the right half is, try changing
                    that to 2.5 or 3.5 and see what happens. :)

                    Now don't read the next part until you've tried that.

                    What you just did, was you created an overlap of the polling
                    into the data stream of the next character, looks pretty neat huh?
                    */
                    Font.setColorPoints(i,
                        waterFlowLeft,waterFlowLeft,1,1, // left
                        waterFlowLeft,waterFlowLeft,1,1,
                        waterFlowRight,waterFlowRight,1,1, //right
                        waterFlowRight,waterFlowRight,1,1
                    );
                }

            }
        }

        /**
        One last thing I have to let you know. Did you notice that we
        never set the font during the loop of the program?

        If your program has only one font, you only need to set it at the
        entry point and never look at it again!

        Have fun. :D
        */
        
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