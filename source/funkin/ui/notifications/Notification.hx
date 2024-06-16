package funkin.ui.notifications;

import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;
import flixel.group.FlxContainer;
import openfl.media.Sound;
import flixel.sound.FlxSound;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class Notification extends FlxSpriteGroup
{
	public var playSound:Bool = true;
	public var soundToPlay:Sound = Paths.sound("scrollMenu");
	public var soundVol:Float = 1;
	public var adjustMusicVolumeOnSoundPlay:Bool = false;
	public var bgSprite:FlxSprite;
	public var onFinish:Void->Void = null;
	public var time:Float = 0;

	public static var musicTween:FlxTween;

	public function new()
	{
		super(0, 0);
		this.loadGraphic(Paths.image('notifrectangle'));
		this.color = 0xFF160B55;
		bgSprite = new FlxSprite();
		bgSprite.loadGraphic(Paths.image('notifrectangle'));
		bgSprite.color = 0xFF160B55;
		add(bgSprite);
		create();
	}

	public function create()
	{
		if (playSound)
		{
			if (adjustMusicVolumeOnSoundPlay && FlxG.sound.music != null && FlxG.sound.music.playing)
			{
				if (musicTween != null)
					musicTween.cancel();

				musicTween = FlxTween.tween(FlxG.sound.music, {volume: 0.5}, 0.2);
				FlxG.sound.play(soundToPlay, soundVol, false, null, true, () ->
				{
					musicTween = FlxTween.tween(FlxG.sound.music, {volume: 1.0}, 0.2);
				});
			}
			else
				FlxG.sound.play(soundToPlay, soundVol);
		}
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function fin()
	{
		if (onFinish != null)
			onFinish();
	}
}
