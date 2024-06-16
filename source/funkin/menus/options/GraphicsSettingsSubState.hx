package funkin.menus.options;

import funkin.plugins.ShaderManager;
import funkin.plugins.WindowMode;
import flixel.text.FlxText;
import flixel.FlxSprite;
#if (cpp && desktop)
import funkin.system.Discord;
#end
import openfl.text.TextField;
import flixel.FlxG;
import flixel.math.FlxMath;
import openfl.Lib;

using StringTools;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	var _windowModeOpt:Option;

	public function new()
	{
		if (!ClientPrefs.vsync)
		{
			// #if !html5
			// Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
			// to the psych dev that wrote this, yes it has vsync enabled by default. why?. browser. - letsgoaway
			var option:Option = new Option('Framerate', "Pretty self explanatory, isn't it?", 'framerate', 'int', 999);
			addOption(option);
			option.changeValue = 5;
			option.minValue = 25;
			option.maxValue = 1000;
			option.displayFormat = '%v FPS';
			option.onChange = onChangeFramerate;
		}
		// #end
		var option:Option = new Option('Show FPS', 'If unchecked, hides the FPS Counter.', 'showFPS', 'bool', true);
		addOption(option);

		var option:Option = new Option('Show RAM Usage', 'If unchecked, hides the memory Counter.', 'showMEM', 'bool', true);
		addOption(option);

		var windowModeArray:Array<String>;
		windowModeArray =
			#if !html5
			[
				'Windowed',
				'Windowed (Borderless)',
				'Fullscreen (Borderless)',
				'Fullscreen (Exclusive)'
			]
			#else
			['Windowed', 'Fullscreen']
			#end;

		var option:Option = new Option('Vsync (Restart Required)', // Name
			'If checked, reduces screen tearing.', // Description
			'vsync', // Save data variable name
			'bool', // Variable type
			false); // Default value
		option.onChange = onChangeVsync;
		addOption(option);

		var option:Option = new Option('Window Mode', "Quick Trigger with Alt+Enter or F11", 'fullscreenMode', 'string', 'Windowed', windowModeArray);
		addOption(option);
		option.onChange = onChangeWindowMode;

		// I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', // Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', // Description
			'lowQuality', // Save data variable name
			'bool', // Variable type
			false); // Default value
		addOption(option);

		var option:Option = new Option('Asset Quality', 'Adjust the resolution of some assets.', 'assetQuality', 'percent', 1);
		option.scrollSpeed = 1;
		option.minValue = 0.10;
		option.maxValue = 1;
		option.changeValue = 0.10;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Anti-Aliasing', 'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'globalAntialiasing', 'bool', true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; // Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		var option:Option = new Option('Brightness', 'Adjust the brightness.', 'brightness', 'percent', 1);
		option.scrollSpeed = 1;
		option.minValue = 0.1;
		option.maxValue = 1.5;
		option.changeValue = 0.10;
		option.decimals = 1;
		option.onChange = onChangeGraphicalShader;
		addOption(option);

		var option:Option = new Option('Contrast', 'Adjust the contrast.', 'contrast', 'percent', 1);
		option.scrollSpeed = 1;
		option.minValue = 0.1;
		option.maxValue = 2;
		option.changeValue = 0.10;
		option.decimals = 1;
		option.onChange = onChangeGraphicalShader;
		addOption(option);

		var option:Option = new Option('Saturation', 'Adjust the saturation.', 'saturation', 'percent', 1);
		option.scrollSpeed = 1;
		option.minValue = 0;
		option.maxValue = 3;
		option.changeValue = 0.10;
		option.decimals = 1;
		option.onChange = onChangeGraphicalShader;
		addOption(option);

		var option:Option = new Option('Vibrance', 'Adjust the vibrance.', 'vibrance', 'percent', 1);
		option.scrollSpeed = 1;
		option.minValue = 0;
		option.maxValue = 3;
		option.changeValue = 0.10;
		option.decimals = 1;
		option.onChange = onChangeGraphicalShader;
		addOption(option);

		super();
	}

	function onChangeAntiAliasing()
	{
		FlxSprite.defaultAntialiasing = ClientPrefs.globalAntialiasing;
		for (sprite in members)
		{
			if (sprite is FlxSprite)
			{
				var sprite:FlxSprite = cast(sprite, FlxSprite); // Don't judge me ok
				if (sprite != null)
					sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		FlxG.updateFramerate = 1000;
		FlxG.drawFramerate = ClientPrefs.framerate;
	}

	function onChangeVsync()
	{
		OptionsState.restart = true;
	}

	function onChangeWindowMode()
	{
		WindowMode.setMode(ClientPrefs.fullscreenMode);
	}

	function onChangeGraphicalShader()
	{
		ShaderManager.apply();
	}
}
