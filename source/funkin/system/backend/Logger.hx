package funkin.system.backend;

import funkin.system.backend.Hardware.OS;
import haxe.PosInfos;

class Logger
{
	public function new()
	{
	}

	private function format(string:String, ?pos:PosInfos, ?noTime:Bool = false):String
	{
		var prefix:String = "";
		if (!noTime)
		{
			var hours:String = Std.string(Date.now().getHours());
			if (hours.length == 1)
			{
				hours = "0" + hours;
			}
			var minutes:String = Std.string(Date.now().getMinutes());
			if (minutes.length == 1)
			{
				minutes = "0" + minutes;
			}
			var seconds:String = Std.string(Date.now().getSeconds());
			if (seconds.length == 1)
			{
				seconds = "0" + seconds;
			}
			prefix += '[${hours + ":" + minutes + ":" + seconds}]';
		}
		if (pos != null)
		{
			prefix += ' ${pos.fileName}:${pos.lineNumber}';
		}
		return prefix + ': ${string}';
	}

	public function log(v:Dynamic, ?pos:PosInfos, ?noTime:Bool = false)
	{
		#if web
		js.html.Console.log(format(Std.string(v), pos, noTime));
		#elseif sys
		Sys.println(format(Std.string(v), pos, noTime));
		#else
		haxe.Log.trace(format(Std.string(v), pos, noTime), null);
		#end
	}
}
