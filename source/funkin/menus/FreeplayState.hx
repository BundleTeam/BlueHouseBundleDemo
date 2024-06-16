package funkin.menus;

import funkin.fx.shaders.BrightnessContrastShader;
import funkin.fx.shaders.SaturationVibranceShader;
import funkin.user.SongScore;
import funkin.user.Highscore;
import lime.math.Vector2;
import flixel.util.FlxTimer;
import flixel.math.FlxRandom;
import openfl.filesystem.File;
import funkin.utils.FlxSVGSprite;
import funkin.system.achievements.Achievements;
import funkin.editors.ChartingState;
import funkin.editors.MasterEditorMenu;
import funkin.music.WeekData;
import funkin.music.Song;
import funkin.gameplay.SongMods.CameraFollow;
import funkin.utils.MemUtil;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxPointer;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouse;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.Json;
import lime.app.Application;
import lime.app.Event;
import lime.graphics.RenderContext;
import lime.net.curl.CURLMultiMessage;
import lime.ui.Window;
import lime.utils.AssetType;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.filters.GlowFilter;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import funkin.fx.shaders.LD_Vaporwave;
import funkin.fx.shaders.Vaporwave;
import funkin.fx.shaders.shadertoy.FlxShaderToyHack;

using StringTools;

#if (cpp && desktop)
import funkin.system.Discord;
#end

class ListFP extends FlxObject
{
	public var items:Array<ListItem> = [];
	public var cam:FlxCamera = new FlxCamera();
	public var selectedID:UInt8 = 0;

	public function add(item:ListItem)
	{
		item.cameras = [cam];
		items.push(item);
	}

	public function new()
	{
		super();
	
	}

	public function checkPreview():Void
	{				
		if (FreeplayState.currentList == 'story')
			FreeplayState.currentlySelectedSong = FreeplayState.storyModeSongs[this.selectedID];
		else if (FreeplayState.currentList == 'freeplay')
			FreeplayState.currentlySelectedSong = FreeplayState.freePlaySongs[this.selectedID];
		else if (FreeplayState.currentList == 'covers')
			FreeplayState.currentlySelectedSong = FreeplayState.coversSongs[this.selectedID];
		FreeplayState.albumArtDisplay.loadPreviewGraphic(FreeplayState.currentlySelectedSong);
		FreeplayState.erectMode = FreeplayState.currentlySelectedSong.contains("-erect") || FreeplayState.currentlySelectedSong.contains("-megamix");	
		
		var score:SongScore = Highscore.getScore(FreeplayState.currentlySelectedSong);
		var nonErectName:String = FreeplayState.currentlySelectedSong.replace("-erect", "").replace("-megamix", "");
		var nonErectScore:SongScore = Highscore.getScore(nonErectName);
		if (!FreeplayState.erectMode && score.rank == "?")
		{
			FreeplayState.highscoreTextAndStuff.text = "Unplayed";
		}
		else if (FreeplayState.erectMode && nonErectScore.rank == "?"){
			FreeplayState.highscoreTextAndStuff.text = "You must complete the normal song\nbefore unlocking the Erect Difficulty.";
		}
		else if (FreeplayState.erectMode && score.rank == "?"){
			FreeplayState.highscoreTextAndStuff.text = "Unplayed";
		}
		else
		{
			FreeplayState.highscoreTextAndStuff.text = 'Score: ${score.score}\n'
				+ 'Rank: ${score.rank}\n'
				+ 'Accuracy: ${Highscore.floorDecimal(score.accuracy * 100, 2)}%\n'
				+ 'Combo Breaks: ${score.comboBreaks}\n'
				+ 'Fire Hits: ${score.sicks}\n'
				+ 'Based Hits: ${score.goods}\n'
				+ 'Stinky Hits: ${score.bads}\n'
				+ 'Yeowch Hits: ${score.shits}\n'
				+ 'Misses: ${score.misses}\n';
		}

		/*
			+ "Times Played: ###\n"
			+ "Times Died: ###\n";
		 */
		FreeplayState.highscoreTextAndStuff.screenCenter(Y);
	}

	public function upArrowPressed():Void
	{
		if (selectedID != 0)
			selectedID--;
		else
			selectedID = items.length - 1;
		checkPreview();
	}

