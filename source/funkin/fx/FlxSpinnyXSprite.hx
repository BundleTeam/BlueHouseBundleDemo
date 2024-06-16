package funkin.fx;

import flixel.math.FlxMath;
import flixel.FlxSprite;

class FlxSpinnyXSprite extends FlxSprite
{
	public var spinny3D:Float = 0;
	public var spinny3DDefaultScale:Float = 1;

	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
	}

	public override function update(elapsed:Float)
	{
		scale.x = FNKMath.fastCos((spinny3D * 6.4)) * spinny3DDefaultScale;
		super.update(elapsed);
	}
}
