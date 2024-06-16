package funkin.ui.notifications;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxState;
import flixel.group.FlxContainer.FlxTypedContainer;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class NotificationManager extends FlxTypedContainer<FlxSprite>
{
	public static var instance:NotificationManager = null;

	var notifTweens:Map<Notification, FlxTween> = new Map<Notification, FlxTween>();

	public var notifs:Array<Notification> = [];

	public var volumeNotif:VolumeNotification = null;

	public static var lastMusicVol:Float;

	public function new()
	{
		super();
		if (NotificationManager.instance == null)
		{
			NotificationManager.instance = this;
		}
		FlxG.sound.onVolumeChange.add((volume) ->
		{
			if (volumeNotif == null)
			{
				volumeNotif = new VolumeNotification();
				notify(volumeNotif);
			}
		});
		FlxG.signals.postStateSwitch.add(() ->
		{
			for (notif in notifs)
			{
				notifTweens.set(notif, FlxTween.tween(notif, {x: FlxG.width - (15 + notif.width)}, 0.5, {
					ease: FlxEase.expoOut,
				}));
			}
		});
	}

	public static function notify(Sprite:Notification):Notification
	{
		return NotificationManager.instance.notif(Sprite);
	}

	public function notif(Sprite:Notification):Notification
	{
		Sprite.y = (115 * (this.notifs.length)) + 10;
		Sprite.x = FlxG.width + 30;
		notifTweens.set(Sprite, FlxTween.tween(Sprite, {x: FlxG.width - (15 + Sprite.width)}, 0.5, {
			ease: FlxEase.expoOut,
		}));
		Sprite.time = 0;
		notifs.push(Sprite);
		add(Sprite);
		return Sprite;
	}

	public override function update(elapsed:Float)
	{
		if (PlayState.instance != null)
			this.cameras = [PlayState.instance.camOther];
		else
		{
			this.cameras = [];
			for (camera in FlxG.cameras.list)
			{
				if (camera.x == 0 && camera.y == 0 || camera.scroll.x == 0 && camera.scroll.y == 0)
				{
					this.cameras = [camera];
					continue;
				}
			}
		}
		if (this.cameras == [])
		{
			this.cameras.push(FlxG.camera);
		}
		for (notif in notifs)
		{
			notif.scrollFactor.set(0, 0);
			notif.time += elapsed;
			var yShouldBe:Float = (115 * (notifs.indexOf(notif))) + 10;
			if (notif.time >= 5 && notifTweens.get(notif).finished /* && notif.y == yShouldBe*/)
			{
				if (volumeNotif == notif)
				{
					volumeNotif = null;
				}
				notif.fin();
				new FlxTimer().start(0.5, (t) ->
				{
					notifTweens.remove(notif);
					remove(notif, true);
					notifs.remove(notif);
					notif.destroy();
				});
				notifTweens.set(notif, FlxTween.tween(notif, {x: FlxG.width + 30}, 0.5, {
					ease: FlxEase.expoOut
				}));
			}

			// move to top of screen
			if (notif.y != yShouldBe && notifTweens.get(notif).finished /*&& !(notifTimes.get(notif) >= 5)*/)
			{
				notif.time -= 1;
				if (!notifTweens.get(notif).finished)
				{
					notifTweens.get(notif).cancel();
				}
				notifTweens.set(notif, FlxTween.tween(notif, {x: FlxG.width - (15 + notif.width), y: yShouldBe}, 0.5, {
					ease: FlxEase.expoOut,
				}));
			}
		}
		super.update(elapsed);
	}

	override function destroy()
	{
		if (FlxG.sound != null && FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.volume = 1.0;

		super.destroy();
	}
}
