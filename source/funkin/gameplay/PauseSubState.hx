package funkin.gameplay;

import funkin.ui.notifications.NotificationManager;
import funkin.ui.notifications.Notification;
import openfl.Lib;
import funkin.menus.options.OptionsState;
import flixel.util.FlxTimer;
import funkin.fx.WaveformSprite;
import funkin.music.WeekData;
import funkin.system.input.Controls;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.fx.DropShadowSprite;

class PauseSubState extends MusicBeatSubstate
{
	var pauseMusic:FlxSound;

	var curTime:Float = Math.max(0, Conductor.songPosition);

	var menubg:DropShadowSprite;
	var resume:DropShadowSprite;
	var options:DropShadowSprite;
	var retry:DropShadowSprite;
	var quit:DropShadowSprite;
	var blackBG:FlxSprite;
	var bg:FlxSprite;

	var slideTween:FlxTween;
	var pauseTween:FlxTween;

	var bgTween:FlxTween;
	var selArrow:DropShadowSprite;
	var selectedID:UInt8 = 0;
	var selArrow_pos:Array<Array<Float32>> = [[494, 28], [457, 176], [426, 344], [403, 536]];

	// var botplayText:FlxText;
	public static var songName:String = '';

	var pauseText:FlxSprite;
	var waveform1:WaveformSprite;
	var waveFormTween:FlxTween;

	var timer:FlxTimer;

	public function new(x:Float, y:Float)
	{
		super();
		if (PlayState.recordMode)
		{
			Conductor.changeBPM(102);
			FlxG.sound.playMusic(Paths.music(Main.MainMenuTheme));

			FlxTransitionableState.skipNextTransOut = true;

			FlxTransitionableState.skipNextTransIn = true;
			menuExit();
			return;
		}
		pauseMusic = new FlxSound();
		if (songName != null)
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		else if (songName != 'None')
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);

		pauseMusic.volume = 0;
		pauseMusic.play(false);

		FlxG.sound.list.add(pauseMusic);
		blackBG = new FlxSprite().makeGraphic(2, 2, FlxColor.BLACK);
		blackBG.antialiasing = false;
		blackBG.setGraphicSize(Lib.application.window.width, Lib.application.window.height);
		add(blackBG);

