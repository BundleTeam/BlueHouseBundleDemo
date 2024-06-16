package funkin.media;

import funkin.plugins.PluginManager;
import funkin.plugins.WindowMode;
import funkin.menus.MainMenuState;
import flixel.system.FlxAssets;
import funkin.menus.TitleState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

/**
 * ...
 * @author ...
 */
class HFIntro extends FlxState
{
	private var _times:Array<Float>;
	private var _curPart:Int = 0;
	private var _functions:Array<Void->Void>;
	private var text:FlxText;
	private var sprite:FlxSprite;

	public override function create():Void
	{
		FlxG.fixedTimestep = false;
		FlxG.maxElapsed = 0.1;
		FlxG.mouse.useSystemCursor = FNK.stopDumbMouseParsecBugBecauseItsAnnoyingAsFuck;
		if (Main.skipSplash)
		{
			finishTween();
			return;
		}
		#if sys
		if (Sys.args().contains('-mainMenu'))
		{
			Hardware.gatherSpecs();
			PlayerSettings.init();
			ClientPrefs.loadPrefs();
			PluginManager.registerAll();
			var mTime:Float = 0.00;
			for (arg in Sys.args())
			{
				if (arg.contains('-mainMenuMusicTime='))
				{
					mTime = Std.parseFloat(arg.replace('-mainMenuMusicTime=', ''));
					break;
				}
			}
			FlxG.sound.playMusic(Paths.music(Main.MainMenuTheme), 1);
			FlxG.sound.music.time = mTime;
			Conductor.changeBPM(102);
			if (Sys.args().contains('--window-vsync=true'))
			{
				FlxG.drawFramerate = 1000;
				FlxG.updateFramerate = 1000;
			}
			LoadingState.loadAndSwitchState(new MainMenuState());
			return;
		}
		#end

		/*
			// These are when the flixel notes/sounds play, you probably shouldn't change these if you want the functions to sync up properly
			_times = [0.041, 0.184, 0.334, 0.495, 0.636];
			// An array of functions to call after each time thing has passed, feel free to rename to whatever
			_functions = [addText1, addText2, addText3, addText4, addText5];
			for (time in _times)
			{
				new FlxTimer().start(time, timerCallback);
			}
			text = new FlxText();
			text.text = "";
			text.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, QualityPrefs.textShadow(), FlxColor.BLACK);
			text.screenCenter();
			text.x = 100;
			add(text);

		 */

		sprite = new FlxSprite();
		sprite.frames = Paths.getSparrowAtlas("flixel");
		add(sprite);
		sprite.animation.addByPrefix("flixel", "flixel", false);
		sprite.animation.play("flixel");
		#if FLX_SOUND_SYSTEM
		if (!FlxG.sound.muted)
		{
			FlxG.sound.load(Paths.sound("flixel"), 1.0, false, null, false, false, null, () ->
			{
				finishTween();
			}).play();
		}
		#end
		super.create();
	}

	public override function update(elapsed:Float):Void
	{
		sprite.setGraphicSize(FlxG.width * 1.45, 0);
		sprite.updateHitbox();
		sprite.screenCenter();
		// Thing to skip the splash screen
		// Comment this out if you want it unskippable
		if (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed)
		{
			finishTween();
		}
		super.update(elapsed);
	}

	private function timerCallback(Timer:FlxTimer):Void
	{
		_functions[_curPart]();
		_curPart++;
		if (_curPart == 5)
		{
			// What happens when the final sound/timer time passes
			// change parameters to whatever you feel like
			FlxG.camera.fade(FlxColor.BLACK, 3.25, false, finishTween);
		}
	}

	private function addText1():Void
	{
		text.text += "blue ";
	}

	private function addText2():Void
	{
		text.text += "house ";
	}

	private function addText3():Void
	{
		text.text += "de";
	}

	private function addText4():Void
	{
		text.text += "bug ";
	}

	private function addText5():Void
	{
		text.text += 'build ';
	}

	private function finishTween():Void
	{
		// Switches to MenuState when the fadeout tween(in the timerCallback function) is finished
		FlxG.switchState(new Intro());
	}
}
