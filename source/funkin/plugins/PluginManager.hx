package funkin.plugins;

import funkin.ui.notifications.NotificationManager;
import funkin.plugins.*;
import funkin.plugins.input.*;
import flixel.FlxBasic;
import flixel.FlxG;

class PluginManager
{
	public static function register(plugin:FlxBasic)
	{
		FlxG.plugins.addIfUniqueType(plugin);
	}

	public static function registerAll()
	{
		FlxG.plugins.drawOnTop = true;
		PluginManager.register(new WindowMode());
		PluginManager.register(new Input());

		PluginManager.register(new ShaderManager());
		PluginManager.register(new Global());
		PluginManager.register(new NotificationManager());
		PluginManager.register(new InfoDisplay());
	}
}