		bg = new FlxSprite();
		#if html5
		if (!ClientPrefs.lowQuality)
		{
		#end
			bg.loadGraphic(Screenshot.getScreen());
		#if html5
		}
		else
			bg.makeGraphic(64, 64);
		#end
		bg.setColorTransform();
		bg.antialiasing = false;
		bg.scrollFactor.set();
		add(bg);
		Scaling.cropScaleToScreen(bg);
		grid = new GridBG();
		add(grid);
		grid.fadeIn();
		waveform1 = new WaveformSprite(0, 0);
		waveform1.sound = pauseMusic;
		add(waveform1);
		waveform1.scale.set(1.75, 1.75);
		waveform1.updateHitbox();
		waveform1.screenCenter();
		waveform1.x = FlxG.width - waveform1.width;
		waveform1.y = FlxG.height - waveform1.height;
		waveform1.y += 150;
		waveform1.alpha = 0;
		timer = new FlxTimer().start(1 / 60, (?_) ->
		{
			if (waveform1.alpha != 0)
			{
				@:privateAccess
				waveform1.updateWaveform();
			}
		}, 0);
		menubg = new DropShadowSprite(Paths.image("pause/menuwall"), -1024, 0);
		add(menubg);
		resume = new DropShadowSprite(Paths.image("pause/resume"));
		add(resume);
		options = new DropShadowSprite(Paths.image("pause/options"));
		add(options);
		retry = new DropShadowSprite(Paths.image("pause/retry"));
		add(retry);
		quit = new DropShadowSprite(Paths.image("pause/quit"));
		add(quit);
		resume.x = menubg.x + 30;
		resume.y = menubg.y + 28;
		options.x = menubg.x + 68;
		options.y = menubg.y + 196;
		retry.x = menubg.x + 99;
		retry.y = menubg.y + 344;
		quit.x = menubg.x + 122;
		quit.y = menubg.y + 541;
		pauseText = new FlxSprite(1600, 33);
		pauseText.loadGraphicWithAssetQuality('pause/pauseText');
		add(pauseText);
		if (pauseTween != null)
			pauseTween.cancel();
		pauseTween = FlxTween.tween(pauseText, {x: 750}, 1, {ease: FlxEase.expoOut});
		selArrow = new DropShadowSprite(Paths.image("selectArrow"), selArrow_pos[0][0], selArrow_pos[0][1]);
		selArrow.alpha = 0;
		add(selArrow);
		if (bgTween != null)
			bgTween.cancel();
		bgTween = FlxTween.tween(bg, {alpha: 0.6}, 0.4, {
			ease: FlxEase.quartInOut,
			onComplete: (?_) ->
			{
				if (!exiting)
				{
					FlxTween.tween(selArrow, {alpha: 1}, 0.2, {ease: FlxEase.linear});
				}
			}
		});
		if (slideTween != null)
			slideTween.cancel();
		slideTween = FlxTween.tween(menubg, {x: 0}, 1, {ease: FlxEase.expoOut});
		if (waveFormTween != null)
			waveFormTween.cancel();
		waveFormTween = FlxTween.tween(waveform1, {alpha: 1}, 0.2, {
			ease: FastEase.sineOut
		});
		cameras = [PlayState.instance.camOther];
		camera.zoom = 1;
		PlayState.instance.camGame.zoom = PlayState.instance.defaultCamZoom;
		PlayState.instance.camHUD.zoom = 1.0;
		PlayState.instance.camOther.zoom = 1.0;
		FlxG.game.filtersEnabled = false;
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	var upP:Bool = false;
	var downP:Bool = false;
	var accepted:Bool = false;
	var exit:Bool = false;
	var exiting:Bool = false;

	function updateMenuButtonsPositionsAndStuffForEpicAndPerfomanceGameAndSmoothAnimsBecauseItsCool()
	{
		resume.x = menubg.x + 30;
		resume.y = menubg.y + 28;
		options.x = menubg.x + 68;
		options.y = menubg.y + 196;
		retry.x = menubg.x + 99;
		retry.y = menubg.y + 344;
		quit.x = menubg.x + 122;
		quit.y = menubg.y + 541;
	}

	function coolExitSlide():Void
	{
		PlayState.instance.camGame.bgColor = FlxColor.BLACK;
		if (bgTween != null)
			bgTween.cancel();
		bgTween = FlxTween.tween(bg, {alpha: 0, angle: 15}, 1, {
			ease: FlxEase.quartInOut,
		});
		FlxTween.tween(bg.scale, {x: bg.scale.x * 0.75, y: bg.scale.y * 0.75}, 1, {
			ease: FlxEase.quartInOut,
		});
	}

	function openOptions():Void
	{
		coolExitSlide();
		slideOut(() ->
		{
			MusicBeatState.switchState(new OptionsState(true));
		});
	}

	function menuExit()
	{
		PlayState.deathCounter = 0;
		PlayState.seenCutscene = false;
		FlxG.drawFramerate = ClientPrefs.framerate;
		if (PlayState.isStoryMode)
			MusicBeatState.switchState(new funkin.menus.StoryMenuState());
		else
			MusicBeatState.switchState(new funkin.menus.FreeplayState());
		PlayState.cancelMusicFadeTween();
		PlayState.changedDifficulty = false;
		PlayState.chartingMode = false;
	}

	function exitToMenu()
	{
		coolExitSlide();
		slideOut(() ->
		{
			Conductor.changeBPM(102);
			FlxG.sound.playMusic(Paths.music(Main.MainMenuTheme));
			menuExit();
		});
	}

	var grid:GridBG;

