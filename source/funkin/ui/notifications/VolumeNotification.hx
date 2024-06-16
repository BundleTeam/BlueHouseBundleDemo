package funkin.ui.notifications;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class VolumeFace extends FlxSprite
{
	private static var anims:Array<String> = ["ten", "nine", "eight", "seven", "six", "five", "four", "three", "two", "one"];

	public function new()
	{
		super();
		frames = Paths.getSparrowAtlas("volumeFace");
		for (anim in anims)
		{
			animation.addByPrefix(anim, anim);
		}
	}

	public function setAnimation(volume:Float)
	{
		var fucking:Float = volume;

		color = FlxColor.interpolate(FlxColor.BLUE, FlxColor.YELLOW, fucking);
		if (0.0 == Math.round(volume * 100))
		{
			animation.play("ten");
			return;
		}
		volume = FlxMath.roundDecimal(volume, 1);
		var vol:Int = Std.int(volume * 10);
		animation.play(anims[vol - 1]);
	}
}

class VolumeNotification extends Notification
{
	public function new()
	{
		super();
	}

	private var title:FlxText;
	private var volumeListener:Float->Void;
	private var volumeFace:VolumeFace;

	public override function create()
	{
		title = new FlxText();
		title.text = "Volume: " + Math.round(FlxG.sound.volume * 100);
		title.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER);
		title.antialiasing = false;
		title.textField.sharpness = -400;
		title.textField.border = false;
		title.x = 15;
		// title.y = -30;
		title.y = 40;
		// FlxTween.tween(title, {y: 10}, 0.2, {startDelay: 0.5, ease: FlxEase.expoOut});
		add(title);
		volumeListener = (vol) ->
		{
			title.text = "Volume: " + Math.round(vol * 100);
			this.time = 2;
			if (vol == 1.0)
				FlxG.sound.play(Paths.sound("cancelMenu"), 0.7);
			else
				FlxG.sound.play(Paths.sound("scrollMenu"));

			ClientPrefs.saveSettings();
			volumeFace.setAnimation(vol);
		};
		FlxG.sound.onVolumeChange.add(volumeListener);
		volumeFace = new VolumeFace();
		add(volumeFace);
		volumeFace.setAnimation(FlxG.sound.volume);
		volumeFace.x += 125;
		super.create();
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public override function destroy()
	{
		FlxG.sound.onVolumeChange.remove(volumeListener);
		super.destroy();
	}
}
