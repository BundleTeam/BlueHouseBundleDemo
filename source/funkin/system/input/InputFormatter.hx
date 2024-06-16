package funkin.system.input;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

using StringTools;

class InputFormatter
{
	public static function getKeyName(key:FlxKey):String
	{
		switch (key)
		{
			case BACKSPACE:
				return "BckSpc";
			case CONTROL:
				return "Ctrl";
			case ALT:
				return "Alt";
			case CAPSLOCK:
				return "Caps";
			case PAGEUP:
				return "PgUp";
			case PAGEDOWN:
				return "PgDown";
			case ZERO:
				return "0";
			case ONE:
				return "1";
			case TWO:
				return "2";
			case THREE:
				return "3";
			case FOUR:
				return "4";
			case FIVE:
				return "5";
			case SIX:
				return "6";
			case SEVEN:
				return "7";
			case EIGHT:
				return "8";
			case NINE:
				return "9";
			case NUMPADZERO:
				return "Num0";
			case NUMPADONE:
				return "Num1";
			case NUMPADTWO:
				return "Num2";
			case NUMPADTHREE:
				return "Num3";
			case NUMPADFOUR:
				return "Num4";
			case NUMPADFIVE:
				return "Num5";
			case NUMPADSIX:
				return "Num6";
			case NUMPADSEVEN:
				return "Num7";
			case NUMPADEIGHT:
				return "Num8";
			case NUMPADNINE:
				return "Num9";
			case NUMPADMULTIPLY:
				return "Num*";
			case NUMPADPLUS:
				return "Num+";
			case NUMPADMINUS:
				return "Num-";
			case NUMPADPERIOD:
				return "Num.";
			case SEMICOLON:
				return ";";
			case COMMA:
				return ",";
			case PERIOD:
				return ".";
			case SLASH:
				return "Slash";
			case GRAVEACCENT:
				return "Tilda";
			case LBRACKET:
				return "[";
			case BACKSLASH:
				return "BckSlash";
			case RBRACKET:
				return "]";
			case QUOTE:
				return "'";
			case PRINTSCREEN:
				return "PrtScrn";
			case NONE:
				return '---';
			default:
				var label:String = '' + key;
				if (label.toLowerCase() == 'null')
					return '---';
				return '' + label.charAt(0).toUpperCase() + label.substr(1).toLowerCase();
		}
	}
}
