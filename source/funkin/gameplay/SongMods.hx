package funkin.gameplay;

import lime.math.Vector2;
import flixel.group.FlxSpriteGroup;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.FlxSprite;
import funkin.gameplay.PlayState;

var songdata:{} = { // left over from blue house christmas
	'santa': ['Santa', 'Nicebonie', '5',],
	'grocery': ['The Grocery Store', 'Nicebonie', '5',],
	'carols': ['Christmas Carols', 'MistaShitty', '5'],
};

function playStateInstance()
{
	return PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
}

class CoolFunkyCredits // Ported to haxe and added stuff by letsgoaway, originally made in lua by omotashi and legole0
{
	public static var offsetX = 10;
	public static var offsetY = 500;
	public static var objWidth = 500;
	public static var creditBox:FlxSprite;
	public static var creditTitle:FlxText;
	public static var creditCreator:FlxText;
	public static var creditBoxTween:FlxTween;
	public static var creditTitleTween:FlxTween;
	public static var creditCreatorTween:FlxTween;
	public static var state:FlxState;
	private static var out = false;

	public static function onCreatePost():Void
	{
		creditBox = new FlxSprite(0 - objWidth, offsetY).makeGraphic(objWidth, 150, FlxColor.BLACK);
		creditBox.cameras = [PlayState.instance.camHUD];
		creditBox.alpha = 0.7;
		playStateInstance().add(creditBox);
		creditTitle = new FlxText(offsetX - objWidth, offsetY + 25, objWidth, 'PlaceholderTitle', 45);
		creditTitle.setFormat(Paths.font("vcr.ttf"), 45, FlxColor.WHITE, LEFT, QualityPrefs.textShadow(), FlxColor.BLACK);
		creditTitle.cameras = [PlayState.instance.camHUD];
		playStateInstance().add(creditTitle);
		creditCreator = new FlxText(offsetX - objWidth, offsetY + 80, objWidth, 'PlaceholderCreator', 30);
		creditCreator.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, LEFT, QualityPrefs.textShadow(), FlxColor.BLACK);
		creditCreator.cameras = [PlayState.instance.camHUD];
		playStateInstance().add(creditCreator);
		out = false;
	}

	public static function onSongStart(songName)
	{
		var songExists:Bool = Reflect.hasField(songdata, songName);
		if (songExists)
		{
			var curSongTable:Array<String> = Reflect.field(songdata, songName);
			creditTitle.text = curSongTable[0];
			creditCreator.text = "Made by: " + curSongTable[1];
			creditBoxTween = FlxTween.tween(creditBox, {x: creditBox.x + objWidth}, 1, {ease: FlxEase.expoOut});
			creditTitleTween = FlxTween.tween(creditTitle, {x: creditTitle.x + objWidth}, 1, {ease: FlxEase.expoOut});
			creditCreatorTween = FlxTween.tween(creditCreator, {x: creditCreator.x + objWidth}, 1, {ease: FlxEase.expoOut});
			var creditDisplay = new FlxTimer().start(Std.parseFloat(curSongTable[2]), onTimerCompleted, 1);

			out = true;
		}
		else
		{
			Funkin.log("Song does not exist within the song data table");
		}
	}

	// added by letsgoaway
	public static function show(title:String = '', description:String = '', state:FlxState, ?centerToScreenY:Bool = false)
	{
		CoolFunkyCredits.state = state;
		creditBox = new FlxSprite(0 - objWidth, offsetY).makeGraphic(objWidth, 150, FlxColor.BLACK);
		creditBox.alpha = 0.7;
		if (centerToScreenY)
			creditBox.screenCenter(Y);
		creditBox.cameras = [PlayState.instance.camHUD];
		state.add(creditBox);
		creditTitle = new FlxText(offsetX - objWidth, creditBox.y + 25, objWidth, 'PlaceholderTitle', 45);
		creditTitle.setFormat(Paths.font("vcr.ttf"), 45, FlxColor.WHITE, LEFT, QualityPrefs.textShadow(), FlxColor.BLACK);
		creditTitle.cameras = [PlayState.instance.camHUD];
		state.add(creditTitle);
		creditCreator = new FlxText(offsetX - objWidth, creditBox.y + 80, objWidth, 'PlaceholderCreator', 30);
		creditCreator.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, LEFT, QualityPrefs.textShadow(), FlxColor.BLACK);
		creditCreator.cameras = [PlayState.instance.camHUD];
		state.add(creditCreator);
		creditTitle.text = title;
		creditCreator.text = description;
		creditBoxTween = FlxTween.tween(creditBox, {x: creditBox.x + objWidth}, 1, {ease: FlxEase.expoOut});
		creditTitleTween = FlxTween.tween(creditTitle, {x: creditTitle.x + objWidth}, 1, {ease: FlxEase.expoOut});
		creditCreatorTween = FlxTween.tween(creditCreator, {x: creditCreator.x + objWidth}, 1, {ease: FlxEase.expoOut});
		out = true;
	}

	public static function setText(?title:String = null, ?description:String = null)
	{
		if (title != null)
			creditTitle.text = title;
		if (description != null)
			creditCreator.text = description;
	}

	public static function hide()
	{
		if (out)
			onTimerCompleted();
	}

	public static function onTimerCompleted(?_)
	{
		out = false;
		creditBoxTween = FlxTween.tween(creditBox, {x: creditBox.x - objWidth}, 0.5, {ease: FastEase.sineIn});
		creditTitleTween = FlxTween.tween(creditTitle, {x: creditTitle.x - objWidth}, 0.5, {ease: FastEase.sineIn});
		creditCreatorTween = FlxTween.tween(creditCreator, {x: creditCreator.x - objWidth}, 0.5, {
			ease: FastEase.sineIn,
			onComplete: (_) ->
			{
				destroy();
			}
		});
	}

	public static function destroy()
	{
		state.remove(creditBox);
		state.remove(creditTitle);
		state.remove(creditCreator);
		creditBoxTween.cancel();
		creditTitleTween.cancel();
		creditCreatorTween.cancel();
		creditBoxTween.destroy();
		creditTitleTween.destroy();
		creditCreatorTween.destroy();
	}
}

