package funkin.gameplay;

import openfl.utils.Assets;
import openfl.filesystem.File;
import flixel.util.FlxAxes;
import flixel.addons.display.FlxBackdrop;
import haxe.crypto.Base64;
import haxe.io.Path;
import flixel.effects.FlxFlicker;
import openfl.filters.BlurFilter;
import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.FlxSprite;
import funkin.fx.Filters;

using StringTools;

function addSpriteToPlayState(sprite:FlxSprite, front:Bool)
{
	if (!front)
		PlayState.instance.add(sprite);
	else
		PlayState.instance.frontSprites.push(sprite);
}

function addInFrontOfGFSprite(sprite:FlxSprite)
{
	PlayState.instance.frontOfGfSprites.push(sprite);
}

class SongStages
{
	public static var stageList:Array<String> = [
		'stage',
		'blue house',
		'code',
		'microwave',
		'nothing',
		'outside',
		'white',
		'white_erm'
	];

	public static function getStageList():Array<String>
	{
		return stageList;
	}

	public static function loadStage(stageName):Void
	{
		PlayState.instance.camGame.bgColor = FlxColor.BLACK;
		switch (stageName)
		{
			case 'stage':
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				addSpriteToPlayState(bg, false);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				addSpriteToPlayState(bg, false);
				if (!ClientPrefs.lowQuality)
				{
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					addSpriteToPlayState(bg, false);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					addSpriteToPlayState(bg, false);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					addSpriteToPlayState(bg, false);
				}
			case 'blue house':
				SongStages.Stage_blueHouse.onCreate();
			// keeping this here for lols but its fixed now
			//
			// this is the most jank thing in the world
			// for some god for saken reason mista shitty is too powerful
			// and just says 'die' and crashes the game if you have a really high fps
			// you cannot win against mista shitty
			// if (FlxG.drawFramerate >= 120)
			// {
			//	Cache.winAlert('Sorry, high fps user, but mista shitty is too powerful and crashes the game if you have a high fps. We dont know why this happens. We\'ve lowered the fps to 120 to limit his power.',
			//		'Sorry', 'info');
			//	FlxG.drawFramerate = 120;
			// }
			// else
			//	FlxG.drawFramerate = ClientPrefs.framerate;
			case 'code':
				SongStages.Stage_code.onCreate();
			case 'microwave':
				SongStages.Stage_microwave.onCreate();
			case 'nothing':
				SongStages.Stage_nothing.onCreate();
			case 'outside':
				SongStages.Stage_outside.onCreate();
			case 'white' | 'white_erm':
				SongStages.Stage_white.onCreate();
		}
	}
}

class MistaPlayer
{
	public static function init():Void
	{
		GameOverSubstate.characterName = 'shattdead';
		GameOverSubstate.deathSoundName = 'shatt_loss_sfx';
		GameOverSubstate.loopSoundName = 'shattgo';
		GameOverSubstate.endSoundName = 'shattgoe';
	}
}

class ErmPlayer
{
	public static function init():Void
	{
		GameOverSubstate.characterName = 'ermnb-death';
		GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
		GameOverSubstate.loopSoundName = 'gameOver';
		GameOverSubstate.endSoundName = 'gameOverEnd';
	}
}

class NBPixelPlayer
{
	public static function init():Void
	{
		GameOverSubstate.characterName = 'nbpixel-death';
		GameOverSubstate.deathSoundName = 'fnf_loss_sfx';
		GameOverSubstate.loopSoundName = 'gameOver';
		GameOverSubstate.endSoundName = 'gameOverEnd';
	}
}

class BGChar_megafun extends FlxSprite
{
	private var frameTimer:Float32 = 0;
	private var timesBounced:Int16 = 0;
	private var dead:Bool = false;

	public var created:Bool = false;

	public function new()
	{
		super(1350, 600);
	}

	public function create()
	{
		this.x = 1350;
		this.y = 600;
		created = true;
		dead = false;
		frameTimer = 0;
		timesBounced = 0;
		frames = Paths.getSparrowAtlas('bhChars/megafun');
		animation.addByPrefix('megafun', 'megafun');
		animation.addByPrefix('megaplop', 'megaplop', 30, false);
		scale.set(0.9, 0.9);
		updateHitbox();
		offset.x = origin.x;
		offset.y = origin.y;
	}

	var isPositive = false;

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!created || dead)
		{
			return;
		}

		angle -= 6 * (elapsed * 60);
		x -= 6 * (elapsed * 60);
		var s:Float = FNKMath.fastSin(frameTimer / 100) * 175;
		if (Math.abs(s) != s && isPositive)
		{
			timesBounced++;
		}
		else if (Math.abs(s) == s && !isPositive)
		{
			timesBounced++;
		}
		isPositive = Math.abs(s) == s;
		y = (0 - Math.abs(s)) + 450; // le magic bounce
		frameTimer += 6 * (elapsed * 60);
		if (timesBounced == 6)
		{
			updateHitbox();
			angle = 0;
			x -= 175;
			y += 20;
			dead = true;
			FlxTween.tween(this, {x: this.x - 135}, 0.7, {
				ease: FastEase.sineOut,
				onComplete: (?_) ->
				{
					FlxFlicker.flicker(this, 0.3, 0.04, true, true, (?_) ->
					{
						kill();
						active = false;
					});
				}
			});

			animation.play('megaplop');
		}
	}
}

