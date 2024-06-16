package funkin.menus;

import flixel.FlxG;
import flixel.FlxState;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;
#if (cpp && desktop)
import funkin.system.Discord;
#end

class GalleryMenu extends MusicBeatState
{
	public override function create()
	{
		bgColor = FlxColor.fromString('#FFB933');
		playedGallery = false;
		super.create();
	}

	private var playedGallery:Bool = false;

	public override function beatHit()
	{
		if (playedGallery == false)
		{
			playedGallery = true;
			FlxG.sound.playMusic(Paths.music('gallery'));
			Conductor.changeBPM(100);
		}
		super.beatHit();
	}

	public override function update(dt:Float)
	{
		if (controls.BACK)
		{
			MusicBeatState.switchState(new FreeplayState());
		}
		var delta = dt * 60;
		super.update(dt);
	}
}