class HealthDrain
{
	public static function onOpponentHit()
	{
		if (PlayState.instance.health > 0.3)
		{
			PlayState.instance.health -= 0.023 * 1;
		}
	}
}

class CameraFollow
{
	private static var movementOffset:Float = 20;
	public static var usedInLevel:Bool = false;
	private static var permYOfs:Float = 75;
	private static var bfxOffset:Float = 75;

	private static function cameraFollowPos(val1:Float, val2:Float)
	{
		PlayState.instance.isCameraOnForcedPos = false;
		PlayState.instance.camFollow.x = val1;
		PlayState.instance.camFollow.y = val2;
		PlayState.instance.isCameraOnForcedPos = true;
	}

	/**
	 * Initialize new camera
	 * @param permYOfs Offset the y level of the camera by this amount. If the camera seems pretty low, try using this.
	 * @param movementOffset When the player hits a note, offset the distance the camera should move in the direction that the player hits by this amount of pixels.
	 * @param bfxOffset Offset the cameras horizontal position by this amount when bf is singing.
	 */
	public static function onCreate(permYOfs:Float, movementOffset:Float, ?bfxOffset:Float = 75)
	{
		CameraFollow.permYOfs = permYOfs;
		CameraFollow.movementOffset = movementOffset;
		CameraFollow.bfxOffset = bfxOffset;

		usedInLevel = true;
	}

	public static function onEvent(permYOfs:String, movementOffset:String)
	{
		CameraFollow.permYOfs = Std.parseFloat(permYOfs);
		CameraFollow.movementOffset = Std.parseFloat(movementOffset);
		usedInLevel = true;
	}

	public static function toggleCamera()
	{
		usedInLevel = !usedInLevel;
		PlayState.instance.isCameraOnForcedPos = usedInLevel;
	}

	private static var yLevel:Float = 200;

	private static var midpointX:Float = 20;

	public static function onUpdate()
	{
		if (!usedInLevel)
		{
			return;
		}
		yLevel = ((PlayState.instance.boyfriend.origin.y + PlayState.instance.dad.origin.y) / 2)
			+ ((PlayState.instance.boyfriend.height + PlayState.instance.dad.height) / 6);
		yLevel += permYOfs;
		midpointX = (PlayState.instance.boyfriend.x + (PlayState.instance.dad.x + PlayState.instance.dad.width)) / 2;

		if (PlayState.SONG.notes[PlayState.instance.currentSection] != null
			&& PlayState.SONG.notes[PlayState.instance.currentSection].mustHitSection)
		{
			midpointX += bfxOffset;
			switch (PlayState.instance.boyfriend.animation.curAnim.name)
			{
				case 'singLEFT':
					cameraFollowPos(midpointX - movementOffset, yLevel);
				case 'singRIGHT':
					cameraFollowPos(midpointX + movementOffset, yLevel);
				case 'singUP':
					cameraFollowPos(midpointX, yLevel - movementOffset);
				case 'singDOWN':
					cameraFollowPos(midpointX, yLevel + movementOffset);
				case 'singLEFT-alt':
					cameraFollowPos(midpointX - movementOffset, yLevel);
				case 'singRIGHT-alt':
					cameraFollowPos(midpointX + movementOffset, yLevel);
				case 'singUP-alt':
					cameraFollowPos(midpointX, yLevel - movementOffset);
				case 'singDOWN-alt':
					cameraFollowPos(midpointX, yLevel + movementOffset);
				case 'idle':
					cameraFollowPos(midpointX, yLevel);
				case 'idle-alt':
					cameraFollowPos(midpointX, yLevel);
			}
		}
		else
		{
			switch (PlayState.instance.dad.animation.curAnim.name)
			{
				case 'singLEFT':
					cameraFollowPos(midpointX - movementOffset, yLevel);
				case 'singRIGHT':
					cameraFollowPos(midpointX + movementOffset, yLevel);
				case 'singUP':
					cameraFollowPos(midpointX, yLevel - movementOffset);
				case 'singDOWN':
					cameraFollowPos(midpointX, yLevel + movementOffset);
				case 'singLEFT-alt':
					cameraFollowPos(midpointX - movementOffset, yLevel);
				case 'singRIGHT-alt':
					cameraFollowPos(midpointX + movementOffset, yLevel);
				case 'singUP-alt':
					cameraFollowPos(midpointX, yLevel - movementOffset);
				case 'singDOWN-alt':
					cameraFollowPos(midpointX, yLevel + movementOffset);
				case 'idle':
					cameraFollowPos(midpointX, yLevel);
				case 'idle-alt':
					cameraFollowPos(midpointX, yLevel);
			}
		}
	}
}
