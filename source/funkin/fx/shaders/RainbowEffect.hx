package funkin.fx.shaders;

import flixel.input.FlxPointer;
import flixel.input.mouse.FlxMouse;
import flixel.FlxG;
import funkin.fx.shaders.shadertoy.FlxShaderToyHack;

class RainbowEffect extends FlxShaderToyHack
{
	// see https://www.shadertoy.com/view/dsfyWB
	public function new()
	{
		super('vec3 palette( float t) {
            //cosine gradient
            vec3 a = vec3(0.750, 0.750, 0.750);
            vec3 b = vec3(0.500, 0.500, 0.500);
            vec3 c = vec3(1.000, 1.000, 1.000);
            vec3 d = vec3(0.000, 0.333, 0.667);
            
            return a + b*cos(6.28318*(c*t+d) );
        }
        
        void mainImage( out vec4 fragColor, in vec2 fragCoord )
        {
            // Normalized pixel coordinates (from 0 to 1)
            vec2 uv = fragCoord/iResolution.xy;
        
            vec3 col = vec3(0.);
            
            vec3 bg = texture(bitmap, uv).rgb;
            
            
            vec3 greyscale = vec3(.5, .5, .5);
            vec3 bg_gs = vec3(dot(bg.rgb, greyscale));
            
            vec2 fx_scroll_direction = normalize(vec2(1.5, 1.));
            
            col = palette(iTime * 0.2 + uv.x * fx_scroll_direction.x + uv.y * fx_scroll_direction.y - bg_gs.x);
            
            // Output to screen
            fragColor = vec4(col,1.0);
        }');

	}

	public override function update(elapsed:Float, mouse:FlxMouse)
	{
		super.update(elapsed, mouse);
	}
}
