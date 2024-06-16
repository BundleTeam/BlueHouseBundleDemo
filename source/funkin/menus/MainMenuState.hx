package funkin.menus;

import funkin.fx.shaders.GrayscaleShader;
import funkin.fx.FlxSpinnyXSprite;
import funkin.utils.CoolUtil;
import openfl.Lib;
import funkin.gameplay.SongStages;
import funkin.menus.options.Option;
import funkin.system.achievements.Achievements;
import funkin.utils.CoolThread;
import funkin.editors.MasterEditorMenu;
import funkin.music.WeekData;
import funkin.utils.MemUtil;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

#if (cpp && desktop)
import funkin.system.Discord;
#end

class MainMenuState extends MusicBeatState
{
	// we love outdated as fuck psych holy sigma -lga
	public static var psychEngineVersion:String = '0.6.2'; // This is also used for Discord RPC
	public static var bundleEngineVersion:String = 'Beta';

	// private static var newsSprite:NewsSprite;
	// Sprites
	var bgBack:FlxSprite;
	var bgBackTween:FlxTween;
	var bgFront:FlxSprite;
	var bgFrontTween:FlxTween;
	var logoBl:FlxSpinnyXSprite;
	var PLACEHOLD_concept:FlxSprite;
	var menuChar:FlxSprite;
	var lastHovered:String = "";
	var lockSpriteREMOVEAFTERDEMO:LockSprite;
	// Buttons
	var play:UIButton;
	var freeplay:UIButton;
	var credits:UIButton;
	var options:UIButton;
	var youtube:UIButton;
	var awards:UIButton;
	////
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	var menuCharTween:FlxTween;

	private static function mainMenuAtlas(key:String):FlxAtlasFrames
	{
		return Paths.getSparrowAtlas('mainmenu/' + key);
	}

