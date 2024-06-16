package funkin.utils;

import openfl.Lib;

class Time
{
	/**
	 * @return Epoch/Unix Time in seconds.
	 */
	public static function getUnixTime():Float
	{
		#if sys
		return Sys.time();
		#elseif html5
		return (js.Browser.window.performance.timeOrigin + js.Browser.window.performance.now()) / 1000;
		#else
		return Date.now().getTime() / 1000;
		#end
	}

	/**
	 * Alias for 
	 * ```haxe
	 * Time.getUnixTime()
	 * ```
	 */
	public static function getEpochTime():Float
	{
		return getUnixTime();
	}

	/**
	 * Get time stamp in milliseconds, returns either unix time or app time running
	 * For current date operations use
	 * ```haxe
	 * Time.getUnixTime()
	 * ``` 
	 * instead as this will be the same on all platforms.
	 * Use this for calculating things like delta time and elapsed stuff.
	 * @return Float
	 */
	public static function getTimestamp():Float
	{
		#if cpp
		return untyped __global__.__time_stamp() * 1000.0;
		#elseif sys
		return Sys.cpuTime() / 1000.0;
		#elseif html5
		return js.Browser.window.performance.now();
		#else
		return lime.system.System.getTimer();
		#end
	}

	public static function getUnixMillis():Float
	{
		#if sys
		return Sys.time() * 1000.0;
		#elseif html5
		return js.Browser.window.performance.timeOrigin + js.Browser.window.performance.now();
		#else
		return Date.now().getTime();
		#end
	}

	public static function getUnixMillisInt():Int
	{
		return Std.int(getUnixMillis());
	}
}
