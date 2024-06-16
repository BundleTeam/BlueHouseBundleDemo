package funkin.system;

import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileSquare;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.addons.transition.TransitionData;
import funkin.plugins.ShaderManager;
import funkin.menus.TitleState;
import funkin.ui.notifications.*;
import funkin.ui.CustomFadeTransition;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import openfl.display.StageQuality;
import funkin.system.input.Controls;
import funkin.user.PlayerSettings;
import flixel.graphics.FlxGraphic;

using funkin.FNK;
using StringTools;

class MusicBeatState extends FlxUIState
{
	private var curSection:UInt32 = 0;

	private var stepsToDo:Int32 = 0;

	private var curStep:Int32 = 0;
	private var curBeat:Int32 = 0;

	private var curDecStep:Float32 = 0;
	private var curDecBeat:Float32 = 0;
	private var controls(get, never):Controls;

	public static var camBeat:FlxCamera;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		if (FlxG.game.soundTray != null)
		{
			FlxG.game.soundTray.volumeDownSound = 'assets/sounds/scrollMenu.wav';
			FlxG.game.soundTray.volumeUpSound = 'assets/sounds/scrollMenu.wav';
		}

		camBeat = FlxG.camera;
		super.create();
		FlxSprite.defaultAntialiasing = ClientPrefs.globalAntialiasing;

		FlxTransitionableState.skipNextTransOut = false;
		if (!FNK.stopDumbMouseParsecBugBecauseItsAnnoyingAsFuck)
		{
			var cursorSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image('selectCursor'));
			FlxG.mouse.load(cursorSprite.pixels);
		}
	}

	override function update(elapsed:Float)
	{
		// */
		// everyStep();
		var oldStep:Int = curStep;

		// FlxG.resizeGame(Main.stageWidth, Main.stageHeight);
		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if (curStep > 0)
				stepHit();

			if (PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if (FlxG.save.data != null)
			FlxG.save.data.fullscreen = FlxG.fullscreen;

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if (stepsToDo < 1)
			stepsToDo = Math.round(getBeatsOnSection() * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if (curStep < 0)
			return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if (stepsToDo > curStep)
					break;

				curSection++;
			}
		}

		if (curSection > lastSection)
			sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit:Float = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState)
	{
		FlxTransitionableState.defaultTransIn = new TransitionData(TransitionType.TILES, FlxColor.BLACK, 0.4, new FlxPoint(-1, -1));
		FlxTransitionableState.defaultTransOut = new TransitionData(TransitionType.TILES, FlxColor.BLACK, 0.4, new FlxPoint(-1, -1));

		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:FlxState = curState;
		FlxG.switchState(nextState);
		if (nextState is TitleState && TitleState.initialized)
		{
			FlxG.sound.playMusic(Paths.music(Main.TitleTheme));
			Conductor.changeBPM(60);
		}
		else if (nextState is funkin.menus.FreeplayState && curState is PlayState)
		{
			FlxG.sound.playMusic(Paths.music(Main.MainMenuTheme));
		}
		nextState.persistentDraw = true;
		nextState.persistentUpdate = true;
		removeTemporaryShaders();
	}

	public static function removeTemporaryShaders()
	{
		if (ShaderManager.instance != null)
		{
			for (id in ShaderManager.instance.shaderIDS)
			{
				if (id.endsWith("-playstate") || id.endsWith("-temp"))
				{
					ShaderManager.remove(id);
				}
			}
			ShaderManager.apply();
		}
	}

	public static function resetState()
	{
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState
	{
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// Funkin.log('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		// Funkin.log('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null)
			val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
