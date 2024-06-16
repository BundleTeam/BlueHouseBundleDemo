package funkin.utils;

import flixel.tweens.FlxEase;
import flixel.math.FlxMath;

class FastEase
{
	/** Easing constants */
	static var PI:Float = 3.141592653;

	/* Math.PI / 2 */
	static var PI2:Float = 1.570796327;

	/* Math.PI * 2 */
	static var PIX2:Float = 6.283185307;

	static var EL:Float = PIX2 / .45;
	static var B1:Float = 1 / 2.75;
	static var B2:Float = 2 / 2.75;
	static var B3:Float = 1.5 / 2.75;
	static var B4:Float = 2.5 / 2.75;
	static var B5:Float = 2.25 / 2.75;
	static var B6:Float = 2.625 / 2.75;
	static var ELASTIC_AMPLITUDE:Float = 1;
	static var ELASTIC_PERIOD:Float = 0.4;

	public static inline function sineIn(t:Float):Float
	{
		return -FNKMath.fastCos(PI2 * t) + 1;
	}

	public static inline function sineOut(t:Float):Float
	{
		return FNKMath.fastSin(PI2 * t);
	}

	public static inline function sineInOut(t:Float):Float
	{
		return -FNKMath.fastCos(PI * t) / 2 + .5;
	}

	public static inline function elasticIn(t:Float):Float
	{
		return -(ELASTIC_AMPLITUDE * Math.pow(2,
			10 * (t -= 1)) * FNKMath.fastSin((t - (ELASTIC_PERIOD / (PIX2) * Math.asin(1 / ELASTIC_AMPLITUDE))) * (PIX2) / ELASTIC_PERIOD));
	}

	public static inline function elasticOut(t:Float):Float
	{
		return (ELASTIC_AMPLITUDE * Math.pow(2,
			-10 * t) * FNKMath.fastSin((t - (ELASTIC_PERIOD / (PIX2) * Math.asin(1 / ELASTIC_AMPLITUDE))) * (PIX2) / ELASTIC_PERIOD)
			+ 1);
	}

	public static function elasticInOut(t:Float):Float
	{
		if (t < 0.5)
		{
			return -0.5 * (Math.pow(2, 10 * (t -= 0.5)) * FNKMath.fastSin((t - (ELASTIC_PERIOD / 4)) * (PIX2) / ELASTIC_PERIOD));
		}
		return Math.pow(2, -10 * (t -= 0.5)) * FNKMath.fastSin((t - (ELASTIC_PERIOD / 4)) * (PIX2) / ELASTIC_PERIOD) * 0.5 + 1;
	}
}
