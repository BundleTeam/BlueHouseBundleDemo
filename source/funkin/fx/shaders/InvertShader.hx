package funkin.fx.shaders;

import flixel.system.FlxAssets.FlxShader;

class InvertShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		void main()
		{
			vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
			gl_FragColor = vec4(textureColor.a - textureColor.r,textureColor.a -textureColor.g,textureColor.a -textureColor.b,textureColor.a);
		}
		')
	public function new()
	{
		super();
	}
}
