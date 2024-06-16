package funkin.gameplay;

import funkin.gameplay.SongStages.addSpriteToPlayState;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import funkin.system.input.Controls;
import flixel.math.FlxPoint;

function playStateInstance():FlxState
{
	return PlayState.instance.isDead ? GameOverSubstate.instance : PlayState.instance;
}

var upperbar:FlxSprite;
var lowerbar:FlxSprite;
var yUpperBar:Float;
var yLowerBar:Float;
var camHUD:FlxCamera;

class EventList
{
	// Add your event details here!
	public static var eventDetails:Array<Array<String>> = [
		['', "Nothing. Yep, that's right."],
		[
			'Hey!',
			"Plays the \"Hey!\" animation from Bopeebo,\nValue 1: BF = Only Boyfriend, GF = Only Girlfriend,\nSomething else = Both.\nValue 2: Custom animation duration,\nleave it blank for 0.6s"
		],
		[
			'Set GF Speed',
			"Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\n\nWarning: Value must be integer!"
		],
		[
			'Add Camera Zoom',
			"Used on MILF on that one \"hard\" part\nValue 1: Camera zoom add (Default: 0.015)\nValue 2: UI zoom add (Default: 0.03)\nLeave the values blank if you want to use Default."
		],
		[
			'Play Animation',
			"Plays an animation on a Character,\nonce the animation is completed,\nthe animation changes to Idle\n\nValue 1: Animation to play.\nValue 2: Character (Dad, BF, GF)"
		],
		[
			'Camera Follow Pos',
			"Value 1: X\nValue 2: Y\n\nThe camera won't change the follow point\nafter using this, for getting it back\nto normal, leave both values blank."
		],
		[
			'Alt Idle Animation',
			"Sets a specified suffix after the idle animation name.\nYou can use this to trigger 'idle-alt' if you set\nValue 2 to -alt\n\nValue 1: Character to set (Dad, BF or GF)\nValue 2: New suffix (Leave it blank to disable)"
		],
		[
			'Screen Shake',
			"Value 1: Camera shake\nValue 2: HUD shake\n\nEvery value works as the following example: \"1, 0.05\".\nThe first number (1) is the duration.\nThe second number (0.05) is the intensity."
		],
		[
			'Change Character',
			"Value 1: Character to change (Dad, BF, GF)\nValue 2: New character's name"
		],
		[
			'Change Scroll Speed',
			"Value 1: Scroll Speed Multiplier (1 is default)\nValue 2: Time it takes to change fully in seconds."
		],
		[
			'CamHUD_Fade',
			"Fades the HUD in or out\n\nValue 1: value to fade (1 = fade in, 0 = fade out)\nValue 2: Duration"
		],
		[
			'Cinematics',
			'Value 1: Start/End of Cinematic\n			Mark this Value with 1 to begin the event\n			or mark this value with 2 to end the event\n		\n		Value 2: Cinematic Bar Speed\n			Mark this Value with how fast you would like\n			the bars to move in (Suggested: 0.5)\n			\n			Leave Blank to only fade out the HUD'
		],
		['Camera Flash', 'Value 1 is the opacity.\nValue 2 is the duration.'],
		['Image Flash', 'Value 1 is the name of the image.\nValue 2 is the duration.'],
		[
			'Lyrics Bf Side',
			'Lyrical Genius but Bf\nPut lyrics in yo song woo\n\nValue 1: text or lyrics\nValue 2: duration before its gone (in seconds). You can use decimals like 0.3'
		],
		[
			'Lyrics Opp Side',
			'Lyrical Genius\nPut lyrics in yo song woo\n\nValue 1: text or lyrics\nValue 2: duration before its gone (in seconds). You can use decimals like 0.3'
		],
		['Lyrics Mega Side', 'hey guys i brought pizza'],
		[
			'Start Shot Window',
			'Begins window for the player to press space. Auto ends if another is started'
		],
		['End Shot Window', 'Ends window for the player to press space'],
		['Shot Warning', 'Plays Shot warning sound'],
		['microwave Toggle Bg', 'wait is that my house burning down oven'],
		[
			'HudHide',
			'Changes visibility of the hud to either show or hide.\nValue 1: "hide" or "show"'
		],
		['introNums', 'val 1 can be 3 2 1 or go'],
		['Camera Zoom Type',
			'Val 1 Types\n'
			+ '"beats"-Camera Zooms every Beat\n'
			+ '"beatsOdd"-Camera Zooms every odd Beat\n'
			+ '"beatsEven"-Camera Zooms every even Beat\n'
			+ '"steps"-Camera Zooms every Step\n'
			+ '"sections"-Camera Zooms every Sections\n'
			+ '"opponentNotes"-Camera Zooms every time opponent hits note\n'
			+ '"playerNotes"-Camera Zooms every time player hits note\n'
			+ '"now" - perform a zoom when this event is ran, and set the camera type to "none"\n'
			+ '"none" - dont zoom the camera'
			+ "Val 2: Zoom Multiplier (default = 1)"],
		["Camera Zoom to Player", "we back"],
		["Toggle Invert", "invert colors yay"],
		["Set New Camera Data",
			"Enables the new camera with below data.\n\n"
			+ "Value 1:\n"
			+ "Offset the y level of the camera by this amount. \nIf the camera seems pretty low, try changing this.\n\n"
			+ "Value 2:\n"
			+ "When the player hits a note,offset the distance the camera should \nmove in the direction that the player hits by this amount of pixels."],
		["Toggle New Camera", "toggles the new camera"],
		["Toggle Botplay", "toggles botplay"],
	];

