package funkin.menus.options;

import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxTimer;
import openfl.Lib;

class LatencyState extends FlxUIState
{
	var latencyDisplay:FlxText;
	var detectedBpm:FlxText;
	var toggler:FlxButton;

	// NOTE:
	//  60,000 / BPM = [one beat in ms]
	//
	//  BPM = 60000 / [one beat in ms]
	var latencies:Array<Float> = [];
	var lastBeatAt:Float;

	// bpm detection
	var currentBpmInMs:Float = 0;
	var bpmIntervals:Array<Float> = [];
	var bpmLastTimestamp:Null<Float> = 0;
	var tempo:Float = 120;

	var isRunning:Bool = false;

	function getCurrentTime():Float
	{
		#if sys
		return Sys.time();
		#elseif html5
		return js.lib.Date.now();
		#else
		return Date.now().getTime();
		#end
	}

	var timer:FlxTimer;

	function start(?_:Dynamic):Void
	{
		bpmIntervals = [];
		latencies = [];
		if (isRunning)
		{
			timer = new FlxTimer().start(currentBpmInMs / 1000, (?_) ->
			{
				FlxG.sound.play(Paths.hitsound('default'));
				lastBeatAt = Date.now().getTime();
			}, 60);
		}
	}

	function slidingWindowAverageOf(array:Array<Float>, amount:Int = 10):Float
	{
		var subArray:Array<Float> = array.slice(amount, array.length - 1);
		var sum:Float = 0;
		for (current in subArray)
		{
			sum += current;
		}

		return sum / subArray.length;
	}

	function toggle():Null<Void>
	{
		isRunning = !isRunning;
		toggler.text = isRunning ? 'Stop' : 'Start';
		currentBpmInMs = 60000 / tempo;
		if (isRunning)
			start();
		else
		{
			timer.cancel();
		}
		return;
	}

	var msDelay:Float = 0.00;

	function handleUserBeat()
	{
		var userBeatAt:Float = Date.now().getTime();

		var latency:Float = userBeatAt - lastBeatAt;
		latencies.push(latency);

		if (latencies.length > 10)
		{
			msDelay = slidingWindowAverageOf(latencies);
			latencyDisplay.text = 'MS Delay (Average): ${FlxMath.roundDecimal(msDelay, 2)}';
		}

		bpmDetector();
	}

	function bpmDetector()
	{
		var newTimestamp:Float = Date.now().getTime();
		var interval:Float = newTimestamp - bpmLastTimestamp;
		bpmIntervals.push(interval);
		bpmLastTimestamp = Date.now().getTime();
		if (bpmIntervals.length > 10)
		{
			var avg = slidingWindowAverageOf(bpmIntervals);
			var bpm = 60000 / avg;
			Funkin.log('bpm ' + bpm);
			detectedBpm.text = 'BPM: ${FlxMath.roundDecimal(bpm, 2)}';
		}
	}

	function exit():Void
	{
		FlxG.sound.music.play(true);
		MusicBeatState.switchState(new MainMenuState());
	}

	var promptShown:Bool = false;

	public override function update(elapsed:Float)
	{
		toggler.screenCenter();
		latencyDisplay.screenCenter();
		latencyDisplay.y += 20;
		detectedBpm.screenCenter();
		detectedBpm.y += 40;
		super.update(elapsed);
		if (FlxG.keys.justReleased.ESCAPE)
		{
			promptShown = true;
			FlxG.state.openSubState(new Prompt('Save offset of ${FlxMath.roundDecimal(msDelay, 0)}?', 0, () ->
			{
				ClientPrefs.noteOffset = Std.int(FlxMath.roundDecimal(msDelay, 0));
				ClientPrefs.saveSettings();

				if (ClientPrefs.noteOffset >= 20 && ClientPrefs.hitsoundVolume != 0)
				{
					FlxG.state.openSubState(new Prompt('Having Hitsounds on while having a high\naudio latency can throw you off course and\nmake the gameplay\nfeel out of sync.\n\nTurn them off?',
						0, () ->
						{
							ClientPrefs.hitsoundVolume = 0;
							ClientPrefs.saveSettings();
							exit();
						}, exit, false, 'Yes', 'No'));
				}
				else
					exit();
			}, exit, false, 'Save', "Don't Save"));
		}
	}

	var onKeyDownFunc:(lime.ui.KeyCode, lime.ui.KeyModifier) -> Void;
	var onMouseDownFunc:(Float, Float, lime.ui.MouseButton) -> Void;

	public override function destroy()
	{
		Lib.application.window.onKeyDown.remove(onKeyDownFunc);
		Lib.application.window.onMouseDown.remove(onMouseDownFunc);

		super.destroy();
	}

	public override function create()
	{
		onKeyDownFunc = (?key, ?__) ->
		{
			if (!FlxG.keys.pressed.ESCAPE && key == 27 && isRunning)
				handleUserBeat();
		};
		onMouseDownFunc = (?_, ?__, ?__) ->
		{
			if (!FlxG.mouse.overlaps(toggler) && isRunning)
				handleUserBeat();
		};
		super.create();
		FlxG.sound.music.pause();
		toggler = new FlxButton(0, 0, 'Start', () ->
		{
			toggle();
		});
		add(toggler);

		latencyDisplay = new FlxText(0, 20);
		add(latencyDisplay);

		detectedBpm = new FlxText(0, 40);
		add(detectedBpm);

		Lib.application.window.onKeyDown.add(onKeyDownFunc);
		Lib.application.window.onMouseDown.add(onMouseDownFunc);
	}
}
