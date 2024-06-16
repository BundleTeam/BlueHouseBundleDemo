package funkin.user;

import funkin.editors.ui.BEUIFormat;
import funkin.utils.CoolUtil;
import funkin.editors.ui.UIData;
import openfl.filters.BitmapFilterQuality;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import funkin.system.input.Controls;
import funkin.menus.TitleState;
import funkin.system.achievements.*;

class ClientPrefs
{
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var opponentStrums:Bool = true;
	public static var showFPS:Bool = true;
	public static var showMEM:Bool = true;
	public static var fullscreenMode:String = 'Windowed';
	public static var flashing:Null<Bool> = null;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var assetQuality:Float = 1;
	public static var framerate:Int32 = 999;
	public static var vsync:Bool = false;

	public static var saturation:Float = 1.0;
	public static var vibrance:Float = 1.0;
	public static var brightness:Float = 1.0;
	public static var contrast:Float = 1.0;

	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var lowQualityAudio:Bool = false;
	public static var noteOffset:Int = 0;
	public static var ghostTapping:Bool = true;
	public static var noReset:Bool = false;
	public static var healthBarAlpha:Float = 1;
	public static var controllerMode:Bool = false;
	public static var hitsoundVolume:Float = 0;
	public static var hitsound:String = 'default';
	public static var pauseMusic:String = 'Default';
	public static var checkForUpdates:Bool = true;
	// TODO AFTER DEMO: move same named related variables into ui eg downscroll
	public static var ui:BEUIFormat = {
		elements: [
			{
				x: 444,
				type: "timeBar",
				attributes: {
					rotation: 0,
					scale: [1, 1],
					opacity: 1
				},
				y: 684
			},
			{
				x: 343.5,
				type: "healthBar",
				attributes: {
					rotation: 0,
					scale: [1, 1],
					opacity: 1
				},
				y: 644.8
			},
			{
				type: "rating",
				x: 525,
				y: 300,
				attributes: {
					scale: [1, 1],
					rotation: 0,
					opacity: 1
				}
			},
			{
				type: "comboNums",
				x: 645,
				y: 420,
				attributes: {
					opacity: 1
				}
			},
			{
				attributes: {
					opacity: 1,
					rotation: 0,
					scale: [1, 1]
				},
				x: 471,
				y: 85,
				type: "coolText"
			}
		],
		downScroll: false,
		scoreTextZoom: true,
		useClassicHealthbar: false,
		timeBarType: "Time Left",
		opponentStrums: true,
		useClassicArrows: false,
		noteHSV: [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]],
		classicStrumline: false,
		middleScroll: false,
		hideHealthIcons: false
	};
	public static var ratingOffset:Int = 0;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var safeFrames:Float = 10;
	// Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_up' => [W, UP],
		'note_right' => [D, RIGHT],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_up' => [W, UP],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R, NONE],
		'volume_mute' => [ZERO, NONE],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
		'debug_1' => [SEVEN, NONE],
		'debug_2' => [EIGHT, NONE],
		'taunt' => [T, SPACE],
	];
	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative',
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys()
	{
		defaultKeys = keyBinds.copy();
	}

	private static var settings:FlxSave;
	private static var controlsSave:FlxSave;

	public static function saveSettings()
	{
		settings.data.downScroll = downScroll;
		settings.data.middleScroll = middleScroll;
		settings.data.opponentStrums = opponentStrums;
		settings.data.showFPS = showFPS;
		settings.data.showMEM = showMEM;
		settings.data.fullscreenMode = fullscreenMode;
		settings.data.flashing = flashing;
		settings.data.globalAntialiasing = globalAntialiasing;
		settings.data.noteSplashes = noteSplashes;
		settings.data.lowQuality = lowQuality;
		settings.data.assetQuality = assetQuality;
		settings.data.framerate = framerate;
		settings.data.vsync = vsync;

		settings.data.saturation = saturation;
		settings.data.vibrance = vibrance;
		settings.data.brightness = brightness;
		settings.data.contrast = contrast;

		settings.data.lowQualityAudio = lowQualityAudio;
		settings.data.camZooms = camZooms;
		settings.data.noteOffset = noteOffset;
		settings.data.hideHud = hideHud;
		settings.data.ghostTapping = ghostTapping;
		settings.data.noReset = noReset;
		settings.data.healthBarAlpha = healthBarAlpha;
		settings.data.ratingOffset = ratingOffset;
		settings.data.sickWindow = sickWindow;
		settings.data.goodWindow = goodWindow;
		settings.data.badWindow = badWindow;
		settings.data.safeFrames = safeFrames;
		settings.data.gameplaySettings = gameplaySettings;
		settings.data.ui = ui;
		settings.data.controllerMode = controllerMode;
		settings.data.hitsoundVolume = hitsoundVolume;
		settings.data.hitsound = hitsound;
		settings.data.pauseMusic = pauseMusic;
		settings.data.checkForUpdates = checkForUpdates;
		settings.flush();

		controlsSave = new FlxSave();
		controlsSave.bind('controls',
			CoolUtil.getSavePath()); // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		controlsSave.data.customControls = keyBinds;
		controlsSave.flush();

		FlxG.save.data.achievementsMap = Achievements.achievementsMap;
		FlxG.save.data.achievementsProgress = Achievements.achievementsProgress;

		FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
		FlxG.save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs()
	{
		FlxG.save.bind("BHBDemo", CoolUtil.getSavePath());
		Achievements.loadAchievements();
		settings = new FlxSave();
		settings.bind("settings", CoolUtil.getSavePath());

		if (settings.data.lowQualityAudio != null)
			lowQualityAudio = settings.data.lowQualityAudio;

		if (settings.data.fullscreenMode != null)
			fullscreenMode = settings.data.fullscreenMode;

		if (settings.data.downScroll != null)
			downScroll = settings.data.downScroll;

		if (settings.data.middleScroll != null)
			middleScroll = settings.data.middleScroll;

		if (settings.data.opponentStrums != null)
			opponentStrums = settings.data.opponentStrums;

		if (settings.data.showFPS != null)
			showFPS = settings.data.showFPS;

		if (settings.data.showMEM != null)
			showMEM = settings.data.showMEM;

		if (settings.data.flashing != null)
			flashing = settings.data.flashing;

		if (settings.data.globalAntialiasing != null)
			globalAntialiasing = settings.data.globalAntialiasing;

		if (settings.data.noteSplashes != null)
			noteSplashes = settings.data.noteSplashes;

		if (settings.data.lowQuality != null)
			lowQuality = settings.data.lowQuality;

		if (settings.data.assetQuality != null)
			assetQuality = settings.data.assetQuality;

		if (settings.data.framerate != null)
		{
			framerate = settings.data.framerate;
			if (framerate > FlxG.drawFramerate)
			{
				FlxG.updateFramerate = 1000;
				FlxG.drawFramerate = framerate;
			}
			else
			{
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = 1000;
			}
		}

		if (settings.data.vsync != null)
			vsync = settings.data.vsync;

		if (settings.data.saturation != null)
			saturation = settings.data.saturation;

		if (settings.data.vibrance != null)
			vibrance = settings.data.vibrance;

		if (settings.data.brightness != null)
			brightness = settings.data.brightness;

		if (settings.data.contrast != null)
			contrast = settings.data.contrast;

		if (settings.data.camZooms != null)
			camZooms = settings.data.camZooms;

		if (settings.data.hideHud != null)
			hideHud = settings.data.hideHud;

		if (settings.data.noteOffset != null)
			noteOffset = settings.data.noteOffset;

		if (settings.data.ghostTapping != null)
			ghostTapping = settings.data.ghostTapping;

		if (settings.data.noReset != null)
			noReset = settings.data.noReset;

		if (settings.data.healthBarAlpha != null)
			healthBarAlpha = settings.data.healthBarAlpha;

		if (settings.data.ui != null)
		{
			if ((Std.isOfType(settings.data.ui, Array)) || Reflect.hasField(settings.data.ui, "ui"))
				settings.data.ui = ui;
			ui = settings.data.ui;
		}

		if (settings.data.ratingOffset != null)
			ratingOffset = settings.data.ratingOffset;

		if (settings.data.sickWindow != null)
			sickWindow = settings.data.sickWindow;

		if (settings.data.goodWindow != null)
			goodWindow = settings.data.goodWindow;

		if (settings.data.badWindow != null)
			badWindow = settings.data.badWindow;

		if (settings.data.safeFrames != null)
			safeFrames = settings.data.safeFrames;

		if (settings.data.controllerMode != null)
			controllerMode = settings.data.controllerMode;

		if (settings.data.hitsoundVolume != null)
			hitsoundVolume = settings.data.hitsoundVolume;

		if (settings.data.hitsoundVolume != null)
			hitsound = settings.data.hitsound;

		if (settings.data.pauseMusic != null)
			pauseMusic = settings.data.pauseMusic;

		if (settings.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = settings.data.gameplaySettings;
			for (name => value in savedMap)
				gameplaySettings.set(name, value);
		}

		// flixel automatically saves your volume!
		if (settings.data.volume != null)
			FlxG.sound.volume = settings.data.volume;

		if (settings.data.mute != null)
			FlxG.sound.muted = settings.data.mute;

		if (settings.data.checkForUpdates != null)
			checkForUpdates = settings.data.checkForUpdates;

		controlsSave = new FlxSave();
		controlsSave.bind('controls', CoolUtil.getSavePath());
		controlsSave.mergeDataFrom('controls_v2', 'ninjamuffin99', false, false);
		if (controlsSave != null && controlsSave.data.customControls != null)
		{
			var loadedControls:Map<String, Array<FlxKey>> = controlsSave.data.customControls;

			for (control => keys in loadedControls)
				keyBinds.set(control, keys);

			reloadControls();
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic
	{
		return /*PlayState.isStoryMode ? defaultValue : */ (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadControls()
	{
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);
		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
