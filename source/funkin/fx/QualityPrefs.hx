package funkin.fx;

import flixel.text.FlxText.FlxTextBorderStyle;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilterQuality;

/**
 * handles various quality enums based on Clientprefs.lowquality
 */
class QualityPrefs
{
	public static function bitmapFilterQuality():BitmapFilterQuality
	{
		return ClientPrefs.lowQuality ? BitmapFilterQuality.LOW : BitmapFilterQuality.HIGH;
	}

	public static function stageQuality():StageQuality
	{
		return ClientPrefs.lowQuality ? StageQuality.LOW : StageQuality.BEST;
	}

	public static function textShadow():FlxTextBorderStyle
	{
		return ClientPrefs.lowQuality ? FlxTextBorderStyle.OUTLINE_FAST : FlxTextBorderStyle.OUTLINE;
	}
}
