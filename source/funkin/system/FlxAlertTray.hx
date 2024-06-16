package funkin.system;

#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

/**
 * Basically sound tray but for other text - letsgoaway
 * 
 * Accessed via `WindowMode.alertTray`.
 */
class FlxAlertTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	var _timer:Float;

	/**
	 * Helps display the volume bars on the sound tray.
	 */
	var _bars:Array<Bitmap>;

	/**
	 * How wide the sound tray background is.
	 */
	var _width:Int = 80;

	var _defaultScale:Float = 2.0;

	/**The sound used when increasing the volume.**/
	public var alertSound:String = "assets/sounds/scrollMenu.wav";

	var text:TextField = new TextField();

	/**Whether or not changing the volume should make noise.**/
	public var silent:Bool = false;

	var tmp:Bitmap = new Bitmap(new BitmapData(80, 30, true, 0x7F000000));

	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	@:keep
	public function new()
	{
		super();

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		screenCenter();
		addChild(tmp);

		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;

		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		#end
		var dtf:TextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 10, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = "VOLUME";
		text.y = 16;

		y = -height;
		visible = false;
	}

	/**
	 * This function just updates the alerttray object.
	 */
	public function update(MS:Float):Void
	{
		x = Math.round((Lib.current.stage.application.window.width - width) / 2);
		if (_timer > 0)
		{
			_timer -= MS / 1000;
		}
		else if (y > -height)
		{
			y -= (MS / 1000) * FlxG.height * 2;

			if (y <= -height)
			{
				visible = false;
				active = false;
			}
		}
	}

	/**
	 * Makes the little alert tray slide out.
	 *
	 * @param	str text the alert will show
	 */
	public function alert(str:String, ?duration:Float = 1):Void
	{
		if (!silent)
		{
			var sound = FlxAssets.getSound(alertSound);
			if (sound != null)
				FlxG.sound.load(sound).play();
		}
		tmp.bitmapData = new BitmapData(Std.int(str.length * 11), Std.int(str.split('\n').length * 20), true, 0x7F000000);
		tmp.x = 0;
		text.text = str;
		text.width = Std.int(str.length * 11);
		text.y = 0;
		text.y += (tmp.height / 4) - text.textHeight / 4;
		text.x = Math.round((tmp.width - text.width) / 2);
		_timer = duration;
		y = 0;
		x = Math.round((Lib.current.stage.application.window.width - width) / 2);
		visible = true;
		active = true;
	}

	public function screenCenter():Void
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
	}
}
#end
