package funkin.utils;

import flixel.system.FlxAssets.FlxSoundAsset;
import openfl.Lib;
import openfl.geom.Matrix;
import openfl.utils.Future;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.graphics.atlas.FlxAtlas;
import funkin.animateatlas.AtlasFrameMaker;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.Rectangle;
import flixel.math.FlxRect;
import haxe.xml.Access;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.Json;
import openfl.media.Sound;
import funkin.menus.FreeplayState;

using StringTools;

// fuck this entire file we should rewrite asap its so long for absolutely no reason and i hate it all -letsgoaway
class Paths
{
	inline public static var SOUND_EXT:String = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT:String = "mp4";

	public static function excludeAsset(key:String)
	{
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = ['assets/music/mainMenu.$SOUND_EXT', 'assets/shared/music/default.$SOUND_EXT'];

	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory()
	{
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				// get rid of it
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null && !obj.persist)
				{
					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}
		// run the garbage collector for good measure lmfao
		System.gc();
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];

	public static function clearStoredMemory(?cleanUnused:Bool = false)
	{
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !obj.persist && !currentTrackedAssets.exists(key))
			{
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				// Funkin.log('test: ' + dumpExclusions, key);
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		openfl.Assets.cache.clear("songs");
	}

	static public var currentModDirectory:String = '';
	static public var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared')
			{
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		var returnPath = '$library:assets/$library/$file';
		return returnPath;
	}

	inline public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function ui(key:String, ?library:String)
	{
		return getPath('data/ui/$key.beui', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function video(key:String)
	{
		return 'assets/videos/$key.$VIDEO_EXT';
	}

	static public function sound(key:String, ?library:String):Sound
	{
		var sound:Sound = returnSound('sounds', key, library, !ClientPrefs.lowQualityAudio);
		return sound;
	}

	static public function hitsound(key:String, ?library:String):Sound
	{
		var sound:Sound = returnSound('hitsounds', key, library, true);
		return sound;
	}

	inline static public function missSound(key:String, min:Int, max:Int, ?library:String)
	{
		var sound:Sound = returnSound('misssounds', key + FlxG.random.int(min, max), library, true);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Sound
	{
		var file:Sound = returnSound('music', key, library, !ClientPrefs.lowQualityAudio);
		return file;
	}

	inline static public function preloadMusic(key:String, ?library:String, onComplete:() -> Void):Any
	{
		return preloadSound('music', key, library, !ClientPrefs.lowQualityAudio, onComplete);
	}

	inline static public function gallery(key:String, ?library:String):Null<FlxGraphicAsset>
	{
		return Paths.image('gallery/${key}', library);
	}

	inline static public function gallerySounds(key:String, ?library:String):Sound
	{
		return Paths.sound('gallery/${key}', library);
	}

	inline static public function pathForVoices(song:String, player:Int = -1):String
	{
		var numStr:String = "";
		switch (player)
		{
			case -1:
				numStr = "Voices";
			case 0:
				numStr = "opponentVoices";
			case 1:
				numStr = "playerVoices";
		}
		var songKey:String = '${formatToSongPath(song)}/${numStr}';
		if (ClientPrefs.lowQualityAudio)
			songKey += ".mp3";
		else
			songKey += ".wav";

		return songKey;
	}

	inline static public function pathForInst(song:String):String
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';
		if (ClientPrefs.lowQualityAudio)
			songKey += ".mp3";
		else
			songKey += ".wav";

		return songKey;
	}

	inline static public function voices(song:String, player:Int = -1):Any
	{
		var numStr:String = "";
		switch (player)
		{
			case -1:
				numStr = "Voices";
			case 0:
				numStr = "opponentVoices";
			case 1:
				numStr = "playerVoices";
		}
		var songKey:String = '${formatToSongPath(song)}/${numStr}';
		var voices = returnSound('songs', songKey, null, !ClientPrefs.lowQualityAudio);
		return voices;
	}

	inline static public function preloadVoices(song:String, player:Int = -1, onComplete:() -> Void):Any
	{
		var numStr:String = "";
		switch (player)
		{
			case -1:
				numStr = "Voices";
			case 0:
				numStr = "opponentVoices";
			case 1:
				numStr = "playerVoices";
		}
		var songKey:String = '${formatToSongPath(song)}/${numStr}';
		var voices = preloadSound('songs', songKey, null, !ClientPrefs.lowQualityAudio, onComplete);
		return voices;
	}

	inline static public function inst(song:String):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';

		var inst = returnSound('songs', songKey, null, !ClientPrefs.lowQualityAudio);
		return inst;
	}

	inline static public function preloadInst(song:String, onComplete:() -> Void):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';

		var inst = preloadSound('songs', songKey, null, !ClientPrefs.lowQualityAudio, onComplete);
		return inst;
	}