	public function downArrowPressed():Void
	{
		selectedID++;
		selectedID = selectedID % items.length;
		checkPreview();
	}

	public override function update(elapsed:Float):Void
	{
		if (items.length != 0)
		{
			for (item in items)
			{
				if (items.indexOf(item) == selectedID)
					item.isSelected = true;
				else
					item.isSelected = false;
			}
		}

		super.update(elapsed);
	}
}

class ListItem extends FlxSpriteGroup
{
	public var text:Alphabet = new Alphabet(0, 0, "", false, false, 99999, 1,true);
	public var songName:String = "";
	public var songData:Dynamic;
	public var list:ListFP;
	public var isSelected:Null<Bool> = false;

	public function new(x:Float, y:Float, songName:String, list:ListFP)
	{
		super(x, y);
		this.list = list;

		if (!Paths.fileExists('data/${songName}/metadata.json', TEXT))
		{
			var songTitle = songName.toLowerCase();
			var titleFirstChar = songTitle.charAt(0).toUpperCase();
			songTitle = titleFirstChar + songTitle.substring(1);
			text.changeText(songTitle);
		}
		else
		{
			this.songData = Json.parse(Song.getJson('metadata', songName));
			text.changeText(songData.title);
		}
		text.x = this.x;
		text.screenCenter(X);

		text.y = this.y;
		alpha = 0.5;
		list.add(this);
		this.add(text);
		this.y = 90 * (list.items.indexOf(this));
	}

	public override function update(elapsed:Float)
	{
		text.y = this.y;
		this.y = 90 * (list.items.indexOf(this));
		if (this.isSelected)
		{
			text.alpha = 1;
		}
		else
		{
			text.alpha = 0.5;
		}
		super.update(elapsed);
	}

	public override function destroy()
	{
		if (text != null) // it trys to destroy again on state close no idea why
		{
			text.destroy();
		}

		songData = null;
		isSelected = null;
		super.destroy();
	}
}

class FreeplayState extends MusicBeatState
{
	public function addSpr(sprite:FlxSprite)
	{
		add(sprite);
	}

	public var musicParticleArray:Array<MusicParticle>;

	public static var erectMode = false;
	public static var currentList:String = 'freeplay'; // list to start on
	public static var instance:FreeplayState;
	public static var listOrderText:Array<String> = ['story', 'freeplay', 'covers', 'gallery'];
	// probably a better way todo these
	public static var storyModeSongs:Array<String> = [];
	public static var freePlaySongs:Array<String> = [];
	public static var coversSongs:Array<String> = [];

	public var list:ListFP = new ListFP();

	public static var songData:Dynamic;
	public static var currentlySelectedSong:String = 'gameing';

	var currentListID:UInt8 = 0;
	var currentListChooser:FlxTypedSpriteGroup<FlxSprite>;
	var currentListChooser_leftArrow:FlxSprite;
	var currentListChooser_currentList:FlxSprite;
	var currentListChooser_rightArrow:FlxSprite;
	var bg:FlxSprite;
	var vaporBG:FlxShaderToyHack;
	var modsTab:FreeplayModsSubState;

	var moreSoonText:FlxText;
	public static var albumArtDisplay:AlbumArtDisplay;

