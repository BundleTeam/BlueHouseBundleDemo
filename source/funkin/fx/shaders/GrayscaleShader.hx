package funkin.fx.shaders;

import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

class GrayscaleShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform bool enabled;
		void main()
		{
			if (enabled) {
				vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
				float gray = dot(textureColor.rgb, vec3(0.299, 0.587, 0.114));
				vec3 grayscale = vec3(gray);
				gl_FragColor = vec4(grayscale, textureColor.a);
			}
			else {
				gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			}
		}
		')
	public function new(enabled:Bool = true)
	{
		super();
		this.enabled.value = [enabled];
	}
}
