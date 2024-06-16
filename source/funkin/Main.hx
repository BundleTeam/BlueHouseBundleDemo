package funkin;

import flixel.FlxCamera;
import openfl.system.Capabilities;
import flixel.system.scaleModes.*;
import funkin.menus.MainMenuState;
import funkin.menus.InitialLoadState;
import funkin.menus.TitleState;
import funkin.media.Intro;
import lime.system.System;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import lime.utils.Log;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.events.FocusEvent;

using StringTools;

#if desktop
#end
// crash handler stuff
#if CRASH_HANDLER
#if (cpp && desktop)
import funkin.system.Discord;
#end
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

#if sys
#end
class Main extends Sprite
{
	public static var originalWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var originalHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameWidth:Int = originalWidth;
	public static var gameHeight:Int = originalHeight;

	public static var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	public static var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.

	var framerate:Int = 999; // How many frames per second the game should run at.

	public static var skipSplash:Bool = false; // Whether to skip the flixel splash screen that appears in release mode.

	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	// private static var game:FlxGame;
	public static var alertTray:FlxAlertTray;
	public static var game:FlxGame;

	public static var TitleTheme:String = "long-pause";
	public static var MainMenuTheme:String = "mainMenu";

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();
		Log.throwErrors = true;

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	public static var stageWidth:Int;
	public static var stageHeight:Int;
	public static var ratioX:Float32;
	public static var ratioY:Float32;
	/* elapsed but accurate to sys time in millis */
	public static var elapsed:Float;

	private function gameInit(initialState:Null<Class<flixel.FlxState>>)
	{
		game = new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, true, startFullscreen);
		FlxG.resizeWindow(originalWidth, originalHeight);
		@:privateAccess
		Lib.application.window.set_x(Math.round((Capabilities.screenResolutionX - Main.originalWidth) / 2));
		@:privateAccess
		Lib.application.window.set_y(Math.round((Capabilities.screenResolutionY - Main.originalHeight) / 2));
		addChild(game);
		FlxG.scaleMode = new RatioScaleMode();
		alertTray = new FlxAlertTray();
		FlxG.autoPause = false;

		// funkin.plugins.WindowMode.alertTray = alertTray;
		game.addChild(alertTray);

		function focusLost(?_)
		{
			#if (sys && android)
			Sys.exit(0);
			#end
		}
		addEventListener(FocusEvent.FOCUS_OUT, focusLost);
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			Main.elapsed = Time.getTimestamp() - currentTime;
			calculateFPS(Main.elapsed);
		});
		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		FlxG.resizeGame(1920, 1080);
		#end
		#if CRASH_HANDLER
		sys.thread.Thread.create(() ->
		{
			Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		});
		#end
	}

	/**
		The current frame rate, expressed using frames-per-second
	**/
	public static var currentFPS:Int = 0;

	@:noCompletion private var cacheCount:Int = 0;
	@:noCompletion private var currentTime:Float = 0.00;
	@:noCompletion private var currentTimeSeconds:Float = 0.00;

	@:noCompletion private var times:Array<Float> = [];

	@:noCompletion
	private function calculateFPS(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
			times.shift();

		var currentCount:Int = times.length;
		Main.currentFPS = Math.round((currentCount + cacheCount) / 2);
		if (Main.currentFPS > ClientPrefs.framerate)
			Main.currentFPS = ClientPrefs.framerate;

		cacheCount = currentCount;
	}

	private function setupGame():Void
	{
		#if (cpp && desktop)
		cpp.vm.Gc.setMinimumWorkingMemory(0);
		#end

		stageWidth = gameWidth;
		stageHeight = gameHeight;
		ratioX = stageWidth / 1280;
		ratioY = stageHeight / 720;
		if (zoom == -1)
		{
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		ClientPrefs.loadDefaultKeys();
		Funkin.init();
		#if (windows && sys && !debug && !hl && !neko)
		if (!Sys.args().contains('-game'))
			gameInit(InitialLoadState);
		else
		{
			gameInit(initialState);
		}
		#else
		gameInit(initialState);
		#end
	} // Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!

	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "BundleEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: "
			+ e.error
			+ "\nPlease report this error to the GitHub page: https://github.com/letsgoawaydev/BundleEngine\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		#if (cpp && desktop)
		Discord.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}