	// Add your event details here!
	public static function run(eventName:String, value1:String, value2:String)
	{
		switch (eventName) // add your event codes here!
		{
			case 'CamHUD_Fade':
				SongEvents.CamHUD_Fade.onEvent(value1, value2);
			case 'Cinematics':
				SongEvents.Cinematics.onEvent(value1, value2);
			case 'Image Flash':
				SongEvents.ImageFlash.onEvent(value1, value2);
			case 'Camera Flash':
				SongEvents.CameraFlash.onEvent(value1, value2);
			case 'Lyrics Bf Side':
				SongEvents.Lyrics_BfSide.onEvent(value1, value2);
			case 'Lyrics Mega Side':
				SongEvents.Lyrics_MegaSide.onEvent(value1, value2);
			case 'Lyrics Opp Side':
				SongEvents.Lyrics_OppSide.onEvent(value1, value2);
			case 'microwave Toggle Bg':
				SongStages.Stage_microwave.toggleBG();
			case 'Start Shot Window':
				SongEvents.ShotWindow.onStartShotWindow();
			case 'End Shot Window':
				SongEvents.ShotWindow.onEndShotWindow();
			case 'Shot Warning':
				SongEvents.ShotWindow.warningSound();
			case 'HudHide':
				SongEvents.HudHide.onEvent(value1);
			case 'introNums':
				SongEvents.Start321.onEvent(value1);
			case 'Camera Zoom Type':
				SongEvents.CameraZoomType.onEvent(value1, value2);
			case 'Camera Zoom to Player':
				SongEvents.CameraZoomPlayer.onEvent(value1, value2);
			case 'Toggle Invert':
				SongEvents.ToggleInvert.onEvent(value1, value2);
			case 'Set New Camera Data':
				SongMods.CameraFollow.onEvent(value1, value2);
			case 'Toggle New Camera':
				SongMods.CameraFollow.toggleCamera();
			case 'Start Skip Section':
				SongMods.CameraFollow.toggleCamera();
			case 'Toggle Botplay':
				if (!ClientPrefs.getGameplaySetting('botplay', false))
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
		}
	}
}

class CinematicsWithHud // Ported to haxe by letsgoaway, originally made in lua by RamenDominoes
{
	public static function onCreatePost():Void
	{
		upperbar = new FlxSprite(-110, -350).makeGraphic(1500, 350, FlxColor.BLACK);
		upperbar.cameras = [PlayState.instance.camGame];
		upperbar.scrollFactor.set(0, 0);
		playStateInstance().add(upperbar);
		lowerbar = new FlxSprite(-110, 720).makeGraphic(1500, 350, FlxColor.BLACK);
		lowerbar.cameras = [PlayState.instance.camGame];
		lowerbar.scrollFactor.set(0, 0);
		playStateInstance().add(lowerbar);
		yUpperBar = upperbar.y;
		yLowerBar = lowerbar.y;
	}