	public static function resize(source:FlxGraphicAsset, width:Int, height:Int):BitmapData
	{
		var graph:FlxGraphic = FlxG.bitmap.add(source, false, null);
		var scaleX:Float = width / graph.bitmap.width;
		var scaleY:Float = height / graph.bitmap.height;
		var data:BitmapData = new BitmapData(width, height, true);
		var matrix:Matrix = new Matrix();
		matrix.scale(scaleX, scaleY);
		data.draw(graph.bitmap, matrix);
		return data;
	}

	/**
	 * ! DONT USE THIS FOR EVERYTHING !
	 * Only use this for sprites that dont change scale using scale.set as this uses that
	 * @param sprite 
	 * @param source 
	 * @param quality 
	 */
	public static function loadGraphicToSprite(sprite:FlxSprite, path:String, quality:Float = -1)
	{
		if (quality == -1)
			quality = ClientPrefs.assetQuality;

		var ogImageWidth:Int;
		var ogImageHeight:Int;

		var ogSpriteX:Float;
		var ogSpriteY:Float;

		var scaleX:Float;
		var scaleY:Float;

		var data:BitmapData;
		var matrix:Matrix;
		var bitmap:BitmapData;

		var gtrrac:FlxGraphic;
		gtrrac = Paths.image(path);
		bitmap = gtrrac.bitmap;
		if (quality != 1)
		{
			ogImageWidth = bitmap.width + 0;
			ogImageHeight = bitmap.height + 0;
			ogSpriteX = sprite.x;
			ogSpriteY = sprite.y;

			scaleX = (ogImageWidth * quality) / bitmap.width;
			scaleY = (ogImageHeight * quality) / bitmap.height;
			data = new BitmapData(Std.int((bitmap.width * quality)), Std.int((bitmap.height * quality)), true, 0x00FFFFFF);
			matrix = new Matrix();

			matrix.scale(scaleX, scaleY);
			data.draw(bitmap, matrix);

			sprite.loadGraphic(data);
			sprite.setGraphicSize(ogImageWidth, ogImageHeight);
			sprite.updateHitbox();
			sprite.setPosition(ogSpriteX, ogSpriteY);
		}
		else
			sprite.loadGraphic(bitmap);
	}

