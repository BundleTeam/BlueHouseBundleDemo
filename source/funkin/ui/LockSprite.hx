package funkin.ui;

import flixel.FlxSprite;

class LockSprite extends FlxSprite
{
	public function new()
	{
		super(0, 0);
		this.frames = Paths.getSparrowAtlas("lock");
		this.animation.addByPrefix("lock", "lock", 30, !ClientPrefs.lowQuality);
		this.animation.play("lock", true);
	}
}
