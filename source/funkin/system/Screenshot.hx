package funkin.system;

import openfl.display.StageQuality;
#if sys
import sys.thread.Thread;
#end
import funkin.ui.notifications.NotificationManager;
import funkin.ui.notifications.TitleNotification;
import openfl.geom.ColorTransform;
import openfl.display.BlendMode;
import funkin.utils.CoolUtil;
import funkin.fx.Filters;
import haxe.io.Bytes;
import flixel.FlxG;
import flixel.FlxGame;
import lime.graphics.Image;
import lime.math.Rectangle;
import lime.utils.UInt8Array;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.JPEGEncoderOptions;
import openfl.display.JPEGEncoderOptions;
import openfl.display.PNGEncoderOptions;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using StringTools;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class Screenshot
{
	public static var bmp:BitmapData;
	private static var _date:Date;
	private static var screenshotName:String = 'BlueHouseBundle';
	private static var _dateTxt:String;
	private static var lastLocation:String;
	private static var screenShotNotification:TitleNotification;

	private static function save()
	{
		#if sys
		if (!FileSystem.exists('./screenshots/'))
		{
			FileSystem.createDirectory('./screenshots/');
		}
		File.saveBytes('.${lastLocation}', bmp.encode(bmp.rect, new PNGEncoderOptions()));
		notify();
		#elseif html5
		FileFunctions.save(bmp.encode(bmp.rect, new PNGEncoderOptions()), '${screenshotName}-${_dateTxt}', 'png');
		notify();
		#end
	}

	private static function notify()
	{
		var screenShotNotification:TitleNotification = new TitleNotification();
		screenShotNotification.setText("\nScreenshot Saved!");
		NotificationManager.notify(screenShotNotification);
	}

	public static function screenshot()
	{
		_date = Date.now();
		_dateTxt = '${_date.getFullYear()}-${_date.getMonth()}-${_date.getDay()} ${_date.getHours()}-${_date.getMinutes()}-${_date.getSeconds()}'; // wtf
		lastLocation = '/screenshots/${screenshotName}-${_dateTxt}.png';
		bmp = BitmapData.fromImage(FlxG.stage.window.readPixels());
		#if html5
		return;
		#end
		save();
	}

	/**
	 * get screen as bitmap data, has issues with shaders on html5
	 * @return BitmapData
	 */
	public static function getScreen():BitmapData
	{
		#if !html5
		if (FlxG.stage != null && FlxG.stage.window != null)
			bmp = BitmapData.fromImage(FlxG.stage.window.readPixels());
		else
			bmp = new BitmapData(Std.int(flixel.FlxG.stage.stageWidth), Std.int(flixel.FlxG.stage.stageHeight), true, 0xFF000000);
		#else
		bmp = new BitmapData(Std.int(flixel.FlxG.stage.stageWidth), Std.int(flixel.FlxG.stage.stageHeight), true, 0xFF000000);
		bmp.drawWithQuality(FlxG.stage, null, null, null, null, ClientPrefs.globalAntialiasing, StageQuality.LOW);
		#end
		return bmp;
	}
}
