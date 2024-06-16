package funkin.gameplay;

import flixel.FlxG;
import flixel.FlxSprite;
import funkin.fx.ColorSwap;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;

	private var idleAnim:String;
	private var textureLoaded:String = null;
	private var animNum:UInt8 = 1;
	private var skin:String = 'noteSplashes';

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);

		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		loadAnims(skin);

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = 'noteSplashes', hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0)
	{
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);

		if (texture == 'noteSplashes')
		{
			if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0 && pixels == null && graphic == null)
				texture = PlayState.SONG.splashSkin;
		}

		if (textureLoaded != texture)
		{
			loadAnims(texture);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		offset.set(10, 10);

		animNum = FlxG.random.int(1, 2);
		if (PlayState.SONG.song == 'lunacy')
			setColorTransform(1, 1, 1, 1, -128, -128, -128, 0); //  makes splash darker
		if (PlayState.SONG.song == 'lunacy')
			animation.play('note0-' + animNum, true); // makes it only play purple splash
		else
			animation.play('note' + note + '-' + animNum, true);
		alpha = 0.25;
		if (animation.curAnim != null)
			animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String)
	{
		if (frames == null && pixels == null && graphic == null)
		{
			frames = Paths.getSparrowAtlas(skin);
			for (i in 1...3)
			{
				animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
				animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
				animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
				animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
			}
		}

		this.frames.parent.persist = true; // keep this cached because its used almost all the time
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
			if (animation.curAnim.finished)
				kill();

		super.update(elapsed);
	}
}