	public static function onEvent(value1, value2):Void
	{
		var Speed:Float = Std.parseFloat(value1);
		var Distance:Float = Std.parseFloat(value2);

		// ENTRANCES

		if ((Speed > 0) && (Distance > 0))
		{
			var hud1:FlxTween = FlxTween.tween(upperbar, {y: yUpperBar + Distance}, Speed, {ease: FlxEase.quadOut});
			var hud2:FlxTween = FlxTween.tween(lowerbar, {y: yLowerBar - Distance}, Speed, {ease: FlxEase.quadOut});
		}
		if (Distance <= 0)
		{
			var hud1:FlxTween = FlxTween.tween(upperbar, {y: yUpperBar}, Speed, {ease: FlxEase.quadIn});
			var hud2:FlxTween = FlxTween.tween(lowerbar, {y: yLowerBar}, Speed, {ease: FlxEase.quadIn});
		}
	}
}

class CamHUD_Fade
{
	private static var fadeTweenCamHud:FlxTween = null;
	private static var fadeTweenCamOther:FlxTween = null;

	public static function onEvent(alpha:Any, duration:Any):Void
	{
		alpha = Std.parseFloat(alpha);
		duration = Std.parseFloat(duration);
		if (fadeTweenCamHud != null)
			fadeTweenCamHud.cancel();
		fadeTweenCamHud = FlxTween.tween(PlayState.instance.camHUD, {alpha: alpha}, duration, {ease: FlxEase.linear});
		if (fadeTweenCamOther != null)
			fadeTweenCamOther.cancel();
		fadeTweenCamOther = FlxTween.tween(PlayState.instance.camOther, {alpha: alpha}, duration, {ease: FlxEase.linear});
	}
}

class CameraZoomType
{
	public static function onEvent(cameraType:String, cameraZoomMultiplier:String = '1'):Void
	{
		if (cameraZoomMultiplier == '')
			cameraZoomMultiplier = '1';

		PlayState.instance.camZoomingMult = Std.parseFloat(cameraZoomMultiplier);
		if (cameraType == "now")
		{
			PlayState.instance.cameraType = "none";
			PlayState.instance.cameraZoomBeat();
			return;
		}
		PlayState.instance.cameraType = cameraType;
	}
}

class CameraZoomPlayer
{
	static var camFollowTween:FlxTween;
	static var camFollowPosTween:FlxTween;
	static var camGameTween:FlxTween;

	public static function onEvent(backward:String, cameraZoomMultiplier:String = '1'):Void
	{
		var point:FlxPoint = PlayState.instance.boyfriend.getGraphicMidpoint();
		camFollowTween = FlxTween.tween(PlayState.instance.camFollow, {x: point.x - 150, y: point.y - 125}, 1.0, {
			ease: FastEase.sineOut,
			type: PINGPONG,
			onComplete: (t) ->
			{
				t.cancel();
			}
		});
		camFollowPosTween = FlxTween.tween(PlayState.instance.camFollowPos, {x: point.x - 150, y: point.y - 125}, 1.0, {
			ease: FastEase.sineOut,
			type: PINGPONG,
			onComplete: (t) ->
			{
				t.cancel();
			}
		});
		camGameTween = FlxTween.tween(PlayState.instance.camGame, {zoom: PlayState.instance.camGame.zoom * 1.4}, 1.0, {
			ease: FastEase.sineOut,
			type: PINGPONG,
			onComplete: (t) ->
			{
				/*
					PlayState.instance.boyfriend.colorTransform.redOffset = -255;
					PlayState.instance.boyfriend.colorTransform.greenOffset = -255;
					PlayState.instance.boyfriend.colorTransform.blueOffset = -255;
				 */
				t.cancel();
			}
		});
	}
}

class ToggleInvert
{
	public static function onEvent(v1:String, v2:String):Void
	{
		PlayState.instance.toggleInvert();
	}
}

class ShotWindow // written by letsgoaway
{
	public static var dodged:Bool = false;
	public static var inShotWindow:Bool = false;
	private static var controls:Null<Controls> = null;
	private static var possibleKeys:Null<Array<flixel.input.keyboard.FlxKey>> = ClientPrefs.keyBinds.get('accept');

	public static function warningSound():Void
	{
		FlxG.sound.play(Paths.sound('warning'));
	}

