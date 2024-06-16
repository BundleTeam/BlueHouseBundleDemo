package funkin.gameplay.hud;

import openfl.text.TextFieldAutoSize;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class LatencyDisplay extends FlxText
{
	public function new()
	{
		super(0, 0, 0, "", 32);
		this.screenCenter();
		this.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 1, ClientPrefs.lowQuality ? 0.5 : 1.0);
		this.alpha = 0;

		this.autoSize = false;
		this.fieldWidth = 345;
	}

	var coolTextTween:FlxTween = null;

	public function showText(text:String, fadeOut:Bool = true)
	{
		this.alpha = 1;
		this.text = text;
		if (fadeOut)
		{
			if (coolTextTween != null)
				coolTextTween.cancel();
			coolTextTween = FlxTween.tween(this, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.002
			});
		}
	}

	public override function update(elapsed:Float)
	{
		if (FlxMath.inBounds(this.x + (this.width / 2), -99999, 426))
		{
			this.alignment = FlxTextAlign.LEFT;
		}
		else if (FlxMath.inBounds(this.x + (this.width / 2), 427, 853))
		{
			this.alignment = FlxTextAlign.CENTER;
		}
		else
		{
			this.alignment = FlxTextAlign.RIGHT;
		}

		super.update(elapsed);
	}
}