class BGChar_LGA extends FlxSprite
{
	public var created:Bool = false;
	public var completed:Bool = false;

	public function new()
	{
		super(1350, 285);
	}

	public function create()
	{
		this.x = 1350;
		this.y = 285;
		created = true;
		frames = Paths.getSparrowAtlas('bhChars/lgacart');
		animation.addByPrefix('idle', 'ap and lga', 24, true);
		animation.play("idle", true);
		scale.set(0.9, 0.9);
		updateHitbox();
	}

	public function goBackWards()
	{
		this.x = -820;
		this.y = 285;
		this.flipX = true;
		completed = true;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!created)
		{
			return;
		}
		if (this.flipX)
			this.x += 5 * (elapsed * 60);
		else
			this.x -= 5 * (elapsed * 60);
	}
}

class BGChar_MALK extends FlxSprite
{
	public var created:Bool = false;
	public var completed:Bool = false;

	public function new()
	{
		super(1350, 294);
	}

	public function create()
	{
		this.x = 1350;
		this.y = 294;
		created = true;
		frames = Paths.getSparrowAtlas('bhChars/malkbg');
		animation.addByPrefix('idle', 'malkwalking', 180, true);
		animation.play("idle", true);
		scale.set(0.9, 0.9);
		updateHitbox();
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!created)
		{
			return;
		}
		if (!completed && -600 >= this.x)
		{
			this.flipX = true;
			this.completed = true;
		}
		if (this.flipX)
			this.x += 25 * (elapsed * 60);
		else
			this.x -= 25 * (elapsed * 60);
	}
}

class Stage_blueHouse
{
	public static var bg:FlxSprite;
	public static var bhf:FlxSprite;
	public static var megaFun:BGChar_megafun;
	public static var lga:BGChar_LGA;
	public static var malk:BGChar_MALK;

	public static function onCreate():Void
	{
		bg = new FlxSprite(-800, -250);
		bg.loadGraphicWithAssetQuality('stages/blue house/blue house');
		bg.scrollFactor.set(0.95, 0.95);
		addSpriteToPlayState(bg, false);
		megaFun = new BGChar_megafun();
		megaFun.alpha = 0;
		addSpriteToPlayState(megaFun, false);
		lga = new BGChar_LGA();
		lga.alpha = 0;
		addSpriteToPlayState(lga, false);
		malk = new BGChar_MALK();
		malk.alpha = 0;
		addSpriteToPlayState(malk, false);
		bhf = Filters.newBlurredSprite(-850, 315, 'stages/blue house/bhf', 12, 12, true);
		bhf.scrollFactor.set(0.7, 0.15);
		FlxTimer.loop(10, (loop) ->
		{
			tickRandomChars(loop);
		}, 0);
		addSpriteToPlayState(bhf, true);
		// megaFun.create();
	}

	private static function tickRandomChars(loop:Int)
	{
		if (PlayState.instance.paused)
		{
			return;
		}
		var random:Int = FlxG.random.int(0, 100);
		if (FlxMath.inBounds(random, 0, 10))
		{
			if (!megaFun.created)
			{
				megaFun.create();
				megaFun.alpha = 1;
			}
		}
		else if (FlxMath.inBounds(random, 11, 20))
		{
			if (!lga.created)
			{
				lga.create();
				lga.alpha = 1;
			}
			else if (!lga.completed)
			{
				lga.goBackWards();
			}
		}
		else if (FlxMath.inBounds(random, 21, 30))
		{
			if (!malk.created)
			{
				malk.create();
				malk.alpha = 1;
			}
		}
	}
}

class App extends FlxSprite
{
	public function new(icon:String, suf:String)
	{
		super();
		frames = Paths.getSparrowAtlas("stages/code/apps" + suf);
		animation.addByPrefix("idle", icon);
		animation.play("idle");
	}
}

class Stage_code
{
	public static var sky:FlxSprite;
	public static var sun:FlxSprite;
	public static var floor:FlxSprite;
	public static var apps:Array<App> = [];
	public static var gyattPercent:Float = 1.0;
	private static var animNames = ["bhb", "clip", "fl", "mista", "vlc", "yt"];

	public static function onCreate():Void
	{
		gyattPercent = 1.0;
		apps = [];
		var assetSuffix:String = "";
		if (PlayState.SONG.song.contains("-erect"))
			assetSuffix = "Cyan";
		sky = new FlxSprite();
		sky.loadGraphicWithAssetQuality('stages/code/sky$assetSuffix');
		sky.scrollFactor.set(0.4, 0.4);
		sky.setGraphicSize(1746, 1011);
		sky.updateHitbox();
		sky.setPosition(-202, -143);
		addSpriteToPlayState(sky, false);

		sun = new FlxSprite();
		sun.loadGraphicWithAssetQuality('stages/code/sun$assetSuffix');
		sun.scrollFactor.set(0.55, 0.55);
		sun.setGraphicSize(672, 332);
		sun.updateHitbox();
		sun.setPosition(316, 231);
		addSpriteToPlayState(sun, false);

		floor = new FlxSprite();
		floor.loadGraphicWithAssetQuality('stages/code/floor$assetSuffix');
		floor.scrollFactor.set(0.95, 0.95);
		floor.setGraphicSize(2076, 503);
		floor.updateHitbox();
		floor.setPosition(-367, 515);
		addSpriteToPlayState(floor, false);
		for (iconName in animNames)
		{
			var app:App = new App(iconName, assetSuffix);
			apps.push(app);
			addSpriteToPlayState(app, false);
		}
	}

