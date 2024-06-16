package funkin.fx;

import flixel.util.FlxColor;
import haxe.io.Bytes;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.util.FlxTimer;
import lime.media.AudioBuffer;
import openfl.geom.Rectangle;

// this code is really bad and messy because i dont understand half of it and i half ripped it out of charting state.hx
// - letsgoaway
class WaveformSprite extends FlxSprite
{
	public var speed:Float = 0.4;
	public var size:Float = 20;
	public var length:Int = 0;
	public var multiplier:Float = 0.5;
	public var gSize:Int = 480;
	public var hSize:Int;
	public var sound:FlxSound = FlxG.sound.music;
	public var loudnessThingy:Float = 0.00;
	public var waveColor:FlxColor;

	private var timer:FlxTimer;

	public function new(X, Y, wavesColor:FlxColor = 0x70FFFFFF)
	{
		super(X, Y);
		waveColor = wavesColor;
		hSize = Std.int(gSize / 2);
		makeGraphic(gSize, gSize, 0x00FFFFFF);

		angle = 270;
		timer = new FlxTimer().start(1 / 60, (?_) ->
		{
			if (alpha != 0)
			{
				updateWaveform();
			}
		}, 0);
	}

	var waveformPrinted:Bool = true;

	var wavData:Array<Array<Array<Float>>> = [[[0], [0]], [[0], [0]]];

	public override function update(elapsed:Float)
	{
		antialiasing = false;

		super.update(elapsed);
	}

	public override function destroy()
	{
		timer.destroy();
		super.destroy();
	}

	function waveformData(buffer:AudioBuffer, bytes:Bytes, time:Float, endTime:Float, multiply:Float = 1, ?array:Array<Array<Array<Float>>>,
			?steps:Float):Array<Array<Array<Float>>>
	{
		#if (lime_cffi && !macro)
		if (buffer == null || buffer.data == null)
			return [[[0], [0]], [[0], [0]]];

		var khz:Float = (buffer.sampleRate / 1000);
		var channels:Int = buffer.channels;

		var index:Int = Std.int(time * khz);

		var samples:Float = ((endTime - time) * khz);

		if (steps == null)
			steps = 44100;

		var samplesPerRow:Float = samples / steps;
		var samplesPerRowI:Int = Std.int(samplesPerRow);

		var gotIndex:Int = 0;

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var rows:Float = 0;

		var simpleSample:Bool = true; // samples > 17200;
		var v1:Bool = false;

		if (array == null)
			array = [[[0], [0]], [[0], [0]]];

		while (index < (bytes.length - 1))
		{
			if (index >= 0)
			{
				var byte:Int = bytes.getUInt16(index * channels * 2);

				if (byte > 65535 / 2)
					byte -= 65535;

				var sample:Float = (byte / 65535);

				if (sample > 0)
				{
					if (sample > lmax)
						lmax = sample;
				}
				else if (sample < 0)
				{
					if (sample < lmin)
						lmin = sample;
				}

				if (channels >= 2)
				{
					byte = bytes.getUInt16((index * channels * 2) + 2);

					if (byte > 65535 / 2)
						byte -= 65535;

					sample = (byte / 65535);

					if (sample > 0)
					{
						if (sample > rmax)
							rmax = sample;
					}
					else if (sample < 0)
					{
						if (sample < rmin)
							rmin = sample;
					}
				}
			}

			v1 = samplesPerRowI > 0 ? (index % samplesPerRowI == 0) : false;
			while (simpleSample ? v1 : rows >= samplesPerRow)
			{
				v1 = false;
				rows -= samplesPerRow;

				gotIndex++;

				var lRMin:Float = Math.abs(lmin) * multiply;
				var lRMax:Float = lmax * multiply;

				var rRMin:Float = Math.abs(rmin) * multiply;
				var rRMax:Float = rmax * multiply;

				if (gotIndex > array[0][0].length)
					array[0][0].push(lRMin);
				else
					array[0][0][gotIndex - 1] = array[0][0][gotIndex - 1] + lRMin;

				if (gotIndex > array[0][1].length)
					array[0][1].push(lRMax);
				else
					array[0][1][gotIndex - 1] = array[0][1][gotIndex - 1] + lRMax;

				if (channels >= 2)
				{
					if (gotIndex > array[1][0].length)
						array[1][0].push(rRMin);
					else
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + rRMin;

					if (gotIndex > array[1][1].length)
						array[1][1].push(rRMax);
					else
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + rRMax;
				}
				else
				{
					if (gotIndex > array[1][0].length)
						array[1][0].push(lRMin);
					else
						array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + lRMin;

					if (gotIndex > array[1][1].length)
						array[1][1].push(lRMax);
					else
						array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + lRMax;
				}

				lmin = 0;
				lmax = 0;

				rmin = 0;
				rmax = 0;
			}

			index++;
			rows++;
			if (gotIndex > steps)
				break;
		}

		return array;
		#else
		return [[[0], [0]], [[0], [0]]];
		#end
	}

	function updateWaveform()
	{
		#if desktop
		if (waveformPrinted)
		{
			makeGraphic(480, 480, 0x00FFFFFF);
			pixels.fillRect(new Rectangle(0, 0, 480, 480), 0x00FFFFFF);
		}
		waveformPrinted = false;

		wavData[0][0] = [];
		wavData[0][1] = [];
		wavData[1][0] = [];
		wavData[1][1] = [];

		var st:Float = sound.time - (500 * speed);
		var et:Float = sound.time + (500 * speed);
		@:privateAccess
		if (sound._sound != null && sound._sound.__buffer != null)
		{
			var bytes:Bytes = sound._sound.__buffer.data.toBytes();

			wavData = waveformData(sound._sound.__buffer, bytes, st, et, multiplier, wavData, 32);
		}

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var leftLength:Int = (wavData[0][0].length > wavData[0][1].length ? wavData[0][0].length : wavData[0][1].length);

		var rightLength:Int = (wavData[1][0].length > wavData[1][1].length ? wavData[1][0].length : wavData[1][1].length);

		length = leftLength > rightLength ? leftLength : rightLength;

		var index:Int;
		for (i in 0...length)
		{
			index = i;

			lmin = FlxMath.bound(((index < wavData[0][0].length && index >= 0) ? wavData[0][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			lmax = FlxMath.bound(((index < wavData[0][1].length && index >= 0) ? wavData[0][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			rmin = FlxMath.bound(((index < wavData[1][0].length && index >= 0) ? wavData[1][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			rmax = FlxMath.bound(((index < wavData[1][1].length && index >= 0) ? wavData[1][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			if (i == Math.floor(length / 2))
				loudnessThingy = (lmin + rmin) + (lmax + rmax);
			pixels.fillRect(new Rectangle(hSize - (lmin + rmin), i * size, (lmin + rmin) + (lmax + rmax), size), waveColor);
		}

		waveformPrinted = true;
		#end
	}
}
