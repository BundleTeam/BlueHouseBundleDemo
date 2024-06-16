package funkin.system;

import flixel.FlxG;
import openfl.Lib;
import funkin.system.backend.Hardware.OS;
import haxe.PosInfos;

class Funkin
{
	private static var logger:Logger = new Logger();

	public static function getLogger():Logger
	{
		return logger;
	}

	public static function log(v:Dynamic, ?pos:PosInfos, ?noTime:Bool = false):Void
	{
		logger.log(v, pos, noTime);
	}

	public static function init()
	{
		FlxG.fixedTimestep = false;
		Lib.application.onUpdate.add(Funkin.update);
	}

	public static function update(frame:Int)
	{
	}
}