	public static function onStartShotWindow():Void
	{
		possibleKeys = ClientPrefs.keyBinds.get('accept');
		if (inShotWindow)
		{
			onEndShotWindow();
			dodged = false;
		}
		inShotWindow = true;
	}

	public static function onEndShotWindow():Void
	{
		possibleKeys = ClientPrefs.keyBinds.get('accept');
		if (!dodged)
		{
			PlayState.instance.health -= 1 / 3;
		}
		inShotWindow = false;
	}

	public static function update()
	{
		if (inShotWindow)
		{
			possibleKeys = ClientPrefs.keyBinds.get('accept');
			if (possibleKeys != null)
			{
				if (FlxG.keys.anyJustPressed(possibleKeys))
				{
					if (!dodged)
					{
						PlayState.instance.boyfriend.playAnim("dodge", true);
						dodged = true;
					}
				}
			}
		}
		else
		{
			dodged = false;
		}
	}
}

function tweenCancelAndContinue(variable:FlxTween, tween:FlxTween)
{
	if (variable != null)
		if (variable.active)
			variable.cancel();
	variable = tween;
}

function getNote(ID:Int):FlxSprite
{
	return PlayState.instance.strumLineNotes.members[ID % PlayState.instance.strumLineNotes.length];
}

class Cinematics // shit is ass, should rewrite...
{
	public static var StartStop:Float = 0;
	public static var Speed:Float = 0;
	public static var UpperBar:FlxSprite;
	public static var LowerBar:FlxSprite;
	public static var created:Bool = false;

	public static var Cinematics1:FlxTween;
	public static var Cinematics2:FlxTween;
	public static var NOTEMOVE1:FlxTween;
	public static var NOTEMOVE2:FlxTween;
	public static var NOTEMOVE3:FlxTween;
	public static var NOTEMOVE4:FlxTween;
	public static var NOTEMOVE5:FlxTween;
	public static var NOTEMOVE6:FlxTween;
	public static var NOTEMOVE7:FlxTween;
	public static var NOTEMOVE8:FlxTween;
	public static var AlphaTween1:FlxTween;
	public static var AlphaTween2:FlxTween;
	public static var AlphaTween3:FlxTween;
	public static var AlphaTween4:FlxTween;
	public static var AlphaTween5:FlxTween;
	public static var AlphaTween6:FlxTween;
	public static var AlphaTween7:FlxTween;
	public static var AlphaTween8:FlxTween;

