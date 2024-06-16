package funkin.menus;

import openfl.display.Sprite;
import flixel.addons.display.FlxBackdrop;
import funkin.utils.CoolUtil;
import haxe.io.Encoding;
#if sys
import funkin.utils.CoolThread;
import lime.system.System;
import haxe.io.Path;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxTimer;
import lime.app.Future;
import lime.app.Promise;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets;
import funkin.music.StageData;
import funkin.utils.MemUtil;

// this is practically only used for debug purposes and to enable vsync because there isnt a way to do it simply in one line of code afaik.
class InitialLoadState extends FlxState
{
	var loaderCharSprite:FlxSprite;

	public static var loaderChar:String = "mistashitty"; // temp, add rng

	var stopMusic = false;
	var directory:String;
	var targetShit:Float = 0;
	var coolThing:FlxBackdrop;

	public static var songTitle:String = '';

	public var songCreator:String = '';

	function new()
	{
		super();
	}

	var funkay:FlxSprite;
	var bg:FlxSprite;

	override function create()
	{
		MemUtil.clearImageCaches();
		FlxSprite.defaultAntialiasing = false;
		load();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	var args:Array<String>;

	function load()
	{
		args = Sys.args();

		sys.thread.Thread.create(() ->
		{
			PlayerSettings.init();
			ClientPrefs.loadPrefs();
			onLoadComplete();
		});
	}

	function close()
	{
		if (!finalUltimateReleaseBuildReady)
		{
			if (gameExecutable.exitCode(false) == null)
			{
				gameExecutable.kill();
			}
		}
		FlxG.stage.window.onActivate.removeAll();
		FlxG.stage.window.onFocusIn.removeAll();
		FlxG.stage.window.onMove.removeAll();
		openfl.system.System.exit(0);
		Sys.exit(0);
	}

	private var gameExecutable:sys.io.Process;
	private var finalUltimateReleaseBuildReady:Bool = true; // WHEN GAME IS DONE, SET TO TRUE!! GG

	function onLoadComplete()
	{
		FlxG.sound.volume = 0;
		FlxG.stage.window.resize(1, 1);
		FlxG.stage.window.move(0, 0);

		FlxG.stage.window.resizable = false;
		@:privateAccess
		FlxG.stage.window.set_minimized(true);
		FlxG.stage.window.borderless = true;
		FlxG.stage.window.title = "BundleEngine Runner";
		@:privateAccess
		FlxG.stage.window.onActivate.add(() ->
		{
			FlxG.stage.window.set_minimized(true);
		});
		@:privateAccess
		FlxG.stage.window.onFocusIn.add(() ->
		{
			FlxG.stage.window.set_minimized(true);
		});
		@:privateAccess
		FlxG.stage.window.onMove.add((x, y) ->
		{
			FlxG.stage.window.move(0, 0);
			FlxG.stage.window.set_minimized(true);
		});
		FlxG.stage.window.onClose.add(() ->
		{
			close();
		});
		var lastLog:String = "";
		for (member in this.members)
		{
			if (Std.isOfType(member, FlxSprite))
			{
				var spr:FlxSprite = cast(member, FlxSprite);
				spr.alpha = 0;
				remove(spr);
				spr.destroy();
			}
		}
		// MemUtil.clearImageCaches();
		args.push('-game');
		args.push('--window-vsync=${Std.string(ClientPrefs.vsync)}');
		gameExecutable = new sys.io.Process(Sys.programPath(), args /*, finalUltimateReleaseBuildReady*/);
		if (!finalUltimateReleaseBuildReady)
		{
			while (gameExecutable.exitCode(false) == null)
			{
				var line:String = gameExecutable.stdout.readLine();
				if (lastLog != line)
				{
					lastLog = line;
					Funkin.log(line, null, true);
				}
			}
		}
		close();
	}

	public override function destroy()
	{
		MemUtil.destroyAllSprites(this);
		super.destroy();
	}
}
#end
