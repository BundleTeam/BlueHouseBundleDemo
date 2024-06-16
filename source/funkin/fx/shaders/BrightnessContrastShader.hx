package funkin.fx.shaders;

import flixel.system.FlxAssets.FlxShader;

// thank you https://github.com/cansik/processing-postfx/blob/master/shader/brightnessContrastFrag.glsl
class BrightnessContrastShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
				
		uniform float brightness;
		uniform float contrast;
		void main()
		{	
			vec4 c = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec3 colorContrasted = c.rgb * contrast;
			vec3 bright = colorContrasted + vec3(brightness, brightness, brightness);

			gl_FragColor = vec4(bright, c.a);
		}
		')
	public function new(brightness:Float = 1.0, contrast:Float = 1.0)
	{
		super();
		set(brightness, contrast);
	}

	public function set(brightness:Float, contrast:Float)
	{
		this.brightness.value = [brightness - 1.0];
		this.contrast.value = [contrast];
	}
}