	public static function gyatt(note:Note)
	{
		if (!note.isSustainNote)
			gyattPercent = 1.0;
	}

	public static function update(elapsed:Float)
	{
		for (app in apps)
		{
			app.spriteCenter(PlayState.instance.dad);
			app.moveAngle(150 + (100 * gyattPercent), (Time.getTimestamp() + (app.ID * 600)) / 10);
		}

		if (gyattPercent > 0.2)
			gyattPercent -= 0.005 * (elapsed * 60);
	}
}

class Stage_microwave
{
	public static var mbg:FlxSprite;
	public static var outsideBurnt:FlxSprite;
	public static var houseBurnt:FlxSprite;

	private static var isBurntBG:Bool = false;

	public static function onCreate():Void
	{
		isBurntBG = PlayState.SONG.song.contains("-erect");
		mbg = new FlxSprite(-200, 0);
		mbg.loadGraphic(Paths.image('stages/microwave/mbg'));
		mbg.scrollFactor.set(0.9, 0.9);
		addSpriteToPlayState(mbg, false);

		outsideBurnt = new FlxSprite(-300, -200);
		outsideBurnt.loadGraphic(Paths.image('stages/microwave/outsideburnt'));
		outsideBurnt.scrollFactor.set(0.5, 0.5);
		outsideBurnt.scale.set(0.9, 0.9);
		addSpriteToPlayState(outsideBurnt, false);

		houseBurnt = new FlxSprite(-200, 400);
		houseBurnt.loadGraphic(Paths.image('stages/microwave/house_burnt'));
		houseBurnt.scrollFactor.set(0.9, 0.9);
		addSpriteToPlayState(houseBurnt, false);

		updateVisibility();
	}

	public static function toggleBG()
	{
		isBurntBG = !isBurntBG;
		updateVisibility();
	}

	private static function updateVisibility()
	{
		PlayState.instance.camGame.bgColor = isBurntBG ? 0xFF920025 : 0xFF492CA5;
		mbg.visible = !isBurntBG;
		outsideBurnt.visible = isBurntBG;
		houseBurnt.visible = isBurntBG;
	}
}

class Stage_nothing
{
	public static function onCreate():Void
	{
	}
}

class Stage_outside
{
	public static var sky:FlxSprite;
	public static var clouds:FlxBackdrop;
	public static var shed:FlxSprite;
	public static var fence:FlxSprite;
	public static var grass:FlxSprite;

	public static function onCreate():Void
	{
		PlayState.instance.camGame.bgColor = 0xFF0099CC;
		sky = new FlxSprite();
		sky.loadGraphicWithAssetQuality('stages/outside/sky');
		PlayState.instance.add(sky);
		sky.setGraphicSize(2428, 1248);
		sky.updateHitbox();
		sky.setPosition(-574, -348);
		sky.scrollFactor.set(0.15, 0.15);

		clouds = new FlxBackdrop();
		clouds.loadGraphicWithAssetQuality('stages/outside/clouds');
		PlayState.instance.add(clouds);
		clouds.setGraphicSize(0, 183);
		clouds.updateHitbox();
		clouds.scrollFactor.set(0.5, 0.5);
		clouds.setPosition(-98, 35);
		clouds.velocity.set(-30);
		clouds.repeatAxes = FlxAxes.X;

		fence = new FlxSprite();
		fence.loadGraphicWithAssetQuality('stages/outside/fence');
		PlayState.instance.add(fence);
		fence.setGraphicSize(1832, 618);
		fence.updateHitbox();
		fence.setPosition(-344, 196);
		fence.scrollFactor.set(0.725, 0.725);

		shed = new FlxSprite();
		shed.loadGraphicWithAssetQuality('stages/outside/shed');
		PlayState.instance.add(shed);
		shed.setGraphicSize(481, 484);
		shed.updateHitbox();
		shed.setPosition(811, 169);
		shed.scrollFactor.set(0.80, 0.80);

		grass = new FlxSprite();
		grass.loadGraphicWithAssetQuality('stages/outside/grass');
		PlayState.instance.add(grass);
		grass.setGraphicSize(2101, 654);
		grass.updateHitbox();
		grass.setPosition(-466, 355);
		grass.scrollFactor.set(0.9, 0.9);
	}
}

class Stage_white
{
	public static function onCreate():Void
	{
		if (PlayState.SONG.song != "bestsongever")
			PlayState.instance.skipCountdown = true;
		PlayState.instance.camGame.bgColor = FlxColor.WHITE;
	}
}
