package funkin.ui;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;

class GridBG extends FlxBackdrop
{
	public function new(CellWidth:Int = 80, CellHeight:Int = 80, Width:Int = 160, Height:Int = 160, Alternate:Bool = true, Color1:FlxColor = 0x0EFFFFFF,
			Color2:FlxColor = 0x0, Velocity:Float = 40)
	{
		super(FlxGridOverlay.createGrid(CellWidth, CellHeight, Width, Height, Alternate, Color1, Color2));
		this.velocity.set(Velocity, Velocity);
		this.alpha = 0;
	}

	public function fadeIn(duration:Float = 0.5, ?options:Null<TweenOptions>)
	{
		FlxTween.tween(this, {alpha: 1}, duration, options);
	}

	public function fadeOut(duration:Float = 0.5, ?options:Null<TweenOptions>)
	{
		FlxTween.tween(this, {alpha: 0}, duration, options);
	}
}