	public static var gameingbugfix:Bool = false;



	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, list:EnumValue):Void
	{
	}

	public function loadSongs():Void
	{
		var freeplaySongs:Dynamic = Json.parse(Assets.getText(Paths.json('freeplaySongs')));
		storyModeSongs = freeplaySongs.story;
		freePlaySongs = freeplaySongs.freeplay;
		coversSongs = freeplaySongs.covers;

		for (item in list.items)
		{
			item.destroy();
		}
		list.items = [];
		if (listOrderText[currentListID] == "story")
		{
			for (songName in storyModeSongs)
			{
				add(new ListItem(15, 0, songName, list));
			}
		}
		else if (listOrderText[currentListID] == "freeplay")
		{
			for (songName in freePlaySongs)
			{
				add(new ListItem(15, 0, songName, list));
			}
		}
		else if (listOrderText[currentListID] == "covers")
		{
			for (songName in coversSongs)
			{
				add(new ListItem(15, 0, songName, list));
			}
		}
	}

	public static function destroyFreeplayVocals():Void
	{
	}

	function leftArrowPressed()
	{
		if (currentListID == 0)
		{
			currentListID = listOrderText.length - 1;
		}
		else
		{
			currentListID--;
		}
		list.selectedID = 0;
		currentList = listOrderText[currentListID];
		if (currentList == 'story')
			currentlySelectedSong = storyModeSongs[list.selectedID];
		else if (currentList == 'freeplay')
			currentlySelectedSong = freePlaySongs[list.selectedID];
		else if (currentList == 'covers')
			currentlySelectedSong = coversSongs[list.selectedID]; 
		triggerListChooser();
		loadSongs();
		list.checkPreview();
	}

	function rightArrowPressed()
	{
		currentListID++;
		currentListID = currentListID % listOrderText.length;
		list.selectedID = 0;
		currentList = listOrderText[currentListID];
		if (currentList == 'story')
			currentlySelectedSong = storyModeSongs[list.selectedID];
		else if (currentList == 'freeplay')
			currentlySelectedSong = freePlaySongs[list.selectedID];
		else if (currentList == 'covers')
			currentlySelectedSong = coversSongs[list.selectedID];
		triggerListChooser();
		loadSongs();
		list.checkPreview();
	}

	function triggerListChooser()
	{
		currentListChooser_currentList.frames = Paths.getSparrowAtlas('freeplay/' + listOrderText[currentListID]);
		currentListChooser_currentList.animation.addByPrefix('idle', 'idle', 24, true);
		currentListChooser_currentList.animation.play('idle');
	}

	var bgCamera:FlxCamera = new FlxCamera();

	public static var highscoreTextAndStuff:FlxText;

	var hudCamera:FlxCamera = new FlxCamera();

	private var nicebonieCouch:FlxSprite;
	private var shitCooking:FlxSprite;
	private var fireassTable:FlxSprite;
	private var megafunAwesom:FlxSprite;
	private var sillyBushes:FlxSprite;
	private var curtains:FlxSprite;

	private var border:FlxSprite;
	private var border2:FlxSprite;

	override function create()
	{
		CameraFollow.usedInLevel = false;
		currentlySelectedSong = 'gameing';
		gameingbugfix = false;
		instance = this;
		if (ClientPrefs.lowQuality)
			vaporBG = new LD_Vaporwave();
		else
			vaporBG = new Vaporwave();

		add(list);
		persistentUpdate = false;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);
		FlxG.cameras.add(bgCamera, false);
		FlxG.cameras.add(list.cam, false);
		FlxG.cameras.add(hudCamera, true);
		FlxG.cameras.setDefaultDrawTarget(hudCamera, true);
		MemUtil.clearImageCaches();
		bg = new FlxSprite(); // .loadGraphic(Paths.image('freeplay/mapFP'));
		bg.loadGraphicWithAssetQuality('freeplay/mapFP');
		bg.setGraphicSize(5334, 0);
		bg.updateHitbox();
		add(bg);
		bg.y = -12;
		bg.cameras = [bgCamera]; // lool

		nicebonieCouch = new FlxSprite();
		nicebonieCouch.frames = Paths.getSparrowAtlas('freeplay/nicebonsitfreeplay');
		add(nicebonieCouch);
		nicebonieCouch.cameras = [bgCamera];
		nicebonieCouch.animation.addByPrefix('idle', 'nicebonie setting', 30, true);
		nicebonieCouch.animation.play('idle');
		nicebonieCouch.setGraphicSize(567, 0);
		nicebonieCouch.updateHitbox();
		nicebonieCouch.setPosition(111, 290);

		shitCooking = new FlxSprite();
		shitCooking.frames = Paths.getSparrowAtlas('freeplay/shatteredfreeplay');
		add(shitCooking);
		shitCooking.cameras = [bgCamera];
		shitCooking.animation.addByPrefix('idle', 'shattered kitchen', 30, true);
		shitCooking.animation.play('idle');
		shitCooking.setGraphicSize(385, 0);
		shitCooking.updateHitbox();
		shitCooking.setPosition(1546, 223);

		fireassTable = new FlxSprite();
		fireassTable.loadGraphic(Paths.image('freeplay/frontcounterfreeplay'));
		add(fireassTable);
		fireassTable.cameras = [bgCamera];
		fireassTable.setGraphicSize(1229, 0);
		fireassTable.updateHitbox();
		fireassTable.setPosition(1262, 422);

		megafunAwesom = new FlxSprite();
		megafunAwesom.frames = Paths.getSparrowAtlas('freeplay/megafunfreeplay');
		add(megafunAwesom);
		megafunAwesom.cameras = [bgCamera];
		megafunAwesom.animation.addByPrefix('idle', 'megafunhi', 30, true);
		megafunAwesom.animation.play('idle');
		megafunAwesom.setGraphicSize(537, 0);
		megafunAwesom.updateHitbox();
		megafunAwesom.setPosition(2948, 175);

		sillyBushes = new FlxSprite();
		sillyBushes.loadGraphic(Paths.image('freeplay/bushfreeplay'));
		add(sillyBushes);
		sillyBushes.cameras = [bgCamera];
		sillyBushes.setGraphicSize(1156, 0);
		sillyBushes.updateHitbox();
		sillyBushes.setPosition(2749, 560);

		curtains = new FlxSprite();
		curtains.loadGraphic(Paths.image('freeplay/curtain'));
		add(curtains);
		curtains.cameras = [bgCamera];
		curtains.setGraphicSize(1319);
		curtains.updateHitbox();
		curtains.setPosition(4093, -12);

		hudCamera.bgColor = FlxColor.TRANSPARENT;
		list.cam.bgColor = FlxColor.TRANSPARENT;
		list.cam.height = 1920;

		border = new FlxSprite();
		border.loadGraphic(Paths.image('freeplay/border'));
		add(border);
		border.setGraphicSize(FlxG.width, FlxG.height);
		border.updateHitbox();
		border.setPosition(0, 0);

		border2 = new FlxSprite();
		border2.loadGraphic(Paths.image('freeplay/border2'));
		add(border2);
		border2.setGraphicSize(FlxG.width);
		border2.updateHitbox();
		border2.setPosition(0, 0);

		highscoreTextAndStuff = new FlxText(35, 0, 0, "", 16);
		highscoreTextAndStuff.text = "Score: ######\n" + "Accuracy: ##.##%\n" + "Rank: ZZ\n" + "Times Played: ###\n" + "Times Died: ###\n";
		highscoreTextAndStuff.screenCenter(Y);
		add(highscoreTextAndStuff);

		musicParticleArray = [];
		var particleAmount:Int = 10;
		if (ClientPrefs.lowQuality)
		{
			particleAmount = 3;
		}
		for (i in 0...particleAmount)
		{
			musicParticleArray.push(new MusicParticle());
		}
		for (particle in musicParticleArray)
		{
			add(particle);
		}

		albumArtDisplay = new AlbumArtDisplay();
		albumArtDisplay.screenCenter(Y);
		albumArtDisplay.x = (FlxG.width - 197) - 50;
		add(albumArtDisplay);
		albumArtDisplay.create();

		currentListChooser = new FlxTypedSpriteGroup<FlxSprite>(3);
		currentListChooser_leftArrow = new FlxSprite().loadGraphic(Paths.image('selectArrow'));
		currentListChooser.add(currentListChooser_leftArrow);

		currentListChooser_currentList = new FlxSprite();
		currentList = listOrderText[currentListID];
		currentListChooser_currentList.frames = Paths.getSparrowAtlas('freeplay/' + listOrderText[currentListID]);
		currentListChooser_currentList.animation.addByPrefix('idle', 'idle', 30, true);
		currentListChooser_currentList.x += currentListChooser_leftArrow.x + currentListChooser_leftArrow.width;
		currentListChooser_currentList.offset.x -= 15;
		currentListChooser.add(currentListChooser_currentList);

		currentListChooser_rightArrow = new FlxSprite().loadGraphic(Paths.image('selectArrow'));
		currentListChooser_rightArrow.flipX = true;
		currentListChooser_rightArrow.x = currentListChooser_currentList.x + currentListChooser_currentList.frameWidth + 25;
		currentListChooser.add(currentListChooser_rightArrow);

		currentListChooser.screenCenter(X);
		currentListChooser.y += 15;
		add(currentListChooser);
		currentListChooser_currentList.animation.play('idle');


		FlxG.watch.add(this, 'currentList');
		FlxG.watch.add(this, 'currentListID');
		FlxG.watch.add(this, 'currentlySelectedSong');
		loadSongs();
		moreSoonText = new FlxText().setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		moreSoonText.fieldWidth = FlxG.width;
		moreSoonText.text = "More songs coming soon!";
		moreSoonText.cameras = [list.cam];
		add(moreSoonText);

		for (particle in musicParticleArray)
		{
			particle.emit();
		}
		list.checkPreview();
		super.create();
	}

	override function beatHit()
	{
		super.beatHit();
		Conductor.changeBPM(haxe.Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json')).bpm);
	}

	function createFilterFrames(sprite:FlxSprite, filter:BitmapFilter)
	{
		var filterFrames = FlxFilterFrames.fromFrames(sprite.frames, 0, 0, [filter]);
		updateFilter(sprite, filterFrames);
		return filterFrames;
	}

	function updateFilter(spr:FlxSprite, sprFilter:FlxFilterFrames)
	{
		sprFilter.applyToSprite(spr, false, true);
	}

	private var cameraTween:FlxTween;

	override function update(elapsed:Float)
	{
		albumArtDisplay.previewSprite.screenCenter(Y);
		albumArtDisplay.previewSprite.x = (FlxG.width - albumArtDisplay.previewSprite.width) - 50;
		albumArtDisplay.visible = currentList != 'gallery';
		for (particle in musicParticleArray)
		{
			particle.visible = currentList != 'gallery';
		}
		albumArtDisplay.locked = highscoreTextAndStuff.text.contains("You must complete");
		if (list.items.length != 0) {
			moreSoonText.screenCenter(X);
			moreSoonText.x += 27.5;
			moreSoonText.y = list.items[list.items.length-1].y + 300;
		}
		highscoreTextAndStuff.visible = albumArtDisplay.visible;
		if (currentList != 'gallery')
		{
			songData = list.items[list.selectedID].songData;
		}
		bgCamera.bgColor = 0xFF240024;
		list.cam.y = -(90 * (list.selectedID + 1));
		list.cam.y += FlxG.height / 2;
		hudCamera.bgColor = 0x30000000;
		currentListChooser.screenCenter(X);
		list.cam.x = -20;
		super.update(elapsed);
		currentList = listOrderText[currentListID];
	
		if (FlxG.mouse.overlaps(currentListChooser_leftArrow) && FlxG.mouse.justReleased || controls.UI_LEFT_R)
		{
			leftArrowPressed();
			if (currentList == 'story')
				currentlySelectedSong = storyModeSongs[list.selectedID];
			else if (currentList == 'freeplay')
				currentlySelectedSong = freePlaySongs[list.selectedID];
			else if (currentList == 'covers')
				currentlySelectedSong = coversSongs[list.selectedID];
			if (cameraTween != null)
				cameraTween.cancel();

			if (currentList == 'story')
				cameraTween = FlxTween.tween(bgCamera, {'scroll.x': 0}, 1, {ease: FlxEase.expoOut});
			else if (currentList == 'freeplay')
				cameraTween = FlxTween.tween(bgCamera, {'scroll.x': 1330}, 1, {ease: FlxEase.expoOut});
			else if (currentList == 'covers')
				cameraTween = FlxTween.tween(bgCamera, {'scroll.x': 2547}, 1, {ease: FlxEase.expoOut});
			else if (currentList == 'gallery')
				cameraTween = FlxTween.tween(bgCamera, {'scroll.x': 4093}, 1, {ease: FlxEase.expoOut});
		}
		else if (FlxG.mouse.overlaps(currentListChooser_rightArrow) && FlxG.mouse.justReleased || controls.UI_RIGHT_R)
		{
			rightArrowPressed();
			if (currentList == 'story')
				currentlySelectedSong = storyModeSongs[list.selectedID];
			else if (currentList == 'freeplay')
				currentlySelectedSong = freePlaySongs[list.selectedID];
			else if (currentList == 'covers')
				currentlySelectedSong = coversSongs[list.selectedID];

			if (cameraTween != null)
				cameraTween.cancel();

			if (currentList == 'story')
				cameraTween = FlxTween.tween(bgCamera, {'scroll.x': 0}, 1, {ease: FlxEase.expoOut});
			else if (currentList == 'freeplay')
				cameraTween = FlxTween.tween(bgCamera, {'scroll.x': 1330}, 1, {ease: FlxEase.expoOut});
			else if (currentList == 'covers')
				cameraTween = FlxTween.tween(bgCamera, {'scroll.x': 2547}, 1, {ease: FlxEase.expoOut});
			else if (currentList == 'gallery')
				cameraTween = FlxTween.tween(bgCamera, {'scroll.x': 4093}, 1, {ease: FlxEase.expoOut});
		}
		
		if (currentList != 'gallery')
		{
			if (controls.UI_DOWN_P)
				list.downArrowPressed();	
			
			if (controls.UI_UP_P)
				list.upArrowPressed();
			
			if (FNKMath.isNegative(FlxG.mouse.wheel)){
				for (i in 0...Std.int(Math.abs(FlxG.mouse.wheel))){
					list.downArrowPressed();	
				}
			}
			else if (FNKMath.isPositive(FlxG.mouse.wheel)){
				for (i in 0...FlxG.mouse.wheel){
					list.upArrowPressed();	
				}
			}

			if (controls.UI_UP_P || controls.UI_DOWN_P)
				FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			
		}
		if (FlxG.keys.justPressed.CONTROL)
		{
			openSubState(new GameplayChangersSubstate());
		}
		if (controls.ACCEPT)
		{
			if (currentList != 'gallery' && !highscoreTextAndStuff.text.contains("You must complete"))
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				PlayState.SONG = Song.loadFromJson(currentlySelectedSong, currentlySelectedSong);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 1;

				if (FlxG.keys.pressed.SHIFT)
				{
					MusicBeatState.switchState(new ChartingState());
				}
				else
				{
					// LoadingState.songTitle = currentlySelectedSong + erectSuffix;
					#if html5
					PlayState.preloadAudio(null, () ->
					{
					#end
						FlxTransitionableState.skipNextTransIn = false;
						FlxTransitionableState.skipNextTransOut = false;
						MusicBeatState.switchState(new PlayState());
					#if html5
					});
					openSubState(new HTML5PlaystateLoader());
					persistentUpdate = false;
					persistentDraw = false;
					#end
				}
				FlxG.sound.music.volume = 0;
			}
			else {
				albumArtDisplay.lockIsAngy = true;
				FlxG.sound.play(Paths.sound('cancelMenu'),1.0,false,null,true,()->{
					albumArtDisplay.lockIsAngy = false;
				});
			}
		}
		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
	}
}

