package funkin.utils;

// most copied from FlxMath
class FNKMath
{
	public static inline function fastSin(n:Float):Float
	{
		n *= 0.3183098862; // divide by pi to normalize
		// bound between -1 and 1
		if (n > 1)
			n -= (Math.ceil(n) >> 1) << 1;
		else if (n < -1)
			n += (Math.ceil(-n) >> 1) << 1;
		// this approx only works for -pi <= rads <= pi, but it's quite accurate in this region
		if (n > 0)
			return n * (3.1 + n * (0.5 + n * (-7.2 + n * 3.6)));
		else
			return n * (3.1 - n * (0.5 + n * (7.2 + n * 3.6)));
	}

	/**
	 * A faster, but less accurate version of `Math.cos()`.
	 * About 2-6 times faster with < 0.05% average error.
	 *
	 * @param	n	The angle in radians.
	 * @return	An approximated cosine of `n`.
	 */
	public static inline function fastCos(n:Float):Float
	{
		return fastSin(n + 1.570796327); // sin and cos are the same, offset by pi/2
	}

	public static inline function isPositive(n:Float):Bool
	{
		return n == Math.abs(n);
	}

	public static inline function isNegative(n:Float):Bool
	{
		return !isPositive(n);
	}

	public static inline function roundToMultiple(number:Float, multiple:Float):Float
	{
		var result:Float = 0.0;
		if (isNegative(number))
			result = Math.abs(number) + multiple / 2;
		else
			result = number + multiple / 2;

		result -= result % multiple;

		return isNegative(number) ? -result : result;
	}
}
