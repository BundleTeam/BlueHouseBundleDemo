package funkin.ui;

import flixel.FlxObject;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import flixel.FlxG;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

/**
 * `HorizontalScrollerSprite` class created by LetsGoAway
 * Feel free to use for any haxeflixel project, no credit is required;
 * This is a sprite group that scrolls horizontally, you can use this for some cool visual effects and user interfaces
 * Scrolling to the Left works only for now
 */
class HorizontalScrollerSprite extends FlxTypedSpriteGroup<FlxSprite>
{
	// TODO: Make right direction work and spacing
	public var movementSpeed:Float = -1;

	private var graphicAsset:FlxGraphicAsset;

	/**
	 * Initialize the scroller Sprite
	 * @param X 			X Position of the Sprite, it is reccomended to leave this at `0` if you want it to scroll across the screen.
	 * @param Y 			Y Position of the Scroller Sprite, change this to whatever you would like
	 * @param movementSpeed Speed of the scroll, negative numbers are scrolling left, positive numbers scroll right
	 * @param spacing 		Distance between each repeated sprite
	 */
	public function new(?X:Int = 0, ?Y:Int = 0, ?movementSpeed:Float = -1)
	{
		this.movementSpeed = movementSpeed;
		super(X, Y);
	}

	/**
	 * Load an image from an embedded graphic file.
	 *
	 * HaxeFlixel's graphic caching system keeps track of loaded image data.
	 * When you load an identical copy of a previously used image, by default
	 * HaxeFlixel copies the previous reference onto the `pixels` field instead
	 * of creating another copy of the image data, to save memory.
	 *
	 * @param   graphic      The image you want to use.
	 * @param   animated     doesnt work as it usually does, just for InitialLoadState.hx to not have clientprefs screw everything
	 * @param   frameWidth   doesnt work LOL
	 *                       doesnt work LOL
	 * @param   frameHeight  doesnt work LOL
	 *                       doesnt work LOL
	 * @param   unique       doesnt work LOL
	 *                       doesnt work LOL
	 *                       doesnt work LOL
	 * @param   key          doesnt work LOL
	 * @return  This `HorizontalScrollerSprite` instance (nice for chaining stuff together, if you're into that).
	 */
	public override function loadGraphic(graphic:flixel.system.FlxAssets.FlxGraphicAsset, animated:Bool = false, frameWidth:Int = 0, frameHeight:Int = 0,
			unique:Bool = false, ?key:Null<String>):FlxSprite
	{
		graphicAsset = graphic;

		var sprite:FlxSprite = new FlxSprite().loadGraphic(graphicAsset, animated, frameWidth, frameHeight, unique, key);
		add(sprite);

		var amountOfSpritesNeeded:Int = 0;
		// (spr.width * amount of sprites)/screenWidth = amount covering width and we need it to be above 1 because it scrolls i think
		while ((sprite.frameWidth * amountOfSpritesNeeded) / FlxG.width < 1)
		{
			amountOfSpritesNeeded++;
		}
		amountOfSpritesNeeded += 1; // other wise it just pops into existance

		var amountOfSpritesAdded:Int = 1;
		while (amountOfSpritesAdded != amountOfSpritesNeeded)
		{
			var sprite:FlxSprite = new FlxSprite().loadGraphic(graphicAsset, animated, frameWidth, frameHeight, unique, key);
			add(sprite);
			amountOfSpritesAdded++;
		}

		// Lib.application.window.alert(Std.string(amountOfSpritesAdded));
		return this;
	}

	/**
	 * Returns: 
	 * 
	 * `null` if it is equal to 0
	 * 
	 * `true` if it is positive
	 * 
	 * `false` if it is negative
	 * @param num Number to check.
	 * @return See above.
	 */
	private function numIsPositive(num:Float):Null<Bool>
	{
		if (num == 0)
			return null;
		else if (num > 0)
			return true;
		else
			return false;
	}

	public override function update(elapsed:Float)
	{
		if (this.members.length != 0)
		{
			var i:Int = 0;

			for (sprite in this.members)
			{
				if (i == 0)
					sprite.x += movementSpeed * (elapsed * 60);
				else
					sprite.x = (this.members[0].x + (this.members[0].frameWidth) * i);

				if (((sprite.x + sprite.frameWidth) < 0) || sprite.isOnScreen(get_camera()) == false)
				{
					remove(sprite, true);
					add(sprite);
					sprite.x = (this.members[0].x + (this.members[0].frameWidth) * (this.members.length - 1));
				}
				i++;
			}
			super.update(elapsed);
		}
	}
}
