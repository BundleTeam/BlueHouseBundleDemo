package funkin.fx.shaders;

import openfl.display.ShaderParameter;
import flixel.system.FlxAssets.FlxShader;

// thank you https://github.com/cansik/processing-postfx/blob/master/shader/saturationVibranceFrag.glsl
class SaturationVibranceShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform float saturation;
		uniform float vibrance;
		void main()
		{
			vec4 col = flixel_texture2D(bitmap, openfl_TextureCoordv);
			vec3 color = col.rgb;
			float luminance = color.r*0.299 + color.g*0.587 + color.b*0.114;
			float mn = min(min(color.r, color.g), color.b);
			float mx = max(max(color.r, color.g), color.b);
			float sat = (1.0-(mx - mn)) * (1.0-mx) * luminance * 5.0;
			vec3 lightness = vec3((mn + mx)/2.0);

			color = mix(color, mix(color, lightness, -vibrance), sat);
			color = mix(color, lightness, (1.0-lightness)*(1.0-vibrance)/2.0*abs(vibrance));
			color = mix(color, vec3(luminance), -saturation);

			gl_FragColor = vec4(mix(col.rgb, color, col.a), col.a);
		}		
	')
	public function new(saturation:Float = 1.0, vibrance:Float = 1.0)
	{
		super();
		set(saturation, vibrance);
	}

	public function set(saturation:Float = 1.0, vibrance:Float = 1.0)
	{
		this.saturation.value = [saturation - 1.0];
		this.vibrance.value = [vibrance - 1.0];
	}
}
