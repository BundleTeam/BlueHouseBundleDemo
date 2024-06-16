package funkin.system;

import flixel.addons.ui.FlxUISlider;

class FlxUIMultipleSlider extends FlxUISlider
{
	public var multiple:Float = -1;

	override function updateValue():Void
	{
		if (_lastPos != relativePos)
		{
			if ((setVariable) && (varString != null))
			{
				if (multiple != -1)
					Reflect.setProperty(_object, varString, FNKMath.roundToMultiple((relativePos * (maxValue - minValue)) + minValue, multiple));
				else
				{
					Reflect.setProperty(_object, varString, (relativePos * (maxValue - minValue)) + minValue);
				}
			}

			_lastPos = relativePos;

			if (callback != null)
				callback(relativePos);
		}
	}
}
