package funkin.fx;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.util.FlxColor;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.BlurFilter;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;
import funkin.fx.shaders.GaussianBlur;

class Filters
{
	public static function stageQualityPref():StageQuality
	{
		return QualityPrefs.stageQuality();
	}

	public static function newBlurredSprite(X:Float = 0, Y:Float = 0, Graphic:String, BlurX:Float = 4, BlurY:Float = 4, forceOpenFlBlur:Bool = null):FlxSprite
	{
		var sprite = new FlxSprite(X, Y).loadGraphic(Paths.image(Graphic));
		if (forceOpenFlBlur || Hardware.os == Web)
		{
			var blur = new BlurFilter(BlurX, BlurY, QualityPrefs.bitmapFilterQuality());
			var filterFrames = FlxFilterFrames.fromFrames(sprite.frames, 0, 0, [blur]);
			filterFrames.applyToSprite(sprite, false, true);
			blur = null;
			filterFrames = null;
			return sprite;
		}
		else
		{
			sprite.shader = new GaussianBlur();
			sprite.angle = 180;
			return sprite;
		}
		return sprite;
	}

	public static function addBlurToSprite(sprite:FlxSprite, BlurX:Float = 4, BlurY:Float = 4):FlxSprite
	{
		#if html5
		var blur = new BlurFilter(BlurX, BlurY, QualityPrefs.bitmapFilterQuality());
		var filterFrames = FlxFilterFrames.fromFrames(sprite.frames, 0, 0, [blur]);
		filterFrames.applyToSprite(sprite, false, true);
		blur = null;
		filterFrames = null;
		return sprite;
		#else
		sprite.shader = new GaussianBlur();
		sprite.angle = 180;
		return sprite;
		#end
	}

	public static function newGlowSprite(X:Float = 0, Y:Float = 0, Graphic:String, Color:FlxColor = FlxColor.WHITE, Alpha:Float = 1, BlurX:Float = 4,
			BlurY:Float = 4, Strength:Int = 128, InnerGlow:Bool = false, Knockout:Bool = false):FlxSprite
	{
		var sprite = new FlxSprite(X, Y).loadGraphic(Paths.image(Graphic)); // using vram loader makes the blur effect not work idk why
		var blur = new GlowFilter(Color, Alpha, BlurX, BlurY, Strength, QualityPrefs.bitmapFilterQuality(), InnerGlow, Knockout);
		var filterFrames = FlxFilterFrames.fromFrames(sprite.frames, 0, 0, [blur]);
		filterFrames.applyToSprite(sprite, false, true);
		blur = null;
		filterFrames = null;
		return sprite;
	}
}
