package funkin.menus;

import funkin.plugins.PluginManager;
import funkin.plugins.WindowMode;
import flixel.text.FlxText;
import funkin.system.achievements.Achievement;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import funkin.utils.MemUtil;
import openfl.filters.ShaderFilter;
import funkin.fx.shaders.GaussianBlur;
import funkin.fx.shaders.RainbowEffect;
import funkin.media.Intro;
import flixel.graphics.FlxGraphic;
import flixel.effects.particles.FlxParticle;
import funkin.utils.FlxSVGSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import funkin.fx.shaders.shadertoy.FlxShaderToyHack; // import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;
import funkin.menus.*;
import funkin.fx.WaveformSprite;
import funkin.user.PlayerSettings;
import funkin.user.Highscore;
import funkin.music.WeekData;
import funkin.fx.Filters;
import funkin.utils.CoolUtil;

using StringTools;

typedef TitleData =
{
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxTypedGroup<FlxSprite>;
	var credTextShit:Alphabet;
	var textGroup:FlxTypedGroup<FlxSprite>;
	var ngSpr:FlxSprite;
	var particlesArray:Array<FlxSprite> = [];
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;
	private var pressToStartText:FlxText;

	public static var updateVersion:String = '';

	public override function create():Void
	{
		// Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		Hardware.gatherSpecs();
		// Funkin.log(path, FileSystem.exists(path));
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		// FlxG.save.bind('funkin', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();
		if (ClientPrefs.framerate > 999)
		{
			ClientPrefs.framerate = 999;
		}
		var args:Array<String> = [""];
		#if sys
		args = Sys.args();
		#elseif html5
		args = js.Browser.window.location.hash.replace("#", '').split("%7C");
		#end

		if (FlxG.onMobile)
		{
			#if html5
			ClientPrefs.lowQualityAudio = true;
			#end
		}
		Highscore.load();

		if (!initialized)
		{
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = !FlxG.onMobile;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if (FlxG.keys.pressed.F)
		{
			MusicBeatState.switchState(new FreeplayState());
		}
		if (!FirstRunSetup.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			MusicBeatState.switchState(new FirstRunSetup());
		}
		else
		{
			PluginManager.registerAll();
			startIntro();
		}
		#end
	}

	var logoBl:FlxSprite;

	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var bg:FlxSprite;
	var waveform1:WaveformSprite;
	var waveform2:FlxSprite;
	var grid:GridBG;

	private final function startIntro()
	{
		bg = new FlxSprite().loadGraphic(Paths.image('introbg'));
		bgColor = FlxColor.fromString("#FFFFFF");
		bg.screenCenter();
		add(bg);

		Scaling.cropScaleToScreen(bg);
		bg.setGraphicSize(Std.int((bg.frameWidth * 0.25) + bg.frameWidth), Std.int((bg.frameHeight * 0.25) + bg.frameHeight));
		bg.scrollFactor.set(0.8, 0.8);
		if (!(Hardware.isMobile && Hardware.os == Web))
			Filters.addBlurToSprite(bg);

		grid = new GridBG();
		add(grid);
		grid.fadeIn();
		if (!initialized)
		{
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
				diamond.persist = true;
				diamond.destroyOnNoUse = false;

				FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
					new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
				FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
					{asset: diamond, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut; */

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music(Main.TitleTheme));
			// FlxG.sound.list.add(music);
			// music.play();

			if (FlxG.sound.music == null)
			{
				FlxG.sound.playMusic(Paths.music(Main.TitleTheme), 0);
				Conductor.changeBPM(60);
			}
		}
		if (!(Hardware.isMobile))
		{
			for (i in 0...64)
			{
				if (false) // TODO: detect when christmas and add these
				{
					var particle:FlxSprite = new FlxSprite().loadGraphic(Paths.image('particle'));
					particle.y = FlxG.random.int(FlxG.height, FlxG.height * 2);
					particle.x = FlxG.random.int(0, FlxG.width);
					var randomFloat:Float = FlxG.random.float(0.5, 1.5);
					particle.scale.set(randomFloat, randomFloat);
					add(particle);
					particlesArray.push(particle);
				}
				else
				{
					var particle:FlxSprite = new FlxSprite().makeGraphic(16, 16, FlxColor.WHITE);
					particle.y = FlxG.random.int(FlxG.height, FlxG.height * 2);
					particle.x = FlxG.random.int(0, FlxG.width);
					var randomFloat:Float = FlxG.random.float(0.5, 1.0);
					particle.scale.set(randomFloat, randomFloat);
					add(particle);
					particlesArray.push(particle);
				}
			}
		}

		Conductor.changeBPM(60);
		persistentUpdate = true;
		waveform1 = new WaveformSprite(0, 0);
		waveform1.sound = FlxG.sound.music;
		add(waveform1);
		waveform1.screenCenter(Y);
		waveform1.scrollFactor.set(0.1, 0.1);
		// we use flxsprite so we dont have to recalculate everything
		waveform2 = new FlxSprite(0, 0).makeGraphic(480, 480);
		waveform2.angle = 270;
		waveform2.flipY = true; // flip graphic
		waveform2.updateHitbox();
		waveform2.x = FlxG.width - waveform2.width;
		waveform2.screenCenter(Y);
		waveform2.scrollFactor.set(0.1, 0.1);

		add(waveform2);

		logoBl = new FlxSprite().loadGraphic(Paths.image('logoBumpin'));
		logoBl.scale.set(0.35, 0.35);
		logoBl.updateHitbox();
		logoBl.screenCenter();
		add(logoBl);

		credGroup = new FlxTypedGroup<FlxSprite>();
		add(credGroup);
		textGroup = new FlxTypedGroup<FlxSprite>();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.40).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		pressToStartText = new FlxText(0, FlxG.height + 40, 0, "Click To Start", 24);
		pressToStartText.scrollFactor.set(0, 0);
		pressToStartText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, QualityPrefs.textShadow(), FlxColor.BLACK);
		add(pressToStartText);

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	private static var playJingle:Bool = false;

	var newTitle:Bool = false;
	var titleTimer:Float = 0;
	private var brightenTween:FlxTween;
	var frameTimer:Int = 0;
	var scaleThing:Float;
	var silly:Float = FlxG.height / 16;
	var bgShader:Dynamic;

	override function update(elapsed:Float)
	{
		var pressedEnter:Bool = FlxG.keys.justReleased.ENTER || FlxG.keys.anyJustReleased(ClientPrefs.keyBinds.get("accept"));
		if (FlxG.keys.pressed.M)
		{
			MusicBeatState.switchState(new Intro());
		}
		if (skippedIntro)
		{
			#if !html5
			bgShader = bg.shader; // lollmaoxd
			(bgShader : FlxShaderToyHack).update(elapsed, FlxG.mouse);
			#end
			// titleText.alpha = 1;
			logoBl.alpha = 1;
			// gfDance.alpha = 1;
			// titleText.y = FlxG.height - 144;
			// gfDance.y = FlxG.height - 550;
			logoBl.updateHitbox();
			logoBl.screenCenter();
			logoBl.scrollFactor.set(0.3, 0.2);
			// titleText.scrollFactor.set(0.1, 0.1);

			// we dont need to recalculate everything, so just copy the calculated sprites pixels
			waveform2.pixels = waveform1.pixels;

			for (particle in particlesArray)
			{
				particle.updateHitbox();
				particle.offset.x = particle.origin.x;
				particle.offset.y = particle.origin.y;
				if (particle.y < silly && !particle.isOnScreen()) // silly = height / 16
				{
					particle.y = FlxG.height; // go back to bottom of screen
					var randomFloat:Float = FlxG.random.float(0.5, 1.5);
					particle.scale.set(randomFloat, randomFloat);
					particle.scrollFactor.set(randomFloat, randomFloat);

					particle.updateHitbox();
					particle.x = FlxG.random.int(0, Std.int(FlxG.width - particle.width));
				}
				if (true) // not snow bool here in future
				{
					particle.angle += (particle.scale.x) * (elapsed * 60);
					particle.alpha = particle.scale.x / 2.5;
				}
				else
				{
					particle.alpha = particle.scale.x / 1.5;
				}
				particle.velocity.y = -145 * particle.scale.x;
			}
			// cool parrelax thingy
			FlxG.camera.scroll.x += FlxG.mouse.deltaX / 32;
			FlxG.camera.scroll.y += FlxG.mouse.deltaY / 32;

			if (FlxG.mouse.overlaps(logoBl))
			{
				if (FlxG.mouse.justReleased)
				{
					pressedEnter = true;
				}
			}

			// gfDance.screenCenter(X);
		}
		else
		{
			if (credGroup != null)
			{
				for (item in credGroup)
				{
					item.screenCenter(X);
				}
			}
			// if (titleText != null)
			// {
			// 	titleText.alpha = 0;
			// 		titleText.width -= 475;
			if (logoBl != null)
				logoBl.alpha = 0;

			// gfDance.alpha = 0;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justReleased.START)
				pressedEnter = true;
			#if switch
			if (gamepad.justReleased.B)
				pressedEnter = true;
			#end
		}
		if (newTitle)
		{
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2)
				titleTimer -= 2;
		}
		// EASTER EGG
		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;

				if (timer >= 1)
					timer = (-timer) + 2;
				timer = FlxEase.quadInOut(timer);
				// titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				// titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			pressToStartText.screenCenter(X);
			if (pressedEnter)
			{
				// titleText.color = FlxColor.WHITE;
				// titleText.alpha = 1;
				// if (titleText != null)
				//	titleText.animation.play('press');
				// FlxG.camera.flash(ClientPrefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.playMusic(Paths.sound('confirmMenu'), 0.7, false);
				transitioning = true;
				// bg.color = FlxColor.GRAY;
				// FlxG.sound.music.stop();
				grid.fadeOut(1);
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (mustUpdate)
					{
						MusicBeatState.switchState(new OutdatedState());
					}
					else
					{
						FlxG.sound.music.volume = 0;
						LoadingState.loadAndSwitchState(new MainMenuState(), false, true);
					}
					closedState = true;
				});

				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}
		if (initialized && pressedEnter && !skippedIntro)
		{
			if (FlxG.sound != null && FlxG.sound.music != null)
			{
				if (FlxG.sound.music.fadeTween != null)
				{
					FlxG.sound.music.fadeTween.cancel();
					// FlxG.sound.music.volume = 0.7;
					skipIntro();
				}
			}
		}
		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if (credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if (textGroup != null && credGroup != null)
		{
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen

	public static var closedState:Bool = false;

	private var bumpTween:FlxTween; // tweens lag sometimes when they arent assigned to a variable
	private var multiplierZoomTween:FlxTween;
	private var bgTween:FlxTween;

	private var acceptKeys:Array<FlxKey>;

	override function stepHit()
	{
		super.stepHit();
		if (FlxMath.isEven(curStep))
		{
			if (bumpTween != null)
			{
				bumpTween.cancel();
			}
			if ((curStep % 4) == 0)
			{
				logoBl.scale.set(0.5, 0.5);
				if (bgTween != null)
				{
					bgTween.cancel();
				}
			}
			else
			{
				logoBl.scale.set(0.4, 0.4);
			}
			#if !html5
			if (multiplierZoomTween != null)
			{
				multiplierZoomTween.cancel();
			}
			multiplierZoomTween = FlxTween.tween(waveform1, {multiplier: 1}, 0.5, {ease: FastEase.sineIn});
			#end
			bumpTween = FlxTween.tween(logoBl, {"scale.x": 0.35, "scale.y": 0.35}, 0.5, {type: ONESHOT, ease: FastEase.sineOut});
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (gfDance != null)
		{
			danceLeft = !danceLeft;
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if (!closedState)
		{
			sickBeats++;
			if (sickBeats == 21)
			{
				FlxTween.tween(pressToStartText, {y: FlxG.height - 64}, 1, {ease: FlxEase.expoOut});
			}
			if (!skippedIntro)
				switch (sickBeats)
				{
					case 1:
						// FlxG.sound.music.stop();
						FlxG.sound.music.loadEmbedded(Paths.music(Main.TitleTheme), true, true);
						FlxG.sound.music.volume = 0;
						FlxG.sound.music.play();
						FlxG.sound.music.fadeIn(4, 0, 0.7);

					case 2:
						createCoolText(['Nicebonie', 'Megaa', 'Delta', 'LetsGoAway', 'AlohaPotatoes']);
					// credTextShit.visible = true;
					case 4:
						addMoreText('present');

					// credTextShit.text += '\npresent...';
					// credTextShit.addText();
					case 5:
						deleteCoolText();
					// credTextShit.visible = false;
					// credTextShit.text = 'In association \nwith';
					// credTextShit.screenCenter();
					case 6:
						createCoolText(['Made', 'with'], -40);
					case 8:
						// addMoreText('newgrounds', -40);
						ngSpr.visible = true;
					// credTextShit.text += '\nNewgrounds';
					case 9:
						deleteCoolText();
						ngSpr.visible = false;

					case 10:
						createCoolText([curWacky[0]]);
					// credTextShit.visible = true;
					case 12:
						addMoreText(curWacky[1]);
					// credTextShit.text += '\nlmao';
					case 13:
						deleteCoolText();
					case 14:
						addMoreText('Blue');
					// credTextShit.visible = true;
					case 15:
						addMoreText('House');
					// credTextShit.text += '\nNight';
					case 16:
						addMoreText('Bundle'); // credTextShit.text += '\nFunkin';

					case 17:
						skipIntro();
				}
			else
			{
				deleteCoolText();
				return;
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;

	function skipIntro():Void
	{
		deleteCoolText();
		if (!skippedIntro)
		{
			remove(ngSpr);
			remove(credGroup);
			FlxG.camera.flash(FlxColor.WHITE, 4);
			FlxG.sound.music.volume = 0.7;
			skippedIntro = true;
		}
	}

	public override function destroy()
	{
		MemUtil.destroyAllSprites(this, true, true);
		Paths.clearUnusedMemory();

		super.destroy();
	}
}
