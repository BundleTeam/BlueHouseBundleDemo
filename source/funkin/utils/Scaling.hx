package funkin.utils;

import openfl.Lib;
import flixel.util.FlxAxes;
import flixel.FlxSprite;
import flixel.FlxG;

class Scaling
{
	/* 
		Crops Image to Fit the Screen, use these on Backgrounds 
	 */
	public static function cropScaleToScreen(sprite:flixel.FlxSprite)
	{
		sprite.setGraphicSize(Math.ceil(sprite.width * Math.max(FlxG.width / sprite.width, FlxG.height / sprite.height)),
			Math.ceil(sprite.height * Math.max(FlxG.width / sprite.width, FlxG.height / sprite.height)));
	}

	public static function getScreenRealWidth():Float
	{
		var ratio = Math.min(Lib.application.window.width / 1280, Lib.application.window.height / 720);

		return 1280 * ratio;
	}

	public static function getScreenRealHeight():Float
	{
		var ratio = Math.min(Lib.application.window.width / 1280, Lib.application.window.height / 720);

		return 720 * ratio;
	}

	@:deprecated
	/**
	 * Deprecated, use FNK.spriteCenter.
	 * @param sprite1 
	 * @param sprite2 
	 * @param axis 
	 */
	public static function centerSprite1OnSprite2(sprite1:FlxSprite, sprite2:FlxSprite, ?axis:FlxAxes = XY)
	{
		sprite1.spriteCenter(sprite2, axis);
	}
}
