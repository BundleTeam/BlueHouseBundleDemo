package funkin.plugins;

import funkin.fx.shaders.BrightnessContrastShader;
import funkin.fx.shaders.SaturationVibranceShader;
import haxe.ds.HashMap;
import openfl.filters.ShaderFilter;
import flixel.FlxG;
import openfl.filters.BitmapFilter;
import flixel.FlxBasic;

class ShaderManager extends FlxBasic
{
	public static var instance:ShaderManager;

	public var shaderIDS:Array<String> = [];

	private var shaders:Array<BitmapFilter> = [];

	private var briConShader:BrightnessContrastShader;
	private var satVibShader:SaturationVibranceShader;

	public function new()
	{
		super();
		instance = this;
		FlxG.signals.postStateSwitch.add(() ->
		{
			apply();
		});
		registerShaders();
		apply();
	}

	public override function update(elapsed:Float)
	{
		if (isLoaded("satvib"))
			satVibShader.set(ClientPrefs.saturation, ClientPrefs.vibrance);

		if (isLoaded("bricon"))
			briConShader.set(ClientPrefs.brightness, ClientPrefs.contrast);
		super.update(elapsed);
	}

	private function registerShaders()
	{
	}

	private function checkGraphicalShaders()
	{
		if (!isLoaded("satvib"))
		{
			if (ClientPrefs.saturation != 1.0 || ClientPrefs.vibrance != 1.0)
			{
				satVibShader = new SaturationVibranceShader();
				add("satvib", new ShaderFilter(satVibShader));
			}
		}
		else
		{
			if (ClientPrefs.saturation == 1.0 && ClientPrefs.vibrance == 1.0) // no point even loading the shader if theres no need
			{
				remove("satvib");
			}
		}
		if (!isLoaded("bricon"))
		{
			if (ClientPrefs.brightness != 1.0 || ClientPrefs.contrast != 1.0)
			{
				briConShader = new BrightnessContrastShader();
				add("bricon", new ShaderFilter(briConShader));
			}
		}
		else
		{
			if (ClientPrefs.brightness == 1.0 && ClientPrefs.contrast == 1.0) // no point even loading the shader if theres no need
			{
				remove("bricon");
			}
		}
	}

	public static function get(shaderID:String):Null<ShaderFilter>
	{
		if (instance.shaders[instance.shaderIDS.indexOf(shaderID)] is ShaderFilter)
			return cast(instance.shaders[instance.shaderIDS.indexOf(shaderID)], ShaderFilter);
		return null;
	}

	public static function isLoaded(shaderID:String):Bool
	{
		return instance.shaderIDS.contains(shaderID);
	}

	public static function add(shaderID:String, shader:ShaderFilter):Void
	{
		if (isLoaded(shaderID))
			remove(shaderID);

		instance.shaderIDS.push(shaderID);
		instance.shaders.push(shader);
	}

	public static function remove(shaderID:String):Void
	{
		var id:Int = instance.shaderIDS.indexOf(shaderID);
		instance.shaderIDS.remove(shaderID);
		instance.shaders.remove(instance.shaders[id]);
	}

	public static function apply()
	{
		instance.checkGraphicalShaders();
		FlxG.game.setFilters(instance.shaders);
	}
}