class MusicParticle extends FlxSprite
{
	private var emitting:Bool = false;
	private var randoAngle:Float = 45;
	private var timer:FlxTimer;
	private var lastScale:Vector2 = new Vector2(1, 1);

	public function new()
	{
		super();
		// loadGraphic(Paths.image('freeplay/note${FlxG.random.int(1, 3)}'));
		this.loadGraphicWithAssetQuality('freeplay/note${FlxG.random.int(1, 3)}');
		setGraphicSize(64, 0);

		this.alpha = 0;
		this.lastScale.x = scale.x;
		this.lastScale.y = scale.y;
	}

	public function emit()
	{
		this.randoAngle = FlxG.random.float(180, 360);
		setGraphicSize(64, 0);
		this.angle = randoAngle;
		this.alpha = 1;
		this.emitting = true;
		this.spriteCenter(FreeplayState.albumArtDisplay.previewSprite);
	}

	public function move(amount:Float, angle:Float)
	{
		this.x += amount * FNKMath.fastSin(angle);
		this.y += amount * FNKMath.fastCos(angle);
	}

	public override function update(elapsed:Float)
	{
		if (this.emitting)
		{
			this.angle += 1 * (elapsed * 60);
			this.move(1 * (elapsed * 165), randoAngle);
			this.alpha -= 0.01 * (elapsed * 60);
			this.scale.x -= 0.01 * (elapsed * 60);
			this.scale.y -= 0.01 * (elapsed * 60);
		}
		if (this.alpha <= 0)
		{
			this.emitting = false;
			this.timer = new FlxTimer().start(FlxG.random.float(), (?_) ->
			{
				this.emit();
			});
		}
		super.update(elapsed);
	}
}
