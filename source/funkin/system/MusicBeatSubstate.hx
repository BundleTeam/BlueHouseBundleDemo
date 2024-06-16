package funkin.system;

import funkin.ui.notifications.NotificationManager;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import funkin.system.input.Controls;
import funkin.user.PlayerSettings;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		FlxSprite.defaultAntialiasing = ClientPrefs.globalAntialiasing;
		if (!FNK.stopDumbMouseParsecBugBecauseItsAnnoyingAsFuck)
		{
			var cursorSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image('selectCursor'));
			FlxG.mouse.load(cursorSprite.pixels);
		}
		super();
	}

	private var lastBeat:Float32 = 0;
	private var lastStep:Float32 = 0;

	private var curStep:Int32 = 0;
	private var curBeat:Int32 = 0;

	private var curDecStep:Float32 = 0;
	private var curDecBeat:Float32 = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function update(elapsed:Float)
	{
		FlxSprite.defaultAntialiasing = ClientPrefs.globalAntialiasing;

		// everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