	private function slideOut(exitScript:() -> Void)
	{
		FlxTransitionableState.skipNextTransOut = true;
		if (exiting)
		{
			return;
		}

		exiting = true;
		FlxG.sound.play(Paths.sound('cancelMenu'));
		grid.fadeOut(1);
		if (waveFormTween != null)
			waveFormTween.cancel();
		waveFormTween = FlxTween.tween(waveform1, {alpha: 0}, 0.2, {
			ease: FastEase.sineOut
		});

		if (arrowTween != null)
			arrowTween.cancel();
		arrowTween = FlxTween.tween(selArrow, {alpha: 0}, 0.2, {ease: FlxEase.linear});

		if (pauseTween != null)
			pauseTween.cancel();
		pauseTween = FlxTween.tween(pauseText, {x: 1600}, 1, {ease: FlxEase.expoOut});

		if (slideTween != null)
			slideTween.cancel();
		slideTween = FlxTween.tween(menubg, {x: -1024}, 1, {
			ease: FlxEase.expoOut,
			onComplete: (?_) ->
			{
				FlxG.game.filtersEnabled = true;
				exitScript();
			}
		});
	}

	function resumeGame():Void
	{
		slideOut(() ->
		{
			_parentState.persistentDraw = true;
			_parentState.persistentUpdate = true;
			PlayState.instance.paused = false;
			close();
		});
	}

	var arrowTween:FlxTween;

	override function update(elapsed:Float)
	{
		if (PlayState.recordMode)
		{
			super.update(elapsed);
			return;
		}
		blackBG.screenCenter();
		bg.screenCenter();
		if (_parentState != null)
		{
			_parentState.persistentDraw = false;
		}
		waveform1.sound = pauseMusic;
		updateMenuButtonsPositionsAndStuffForEpicAndPerfomanceGameAndSmoothAnimsBecauseItsCool();
		cantUnpause -= elapsed;
		if (!exiting)
		{
			if (_parentState != null)
			{
				_parentState.persistentUpdate = false;
			}
			if (pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.01 * (elapsed * 750);
		}
		else
		{
			if (pauseMusic.volume >= 0.01)
				pauseMusic.volume -= 0.01 * (elapsed * 240);
		}

		upP = controls.UI_UP_P;
		downP = controls.UI_DOWN_P;
		accepted = controls.ACCEPT;
		exit = controls.BACK;

		if ((exit) && cantUnpause <= 0)
			resumeGame();
		if (!exiting)
		{
			if (upP)
			{
				selectedID--;
				if (selectedID == -1 || selectedID > 3 || selectedID == 255)
					selectedID = 3;
				if (arrowTween != null)
					arrowTween.cancel();
				arrowTween = FlxTween.tween(selArrow, {x: selArrow_pos[selectedID][0], y: selArrow_pos[selectedID][1]}, 0.5, {ease: FlxEase.expoOut});
			}
			else if (downP)
			{
				selectedID++;
				if (selectedID == 4)
					selectedID = 0;
				if (arrowTween != null)
					arrowTween.cancel();
				arrowTween = FlxTween.tween(selArrow, {x: selArrow_pos[selectedID][0], y: selArrow_pos[selectedID][1]}, 0.5, {ease: FlxEase.expoOut});
			}

			if (accepted)
			{
				switch (selectedID)
				{
					case 0:
						resumeGame();
					case 1:
						openOptions();
					case 2:
						restartSong();
					case 3:
						exitToMenu();
					default:
						resumeGame();
				}
			}
		}

		PlayState.instance.camGame.zoom = PlayState.instance.defaultCamZoom;
		PlayState.instance.camHUD.zoom = 1.0;
		PlayState.instance.camOther.zoom = 1.0;
		super.update(elapsed);
	}

	public function restartSong(noTrans:Bool = false)
	{
		coolExitSlide();
		slideOut(() ->
		{
			PlayState.instance.paused = true;
			FlxG.sound.music.volume = 0;
			PlayState.instance.opponentVocals.volume = 0;
			PlayState.instance.playerVocals.volume = 0;

			MusicBeatState.switchState(new PlayState());
		});
	}

	override function destroy()
	{
		if (!PlayState.recordMode)
		{
			pauseMusic.destroy();
			timer.destroy();
		}
		super.destroy();
	}
}
