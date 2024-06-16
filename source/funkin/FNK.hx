package funkin;

import flixel.util.FlxAxes;
import funkin.utils.Paths;
import flixel.FlxSprite;

class FNK
{
	public static var stopDumbMouseParsecBugBecauseItsAnnoyingAsFuck = false;

	public static inline function loadGraphicWithAssetQuality(v:FlxSprite, path:String, quality:Float = -1):Void
	{
		Paths.loadGraphicToSprite(v, path, quality);
	}

	public static inline function copyScale(v:FlxSprite, from:FlxSprite):Void
	{
		v.scale.set(from.scale.x, from.scale.y);
	}

	public static inline function copyAngle(v:FlxSprite, from:FlxSprite):Void
	{
		v.angle = from.angle;
	}

	public static inline function copyAlpha(v:FlxSprite, from:FlxSprite):Void
	{
		v.alpha = from.alpha;
	}

	public static inline function copyPosition(v:FlxSprite, from:FlxSprite):Void
	{
		v.setPosition(from.x, from.y);
	}

	/**
	 * Center a sprites center to another sprites center.
	 * @param sprite sprite to center. 
	 * @param to sprite to center to
	 * @param axis center x or y
	 */
	public static inline function spriteCenter(sprite:FlxSprite, to:FlxSprite, axis:FlxAxes = XY):Void
	{
		if (axis == XY)
		{
			sprite.x = to.x + (to.width / 2) - (sprite.width / 2);
			sprite.y = to.y + (to.height / 2) - (sprite.height / 2);
		}
		else if (axis == X)
			sprite.x = to.x + (to.width / 2) - (sprite.width / 2);
		else if (axis == Y)
			sprite.y = to.y + (to.height / 2) - (sprite.height / 2);
	}

	/**
	 * Center a sprites center to another sprites center.
	 * @param sprite sprite to center. 
	 * @param to sprite to center to
	 * @param axis center x or y
	 */
	public static inline function spriteCenterFrame(sprite:FlxSprite, to:FlxSprite, axis:FlxAxes = XY):Void
	{
		if (axis == XY)
		{
			sprite.x = to.x + (to.frameWidth / 2) - (sprite.frameWidth / 2);
			sprite.y = to.y + (to.frameHeight / 2) - (sprite.frameHeight / 2);
		}
		else if (axis == X)
			sprite.x = to.x + (to.frameWidth / 2) - (sprite.frameWidth / 2);
		else if (axis == Y)
			sprite.y = to.y + (to.frameHeight / 2) - (sprite.frameHeight / 2);
	}

	/**
	 * yeah this is basically scratches move steps block but for flixel, helps alot with ui stuff though so cry
	 * @param steps Steps to move
	 */
	public static inline function move(sprite:FlxSprite, steps:Float):Void
	{
		moveAngle(sprite, steps, sprite.angle);
	}

	/**
	 * Scratch Move block but with custom angle for ui stuff lmao
	 * @param sprite Sprite to move
	 * @param steps Steps to move
	 * @param angle Move towards this angle.
	 */
	public static inline function moveAngle(sprite:FlxSprite, steps:Float, angle:Float):Void
	{
		var radians:Float = (Math.PI / 180) * (angle);
		sprite.x += steps * Math.cos(radians);
		sprite.y += steps * Math.sin(radians);
	}
}
