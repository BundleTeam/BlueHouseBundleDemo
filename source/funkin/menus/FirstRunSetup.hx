package funkin.menus;

import funkin.system.backend.Hardware.OS;
import funkin.media.Intro;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import funkin.media.HFIntro;

class FirstRunSetup extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var state:FlxState = new HFIntro();

	var warnText:FlxText;

	override function create()
	{
		super.create();
		FlxG.fixedTimestep = false;
		if (ClientPrefs.flashing == null)
		{
			warnText = new FlxText(0, 0, FlxG.width,
				"Press enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter to enter\n\n:)",
				32);
			warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
			warnText.screenCenter(Y);
			add(warnText);
		}
		else
		{
			#if html5
			warnText = new FlxText(0, 0, FlxG.width, "Click or press any key to enable audio.", 32);
			warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
			warnText.screenCenter(Y);
			add(warnText);
			#else
			leftState = true;

			MusicBeatState.switchState(state);
			#end
		}
	}

	override function update(elapsed:Float)
	{
		if (controls != null)
		{
			if (!leftState)
			{
				if (ClientPrefs.flashing == null)
				{
					if (controls.ACCEPT || controls.BACK)
					{
						leftState = true;
						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;

						if (controls.ACCEPT)
						{
							ClientPrefs.flashing = false;
							ClientPrefs.saveSettings();
							FlxG.sound.play(Paths.sound('confirmMenu'));
							FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker)
							{
								new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									if (leftState)
									{
										MusicBeatState.switchState(state);
									}
								});
							});
						}
						else if (controls.BACK)
						{
							FlxG.sound.play(Paths.sound('cancelMenu'));
							FlxTween.tween(warnText, {alpha: 0}, 1, {
								onComplete: function(twn:FlxTween)
								{
									if (leftState)
									{
										MusicBeatState.switchState(state);
									}
								}
							});
						}
					}
				}
			}
		}

		#if html5
		if (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed || FlxG.mouse.justPressedRight || FlxG.mouse.justPressedMiddle)
		{
			leftState = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			// js.Lib.eval("navigator.keyboard.lock()");
			FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker)
			{
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(state);
				});
			});
		}
		#end
		super.update(elapsed);
	}
}
