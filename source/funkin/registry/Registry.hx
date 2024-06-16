package funkin.registry;

import flixel.util.FlxStringUtil;

class Registry<T:Any>
{
	public var list:Array<T>;

	public function new()
	{
		list = [];
	}

	public function registerAll()
	{
	}

	public function add(item:T):T
	{
		for (listItem in list)
		{
			if (FlxStringUtil.sameClassName(item, listItem))
				return item;
		}

		// No repeats found
		list.push(item);
		return item;
	}

	public function remove(item:T):Bool
	{
		for (listItem in list)
		{
			if (listItem == item || FlxStringUtil.sameClassName(item, listItem))
				return true;
		}
		return false;
	}
}
