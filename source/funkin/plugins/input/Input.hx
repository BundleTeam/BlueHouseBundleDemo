package funkin.plugins.input;

import flixel.FlxBasic;
import flixel.FlxG;

class Input extends FlxBasic
{
	public static var curType:EnumValue = InputTypes.KEYBOARD;

	public function new()
	{
		super();
	}

	public override function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.ANY || FlxG.mouse.wheel != 0) // mouse wheel is treated as a key as it isnt the mouse moving or any mouse button
		{
			curType = InputTypes.KEYBOARD;
		}
		else if (FlxG.mouse.justMoved)
		{
			curType = InputTypes.MOUSE;
		}
		else if (FlxG.gamepads.anyInput())
		{
			curType = InputTypes.CONTROLLER;
		}
		else
		{
			for (touch in FlxG.touches.list)
			{
				if (touch.pressed)
				{
					curType = InputTypes.TOUCH;
					break;
				}
			}
		}
		super.update(elapsed);
	}
}
