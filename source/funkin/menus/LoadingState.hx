package funkin.menus;

import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;
import funkin.gameplay.Character;
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
import funkin.gameplay.SongMods.CoolFunkyCredits;

using funkin.FNK;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	// Browsers will load create(), you can make your song load a custom directory there
	// If you're compiling to desktop (or something that doesn't use NO_PRELOAD_ALL), search for getNextState instead
	// I'd recommend doing it on both actually lol
	// TO DO: Make this easier
	var target:FlxState;

	var loaderCharSprite:FlxSprite;

	public static var loaderChar:String = "mistashitty"; // TODO: temp, add rng

	var coolThing:FlxBackdrop;
	var funkay:FlxSprite;
	var stopMusic = false;
	var directory:String;
	var callbacks:MultiCallback;
	var targetShit:Float = 0;

	public static var songTitle:String = '';

	public var songCreator:String = '';

	function new(target:FlxState, stopMusic:Bool, directory:String)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.directory = directory;
	}

	public static var loadedShared = false;

	override function create()
	{
		MemUtil.clearImageCaches();
		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d);
		add(bg);

		funkay = new FlxSprite(0, 0); // .loadGraphic(Paths.getPath('images/funkay.png', IMAGE));
		funkay.loadGraphicWithAssetQuality('funkay');
		funkay.setGraphicSize(0, FlxG.height);
		funkay.updateHitbox();
		add(funkay);
		funkay.scrollFactor.set();
		funkay.screenCenter();

		loaderCharSprite = new FlxSprite();
		add(loaderCharSprite);
		loaderCharSprite.frames = Paths.getSparrowAtlas('spinnys/' + loaderChar);
		loaderCharSprite.animation.addByPrefix("spin", loaderChar + "_spin", 40);
		loaderCharSprite.scale.set(0.35, 0.35);
		loaderCharSprite.updateHitbox();
		loaderCharSprite.y = 0;
		loaderCharSprite.x = FlxG.width - loaderCharSprite.width;
		loaderCharSprite.animation.play("spin");

		coolThing = new FlxBackdrop();
		coolThing.loadGraphic(Paths.image('coolthing'));
		coolThing.x = 0;
		coolThing.repeatAxes = X;
		add(coolThing);
		coolThing.y = FlxG.height - coolThing.height;
		coolThing.velocity.set(-60, 0);

		initSongsManifest().onComplete(function(lib)
		{
			callbacks = new MultiCallback(onLoad);
			var introComplete = callbacks.add("introComplete");
			checkLibrary("shared");
			loadedShared = true;
			if (directory != null && directory.length > 0 && directory != 'shared')
			{
				checkLibrary(directory);
			}

			var fadeTime = 0.5;
			FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
			new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
		});
		super.create();
	}

	function checkLibrary(library:String)
	{
		Funkin.log(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;

			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function(_)
			{
				callback();
			});
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		songTitle = '';
		songCreator = '';
		MusicBeatState.switchState(target);
	}

	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.song);
	}

	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.song);
	}

	inline static public function loadAndSwitchState(target:FlxState, stopMusic:Bool = false, ?freeplayOverride:Bool = false)
	{
		if (FlxG.sound.music.volume == 0 && target is MainMenuState)
		{
			FlxG.sound.playMusic(Paths.music(Main.MainMenuTheme));
			Conductor.changeBPM(102);
		}

		MusicBeatState.switchState(getNextState(target, stopMusic, freeplayOverride));
	}

	static function getNextState(target:FlxState, stopMusic:Bool = false, ?freeplayOverride:Bool = false):FlxState
	{
		var directory:String = 'shared';
		var weekDir:String = StageData.forceNextDirectory;
		StageData.forceNextDirectory = null;
		if (!freeplayOverride)
		{
			if (weekDir != null && weekDir.length > 0 && weekDir != '') // had to add freeplay override because of memory limits on mobile browsers
				directory = weekDir;
		}
		else
		{
			directory = "shared";
		}
		Paths.setCurrentLevel(directory);
		Funkin.log('Setting asset folder to ' + directory);

		var loaded:Bool = false;
		if (PlayState.SONG != null)
		{
			loaded = isSoundLoaded(getSongPath())
				&& (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath()))
				&& isLibraryLoaded("shared")
				&& isLibraryLoaded(directory);
		}

		if (!loaded)
			return new LoadingState(target, stopMusic, directory);

		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		return target;
	}

	static function isSoundLoaded(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}

	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}

	public override function destroy()
	{
		MemUtil.destroyAllSprites(this);
		super.destroy();

		callbacks = null;
	}

	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
				promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;

	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();

	public function new(callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}

	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;

				if (logId != null)
					log('fired $id, $numRemaining remaining');

				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}

	inline function log(msg):Void
	{
		if (logId != null)
			Funkin.log('$logId: $msg');
	}

	public function getFired()
		return fired.copy();

	public function getUnfired()
		return [for (id in unfired.keys()) id];
}
