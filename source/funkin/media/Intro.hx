package funkin.media;

import funkin.menus.MainMenuState;
import openfl.Assets;
import flixel.input.gamepad.FlxGamepadInputID;
import funkin.menus.TitleState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxState;
import flxgif.FlxGifSprite;

class Intro extends FlxState
{
	var introGIF:FlxGifSprite = new FlxGifSprite(0, 0);
	var startedSound:Bool = false;
	var canStart:Bool = false;
	var stateToSwitchTo:Class<FlxState> = TitleState;

	public override function create()
	{
		#if html5
		var onHTML5MOBILE:Bool = FlxG.html5.onMobile;
		if (onHTML5MOBILE)
		{
			finish();
			return;
		}
		#end
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}
		FlxG.autoPause = false;
		// var future:openfl.utils.Future<openfl.utils.ByteArray> = Assets.loadBytes('assets/images/intro.gif').onComplete((bytes) ->
		// {
		//	introGIF.loadGif(bytes);
		//	introGIF.screenCenter();
		//	add(introGIF);
		//	canStart = true;
		// });
		finish();
		super.create();
	}

	function finish()
	{
		FlxG.sound.pause();
		var state:Class<FlxState> = stateToSwitchTo;
		var _requestedState:MusicBeatState = cast Type.createInstance(state, []);
		MusicBeatState.switchState(_requestedState);
	}

	public override function update(elapsed:Float)
	{
		if (canStart)
		{
			if (!startedSound)
			{
				{
					FlxG.sound.play(Paths.sound('intro'), 1, false, null, true, () ->
					{
						FlxG.camera.fade(FlxColor.BLACK, 0.75, false, function()
						{
							finish();
						});
					});
					startedSound = true;
				}
			}
		}
		if (startedSound)
		{
			if (FlxG.keys.justPressed.ANY || (FlxG.gamepads.anyJustPressed(FlxGamepadInputID.ANY)))
			{
				finish();
			}
		}

		super.update(elapsed);
	}
}
