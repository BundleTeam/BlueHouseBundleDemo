package funkin.editors.ui;

import haxe.Json;
import flixel.FlxSprite;
import openfl.Vector;
import lime.math.Vector2;
import flixel.group.*;
import funkin.gameplay.hud.*;

class UIData
{
	public static function get(id:String):UIElement
	{
		for (object in ClientPrefs.ui.elements)
		{
			if (object.type == id)
			{
				return object;
			}
		}
		return null;
	}

	public static function getPos(id:String):Null<Vector2>
	{
		for (object in ClientPrefs.ui.elements)
		{
			if (object.type == id)
			{
				return new Vector2(object.x, object.y);
			}
		}
		return null;
	}

	private static var defaultAttributes:UIElementAttributes = {
		opacity: 1,
		scale: [1, 1],
		rotation: 0,
	}

	public static function getAndApplyToSprite(id:String, sprite:FlxSprite)
	{
		if (sprite is IEditableHudGroup)
			sprite = cast(sprite, IEditableHudGroup).getSprite();

		for (object in ClientPrefs.ui.elements)
		{
			if (object.type == id)
			{
				sprite.x = object.x;
				sprite.y = object.y;
				var attributes = object.attributes;
				if (Reflect.hasField(attributes, "opacity"))
					sprite.alpha = attributes.opacity;
				else
					sprite.alpha = defaultAttributes.opacity;
				if (Reflect.hasField(attributes, "scale"))
					sprite.scale.set(attributes.scale[0], attributes.scale[1]);
				if (Reflect.hasField(attributes, "rotation"))
					sprite.angle = attributes.rotation;
				if (!(sprite is FlxSpriteGroup) && !(sprite is FlxSpriteContainer))
				{
					sprite.updateHitbox();
				}
				return;
			}
		}
	}

	public static function getData(id:String)
	{
		for (object in ClientPrefs.ui.elements)
		{
			if (object.type == id)
			{
				return object;
			}
		}
		return null;
	}

	public static function set(id:String, sprite:FlxSprite)
	{
		if (sprite is IEditableHudGroup)
			sprite = cast(sprite, IEditableHudGroup).getSprite();
		var data:UIElement = {
			type: id,
			x: sprite.x,
			y: sprite.y,
			attributes: null
		};
		var attributes:UIElementAttributes;
		if (!(sprite is FlxSpriteGroup) && !(sprite is FlxSpriteContainer))
		{
			attributes = {
				opacity: sprite.alpha,
				rotation: Std.int(sprite.angle),
				scale: [sprite.scale.x, sprite.scale.y],
			}
		}
		else
		{
			attributes = {
				opacity: sprite.alpha
			}
		}
		data.attributes = attributes;

		for (object in ClientPrefs.ui.elements)
		{
			if (object.type == id)
			{
				ClientPrefs.ui.elements.remove(object);
				ClientPrefs.ui.elements.push(data);
				return;
			}
		}
		ClientPrefs.ui.elements.push(data);
	}
}
