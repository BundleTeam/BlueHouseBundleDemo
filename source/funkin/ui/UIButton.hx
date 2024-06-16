package funkin.ui;

import funkin.fx.shaders.GrayscaleShader;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class UIButton extends FlxSprite
{
	public var hovered:Bool = false;
	public var hoverTween:FlxTween;
	public var disabled:Bool = false;
	public var onClick:() -> Void;
	public var canClick:Bool = true;
	public var playedHoverTweens:Bool = false;

	public override function new(X:Float32 = 0, Y:Float32 = 0, spritesheet:String = 'blank', ?onClick:() -> Void, disabled:Bool = false)
	{
		super(X, Y);
		this.onClick = onClick;
		this.frames = Paths.getSparrowAtlas(spritesheet);

		var fps:Int32 = 24;
		if (ClientPrefs.lowQuality)
			fps = 1;
		this.animation.addByPrefix('idle', "idle", fps, !ClientPrefs.lowQuality);
		this.animation.addByPrefix('select', "select", fps, !ClientPrefs.lowQuality);
		this.animation.play('idle');
		this.setPosition(X, Y);
		this.disabled = disabled;
		if (disabled)
			this.shader = new GrayscaleShader();
	}

	function buttonHover(hoverCheck:Bool, pressed:Bool):Void
	{
		if (this.alpha > 0.7 && canClick /*&& NewsSprite.uiInitialized*/) // dont update if this is basically invisible
		{
			if (hoverCheck)
			{
				this.animation.play('select');
				if (!hovered)
				{
					if (!this.disabled)
						FlxG.sound.play(Paths.sound('scrollMenu'));
					hovered = true;
				}

				if (pressed)
				{
					if (!this.disabled)
					{
						FlxG.sound.play(Paths.sound('confirmMenu'));
						onClick();
					}
					else
					{
						Main.alertTray.alertSound = "assets/sounds/cancelMenu.wav";
						Main.alertTray.alert("Coming soon!", 1);
						Main.alertTray.alertSound = "assets/sounds/scrollMenu.wav";
					}
				}
			}
			else
			{
				hovered = false;
				this.animation.play('idle');
			}
		}
	}

	public override function update(dt)
	{
		if (!FlxG.onMobile)
		{
			buttonHover(FlxG.mouse.overlaps(this), FlxG.mouse.justReleased);
		}
		if (FlxG.mouse.overlaps(this) && !playedHoverTweens)
		{
			playedHoverTweens = true;
			if (hoverTween != null)
				hoverTween.cancel();
			hoverTween = FlxTween.tween(this, {"scale.x": 1.25, "scale.y": 1.25}, 0.1, {ease: FastEase.sineIn});
		}
		else if (playedHoverTweens && !FlxG.mouse.overlaps(this))
		{
			playedHoverTweens = false;
			if (hoverTween != null)
				hoverTween.cancel();
			hoverTween = FlxTween.tween(this, {"scale.x": 1.0, "scale.y": 1.0}, 0.1);
		}

		super.update(dt);
	}
}
