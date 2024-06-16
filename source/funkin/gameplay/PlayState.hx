package funkin.gameplay;

import funkin.plugins.ShaderManager;
import funkin.fx.shaders.GrayscaleShader;
import funkin.menus.HTML5PlaystateLoader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import funkin.editors.CharacterEditorState;
import funkin.editors.ChartingState;
import funkin.editors.ui.UIData;
import funkin.fx.*;
import funkin.fx.shaders.*;
import funkin.gameplay.DialogueBoxPsych;
import funkin.gameplay.Note.EventNote;
import funkin.gameplay.hud.*;
import funkin.menus.StoryMenuState;
import funkin.ui.notifications.AchievementNotification;
import funkin.ui.notifications.NotificationManager;
import funkin.music.Conductor.Rating;
import funkin.music.Song.SwagSong;
import funkin.music.Song;
import funkin.music.StageData;
import funkin.music.WeekData;
import funkin.system.achievements.Achievements;
import funkin.system.chart.Section.SwagSection;
import funkin.system.input.Controls;
import funkin.user.Highscore;
import funkin.utils.CoolUtil;
import funkin.utils.MemUtil;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFLAssets;
#if (cpp && desktop)
import funkin.system.Discord;
#end
#if !flash
#end
#if sys
import sys.FileSystem;
#end
#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X:Int32 = 42;
	public static var STRUM_X_MIDDLESCROLL:Int32 = -272;

	public static var ratingStuff:Array<Array<Dynamic>> = [
		['You Suck!', 0.2], // From 0% to 19%
		['Shit', 0.4], // From 20% to 39%
		['Bad', 0.5], // From 40% to 49%
		['Bruh', 0.6], // From 50% to 59%
		['Meh', 0.69], // From 60% to 68%
		['Nice', 0.7], // 69%
		['Good', 0.8], // From 70% to 79%
		['Great', 0.9], // From 80% to 89%
		['Sick!', 1], // From 90% to 99%
		['Perfect!!', 1] // The value on this one isn't used actually, since Perfect is always "1"
	];

	// event variables
	public var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();

	public var frontSprites:Array<FlxSprite> = [];
	public var BF_X:Float32 = 770;
	public var BF_Y:Float32 = 100;
	public var DAD_X:Float32 = 100;
	public var DAD_Y:Float32 = 100;
	public var GF_X:Float32 = 400;
	public var GF_Y:Float32 = 130;
	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float32 = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float32 = 350;
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float32 = 2000;

	public var usingDoubleVoices:Bool = false;
	public var opponentVocals:FlxSound;
	public var playerVocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;
	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	// Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;

	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedSpriteGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;

	private var curSong:String = "";

	public var gfSpeed:Int32 = 1;
	public var health:Float = 1;

	public var combo:Int32 = 0;
	public var comboBreaks:Int32 = 0;

	public var healthBar:HealthBar;
	public var timeBar:TimeBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int16 = 0;
	public var goods:Int16 = 0;
	public var bads:Int16 = 0;
	public var shits:Int16 = 0;

	private var generatedMusic:Bool = false;

	public var endingSong:Bool = false;
	public var startingSong:Bool = false;

	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	public var healthGain:Float = 1.0;
	public var healthLoss:Float = 1.0;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var noFail:Bool = false;
	public var tauntMode:Bool = false;

	public var camOther:FlxCamera;
	public var camHUD:FlxCamera;
	public var camNotes:FlxCamera;
	public var camGame:FlxCamera;

	public var cameraSpeed:Float = 1;

	public static var playbackSpeed:Float = 1.0;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;
	var heyTimer:Float32;

	public var songScore:Int32 = 0;
	public var songHits:UInt16 = 0;
	public var songMisses:UInt16 = 0; // this really doesnt have to be a int32 unless your planning to hit from 65,535 to 2,147,483,647 misses (your bad!) -lga
	public var currentSection:UInt32 = 0;

	public static var campaignScore:Int32 = 0;
	public static var campaignMisses:UInt16 = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int32 = 0;

	public var defaultCamZoom:Float32 = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float32 = 6;

	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;

	var songLength:Float32 = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	// Achievement shit
	var keysPressed:Array<Bool> = [];

	public static var instance:PlayState;

	public var invert:Bool = false;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;
	private var precacheList:Map<String, String> = new Map<String, String>();

	public static var recordMode:Bool = false;

	public var frontOfGfSprites:Array<FlxSprite> = [];

	public function new()
	{
		super();
	}

	// one day this will be the smallest ccode in the whole playstate i promis -lga
	public static function preloadAudio(song:Null<String> = null, onComplete:() -> Void)
	{
		if (song == null)
			song = PlayState.SONG.song;
		HTML5PlaystateLoader.statusText = "Loading " + song + "...\nLoading vocals...";
		// what the fuck i love html5
		// never let me program for this game again thanks -lga
		Paths.preloadVoices(song, -1, () ->
		{
			HTML5PlaystateLoader.statusText = "Loading opponent vocals...";
			Paths.preloadVoices(song, 0, () ->
			{
				HTML5PlaystateLoader.statusText = "Loading player vocals...";
				Paths.preloadVoices(song, 1, () ->
				{
					HTML5PlaystateLoader.statusText = "Loading instrumental...";
					Paths.preloadInst(song, () ->
					{
						HTML5PlaystateLoader.statusText = "Loading pause music...";
						Paths.preloadMusic(Paths.formatToSongPath(ClientPrefs.pauseMusic), "shared", onComplete);
					});
				});
			});
		});
	}

	public function toggleInvert()
	{
		invert = !invert;

		if (invert)
			ShaderManager.add("invert-playstate", new ShaderFilter(new InvertShader()));
		else
			ShaderManager.remove("invert-playstate");
	}

	public function initCrap()
	{
		curSection = 0;
		// SongEvents.Cinematics.onCreate();
		SongMods.CoolFunkyCredits.onCreatePost();
		SongEvents.SkipSection.reset();
		SongMods.CameraFollow.usedInLevel = false;
	}

	public override function create()
	{
		FlxSprite.defaultAntialiasing = ClientPrefs.globalAntialiasing;
		// Paths.clearStoredMemory();
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; // Reset to default

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		controlArray = ['NOTE_LEFT', 'NOTE_DOWN', 'NOTE_UP', 'NOTE_RIGHT'];

		// Ratings
		var rating:Rating = new Rating('sick');
		rating.hitWindow = ClientPrefs.sickWindow;
		rating.resetsCombo = false;
		ratingsData.push(rating); // default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.hitWindow = ClientPrefs.goodWindow;
		rating.resetsCombo = false;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.hitWindow = ClientPrefs.badWindow;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.hitWindow = 160;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
			keysPressed.push(false);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		playbackSpeed = ClientPrefs.getGameplaySetting('playbackspeed', 1.0);
		FlxG.animationTimeScale = playbackSpeed;
		// FlxG.timeScale = playbackSpeed;
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1.0);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1.0);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		noFail = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);
		recordMode = ClientPrefs.getGameplaySetting('recordmode', false);
		tauntMode = ClientPrefs.getGameplaySetting('tauntmode', false);
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camNotes = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camNotes.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camNotes, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('shitread');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		// Funkin.log('stage is: ' + curStage);
		if (SONG.stage == null || SONG.stage.length < 1)
			curStage = 'blue house';
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if (stageData == null)
		{ // Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,
				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if (stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if (boyfriendCameraOffset == null) // Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if (opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if (girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		SongStages.loadStage(curStage);

		switch (Paths.formatToSongPath(SONG.song)) // todo: make this load from char json
		{
			case 'megafun' | 'megafun-erect' | 'bestsongever':
				SongStages.MistaPlayer.init();
			case 'erm':
				SongStages.ErmPlayer.init();
			case 'lunacy':
				SongStages.NBPixelPlayer.init();
		}

		if (isPixelStage)
			introSoundsSuffix = '-pixel';

		add(gfGroup); // Needed for blammed lights
		if (frontOfGfSprites.length > 0)
		{
			for (sprite in frontOfGfSprites)
				add(sprite);
		}

		add(dadGroup);
		add(boyfriendGroup);

		var gfVersion:String = SONG.gfVersion;
		if (gfVersion == null || gfVersion.length < 1)
		{
			gfVersion = 'frankie';
			SONG.gfVersion = gfVersion; // Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);

		initCrap();
		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if (gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if (dad.curCharacter.startsWith('gf'))
		{
			dad.setPosition(GF_X, GF_Y);
			if (gf != null)
				gf.visible = false;
		}

		var file:String = Paths.json(songName + '/dialogue'); // Checks for json/Psych Engine dialogue
		if (OpenFLAssets.exists(file))
			dialogueJson = DialogueBoxPsych.parseDialogue(file);

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); // Checks for vanilla/Senpai dialogue
		if (OpenFLAssets.exists(file))
			dialogue = CoolUtil.coolTextFile(file);

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (ClientPrefs.downScroll)
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		healthBar = new HealthBar();
		UIData.getAndApplyToSprite('healthBar', healthBar);
		add(healthBar);

		timeBar = new TimeBar();
		UIData.getAndApplyToSprite('timeBar', timeBar);
		add(timeBar);

		strumLineNotes = new FlxTypedSpriteGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		generateSong(SONG.song);
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		grpNoteSplashes.cameras = [camNotes];
		strumLineNotes.cameras = [camNotes];
		notes.cameras = [camNotes];
		healthBar.cameras = [camHUD];
		timeBar.cameras = [camHUD];

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		moveCameraSection();

		RecalculateRating();

		if (ClientPrefs.hitsoundVolume > 0)
			precacheList.set('${ClientPrefs.hitsound}', 'hitsound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null)
			precacheList.set(PauseSubState.songName, 'music');
		else if (ClientPrefs.pauseMusic != 'None')
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');

		precacheList.set('alphabet', 'image');

		if (!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		if (frontSprites.length > 0)
		{
			for (sprite in frontSprites)
			{
				add(sprite);
			}
		}

		super.create();

		cacheCountdown();
		cachePopUpScore();
		for (key => type in precacheList)
		{
			// Funkin.log('Key $key is type $type');
			switch (type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'hitsound':
					Paths.hitsound(key);
				case 'music':
					Paths.music(key);
			}
		}
		// Paths.clearUnusedMemory();
		CustomFadeTransition.nextCamera = camOther;

		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			startCountdown();
			seenCutscene = true;
		}
		else
			startCountdown();
	}

	public function reloadHealthBarColors()
	{
		healthBar.reloadColors();
	}

	function set_songSpeed(value:Float):Float
	{
		if (generatedMusic)
		{
			var ratio:Float = value / songSpeed;
			for (note in notes)
				note.resizeByRatio(ratio);
			for (note in unspawnNotes)
				note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function addCharacterToList(newCharacter:String, type:Int)
	{
		switch (type)
		{
			case 0:
				if (!boyfriendMap.exists(newCharacter))
				{
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0;
				}

			case 1:
				if (!dadMap.exists(newCharacter))
				{
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0;
				}

			case 2:
				if (gf != null && !gfMap.exists(newCharacter))
				{
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0;
				}
		}
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false)
	{
		if (gfCheck && char.curCharacter.startsWith('gf'))
		{ // IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if (!FileSystem.exists(filepath))
		#else
		if (!OpenFLAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:MP4Handler = new MP4Handler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if (endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;

	public var psychDialogue:DialogueBoxPsych;

	// You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if (psychDialogue != null)
			return;

		if (dialogueFile.dialogue.length > 0)
		{
			inCutscene = true;
			precacheList.set('dialogue', 'sound');
			precacheList.set('dialogueClose', 'sound');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if (endingSong)
			{
				psychDialogue.finishThing = function()
				{
					psychDialogue = null;
					endSong();
				}
			}
			else
			{
				psychDialogue.finishThing = function()
				{
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		}
		else
		{
			FlxG.log.warn('Your dialogue file is badly formatted!');
			startAndEnd();
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;

	public static var startOnTime:Float = 0;

	public var introAlts:Array<String>;

	function cacheCountdown()
	{
		var pixelFolder:String = 'pixelUI';
		if (curStage == 'white')
			pixelFolder = "lunacyUI";

		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', [
			pixelFolder + '/ready-pixel',
			pixelFolder + '/set-pixel',
			pixelFolder + '/go-pixel'
		]);

		introAlts = introAssets.get('default');
		var antialias:Bool = ClientPrefs.globalAntialiasing;
		if (isPixelStage)
		{
			introAlts = introAssets.get('pixel');
			antialias = false;
			FlxG.camera.pixelPerfectRender = true;
		}

		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown():Void
	{
		if (startedCountdown)
			return;

		inCutscene = false;

		skipArrowStartTween = true;

		generateStaticArrows(0);
		generateStaticArrows(1);
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= (Conductor.crochet * 5) + ClientPrefs.noteOffset;

		if (startOnTime < 0)
			startOnTime = 0;

		if (startOnTime > 0)
		{
			clearNotesBefore(startOnTime);
			setSongTime((startOnTime - ((Conductor.crochet * 5) + ClientPrefs.noteOffset)));
			return;
		}
		else if (skipCountdown)
		{
			setSongTime(0);
			return;
		}

		notes.forEachAlive((note:Note) ->
		{
			if ((ClientPrefs.opponentStrums && SONG.song != "bestsongever") || note.mustPress)
			{
				note.copyAlpha = false;
				note.alpha = note.multAlpha;
				if (ClientPrefs.middleScroll && !note.mustPress)
					note.alpha *= 0.35;
			}
		});
	}

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}

	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}

	public function addBehindDad(obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = unspawnNotes[i];
			if (daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0)
		{
			var daNote:Note = notes.members[i];
			if (daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if (time < 0)
			time = 0;

		FlxG.sound.music.pause();
		opponentVocals.pause();
		playerVocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();
		if (Conductor.songPosition <= opponentVocals.length)
		{
			opponentVocals.time = Conductor.songPosition;
			opponentVocals.play();
		}

		if (Conductor.songPosition <= playerVocals.length)
		{
			playerVocals.time = Conductor.songPosition;
			playerVocals.play();
		}

		opponentVocals.play();
		playerVocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	function startNextDialogue()
	{
		dialogueCount++;
	}

	function skipDialogue()
	{
	}

	var previousFrameTime:Int = 0;

	public var lastReportedPlayheadPosition:Int = 0;

	public var songTime:Float = 0;

	public function startSong():Void
	{
		startingSong = false;
		switch (SONG.song)
		{
			case "megafun-erect" | "megafun":
				SongMods.CoolFunkyCredits.show("WIP", "Gameplay is not final.", this);
		}
		FlxTween.tween(camGame, {zoom: camGame.zoom + 0.2}, 1, {
			ease: FastEase.sineOut,
		}); // cool ass zoom
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = finishSong.bind();

		opponentVocals.play();
		playerVocals.play();
		FlxG.sound.music.pitch = playbackSpeed;
		opponentVocals.pitch = playbackSpeed;
		playerVocals.pitch = playbackSpeed;
		if (startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if (paused)
		{
			// Funkin.log('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			opponentVocals.pause();
			playerVocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		var achieve:String = checkForAchievement(['april17date']);

		if (achieve != null)
		{
			startAchievement(achieve);
			return;
		}
	}

	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	var noteData:Array<SwagSection>;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype', 'multiplicative');

		switch (songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		Conductor.changeBPM(SONG.bpm);
		Conductor.bpm *= playbackSpeed;
		songSpeed /= playbackSpeed;
		curSong = SONG.song;

		usingDoubleVoices = false;
		if (SONG.needsVoices)
		{
			var voices = Paths.voices(PlayState.SONG.song, 0);
			var voices1 = Paths.voices(PlayState.SONG.song, 1);
			if (voices != null && voices1 != null)
			{
				opponentVocals = new FlxSound().loadEmbedded(voices);
				playerVocals = new FlxSound().loadEmbedded(voices1);
				usingDoubleVoices = true;
			}
			else
			{
				opponentVocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				playerVocals = new FlxSound();
			}
		}
		else
		{
			opponentVocals = new FlxSound();
			playerVocals = new FlxSound();
		}
		opponentVocals.looped = false;
		playerVocals.looped = false;
		FlxG.sound.list.add(opponentVocals);
		FlxG.sound.list.add(playerVocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		notes.cameras = [camNotes];
		add(notes);
		noteData = SONG.notes;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String;
		#if (sys && desktop)
		file = 'assets/shared/data/${songName + '/events'}.json';
		#else
		file = Paths.json(songName + '/events', 'shared');
		#end
		if (#if !sys OpenFLAssets.exists(file) #elseif sys FileSystem.exists(file) #end)
		{
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;

			for (event in eventsData) // Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0]
						/*- ClientPrefs.noteOffset*/,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;
				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1] < 4));
				swagNote.noteType = songNotes[3];
				if (!Std.isOfType(songNotes[3], String))
					swagNote.noteType = funkin.editors.ChartingState.noteTypeList[songNotes[3]]; // Backward compatibility + compatibility with Week 7 charts
				swagNote.scrollFactor.set();
				var susLength:Float = swagNote.sustainLength;
				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				var floorSus:Int = Math.floor(susLength);

				if (floorSus > 0)
				{
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						var sustainNote:Note = new Note(daStrumTime
							+ (Conductor.stepCrochet * susNote)
							+ (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData,
							oldNote, true);

						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1] < 4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if (ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if (daNoteData > 1) // Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}
				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if (ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if (daNoteData > 1) // Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}
				if (!noteTypeMap.exists(swagNote.noteType))
				{
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in SONG.events) // Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];

				var subEvent:EventNote = {
					strumTime: newEventNote[0],
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}
		unspawnNotes.sort(sortByShit);
		if (eventNotes.length > 1) // No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);

		checkEventNote();

		generatedMusic = true;
	}

	function eventPushed(event:EventNote)
	{
		switch (event.event)
		{
			case 'Change Character':
				var charType:Int = 0;
				switch (event.value1.toLowerCase())
				{
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
			case 'introNums':
				skipCountdown = true;
			case 'Cinematics':
				SongEvents.Cinematics.onCreate();
			case "Set New Camera Data":
				if (10.0 >= event.strumTime)
					SongMods.CameraFollow.onEvent(event.value1, event.value2);
		}

		if (!eventPushedMap.exists(event.event))
		{
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float
	{
		/*
			switch (event.event)
			{
				
					case 'Kill Henchmen': // Better timing so that the kill sound matches the beat intended
						return 280; // Plays 280ms before the actual position
			}
		 */

		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false;

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if (!ClientPrefs.opponentStrums || SONG.song == "bestsongever")
					targetAlpha = 0;
				else if (ClientPrefs.middleScroll)
					targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				// babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
				babyArrow.alpha = targetAlpha;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
			{
				if (ClientPrefs.middleScroll)
				{
					babyArrow.x = STRUM_X_MIDDLESCROLL + 310;
					if (i > 1) // Up and Right
						babyArrow.x = FlxG.width + (STRUM_X_MIDDLESCROLL * 2) - 20;
				}
				opponentStrums.add(babyArrow);
			}
			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				opponentVocals.pause();
				playerVocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars)
				if (char != null && char.colorTween != null)
					char.colorTween.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars)
				if (char != null && char.colorTween != null)
					char.colorTween.active = true;

			paused = false;
		}

		super.closeSubState();
	}

	public override function onFocus():Void
	{
		super.onFocus();
	}

	public override function onFocusLost():Void
	{
		if (!paused && !recordMode && !endingSong)
			openPauseMenu();
		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (finishTimer != null)
			return;

		opponentVocals.pause();
		playerVocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= opponentVocals.length)
		{
			opponentVocals.time = Conductor.songPosition;
			opponentVocals.play();
		}

		if (Conductor.songPosition <= playerVocals.length)
		{
			playerVocals.time = Conductor.songPosition;
			playerVocals.play();
		}
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;
	var bffinAnim:Bool = false;
	var dadfinAnim:Bool = false;
	var fakeCrochet:Float;
	var swagCounter:Int32 = 0;

	private var tauntSound:FlxSound;

	public override function update(elapsed:Float)
	{
		currentSection = curSection;
		healthBar.scoreTxt.screenCenter(X);
		Conductor.safeZoneOffset = ((ClientPrefs.safeFrames / 60) * 1000) * playbackSpeed;
		SongEvents.ShotWindow.update();
		SongEvents.SkipSection.update(elapsed);
		SongMods.CameraFollow.onUpdate();

		if (recordMode)
		{
			cpuControlled = true;
			camHUD.alpha = 0;
			camNotes.alpha = 0;
			camOther.alpha = 0;
			camHUD.visible = false;
			camNotes.visible = false;
			camOther.visible = false;
		}

		if (!inCutscene)
		{
			var lerpVal:Float32 = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		super.update(elapsed);
		// fixes bug with holding notes playing sing anim even if no note is there
		if (boyfriend.holdTimer >= (Conductor.stepCrochet / 1000) * 4 && totalNotesHit == lastTotalHits && !bffinAnim && !boyfriend.specialAnim)
		{
			bffinAnim = true;
			boyfriend.playAnim(boyfriend.animation.curAnim.name, true, true, boyfriend.animation.curAnim.frames.length - 1);
		}
		if (bffinAnim && boyfriend.animation.curAnim.curFrame == 0 && !boyfriend.specialAnim)
		{
			boyfriend.dance(true);
			bffinAnim = false;
		}

		if (controls.TAUNT)
		{
			taunt();
		}

		if (controls.PAUSE && startedCountdown && canPause)
			openPauseMenu();

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
			openChartEditor();

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene)
			openCharEditor();

		if (health > 2)
			health = 2;
		camOther.zoom = camHUD.zoom;
		camNotes.zoom = camHUD.zoom;
		camNotes.alpha = camHUD.alpha;
		if (startingSong)
		{
			if (startedCountdown)
			{
				if (!(Main.elapsed >= 500))
				{
					if (startTimer == null && !skipCountdown)
					{
						startTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, (_) ->
						{
							startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
							{
								if (gf != null
									&& tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
									&& gf.animation.curAnim != null
									&& !gf.animation.curAnim.name.startsWith("sing")
									&& !gf.stunned)
								{
									gf.dance();
								}
								if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0
									&& boyfriend.animation.curAnim != null
									&& !boyfriend.animation.curAnim.name.startsWith('sing')
									&& !boyfriend.stunned)
								{
									boyfriend.dance();
								}
								if (tmr.loopsLeft % dad.danceEveryNumBeats == 0
									&& dad.animation.curAnim != null
									&& !dad.animation.curAnim.name.startsWith('sing')
									&& !dad.stunned)
								{
									dad.dance();
								}
								if (!recordMode)
								{
									switch (swagCounter)
									{
										case 0:
											FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
										case 1:
											countdownReady = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
											countdownReady.cameras = [camHUD];
											countdownReady.scrollFactor.set();
											countdownReady.updateHitbox();

											if (PlayState.isPixelStage)
												countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

											countdownReady.screenCenter();
											countdownReady.antialiasing = !PlayState.isPixelStage && ClientPrefs.globalAntialiasing;
											insert(members.indexOf(notes), countdownReady);
											FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
												ease: FlxEase.cubeInOut,
												onComplete: function(twn:FlxTween)
												{
													remove(countdownReady);
													countdownReady.destroy();
												}
											});
											FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
										case 2:
											countdownSet = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
											countdownSet.cameras = [camHUD];
											countdownSet.scrollFactor.set();

											if (PlayState.isPixelStage)
												countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

											countdownSet.screenCenter();
											countdownSet.antialiasing = !PlayState.isPixelStage && ClientPrefs.globalAntialiasing;
											insert(members.indexOf(notes), countdownSet);
											FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
												ease: FlxEase.cubeInOut,
												onComplete: function(twn:FlxTween)
												{
													remove(countdownSet);
													countdownSet.destroy();
												}
											});
											FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
										case 3:
											countdownGo = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
											countdownGo.cameras = [camHUD];
											countdownGo.scrollFactor.set();

											if (PlayState.isPixelStage)
												countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

											countdownGo.updateHitbox();

											countdownGo.screenCenter();
											countdownGo.antialiasing = !PlayState.isPixelStage && ClientPrefs.globalAntialiasing;
											insert(members.indexOf(notes), countdownGo);
											FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
												ease: FlxEase.cubeInOut,
												onComplete: function(twn:FlxTween)
												{
													remove(countdownGo);
													countdownGo.destroy();
												}
											});
											FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
										case 4:
									}
								}
								swagCounter += 1;
							}, 5);
						}, 1);
					}
					Conductor.songPosition += (Main.elapsed) * playbackSpeed;
					if (Conductor.songPosition >= 0)
						startSong();
				}
			}
		}
		else
		{
			if (!(Main.elapsed >= 500))
				Conductor.songPosition += (Main.elapsed) * playbackSpeed;
			if (!paused)
			{
				songTime = Conductor.songPosition;
				//				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}
		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay), 0, 1));
		}

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			Funkin.log("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float32 = spawnTime;
			if (songSpeed < 1)
				time /= songSpeed;
			if (unspawnNotes[0].multSpeed < 1)
				time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (!inCutscene)
			{
				if (!cpuControlled)
				{
					keyShit();
				}
				else if (boyfriend.animation.curAnim != null
					&& boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration
					&& boyfriend.animation.curAnim.name.startsWith('sing')
					&& !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.dance();
					// boyfriend.animation.curAnim.finish();
				}
			}
			fakeCrochet = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(noteUpdate);
		}
		checkEventNote();

		#if debug
		if (!endingSong && !startingSong)
		{
			if (FlxG.keys.justPressed.ONE)
			{
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if (FlxG.keys.justPressed.TWO)
			{ // Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end
		for (key in FlxG.keys.getIsDown())
		{
			if (ClientPrefs.keyBinds.get("note_left").contains(key.ID)
				|| ClientPrefs.keyBinds.get("note_down").contains(key.ID)
				|| ClientPrefs.keyBinds.get("note_up").contains(key.ID)
				|| ClientPrefs.keyBinds.get("note_right").contains(key.ID))
			{
				if (!ultimateShitterCheck.contains(key.ID))
				{
					ultimateShitterCheck.push(key.ID);
				}
			}
		}
		switch (curStage)
		{
			case "code":
				SongStages.Stage_code.update(elapsed);
		}
		lastUpdateTime = Time.getTimestamp();
	}

	function taunt()
	{
		if (!boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.animation.exists("hey"))
		{
			if (boyfriend.specialAnim)
			{
				if (boyfriend.animation.curAnim.name != "hey")
				{
					return;
				}
			}
			boyfriend.playAnim('hey', true);
			boyfriend.specialAnim = true;
			if (boyfriend.tauntSound != "" && boyfriend.tauntSound != null)
				tauntSound = FlxG.sound.play(Paths.sound('taunts/${boyfriend.tauntSound}'));
			else
				tauntSound = FlxG.sound.play(Paths.sound('taunts/peace'));
			tauntSound.pitch = playbackSpeed;
		}
	}

	public var lastUpdateTime:Float = 0.00;

	// called for each note and runs behaviours for them
	private function noteUpdate(daNote:Note)
	{
		var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
		if (!daNote.mustPress)
			strumGroup = opponentStrums;

		var strumX:Float = strumGroup.members[daNote.noteData].x;
		var strumY:Float = strumGroup.members[daNote.noteData].y;
		var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
		var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
		var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
		var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

		strumX += daNote.offsetX;
		strumY += daNote.offsetY;
		strumAngle += daNote.offsetAngle;
		strumAlpha *= daNote.multAlpha;

		if (strumScroll) // Downscroll
			daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
		else // Upscroll
			daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);

		var angleDir:Float32 = strumDirection * Math.PI / 180;
		if (daNote.copyAngle)
			daNote.angle = strumDirection - 90 + strumAngle;

		if (daNote.copyAlpha)
			daNote.alpha = strumAlpha;

		if (daNote.copyX)
			daNote.x = strumX + FNKMath.fastCos(angleDir) * daNote.distance;

		if (daNote.ignoreNote && !daNote.hitCausesMiss)
			daNote.alpha = 0;

		if (daNote.copyY)
		{
			daNote.y = strumY + FNKMath.fastSin(angleDir) * daNote.distance;

			// Jesus fuck this took me so much mother fucking time AAAAAAAAAA
			if (strumScroll && daNote.isSustainNote)
			{
				if (daNote.animation.curAnim != null)
				{
					if (daNote.animation.curAnim.name.endsWith('end'))
					{
						daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
						daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
						if (PlayState.isPixelStage)
							daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
						else
							daNote.y -= 19;
					}
					daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
					daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
				}
			}
		}

		if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
		{
			opponentNoteHit(daNote);
			switch (curStage)
			{
				case "code":
					SongStages.Stage_code.gyatt(daNote);
			}
		}

		if (!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit)
		{
			if (daNote.isSustainNote)
			{
				if (daNote.canBeHit)
				{
					goodNoteHit(daNote);
				}
			}
			else if (daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote)
				goodNoteHit(daNote);
		}

		var center:Float = strumY + Note.swagWidth / 2;
		if (strumGroup.members[daNote.noteData].sustainReduce
			&& daNote.isSustainNote
			&& (daNote.mustPress || !daNote.ignoreNote)
			&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
		{
			if (strumScroll)
			{
				if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
				{
					var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
					swagRect.height = (center - daNote.y) / daNote.scale.y;
					swagRect.y = daNote.frameHeight - swagRect.height;

					daNote.clipRect = swagRect;
				}
			}
			else
			{
				if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
				{
					var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
					swagRect.y = (center - daNote.y) / daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}
			}
		}

		// Kill extremely late notes and cause misses
		if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
		{
			if (daNote.mustPress
				&& !cpuControlled
				&& !daNote.ignoreNote
				&& !endingSong
				&& (daNote.tooLate || !daNote.wasGoodHit)
				&& !daNote.wasComboBreakHit)
				noteMiss(daNote);

			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
	}

	// Used for bhb ultimate shitter achieve
	private static var ultimateShitterCheck:Array<FlxKey> = [];

	public function openPauseMenu()
	{
		if (paused || endingSong)
			return;

		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			opponentVocals.pause();
			playerVocals.pause();
		}
		if (PlayState.chartingMode)
			openSubState(new funkin.menus.OldPauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		else
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;
	}

	function openCharEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
	}

	public var isDead:Bool = false; // Don't mess with this!!!

	function doDeathCheck(?skipHealthCheck:Bool = false)
	{
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !noFail && !isDead)
		{
			boyfriend.stunned = true;
			deathCounter++;

			paused = true;

			opponentVocals.stop();
			playerVocals.stop();
			FlxG.sound.music.stop();

			persistentUpdate = false;
			persistentDraw = false;
			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0],
				boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

			isDead = true;
			return true;
		}
		return false;
	}

	public function checkEventNote()
	{
		while (eventNotes.length > 0)
		{
			var leStrumTime:Float = eventNotes[0].strumTime;
			if (Conductor.songPosition < leStrumTime)
				break;

			var value1:String = '';
			if (eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if (eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String)
	{
		var pressed:Bool = Reflect.getProperty(controls, key);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String)
	{
		switch (eventName)
		{
			case 'Hey!':
				var value:Int = 2;
				switch (value1.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float32 = Std.parseFloat(value2);
				if (Math.isNaN(time) || time <= 0)
					time = 0.6;

				if (value != 0)
				{
					if (dad.curCharacter.startsWith('gf'))
					{ // Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					}
					else if (gf != null)
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if (value != 1)
				{
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if (Math.isNaN(value) || value < 1)
					value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if (ClientPrefs.camZooms && FlxG.camera.zoom < 1.35)
				{
					var camZoom:Float32 = Std.parseFloat(value1);
					var hudZoom:Float32 = Std.parseFloat(value2);
					if (Math.isNaN(camZoom))
						camZoom = 0.015;
					if (Math.isNaN(hudZoom))
						hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Play Animation':
				// Funkin.log('Anim to play: ' + value1);
				var char:Character = dad;
				switch (value2.toLowerCase().trim())
				{
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if (Math.isNaN(val2))
							val2 = 0;

						switch (val2)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 0;
				if (Math.isNaN(val2))
					val2 = 0;

				isCameraOnForcedPos = false;
				if (!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2)))
				{
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if (Math.isNaN(val))
							val = 0;

						switch (val)
						{
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length)
				{
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if (split[0] != null)
						duration = Std.parseFloat(split[0].trim());
					if (split[1] != null)
						intensity = Std.parseFloat(split[1].trim());
					if (Math.isNaN(duration))
						duration = 0;
					if (Math.isNaN(intensity))
						intensity = 0;

					if (duration > 0 && intensity != 0)
						targetsArray[i].shake(intensity, duration);
				}

			case 'Change Character':
				var charType:Int = 0;
				switch (value1.toLowerCase().trim())
				{
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if (Math.isNaN(charType)) charType = 0;
				}

				switch (charType)
				{
					case 0:
						if (boyfriend.curCharacter != value2)
						{
							if (!boyfriendMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							healthBar.iconP1.changeIcon(boyfriend.healthIcon);
						}

					case 1:
						if (dad.curCharacter != value2)
						{
							if (!dadMap.exists(value2))
							{
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0;
							dad = dadMap.get(value2);
							if (!dad.curCharacter.startsWith('gf'))
							{
								if (wasGf && gf != null)
								{
									gf.visible = true;
								}
							}
							else if (gf != null)
							{
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							healthBar.iconP2.changeIcon(dad.healthIcon);
						}

					case 2:
						if (gf != null)
						{
							if (gf.curCharacter != value2)
							{
								if (!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if (Math.isNaN(val1))
					val1 = 1;
				if (Math.isNaN(val2))
					val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;
				newValue /= playbackSpeed;
				if (val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {
						ease: FlxEase.linear,
						onComplete: (twn:FlxTween) ->
						{
							songSpeedTween = null;
						}
					});
				}
			default:
				SongEvents.EventList.run(eventName, value1, value2);
		}
	}

	public function setShitToZero():Void
	{
		curSection = 0;
		curStep = 0;
		curBeat = 0;
		curDecBeat = 0;
		curDecStep = 0;
	}

	public function moveCameraSection():Void
	{
		if (SONG.notes[curSection] == null)
			return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
			moveCamera(true);
		else
			moveCamera(false);
	}

	var cameraTwn:FlxTween;

	public function moveCamera(isDad:Bool)
	{
		if (isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {
					ease: FastEase.elasticInOut,
					onComplete: function(twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn()
	{
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3)
		{
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {
				ease: FastEase.elasticInOut,
				onComplete: function(twn:FlxTween)
				{
					cameraTwn = null;
				}
			});
		}
	}

	public function snapCamFollowToPos(x:Float, y:Float)
	{
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; // In case you want to change it in a specific song.

		FlxG.sound.music.volume = 0;
		opponentVocals.volume = 0;
		playerVocals.volume = 0;
		opponentVocals.pause();
		playerVocals.pause();

		if (ClientPrefs.noteOffset <= 0 || ignoreNoteOffset)
		{
			finishCallback();
		}
		else
		{
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer)
			{
				finishCallback();
			});
		}
	}

	public var transitioning = false;

	public function endSong():Void
	{
		// Should kill you if you tried to cheat
		if (!startingSong)
		{
			notes.forEach(function(daNote:Note)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
					health -= 0.05 * healthLoss;
			});
			for (daNote in unspawnNotes)
			{
				if (daNote.strumTime < songLength - Conductor.safeZoneOffset)
				{
					health -= 0.05 * healthLoss;
				}
			}

			if (doDeathCheck())
				return;
		}

		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;

		deathCounter = 0;
		seenCutscene = false;
		if (achievementObj != null)
			return;
		else
		{
			var achieve:String = checkForAchievement(['ultimate_shitter']);

			if (achieve != null)
			{
				startAchievement(achieve);
				return;
			}
		}

		if (!transitioning)
		{
			SONG.validScore = !cpuControlled && !chartingMode && !recordMode && playbackSpeed == 1.0 && !noFail && healthGain == 1.0 && healthLoss == 1.0
				&& !tauntMode;

			if (SONG.validScore)
			{
				var percent:Float = ratingPercent;
				if (Math.isNaN(percent))
					percent = 0;
				Highscore.saveScore(SONG.song, {
					score: songScore,
					rank: ratingFC,
					misses: songMisses,
					accuracy: percent,
					sicks: sicks,
					goods: goods,
					bads: bads,
					shits: shits,
					comboBreaks: comboBreaks
				});
			}

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += Math.round(songMisses);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music(Main.MainMenuTheme));

					cancelMusicFadeTween();

					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if (!ClientPrefs.getGameplaySetting('practice', false)
						&& !ClientPrefs.getGameplaySetting('botplay', false)
						&& !recordMode)
					{
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							// Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					Funkin.log('LOADING NEXT SONG');
					Funkin.log(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					cancelMusicFadeTween();
					MusicBeatState.switchState(new PlayState());
				}
			}
			else
			{
				Funkin.log('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				MusicBeatState.switchState(new funkin.menus.FreeplayState());

				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	var achievementObj:AchievementNotification = null;

	function startAchievement(achieve:String)
	{
		achievementObj = new AchievementNotification(achieve);
		achievementObj.onFinish = achievementEnd;
		NotificationManager.notify(achievementObj);
		Funkin.log('Giving achievement ' + achieve);
	}

	function achievementEnd():Void
	{
		achievementObj = null;
		if (endingSong && !inCutscene)
			endSong();
	}

	public function KillNotes()
	{
		while (notes.length > 0)
		{
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			if (curStage == 'white')
				pixelShitPart1 = 'lunacyUI/';
			else
				pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);

		for (i in 0...10)
		{
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	var rating:FlxSprite = new FlxSprite();
	var lastTotalHits:Float = 0.00;

	// tryna do MS based judgment due to popular demand
	var daRating:Rating;
	var coolText:LatencyDisplay = null;
	var avgLatencies:Array<Float32> = [];

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs((Conductor.songPosition - note.strumTime) + ClientPrefs.ratingOffset) / playbackSpeed;
		var MS:Float32 = (Conductor.songPosition - note.strumTime) / playbackSpeed;
		avgLatencies.push(MS);
		if (!tauntMode)
			playerVocals.volume = 1;
		else
			playerVocals.volume = 0;
		var placement:String = Std.string(combo);

		rating = new FlxSprite();
		var score:Int = 350;

		// tryna do MS based judgment due to popular demand
		daRating = Conductor.judgeNote(note, noteDiff);
		if (daRating.resetsCombo && !note.ignoreNote && !note.hitCausesMiss)
		{
			note.wasComboBreakHit = true;
			resetCombo();
		}
		else
		{
			combo += 1;
			if (combo > 9999)
				combo = 9999;
		}

		totalNotesHit += daRating.ratingMod;
		lastTotalHits = totalNotesHit;
		note.ratingMod = daRating.ratingMod;
		if (!note.ratingDisabled)
			daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if (daRating.noteSplash && !note.noteSplashDisabled && !recordMode)
		{
			spawnNoteSplashOnNote(note);
		}

		songScore += score;
		if (!note.ratingDisabled)
		{
			songHits++;
			if (!note.hitCausesMiss)
				totalPlayed++;
			RecalculateRating(false);
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			if (curStage == 'white')
				pixelShitPart1 = 'lunacyUI/';
			else
				pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}
		if (!recordMode)
		{
			if (coolText == null)
			{
				coolText = new LatencyDisplay();
				coolText.cameras = [camHUD];
				add(coolText);
				UIData.getAndApplyToSprite('coolText', coolText);
			}
			//	rating.loadGraphic();
			if (!isPixelStage)
				rating.loadGraphicWithAssetQuality(pixelShitPart1 + daRating.image + pixelShitPart2);
			else
				rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));

			rating.cameras = [camHUD];
			rating.screenCenter();
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			//	rating.velocity.x -= FlxG.random.int(0, 10);
			rating.visible = (!ClientPrefs.hideHud && showRating);

			var comboSpr:FlxSprite = new FlxSprite(); // .loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			if (!isPixelStage)
				comboSpr.loadGraphicWithAssetQuality(pixelShitPart1 + 'combo' + pixelShitPart2);
			else
				comboSpr.loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));

			comboSpr.cameras = [camHUD];
			comboSpr.screenCenter();
			comboSpr.acceleration.y = 550;
			comboSpr.velocity.y -= FlxG.random.int(140, 160);
			comboSpr.visible = (!ClientPrefs.hideHud && showCombo);

			comboSpr.y += 70;
			//			comboSpr.velocity.x += FlxG.random.int(0, 5);

			insert(members.indexOf(strumLineNotes), rating);

			if (!PlayState.isPixelStage)
			{
				rating.setGraphicSize(Std.int(rating.width));
				comboSpr.setGraphicSize(Std.int(comboSpr.width));
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.5));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.5));
				rating.antialiasing = false;
				comboSpr.antialiasing = false;
			}
			var oldScaleX = rating.scale.x;
			var oldScaleY = rating.scale.y;
			UIData.getAndApplyToSprite('rating', rating);
			rating.scale.set(oldScaleX * UIData.getData('rating').attributes.scale[0], oldScaleY * UIData.getData('rating').attributes.scale[1]);
			rating.updateHitbox();
			comboSpr.updateHitbox();

			var seperatedScore:Array<Int> = [];

			if (combo >= 1000)
				seperatedScore.push(Math.floor(combo / 1000) % 10);

			seperatedScore.push(Math.floor(combo / 100) % 10);
			seperatedScore.push(Math.floor(combo / 10) % 10);
			seperatedScore.push(combo % 10);

			var daLoop:Int = 0;
			var xThing:Float = 0;
			if (showCombo)
				insert(members.indexOf(strumLineNotes), comboSpr);

			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite();

				if (!isPixelStage)
					numScore.loadGraphicWithAssetQuality(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2);
				else
					numScore.loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));

				numScore.cameras = [camHUD];
				numScore.screenCenter();

				if (PlayState.isPixelStage)
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom * 0.75));
				else
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));

				numScore.antialiasing = !PlayState.isPixelStage;
				numScore.updateHitbox();
				UIData.getAndApplyToSprite('comboNums', numScore);
				numScore.x += (numScore.width * daLoop);
				numScore.acceleration.y = 550;
				numScore.velocity.y -= FlxG.random.int(140, 160);
				// numScore.velocity.x = FlxG.random.float(-5, 5);
				numScore.visible = !ClientPrefs.hideHud;

				if (showComboNum && (combo >= 10 || combo == 0))
					insert(members.indexOf(strumLineNotes), numScore);

				FlxTween.tween(numScore, {alpha: 0}, Conductor.crochet * 0.0005, {
					onComplete: function(tween:FlxTween)
					{
						numScore.graphic = null;
						numScore.destroy();
						remove(numScore, true);
						numScore = null;
					},
					startDelay: Conductor.crochet * 0.001
				});

				daLoop++;
				if (numScore.x > xThing)
					xThing = numScore.x;
			}
			comboSpr.x = xThing + 50;

			var sum:Float32 = 0.00;
			for (ms in avgLatencies)
				sum += ms;

			var highest:Float32 = 0.00;
			for (ms in avgLatencies)
				if (ms > highest)
					highest = ms;

			var lowest:Float32 = 0.00;
			for (ms in avgLatencies)
				if (lowest > ms)
					lowest = ms;

			// thank you https://ourcodeworld.com/articles/read/1470/how-to-find-the-closest-value-to-zero-from-an-array-with-positive-and-negative-numbers-in-javascript
			// for this VVVV
			var closest:Float32 = 0.00;
			for (ms in avgLatencies)
				if (closest == 0)
					closest = ms;
				else if (ms > 0 && ms <= Math.abs(closest))
					closest = ms;
				else if (ms < 0 && -ms < Math.abs(closest))
					closest = ms;

			sum /= avgLatencies.length;
			coolText.showText('${FlxMath.roundDecimal(MS, 2)}ms');
			// + '\nAvg: ${FlxMath.roundDecimal(sum, 2)}ms'
			//		+ '\nL: ${FlxMath.roundDecimal(lowest, 2)}ms\nH: ${FlxMath.roundDecimal(highest, 2)}ms\nC: ${FlxMath.roundDecimal(closest, 2)}';

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					comboSpr.destroy();
					remove(comboSpr, true);
					comboSpr = null;
				},
				startDelay: Conductor.crochet * 0.002
			});
		}
	}

	public var strumsBlocked:Array<Bool> = [];
	public var lastKeyTime:Float = 0.0;

	private function onKeyPress(event:KeyboardEvent):Void
	{
		lastKeyTime = Time.getTimestamp() - lastUpdateTime;
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if (!cpuControlled
			&& startedCountdown
			&& !paused
			&& key > -1
			&& (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if (!boyfriend.stunned && generatedMusic && !endingSong)
			{
				// more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition += lastKeyTime;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				var notesStopped:Bool = false;
				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true
						&& daNote.canBeHit
						&& daNote.mustPress
						&& !daNote.tooLate
						&& !daNote.wasGoodHit
						&& !daNote.isSustainNote
						&& !daNote.blockHit)
					{
						if (daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							// notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0)
				{
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes)
						{
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1)
							{
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							}
							else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped)
						{
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}
					}
				}
				else
				{
					// ghost tap
					if (canMiss)
					{
						noteMissPress(key);
					}
				}

				keysPressed[key] = true;

				// more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if (strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed', true);
				spr.resetAnim = 0;
			}
		}
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		lastKeyTime = Time.getTimestamp() - lastUpdateTime;
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if (!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if (spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	private var missSound:FlxSound;

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if (parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if (parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true
					&& daNote.isSustainNote
					&& parsedHoldArray[daNote.noteData]
					&& daNote.canBeHit
					&& daNote.mustPress
					&& !daNote.tooLate
					&& !daNote.wasGoodHit
					&& !daNote.blockHit)
				{
					goodNoteHit(daNote);
				}
			});

			if (parsedHoldArray.contains(true) && !endingSong)
			{
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null)
					startAchievement(achieve);
			}
			else if (boyfriend.animation.curAnim != null
				&& boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration
				&& boyfriend.animation.curAnim.name.startsWith('sing')
				&& !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				// boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if (ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if (parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if (parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void // You didn't hit the key and let it go offscreen, also used by Hurt Notes
	{
		// Dupe note remove
		notes.forEachAlive(function(note:Note)
		{
			if (daNote != note
				&& daNote.mustPress
				&& daNote.noteData == note.noteData
				&& daNote.isSustainNote == note.isSustainNote
				&& Math.abs(daNote.strumTime - note.strumTime) < 1)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		health -= daNote.missHealth * healthLoss;

		if (daNote.isSustainNote)
		{
			for (daOtherNotes in daNote.parent.tail)
			{
				daOtherNotes.ignoreNote = true;
			}
		}
		else
		{
			resetCombo();
		}

		if (instakillOnMiss)
		{
			opponentVocals.volume = 0;
			playerVocals.volume = 0;

			doDeathCheck(true);
		}
		// For testing purposes
		// Funkin.log(daNote.missHealth);
		songMisses++;
		if (usingDoubleVoices)
			playerVocals.volume = 0;
		else
			opponentVocals.volume = 0;

		songScore -= 10;
		if (!daNote.hitCausesMiss)
			totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if (daNote.gfNote)
			char = gf;

		if (char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;

			char.playAnim(animToPlay, true);
			if (!daNote.isSustainNote)
			{
				if (missSound != null)
					missSound.stop();
				missSound = FlxG.sound.play(Paths.missSound(boyfriend.missSound, 1, boyfriend.missAmount),
					FlxG.random.float(boyfriend.missSoundVolArray[0], boyfriend.missSoundVolArray[1]));
				missSound.pitch = playbackSpeed;
			}
		}
	}

	function resetCombo()
	{
		combo = 0;
		comboBreaks++;
	}

	function noteMissPress(direction:Int = 1):Void // You pressed a key when there was no notes to press for this key
	{
		if (ClientPrefs.ghostTapping)
			return; // cancel doing damage and stuff if ghost tapped

		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if (instakillOnMiss)
			{
				playerVocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
				gf.playAnim('sad');

			resetCombo();

			songScore -= 10;
			if (!endingSong)
				songMisses++;

			totalPlayed++;
			RecalculateRating(true);

			if (missSound != null)
				missSound.stop();

			missSound = FlxG.sound.play(Paths.missSound(boyfriend.missSound, 1, boyfriend.missAmount),
				FlxG.random.float(boyfriend.missSoundVolArray[0], boyfriend.missSoundVolArray[1]));

			if (boyfriend.hasMissAnimations)
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);

			if (usingDoubleVoices)
				playerVocals.volume = 0;
			else
				opponentVocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		healthBar.onOpponentNoteHit(note);
		// SongMods.CoolFunkyCredits.hide();
		if (!note.isSustainNote && cameraType == "opponentNotes")
			cameraZoomBeat();

		camZooming = true;

		if (note.noteType == 'Hey!' && dad.animOffsets.exists('hey'))
		{
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		}
		else if (!note.noAnimation)
		{
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection)
					altAnim = '-alt';

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if (note.gfNote)
				char = gf;

			if (char != null)
			{
				if (!note.isSustainNote)
					char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			opponentVocals.volume = 1;

		var time:Float = 0.11;
		if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
			time += 0.11;

		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		note.hitByOpponent = true;

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
		SongMods.HealthDrain.onOpponentHit();
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit && !note.wasComboBreakHit)
		{
			camZooming = true;
			if (cpuControlled && (note.ignoreNote || note.hitCausesMiss))
				return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled && !recordMode)
			{
				var hitsound = new FlxSound();
				hitsound.loadEmbedded(Paths.hitsound(ClientPrefs.hitsound), false, true);
				hitsound.volume = ClientPrefs.hitsoundVolume;
				hitsound.play();
			}
			healthBar.goodNoteHit(note);

			if (!note.isSustainNote && cameraType == 'playerNotes')
				cameraZoomBeat();

			if (note.hitCausesMiss)
			{
				noteMiss(note);
				if (!note.noteSplashDisabled && !note.isSustainNote)
					spawnNoteSplashOnNote(note);

				if (!note.noMissAnimation)
				{
					switch (note.noteType)
					{
						case 'Hurt Note': // Hurt note
							if (boyfriend.animation.getByName('hurt') != null)
							{
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}
							else
							{
								if (boyfriend.hasMissAnimations)
								{
									boyfriend.playAnim('singRIGHTmiss', true);
									boyfriend.specialAnim = true;
								}
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				popUpScore(note);
			}
			else if (!note.ignoreNote && !note.hitCausesMiss)
			{
				if (note.animation.curAnim.name.endsWith('end'))
					songScore += 100;
				else
					songScore += 10;
				healthBar.updateScore(false);
			}
			// /healthGain = daRating.ratingMod;
			if (!note.ignoreNote)
			{
				health += note.hitHealth * healthGain;
			}
			if (!note.noAnimation)
			{
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if (note.gfNote)
				{
					if (gf != null)
					{
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					if (!note.isSustainNote)
					{
						if (!tauntMode)
							boyfriend.playAnim(animToPlay + note.animSuffix, true);
						else
							taunt();
					}
					boyfriend.holdTimer = 0;
				}

				if (note.noteType == 'Hey!')
				{
					if (boyfriend.animOffsets.exists('hey'))
					{
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if (gf != null && gf.animOffsets.exists('cheer'))
					{
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if (cpuControlled)
			{
				var time:Float = 0.11;
				if (note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
					time += 0.11;

				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			}
			else
			{
				var spr:StrumNote = playerStrums.members[note.noteData];
				if (spr != null)
				{
					spr.playAnim('confirm', true);
					if ((note.isSustainNote && !spr.animation.curAnim.name.endsWith('end')) || (!note.isSustainNote))
					{
						spr.animPlaying = false;
					}
				}
			}
			note.wasGoodHit = true;
			if (!tauntMode)
			{
				if (usingDoubleVoices)
					playerVocals.volume = 1;
				else
					opponentVocals.volume = 1;
			}
			if (!note.isSustainNote && !note.wasComboBreakHit)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function spawnNoteSplashOnNote(note:Note)
	{
		if (ClientPrefs.noteSplashes && note != null)
		{
			if (playerStrums.members[note.noteData] != null)
				spawnNoteSplash(playerStrums.members[note.noteData].x, playerStrums.members[note.noteData].y, note.noteData, note);
		}
	}

	var skin:String = 'noteSplashes';
	var hue:Float32 = 0;
	var sat:Float32 = 0;
	var brt:Float32 = 0;
	var splash:NoteSplash;

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null)
	{
		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		if (data > -1 && data < ClientPrefs.ui.noteHSV.length)
		{
			hue = ClientPrefs.ui.noteHSV[data][0] / 360;
			sat = ClientPrefs.ui.noteHSV[data][1] / 100;
			brt = ClientPrefs.ui.noteHSV[data][2] / 100;
			if (note != null)
			{
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		splash = grpNoteSplashes.recycle(NoteSplash, null, true);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		if (!grpNoteSplashes.members.contains(splash))
			grpNoteSplashes.add(splash);
	}

	override function destroy() // des
	{
		SongEvents.Cinematics.created = false;
		FlxG.animationTimeScale = 1.0;

		for (sprite in frontSprites)
			sprite.destroy();

		frontSprites = [];
		ultimateShitterCheck = [];
		MemUtil.destroyAllSprites(this, true, true);
		FlxG.camera.pixelPerfectRender = false;
		if (!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		instance = null;
		super.destroy();

		MemUtil.clearImageCaches();
	}

	public static function cancelMusicFadeTween()
	{
		if (FlxG.sound.music.fadeTween != null)
			FlxG.sound.music.fadeTween.cancel();

		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;

	public var cameraType:String = "sections";
	public var cameraZoom:Float = 0.03;

	var cameraBeatsOnSteps:Bool = false;
	var cameraBeatsOnBeats:Bool = true;
	var cameraBeatsOnSection:Bool = false;

	public function cameraZoomBeat()
	{
		if (camZooming && FlxG.camera.zoom < defaultCamZoom + 0.25 && ClientPrefs.camZooms)
		{
			FlxG.camera.zoom += 0.03 * camZoomingMult;
			camHUD.zoom += 0.015 * camZoomingMult;
		}
	}

	override function stepHit()
	{
		super.stepHit();
		if (cameraType == "steps")
			cameraZoomBeat();

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(opponentVocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
			resyncVocals();

		if (curStep == lastStepHit)
			return;

		lastStepHit = curStep;
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		healthBar.beatHit();
		if (cameraType == "beats")
			cameraZoomBeat();
		else if (FlxMath.isOdd(curBeat) && cameraType == "beatsOdd")
			cameraZoomBeat();
		else if (FlxMath.isEven(curBeat) && cameraType == "beatsEven")
			cameraZoomBeat();

		if (lastBeatHit >= curBeat)
			return;

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		if (gf != null
			&& curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
			&& gf.animation.curAnim != null
			&& !gf.animation.curAnim.name.startsWith("sing")
			&& !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0
			&& boyfriend.animation.curAnim != null
			&& !boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0
			&& dad.animation.curAnim != null
			&& !dad.animation.curAnim.name.startsWith('sing')
			&& !dad.stunned)
		{
			dad.dance();
		}

		lastBeatHit = curBeat;
	}

	override function sectionHit()
	{
		super.sectionHit();
		if (curSection == 4)
		{
			SongMods.CoolFunkyCredits.hide();
		}
		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
				moveCameraSection();

			if (cameraType == "sections")
				cameraZoomBeat();

			if (SONG.notes[curSection].changeBPM)
				Conductor.changeBPM(SONG.notes[curSection].bpm);
		}
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float)
	{
		var spr:StrumNote = null;
		if (isDad)
			spr = strumLineNotes.members[id];
		else
			spr = playerStrums.members[id];

		if (spr != null)
		{
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String = "??";

	public function RecalculateRating(badHit:Bool = false)
	{
		if (totalPlayed < 1) // Prevent divide by 0
			ratingName = '?';
		else
		{
			ratingPercent = ((sicks + goods) / totalPlayed);
			if (ratingPercent >= 1)
				ratingName = ratingStuff[ratingStuff.length - 1][0]; // Uses last string
			else
			{
				for (i in 0...ratingStuff.length - 1)
					if (ratingPercent < ratingStuff[i][1])
					{
						ratingName = ratingStuff[i][0];
						break;
					}
			}
		}

		// Rating FC
		ratingFC = "??";
		// old ratings, maybe make it into a option? -letsgoaway
		// if (sicks > 0)
		//	ratingFC = "SS";
		// if (goods > 0)
		//	ratingFC = "S";
		// if (bads > 0 || shits > 0)
		//	ratingFC = "A";
		// if (songMisses > 0 && songMisses < 10)
		//	ratingFC = "B";
		// else if (songMisses >= 10)
		//	ratingFC = "C";
		var sickPercent:Float = (sicks + goods) / totalPlayed;
		if (sickPercent == 1)
			ratingFC = "SS";
		else if (sickPercent > 0.97)
			ratingFC = "S";
		else if (sickPercent > 0.85)
			ratingFC = "A";
		else if (sickPercent > 0.70)
			ratingFC = "B";
		else if (sickPercent > 0.60)
			ratingFC = "C";
		else if (sickPercent > 0.50)
			ratingFC = "D";
		else
			ratingFC = "E";
		healthBar.updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
	}

	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if (chartingMode || recordMode)
			return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		if (usedPractice)
		{
			return null;
		}
		for (i in 0...achievesToCheck.length)
		{
			var achievementName:String = achievesToCheck[i];
			if (!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled)
			{
				var unlock:Bool = false;
				switch (achievementName)
				{
					// case 'example':
					// if (criteria){
					//	unlock = true
					// }
					case 'ultimate_shitter':
						if (SONG.song == 'shitread-erect')
						{
							unlock = true;
							for (key in ultimateShitterCheck)
							{
								if (key != FlxKey.S || key != FlxKey.H || key != FlxKey.I || key != FlxKey.T)
								{
									unlock = false;
									break;
								}
							}
						}
					case 'april17date':
						if (SONG.song == 'april17')
							unlock = (Date.now().getDate() == 17 && Date.now().getMonth() == 3);
				}

				if (unlock)
				{
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
}
