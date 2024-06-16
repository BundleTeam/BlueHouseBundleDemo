package funkin.gameplay;

import funkin.fx.ColorSwap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import funkin.fx.shaders.GrayscaleShader;

using StringTools;

class StrumNote extends FlxSprite
{
	private var colorSwap:ColorSwap;

	public var resetAnim:Float32 = 0;

	private var noteData:Int32 = 0;

	public var direction:Float32 = 90; // plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;
	public var sustainReduce:Bool = true;

	private var player:Int32;
	private var grayscaleShader:GrayscaleShader;

	public var texture(default, set):String = null;

	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int)
	{
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);
		var skin:String = 'NOTE_assets';
		if (ClientPrefs.ui.useClassicArrows && !PlayState.isPixelStage) // bhb code - letsgoaway
			skin = 'classicNOTE_assets';
		else if (PlayState.SONG != null)
		{
			if (PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1)
				skin = PlayState.SONG.arrowSkin;
		}
		texture = skin; // Load texture and anims

		if (ClientPrefs.ui.classicStrumline)
		{
			grayscaleShader = new GrayscaleShader();
			this.shader = grayscaleShader;
		}
		animation.finishCallback = (name) ->
		{
			if (name == "confirm" && !animPlaying)
				playAnim("pressed", true);
		};
		scrollFactor.set();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if (animation.curAnim != null)
			lastAnim = animation.curAnim.name;

		if (PlayState.isPixelStage)
		{
			var pixelPrefix:String = 'pixelUI';
			if (PlayState.SONG.song == 'lunacy')
				pixelPrefix = "lunacyUI";

			loadGraphic(Paths.image('${pixelPrefix}/' + texture));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image('${pixelPrefix}/' + texture), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			pixelPerfectPosition = true;
			pixelPerfectRender = true;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			animation.add('green', [6], 24);
			animation.add('red', [7], 24);
			animation.add('blue', [5], 24);
			animation.add('purple', [4], 24);
			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 24, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 24, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 24, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 24, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture);
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red', 'arrowRIGHT');
			setGraphicSize(Math.ceil(frameWidth * Math.max(110 / frameWidth, 110 / frameHeight)),
				Math.ceil(frameHeight * Math.max(110 / frameWidth, 110 / frameHeight)));

			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.addByPrefix('static', 'arrowLEFT');
					animation.addByPrefix('pressed', 'left press', 24, false);
					animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					animation.addByPrefix('static', 'arrowDOWN');
					animation.addByPrefix('pressed', 'down press', 24, false);
					animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					animation.addByPrefix('static', 'arrowUP');
					animation.addByPrefix('pressed', 'up press', 24, false);
					animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					animation.addByPrefix('static', 'arrowRIGHT');
					animation.addByPrefix('pressed', 'right press', 24, false);
					animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
		}
		updateHitbox();
		if (lastAnim != null)
			playAnim(lastAnim, true);

		this.graphic.persist = true; // keep this cached because its used almost all the time
		this.frames.parent.persist = true;
	}

	public function postAddedToGroup()
	{
		playAnim('static');
		if (player != 1 || ClientPrefs.middleScroll)
		{
			x += Note.swagWidth * noteData;
			x += 50;
			x += ((FlxG.width / 2) * player);
		}
		else
		{
			x += FlxG.width - (x * 3);
			x += Note.swagWidth * noteData;
			x -= Note.swagWidth * 4;
		}
		ID = noteData;
	}

	override function update(elapsed:Float)
	{
		if (resetAnim > 0)
		{
			resetAnim -= elapsed;
			if (resetAnim <= 0)
			{
				playAnim('static');
				resetAnim = 0;
			}
		}
		if (animation.curAnim != null)
		{ // my bad i was upset
			if (animation.curAnim.name == 'confirm' && !PlayState.isPixelStage)
			{
				centerOrigin();
			}

			if (ClientPrefs.ui.classicStrumline && grayscaleShader != null)
			{
				switch (animation.curAnim.name)
				{
					case "pressed" | "confirm":
						grayscaleShader.enabled.value = [false];
					default:
						grayscaleShader.enabled.value = [true];
				}
			}
		}
		super.update(elapsed);
	}

	public var animPlaying = false;

	public function playAnim(anim:String, ?force:Bool = false)
	{
		animation.play(anim, force);
		animPlaying = true;
		centerOffsets();
		centerOrigin();

		if (animation.curAnim == null || animation.curAnim.name == 'static')
		{
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		}
		else
		{
			if (noteData > -1 && noteData < ClientPrefs.ui.noteHSV.length)
			{
				colorSwap.hue = ClientPrefs.ui.noteHSV[noteData][0] / 360;
				colorSwap.saturation = ClientPrefs.ui.noteHSV[noteData][1] / 100;
				colorSwap.brightness = ClientPrefs.ui.noteHSV[noteData][2] / 100;
			}

			if (animation.curAnim.name == 'confirm' && !PlayState.isPixelStage)
				centerOrigin();
		}
	}
}