	inline static public function image(key:String, ?library:String):Null<FlxGraphicAsset>
	{
		var returnAsset:FlxGraphicAsset;
		// streamlined the assets process more
		returnAsset = returnGraphic(key, library);
		return returnAsset;
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if sys
		if (FileSystem.exists(getPreloadPath(key)))
			return File.getContent(getPreloadPath(key));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared')
			{
				levelPath = getLibraryPathForce(key, currentLevel);
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}

			levelPath = getLibraryPathForce(key, 'shared');
			if (FileSystem.exists(levelPath))
				return File.getContent(levelPath);
		}
		#end
		return Assets.getText(getPath(key, TEXT));
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		if (OpenFlAssets.exists(getPath(key, type)))
			return true;

		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		// streamlined the assets process more
		var frames:FlxAtlasFrames;
		frames = FlxAtlasFrames.fromSparrow(returnGraphic(key, library), file('images/$key.xml', library));
		return frames;
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		var frames:FlxAtlasFrames;
		frames = FlxAtlasFrames.fromSpriteSheetPacker(returnGraphic(key, library), file('images/$key.txt', library));
		return frames;
	}

	inline static public function formatToSongPath(path:String)
	{
		return path.toLowerCase()
			.replace(' ', '-')
			.replace('.', '')
			.replace('?', '')
			.replace('!', '')
			.replace('\\', '')
			.replace('/', '')
			.replace('(', '')
			.replace(')', '');
	}

	// completely rewritten asset loading? fuck!
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];

	public static function returnGraphic(key:String, ?library:String):Null<FlxGraphic>
	{
		var path = getPath('images/$key.png', IMAGE, library);
		// Funkin.log(path);
		if (OpenFlAssets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
			{
				var newGraphic:FlxGraphic = FlxG.bitmap.add(path, false, path);
				newGraphic.persist = true;
				currentTrackedAssets.set(path, newGraphic);
			}
			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}
		Funkin.log('oh no its returning null NOOOO');
		return null;
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function returnSound(path:String, key:String, ?library:String, ?useWAV:Bool = false):FlxSoundAsset
	{
		if (ClientPrefs.lowQualityAudio)
		{
			#if (html5 || mobile)
			if (!useWAV)
			{
				key += '-lq';
			}
			#end
		}
		// I hate this so god damn much
		var gottenPath:String = '';
		if (!useWAV)
			gottenPath = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		else
			gottenPath = getPath('$path/$key.wav', SOUND, library);

		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// Funkin.log(gottenPath);
		if (!currentTrackedSounds.exists(gottenPath) #if sys && FileSystem.exists(gottenPath) #end)
			#if sys
			currentTrackedSounds.set(gottenPath, Sound.fromFile(gottenPath));
			#else
			{
				var folder:String = '';
				if (path == 'songs')
					folder = 'songs:';
				try
				{
					#if !html5
					if (!useWAV)
						currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library), false));
					else
						currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.wav', SOUND, library), false));
					#else
					if (!useWAV)
					{
						OpenFlAssets.loadSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library), true)
							.onComplete((sound) -> currentTrackedSounds.set(gottenPath, sound));
					}
					else
					{
						OpenFlAssets.loadSound(folder + getPath('$path/$key.wav', SOUND, library), true)
							.onComplete((sound) -> currentTrackedSounds.set(gottenPath, sound));
					}
					#end
				}
				catch (e)
				{
					Funkin.log(e);
					return null;
				}
			}
			#end
		localTrackedAssets.push(gottenPath);

		return currentTrackedSounds.get(gottenPath);
	}

	public static function preloadSound(path:String, key:String, ?library:String, ?useWAV:Bool = false, onComplete:() -> Void):FlxSoundAsset
	{
		if (ClientPrefs.lowQualityAudio)
		{
			#if (html5 || mobile)
			if (!useWAV)
			{
				key += '-lq';
			}
			#end
		}
		// I hate this so god damn much
		var gottenPath:String = '';
		if (!useWAV)
			gottenPath = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		else
			gottenPath = getPath('$path/$key.wav', SOUND, library);

		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// Funkin.log(gottenPath);
		if (!currentTrackedSounds.exists(gottenPath) #if sys && FileSystem.exists(gottenPath) #end)
			#if sys
			currentTrackedSounds.set(gottenPath, Sound.fromFile(gottenPath));
			onComplete();
			#else
			{
				var folder:String = '';
				if (path == 'songs')
					folder = 'songs:';
				try
				{
					#if !html5
					if (!useWAV)
						currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library), false));
					else
						currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.wav', SOUND, library), false));
					onComplete();
					#else
					// what even the fuck anymore
					if (!useWAV)
					{
						OpenFlAssets.loadSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library), true).onComplete((sound) ->
						{
							currentTrackedSounds.set(gottenPath, sound);
							onComplete();
						}).onError((_) ->
							{
								onComplete();
							});
						return null;
					}
					else
					{
						OpenFlAssets.loadSound(folder + getPath('$path/$key.wav', SOUND, library), true).onComplete((sound) ->
						{
							currentTrackedSounds.set(gottenPath, sound);
							onComplete();
						}).onError((_) ->
							{
								onComplete();
							});
						return null;
					}
					#end
				}
				catch (e)
				{
					Funkin.log(e);
					onComplete();
					return null;
				}
			}
			#end
		localTrackedAssets.push(gottenPath);
		onComplete();
		return currentTrackedSounds.get(gottenPath);
	}
}