	public static function onCreate()
	{
		if (created)
			return;
		else
			created = true;

		UpperBar = new FlxSprite(0, -120).makeGraphic(FlxG.width, 120, FlxColor.BLACK);
		UpperBar.cameras = [PlayState.instance.camGame];
		UpperBar.scrollFactor.set();
		addSpriteToPlayState(UpperBar, false);

		// THE BOTTOM BAR
		LowerBar = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, 120, FlxColor.BLACK);
		LowerBar.cameras = [PlayState.instance.camGame];
		LowerBar.scrollFactor.set();
		addSpriteToPlayState(LowerBar, false);
	}

	public static function tweens()
	{
		if (StartStop == 1)
		{
			if (!ClientPrefs.downScroll)
			{
				tweenCancelAndContinue(Cinematics1, FlxTween.tween(UpperBar, {y: 0}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(Cinematics2, FlxTween.tween(LowerBar, {y: FlxG.height - 120}, Speed, {ease: FlxEase.linear}));

				tweenCancelAndContinue(NOTEMOVE1, FlxTween.tween(getNote(0), {y: 130}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE2, FlxTween.tween(getNote(1), {y: 130}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE3, FlxTween.tween(getNote(2), {y: 130}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE4, FlxTween.tween(getNote(3), {y: 130}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE5, FlxTween.tween(getNote(4), {y: 130}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE6, FlxTween.tween(getNote(5), {y: 130}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE7, FlxTween.tween(getNote(6), {y: 130}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE8, FlxTween.tween(getNote(7), {y: 130}, Speed, {ease: FlxEase.linear}));

				/* tweenCancelAndContinue(AlphaTween1, FlxTween.tween(PlayState.instance.healthBarBG, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween2, FlxTween.tween(PlayState.instance.healthBar, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween3, FlxTween.tween(PlayState.instance.scoreTxt, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween4, FlxTween.tween(PlayState.instance.iconP1, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween5, FlxTween.tween(PlayState.instance.iconP2, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween6, FlxTween.tween(PlayState.instance.timeBar, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween7, FlxTween.tween(PlayState.instance.timeBarBG, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween8, FlxTween.tween(PlayState.instance.timeTxt, {alpha: 0}, 0.1, {ease: FlxEase.linear})); */
			}
			else
			{
				var moveArrowToPos:Float = FlxG.height - 240;
				tweenCancelAndContinue(Cinematics1, FlxTween.tween(UpperBar, {y: 0}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(Cinematics2, FlxTween.tween(LowerBar, {y: FlxG.height - 120}, Speed, {ease: FlxEase.linear}));

				tweenCancelAndContinue(NOTEMOVE1, FlxTween.tween(getNote(0), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE2, FlxTween.tween(getNote(1), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE3, FlxTween.tween(getNote(2), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE4, FlxTween.tween(getNote(3), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE5, FlxTween.tween(getNote(4), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE6, FlxTween.tween(getNote(5), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE7, FlxTween.tween(getNote(6), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE8, FlxTween.tween(getNote(7), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));

				/* tweenCancelAndContinue(AlphaTween1, FlxTween.tween(PlayState.instance.healthBarBG, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween2, FlxTween.tween(PlayState.instance.healthBar, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween3, FlxTween.tween(PlayState.instance.scoreTxt, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween4, FlxTween.tween(PlayState.instance.iconP1, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween5, FlxTween.tween(PlayState.instance.iconP2, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween6, FlxTween.tween(PlayState.instance.timeBar, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween7, FlxTween.tween(PlayState.instance.timeBarBG, {alpha: 0}, 0.1, {ease: FlxEase.linear}));
					tweenCancelAndContinue(AlphaTween8, FlxTween.tween(PlayState.instance.timeTxt, {alpha: 0}, 0.1, {ease: FlxEase.linear})); */
			}
		}
		if (StartStop == 2)
		{
			if (!ClientPrefs.downScroll)
			{
				tweenCancelAndContinue(Cinematics1, FlxTween.tween(UpperBar, {y: -120}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(Cinematics2, FlxTween.tween(LowerBar, {y: FlxG.height}, Speed, {ease: FlxEase.linear}));

				tweenCancelAndContinue(NOTEMOVE1, FlxTween.tween(getNote(0), {y: 50}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE2, FlxTween.tween(getNote(1), {y: 50}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE3, FlxTween.tween(getNote(2), {y: 50}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE4, FlxTween.tween(getNote(3), {y: 50}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE5, FlxTween.tween(getNote(4), {y: 50}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE6, FlxTween.tween(getNote(5), {y: 50}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE7, FlxTween.tween(getNote(6), {y: 50}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE8, FlxTween.tween(getNote(7), {y: 50}, Speed, {ease: FlxEase.linear}));

				tweenCancelAndContinue(AlphaTween2, FlxTween.tween(PlayState.instance.healthBar, {alpha: 1}, 0.1, {ease: FlxEase.linear}));
			}
			else
			{
				var moveArrowToPos:Float = FlxG.height - 150;
				tweenCancelAndContinue(Cinematics1, FlxTween.tween(UpperBar, {y: -120}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(Cinematics2, FlxTween.tween(LowerBar, {y: FlxG.height}, Speed, {ease: FlxEase.linear}));

				tweenCancelAndContinue(NOTEMOVE1, FlxTween.tween(getNote(0), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE2, FlxTween.tween(getNote(1), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE3, FlxTween.tween(getNote(2), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE4, FlxTween.tween(getNote(3), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE5, FlxTween.tween(getNote(4), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE6, FlxTween.tween(getNote(5), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE7, FlxTween.tween(getNote(6), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));
				tweenCancelAndContinue(NOTEMOVE8, FlxTween.tween(getNote(7), {y: moveArrowToPos}, Speed, {ease: FlxEase.linear}));

				tweenCancelAndContinue(AlphaTween2, FlxTween.tween(PlayState.instance.healthBar, {alpha: 1}, 0.1, {ease: FlxEase.linear}));
			}
		}
	}

	public static function onEvent(value1:String, value2:String):Void
	{
		StartStop = Std.parseFloat(value1);
		Speed = Std.parseFloat(value2);
		tweens();
	}
}

class CameraFlash
{
	public static function onEvent(opacity:String = '0.5', duration:String = '0.5'):Void
	{
		var opacity:Float = Std.parseFloat(opacity);
		var duration:Float = Std.parseFloat(duration);
		FlxG.camera.flash(FlxColor.fromRGB(255, 255, 255, Std.int(255 * opacity)), duration);
	}
}

class HudHide
{
	public static function onEvent(visibility:String = 'hide'):Void
	{
		switch (visibility.toLowerCase())
		{
			case 'hide':
				PlayState.instance.camHUD.visible = false;
				PlayState.instance.camOther.visible = false;
			case 'show':
				PlayState.instance.camHUD.visible = true;
				PlayState.instance.camOther.visible = true;
		}
	}
}

class ImageFlash
{
	public static function onEvent(path:Any, duration:Any):Void
	{
		var image:FlxSprite;
		image = new FlxSprite(0, 0).loadGraphic(Paths.image(path));
		function onTweenCompleted(?_:FlxTween):Void
		{
			image.destroy();
		}
		function onTimerCompleted(?_:FlxTimer):Void
		{
			FlxTween.tween(image, {alpha: 0}, 1, {ease: FlxEase.linear, onComplete: onTweenCompleted});
		}
		path = path + "";
		duration = Std.parseFloat(duration);
		PlayState.instance.add(image);
		FlxTween.tween(image, {color: FlxColor.WHITE}, 0, {ease: FlxEase.quartIn});
		image.cameras = [PlayState.instance.camOther];
		new FlxTimer().start(duration, onTimerCompleted);
	}
}

class Start321
{
	private static var countdownReady:FlxSprite;

	private static var countdownSet:FlxSprite;
	private static var countdownGo:FlxSprite;

	private static function three()
	{
		FlxG.sound.play(Paths.sound('intro3' + PlayState.instance.introSoundsSuffix), 1);
	}

	private static function ready()
	{
		countdownReady = new FlxSprite().loadGraphic(Paths.image(PlayState.instance.introAlts[0]));
		PlayState.instance.add(countdownReady);
		countdownReady.cameras = [PlayState.instance.camHUD];
		countdownReady.scrollFactor.set();
		countdownReady.updateHitbox();

		if (PlayState.isPixelStage)
			countdownReady.setGraphicSize(Std.int(countdownReady.width * PlayState.daPixelZoom));

		countdownReady.screenCenter();
		countdownReady.antialiasing = !PlayState.isPixelStage;

		FlxTween.tween(countdownReady, {/*y: countdownReady.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				PlayState.instance.remove(countdownReady);
				countdownReady.destroy();
			}
		});
		FlxG.sound.play(Paths.sound('intro2' + PlayState.instance.introSoundsSuffix), 1);
	}

	private static function set()
	{
		countdownSet = new FlxSprite().loadGraphic(Paths.image(PlayState.instance.introAlts[1]));
		PlayState.instance.add(countdownSet);
		countdownSet.cameras = [PlayState.instance.camHUD];
		countdownSet.scrollFactor.set();

		if (PlayState.isPixelStage)
			countdownSet.setGraphicSize(Std.int(countdownSet.width * PlayState.daPixelZoom));

		countdownSet.screenCenter();
		countdownSet.antialiasing = !PlayState.isPixelStage;

		FlxTween.tween(countdownSet, {/*y: countdownSet.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				PlayState.instance.remove(countdownSet);
				countdownSet.destroy();
			}
		});
		FlxG.sound.play(Paths.sound('intro1' + PlayState.instance.introSoundsSuffix), 1);
	}

	private static function go()
	{
		countdownGo = new FlxSprite().loadGraphic(Paths.image(PlayState.instance.introAlts[2]));
		PlayState.instance.add(countdownGo);

		countdownGo.cameras = [PlayState.instance.camHUD];
		countdownGo.scrollFactor.set();

		if (PlayState.isPixelStage)
			countdownGo.setGraphicSize(Std.int(countdownGo.width * PlayState.daPixelZoom));

		countdownGo.updateHitbox();

		countdownGo.screenCenter();
		countdownGo.antialiasing = !PlayState.isPixelStage;

		FlxTween.tween(countdownGo, {/*y: countdownGo.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				PlayState.instance.remove(countdownGo);
				countdownGo.destroy();
			}
		});
		FlxG.sound.play(Paths.sound('introGo' + PlayState.instance.introSoundsSuffix), 1);
	}

	public static function onEvent(val1:String)
	{
		if (PlayState.recordMode)
		{
			return;
		}
		switch (val1.toLowerCase())
		{
			case '3':
				three();
			case '2':
				ready();
			case '1':
				set();
			case 'go':
				go();
		}
	}
}

class Lyrics_BfSide
{
	private static var yappin:FlxText; // why tf did this define a new flxtext everytime before
	private static var createdYap:Bool = false;
	private static var timer:FlxTimer = new FlxTimer();

	public static function onEvent(val1:String, val2:String):Void
	{
		var string:String = val1 + ""; // make sure its a string
		var length:Float;
		if (val2 != '')
		{
			length = Std.parseFloat(val2);
		}
		else
		{
			length = 0.3;
		}
		if (!createdYap)
		{
			yappin = new FlxText(500, 50, 0);
			yappin.setFormat(Paths.font('vcr.ttf'), 35, FlxColor.fromString('0x1950a8'), CENTER);
			yappin.cameras = [PlayState.instance.camHUD];

			PlayState.instance.add(yappin);
			createdYap = true;
		}
		yappin.text = string;
		yappin.screenCenter(X);
		timer.cancel();
		timer = new FlxTimer().start(length, (?_:FlxTimer) ->
		{
			yappin.text = "";
		}, 1);
	}
}

class Lyrics_MegaSide
{
	private static var yappin:FlxText; // why tf did this define a new flxtext everytime before
	private static var createdYap:Bool = false;
	private static var timer:FlxTimer = new FlxTimer();

	public static function onEvent(val1:Any, val2:Any):Void
	{
		var string:String = val1 + ""; // make sure its a string
		var length:Float;
		if (val2 != '')
		{
			length = Std.parseFloat(val2);
		}
		else
		{
			length = 0.3;
		}
		if (!createdYap)
		{
			yappin = new FlxText(500, 50, 0);
			yappin.setFormat(Paths.font('vcr.ttf'), 35, FlxColor.fromString('0xffa600'), CENTER);
			yappin.cameras = [PlayState.instance.camHUD];
			PlayState.instance.add(yappin);
			createdYap = true;
		}
		yappin.text = string;
		yappin.screenCenter(X);

		timer.cancel();
		timer = new FlxTimer().start(length, (?_:FlxTimer) ->
		{
			yappin.text = "";
		}, 1);
	}
}

class Lyrics_OppSide
{
	private static var yappin:FlxText; // why tf did this define a new flxtext everytime before
	private static var createdYap:Bool = false;
	private static var timer:FlxTimer = new FlxTimer();

	public static function onEvent(val1:Any, val2:Any):Void
	{
		var string:String = val1 + ""; // make sure its a string
		var length:Float;
		if (val2 != '')
		{
			length = Std.parseFloat(val2);
		}
		else
		{
			length = 0.3;
		}
		if (!createdYap)
		{
			yappin = new FlxText(450, 650, 0);
			yappin.setFormat(Paths.font('vcr.ttf'), 35, FlxColor.fromString('0x3f454f'), CENTER);
			yappin.cameras = [PlayState.instance.camHUD];
			PlayState.instance.add(yappin);
			createdYap = true;
		}
		yappin.text = string;
		yappin.screenCenter(X);

		timer.cancel();
		timer = new FlxTimer().start(length, (?_:FlxTimer) ->
		{
			yappin.text = "";
		}, 1);
	}
}

class SkipSection
{
	private static var skipTime:Float = -1;

	public static function reset()
	{
		SkipSection.skipTime = -1;
	}

	public static function onEvent(time:String, val2:String)
	{
		SkipSection.skipTime = Std.parseFloat(time) * 1000;
	}

	public static function skip()
	{
		PlayState.instance.clearNotesBefore(SkipSection.skipTime);
		PlayState.instance.setSongTime(SkipSection.skipTime);
	}

	public static function update(elapsed:Float)
	{
		if (SkipSection.skipTime != -1)
		{
			if (PlayerSettings.player1.controls.ACCEPT)
			{
				skip();
				reset();
			}
		}
	}
}
