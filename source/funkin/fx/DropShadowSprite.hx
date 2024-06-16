package funkin.fx;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;

class DropShadowSprite extends FlxSpriteGroup
{
	public var sprite:FlxSprite;
	public var dropShadow:FlxSprite;

	private var __opacity:Float;

	public function new(Graphic:FlxGraphicAsset, ?X:Float = 0, ?Y:Float = 0, ShadowXOffset:Float = 2, ShadowYOffset:Float = 6, Opacity:Float = 0.25)
	{
		super(X, Y);
		dropShadow = new FlxSprite();
		this.add(dropShadow);
		sprite = new FlxSprite();
		sprite.loadGraphic(Graphic);

		this.add(sprite);
		dropShadow.pixels = sprite.pixels;
		dropShadow.x += ShadowXOffset;
		dropShadow.y += ShadowYOffset;
		dropShadow.setColorTransform(0, 0, 0);
		dropShadow.alpha = Opacity;
		__opacity = Opacity;
	}

	public override function update(elapsed:Float)
	{
		if (sprite.pixels != null)
		{
			dropShadow.alpha = this.alpha * __opacity;
		}
		super.update(elapsed);
	}
}
