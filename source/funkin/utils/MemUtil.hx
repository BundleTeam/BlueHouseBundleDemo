package funkin.utils;

import funkin.ui.notifications.NotificationManager;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import openfl.system.System;
#if cpp
import cpp.vm.Gc;
#end

class MemUtil
{
	// run ALL the garbage collector for good measure lmfao
	public static function clearImageCaches()
	{
		FlxG.bitmap.clearUnused();
		Paths.clearUnusedMemory();
		System.gc();
		#if cpp
		Gc.setMinimumFreeSpace(104857600);
		Gc.setMinimumWorkingMemory(0);
		Gc.enable(true);
		Gc.run(true);
		Gc.compact();
		#end
		if (NotificationManager.instance != null && NotificationManager.instance.notifs.length > 0)
		{
			return;
		}
		FlxG.bitmap.clearCache();
		Paths.clearStoredMemory();
	}

	public static function destroyAllSprites(state:FlxState, ?clearCaches:Bool = false, ?destroyAllFlxDestoyables = false)
	{
		/*
			for (obj in state.members)
			{
				if (Std.isOfType(obj, FlxSprite))
				{
					obj.destroy();
				}
			}
			if (destroyAllFlxDestoyables)
			{
				for (obj in state.members)
				{
					if (Std.isOfType(obj, flixel.util.FlxDestroyUtil.IFlxDestroyable))
					{
						obj.destroy();
					}
				}
			}
			if (clearCaches)
				clearImageCaches();
		 */
	}
}
