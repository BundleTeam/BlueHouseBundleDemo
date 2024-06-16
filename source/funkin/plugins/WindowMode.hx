package funkin.plugins;

import funkin.ui.notifications.TitleNotification;
import funkin.ui.notifications.NotificationManager;
import flixel.FlxBasic;
import haxe.MainLoop;
import lime.app.Application;
import openfl.events.Event;
import funkin.system.FlxAlertTray;
import openfl.system.Capabilities;
import flixel.FlxG;
import openfl.display.StageDisplayState;
import openfl.Lib;

class WindowMode extends FlxBasic
{
	private static var ModeOrder:Array<String> =
		#if !html5
		[
			'Windowed',
			'Windowed (Borderless)',
			'Fullscreen (Borderless)',
			'Fullscreen (Exclusive)'
		]
		#else
		['Windowed', 'Fullscreen']
		#end;

	public function new()
	{
		super();
		#if !html5
		setMode(ClientPrefs.fullscreenMode);
		currentMode = ModeOrder.indexOf(ClientPrefs.fullscreenMode);
		#end
	}

	public override function update(elapsed:Float)
	{
		Main.alertTray.update(FlxG.elapsed * 1000);

		if (FlxG.keys.justPressed.F11)
		{
			WindowMode.toggleMode();
		}
		if (FlxG.keys.pressed.ALT && FlxG.keys.justPressed.ENTER)
		{
			FlxG.fullscreen = false;
			WindowMode.toggleMode();
		}
		super.update(elapsed);
	}

	private static var currentMode:UInt8 = 0;

	public static var windowModeNotification:TitleNotification = null;

	public static function toggleMode():Void
	{
		#if !html5
		currentMode = ModeOrder.indexOf(ClientPrefs.fullscreenMode);
		currentMode++;
		currentMode = currentMode % ModeOrder.length;
		setMode(ModeOrder[currentMode]);
		if (windowModeNotification == null)
		{
			windowModeNotification = new TitleNotification();
			windowModeNotification.setText("Video Mode\n\n" + ModeOrder[currentMode]);
			windowModeNotification.onFinish = () ->
			{
				WindowMode.windowModeNotification = null;
			}
			NotificationManager.notify(windowModeNotification);
		}
		else
		{
			windowModeNotification.setText("Video Mode\n\n" + ModeOrder[currentMode]);
		}
		#end
	}

	public static function setMode(?mode:String = 'Windowed'):Void
	{
		#if !html5
		@:privateAccess
		switch (mode)
		{
			case 'Windowed':
				FlxG.fullscreen = false;
				Lib.application.window.set_fullscreen(false);
				Lib.application.window.set_resizable(true);
				Lib.application.window.set_mouseLock(false);
				Lib.application.window.set_borderless(false);
				Lib.application.window.set_maximized(false);
				Lib.application.window.set_width(Main.originalWidth);
				Lib.application.window.set_height(Main.originalHeight);
				Lib.application.window.set_x(Math.round((Capabilities.screenResolutionX - Main.originalWidth) / 2));
				Lib.application.window.set_y(Math.round((Capabilities.screenResolutionY - Main.originalHeight) / 2));
				Lib.application.window.__attributes.alwaysOnTop = false;
			case 'Windowed (Borderless)':
				FlxG.fullscreen = false;
				Lib.application.window.set_fullscreen(false);
				Lib.application.window.set_resizable(false);
				Lib.application.window.set_mouseLock(false);
				Lib.application.window.set_borderless(true);
				Lib.application.window.__attributes.alwaysOnTop = false;
			/* 
				Lib.application.window.set_maximized(false);

				Lib.application.window.set_width(1280);
				Lib.application.window.set_height(720);
				Lib.application.window.set_x(Math.round((Capabilities.screenResolutionX - FlxG.width) / 2));
				Lib.application.window.set_y(Math.round((Capabilities.screenResolutionY - FlxG.height) / 2));
			 */

			case 'Fullscreen (Borderless)':
				FlxG.fullscreen = false;
				// tricks windows to not put it as an actual fullscreen app and just as a window overlaying everything
				// so borderless isnt actually borderless (trolled)
				Lib.application.window.set_fullscreen(false);
				Lib.application.window.set_resizable(false);
				Lib.application.window.set_mouseLock(false);
				Lib.application.window.set_borderless(false);
				Lib.application.window.set_maximized(true);
				Lib.application.window.set_width(Std.int(Capabilities.screenResolutionX));
				Lib.application.window.set_height(Std.int(Capabilities.screenResolutionY));
				Lib.application.window.set_x(0);
				Lib.application.window.set_y(0);
				FlxG.stage.displayState = StageDisplayState.NORMAL;
				Lib.application.window.__attributes.alwaysOnTop = true;

			case 'Fullscreen (Exclusive)':
				Lib.application.window.set_fullscreen(true);
				Lib.application.window.set_resizable(false);
				Lib.application.window.set_mouseLock(true);
				Lib.application.window.set_borderless(false);
				Lib.application.window.set_maximized(false);
				Lib.application.window.__attributes.alwaysOnTop = true;
				FlxG.fullscreen = true;
		}
		ClientPrefs.fullscreenMode = mode;
		ClientPrefs.saveSettings();
		#end
	}
}