	override function create()
	{
		MemUtil.clearImageCaches();
		FlxSprite.defaultAntialiasing = ClientPrefs.globalAntialiasing;
		Conductor.changeBPM(102);
		bgColor = FlxColor.fromString('#6683FF');
		FlxG.mouse.enabled = true;
		FlxG.mouse.visible = !FlxG.onMobile;
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		bgBack = new FlxSprite().makeGraphic(1920, 1080);
		bgBack.loadGraphicWithAssetQuality('mainmenu/bgBACK');
		bgBack.screenCenter();
		add(bgBack);
		bgBackTween = FlxTween.tween(bgBack, {x: bgBack.x, y: bgBack.y}, 0.5, {ease: FlxEase.expoOut, startDelay: 0.2});
		bgBack.x = -1920;
		bgBack.y = -1080;

		grid = new GridBG();
		add(grid);
		grid.fadeIn();

		menuChar = new FlxSprite().loadGraphic(Paths.image('mainmenu/menuChars/nicebon'));
		menuChar.x = 1680;
		menuChar.y = 0;
		menuChar.width = 303;
		menuChar.height = 442;
		add(menuChar);

		bgFront = new FlxSprite().makeGraphic(1920, 1080);
		bgFront.loadGraphicWithAssetQuality('mainmenu/bgFRONT');
		bgFront.screenCenter();
		add(bgFront);
		bgFrontTween = FlxTween.tween(bgFront, {x: bgFront.x, y: bgFront.y}, 0.5, {ease: FlxEase.expoOut, startDelay: 0.2});
		bgFront.x = 1920;
		bgFront.y = 1080;

		play = new UIButton(15, 311, 'mainmenu/play', () ->
		{
			bgColor = FlxColor.BLACK;
		}, true);
		add(play);

		freeplay = new UIButton(280, 311, 'mainmenu/freeplay', () ->
		{
			bgColor = FlxColor.BLACK;
			MusicBeatState.switchState(new funkin.menus.FreeplayState());
		});
		add(freeplay);

		credits = new UIButton(90, 444, 'mainmenu/credits', () ->
		{
			bgColor = FlxColor.BLACK;
			MusicBeatState.switchState(new funkin.menus.CreditsState());
		});
		add(credits);

		options = new UIButton(366, 440, 'mainmenu/options', () ->
		{
			bgColor = FlxColor.BLACK;
			MusicBeatState.switchState(new funkin.menus.options.OptionsState());
		});
		add(options);

		youtube = new UIButton(192, 573, 'mainmenu/youtube', () ->
		{
			funkin.utils.CoolUtil.browserLoad('https://www.youtube.com/@BundleTeamBHB');
		});
		add(youtube);

		awards = new UIButton(502, 573, 'mainmenu/awards', () ->
		{
			bgColor = FlxColor.BLACK;
			MusicBeatState.switchState(new funkin.menus.AchievementsMenuState());
		});
		add(awards);

		lockSpriteREMOVEAFTERDEMO = new LockSprite();
		add(lockSpriteREMOVEAFTERDEMO);
		lockSpriteREMOVEAFTERDEMO.spriteCenter(play);

		logoBl = new FlxSpinnyXSprite();
		logoBl.frames = Paths.getSparrowAtlas('menulogo');
		logoBl.screenCenter();

		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.scale.set(0.75, 0.75);
		logoBl.spinny3DDefaultScale = 0.75;
		logoBl.updateHitbox();
		logoBl.setPosition(50, 27);
		add(logoBl);
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, 'BundleEngine ${bundleEngineVersion}', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, QualityPrefs.textShadow(), FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Blue House Bundle: DEMO v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, QualityPrefs.textShadow(), FlxColor.BLACK);
		add(versionShit);
		super.create();
		menuCharTween = FlxTween.tween(menuChar, {x: 730, y: 0}, 0.5, {ease: FlxEase.backOut});
		/*
			newsSprite = new NewsSprite();
			add(newsSprite);
			newsSprite.init(); */
	}

	override function beatHit()
	{
		super.beatHit();
		if (logoBl != null)
			logoBl.animation.play('bump', true);
		Conductor.changeBPM(haxe.Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json')).bpm);
	}

	var logoBlTween:FlxTween = null;
	var grid:GridBG;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SEVEN)
		{
			MusicBeatState.switchState(new MasterEditorMenu());
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		if (FlxG.mouse.overlaps(logoBl) && (FlxG.mouse.deltaX > 8 || FlxG.mouse.deltaX < -8))
		{
			logoBl.spinny3D = 0;

			if (logoBlTween != null)
				logoBlTween.cancel();
			logoBlTween = FlxTween.tween(logoBl, {spinny3D: 1}, 1, {
				ease: FastEase.sineOut,
				onComplete: (?_) ->
				{
					logoBl.spinny3D = 0;
				}
			});
		}
		lockSpriteREMOVEAFTERDEMO.copyScale(play);
		if (freeplay.hovered && lastHovered != "freeplay")
		{
			lastHovered = "freeplay";
			if (menuCharTween != null)
			{
				menuCharTween.cancel();
			}
			menuChar.loadGraphic(Paths.image('mainmenu/menuChars/shattered'));
			menuChar.x = 1680;
			menuChar.y = 0;
			menuChar.scale.set(0.9, 0.9);
			menuChar.width = 303;
			menuChar.height = 442;
			menuCharTween = FlxTween.tween(menuChar, {x: 730, y: 20}, 0.5, {ease: FlxEase.backOut});
		}
		else if (play.hovered && lastHovered != "play")
		{
			lastHovered = "play";

			if (menuCharTween != null)
			{
				menuCharTween.cancel();
			}
			menuChar.loadGraphic(Paths.image('mainmenu/menuChars/nicebon'));
			menuChar.x = 1680;
			menuChar.y = 0;
			menuChar.scale.set(1, 1);
			menuChar.width = 303;
			menuChar.height = 442;
			menuCharTween = FlxTween.tween(menuChar, {x: 730, y: 0}, 0.5, {ease: FlxEase.backOut});
		}
		else if (options.hovered && lastHovered != "options")
		{
			lastHovered = "options";

			if (menuCharTween != null)
			{
				menuCharTween.cancel();
			}
			menuChar.loadGraphic(Paths.image('mainmenu/menuChars/delta'));
			menuChar.x = 1680;
			menuChar.y = 0;
			menuChar.scale.set(1, 1);
			menuChar.width = 303;
			menuChar.height = 442;
			menuCharTween = FlxTween.tween(menuChar, {x: 730, y: 0}, 0.5, {ease: FlxEase.backOut});
		}
		else if (awards.hovered && lastHovered != "awards")
		{
			lastHovered = "awards";

			if (menuCharTween != null)
			{
				menuCharTween.cancel();
			}
			menuChar.loadGraphic(Paths.image('mainmenu/menuChars/megafun'));
			menuChar.x = 1680;
			menuChar.y = 0;
			menuChar.scale.set(0.75, 0.75);
			menuChar.width = 303;
			menuChar.height = 442;
			menuCharTween = FlxTween.tween(menuChar, {x: 600, y: 0}, 0.5, {ease: FlxEase.backOut});
		}
		if (!freeplay.hovered && !play.hovered && !options.hovered && !awards.hovered)
		{
			lastHovered = "";
		}
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new TitleState());
		}
		super.update(elapsed);
	}

	public override function destroy()
	{
		MemUtil.destroyAllSprites(this, true, true);
		super.destroy();
	}
}
