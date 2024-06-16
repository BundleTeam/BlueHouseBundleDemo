package funkin.gameplay;

import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import funkin.editors.ChartingState;
import funkin.fx.ColorSwap;

using StringTools;

typedef EventNote =
{
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{
	public var extraData:Map<String, Dynamic> = [];
	public var overlayNote:FlxSprite;
	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int32 = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var wasComboBreakHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;

	public var spawned:Bool = false;

	public var tail:Array<Note> = []; // for sustains
	public var parent:Note;
	public var blockHit:Bool = false; // only works for player

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int32 = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;

	public var animSuffix:String = '';
	public var gfNote:Bool = false;
	public var earlyHitMult:Float32 = 0.5;
	public var lateHitMult:Float32 = 1;
	public var lowPriority:Bool = false;

	public static var swagWidth:Float = 116;
	public static var PURP_NOTE:UInt8 = 0;
	public static var BLUE_NOTE:UInt8 = 1;
	public static var GREEN_NOTE:UInt8 = 2;
	public static var RED_NOTE:UInt8 = 3;

	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float32 = 0;
	public var noteSplashSat:Float32 = 0;
	public var noteSplashBrt:Float32 = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float32 = 1;
	public var multSpeed(default, set):Float32 = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; // 9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; // plan on doing scroll directions soon -bb

	public var hitsoundDisabled:Bool = false;

	private function set_multSpeed(value:Float):Float
	{
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		// Funkin.log('fuck cock');
		return value;
	}

	public function resizeByRatio(ratio:Float) // haha funny twitter shit
	{
		if (isSustainNote && !animation.curAnim.name.endsWith('end'))
		{
			scale.y *= ratio;
			updateHitbox();
		}
	}

	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	private function set_noteType(value:String):String
	{
		noteSplashTexture = PlayState.SONG.splashSkin;
		if (noteData > -1 && noteData < ClientPrefs.ui.noteHSV.length)
		{
			colorSwap.hue = ClientPrefs.ui.noteHSV[noteData][0] / 360;
			colorSwap.saturation = ClientPrefs.ui.noteHSV[noteData][1] / 100;
			colorSwap.brightness = ClientPrefs.ui.noteHSV[noteData][2] / 100;
		}

		if (noteData > -1 && noteType != value)
		{
			switch (value)
			{
				case 'Hurt Note':
					ignoreNote = mustPress;
					reloadNote('HURT');
					noteSplashTexture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					lowPriority = true;

					if (isSustainNote)
						missHealth = 0.1;
					else
						missHealth = 0.3;

					hitCausesMiss = true;
				case 'Alt Animation':
					animSuffix = '-alt';
				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
				case 'GF Sing':
					gfNote = true;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;

		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;

		this.strumTime = strumTime;
		if (!inEditor)
			this.strumTime += ClientPrefs.noteOffset;

		this.noteData = noteData;

		if (noteData > -1)
		{
			texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += swagWidth * (noteData);
			if (!isSustainNote && noteData > -1 && noteData < 4)
			{ // Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				switch (noteData % 4)
				{
					case 0:
						animToPlay = 'purple';
					case 1:
						animToPlay = 'blue';
					case 2:
						animToPlay = 'green';
					case 3:
						animToPlay = 'red';
				}
				animation.play(animToPlay + 'Scroll');
			}
		}

		// Funkin.log(prevNote);

		if (prevNote != null)
			prevNote.nextNote = this;

		if (isSustainNote && prevNote != null)
		{
			alpha = 1;
			multAlpha = 1;
			hitsoundDisabled = true;
			this.pixelPerfectPosition = true;

			copyAngle = false;

			switch (noteData % 4)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			// ? Why the fuck does this work? Is there any easier math i can do other than these random numbers that happen to work i legit just tested until it worked right -letsgoaway
			if (PlayState.isPixelStage)
			{
				offsetX += width * 2;
				offsetX -= swagWidth / 2;
			}
			else
			{
				offsetX += width;
				offsetX -= swagWidth / 1.5;
			}

			updateHitbox();

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData % 4)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if (PlayState.instance != null)
				{
					prevNote.scale.y *= PlayState.instance.songSpeed;
				}

				if (PlayState.isPixelStage)
				{
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); // Auto adjust note size
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
			x += offsetX;
			if (PlayState.isPixelStage)
			{
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		}
		else if (!isSustainNote)
		{
			earlyHitMult = 1;
		}
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= this.height;
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;

	public var originalHeightForCalcs:Float = 6;

	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '')
	{
		if (prefix == null)
			prefix = '';
		if (texture == null)
			texture = '';
		if (suffix == null)
			suffix = '';

		var skin:String = texture;
		if (texture.length < 1)
		{
			skin = PlayState.SONG.arrowSkin;
			if (skin == null || skin.length < 1)
			{
				skin = 'NOTE_assets';
				if ((ClientPrefs.ui.useClassicArrows && !PlayState.isPixelStage)) // bhb code - letsgoaway
				{
					skin = 'classicNOTE_assets';
				}
			}
		}

		var animName:String = null;
		if (animation.curAnim != null)
		{
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length - 1] = prefix + arraySkin[arraySkin.length - 1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');
		if (PlayState.isPixelStage)
		{
			var pixelPrefix:String = 'pixelUI';
			if (PlayState.SONG.song == "lunacy")
				pixelPrefix = 'lunacyUI';
			if (isSustainNote)
			{
				loadGraphic(Paths.image('${pixelPrefix}/${blahblah}ENDS'));
				width = width / 4;
				height = height / 2;
				originalHeightForCalcs = height;
				loadGraphic(Paths.image('${pixelPrefix}/${blahblah}ENDS'), true, Math.floor(width), Math.floor(height));
			}
			else
			{
				loadGraphic(Paths.image('${pixelPrefix}/${blahblah}'));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('${pixelPrefix}/${blahblah}'), true, Math.floor(width), Math.floor(height));
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			loadPixelNoteAnims();
			antialiasing = false;
			pixelPerfectPosition = true;
			pixelPerfectRender = true;
			if (isSustainNote)
			{
				offsetX += lastNoteOffsetXForPixelAutoAdjusting;
				lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
				offsetX -= lastNoteOffsetXForPixelAutoAdjusting;

				if (animName != null && !animName.endsWith('end'))
				{
					lastScaleY /= lastNoteScaleToo;
					lastNoteScaleToo = (6 / frameHeight);
					lastScaleY *= lastNoteScaleToo;
				}
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(blahblah);
			loadNoteAnims();
		}
		if (isSustainNote)
		{
			scale.y = lastScaleY;
		}
		updateHitbox();

		if (animName != null)
			animation.play(animName, true);

		if (inEditor)
		{
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}

		//		this.graphic.persist = true; // keep this cached because its used almost all the time
		//		this.frames.parent.persist = true;
	}

	function loadNoteAnims()
	{
		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'purple hold end', 1, false, false, ClientPrefs.downScroll);
			animation.addByPrefix('greenholdend', 'green hold end', 1, false, false, ClientPrefs.downScroll);
			animation.addByPrefix('redholdend', 'red hold end', 1, false, false, ClientPrefs.downScroll);
			animation.addByPrefix('blueholdend', 'blue hold end', 1, false, false, ClientPrefs.downScroll);

			animation.addByPrefix('purplehold', 'purple hold piece', 1, false, false, ClientPrefs.downScroll);
			animation.addByPrefix('greenhold', 'green hold piece', 1, false, false, ClientPrefs.downScroll);
			animation.addByPrefix('redhold', 'red hold piece', 1, false, false, ClientPrefs.downScroll);
			animation.addByPrefix('bluehold', 'blue hold piece', 1, false, false, ClientPrefs.downScroll);
		}
		else
		{
			animation.addByPrefix('greenScroll', 'green0', 1, false);
			animation.addByPrefix('redScroll', 'red0', 1, false);
			animation.addByPrefix('blueScroll', 'blue0', 1, false);
			animation.addByPrefix('purpleScroll', 'purple0', 1, false);
		}
		setGraphicSize(Math.ceil(frameWidth * Math.max(110 / frameWidth, 110 / frameHeight)),
			Math.ceil(frameHeight * Math.max(110 / frameWidth, 110 / frameHeight)));

		updateHitbox();
	}

	function loadPixelNoteAnims()
	{
		if (isSustainNote)
		{
			animation.add('purpleholdend', [PURP_NOTE + 4], 1, false, false, ClientPrefs.downScroll);
			animation.add('greenholdend', [GREEN_NOTE + 4], 1, false, false, ClientPrefs.downScroll);
			animation.add('redholdend', [RED_NOTE + 4], 1, false, false, ClientPrefs.downScroll);
			animation.add('blueholdend', [BLUE_NOTE + 4], 1, false, false, ClientPrefs.downScroll);

			animation.add('purplehold', [PURP_NOTE], 1, false, false, ClientPrefs.downScroll);
			animation.add('greenhold', [GREEN_NOTE], 1, false, false, ClientPrefs.downScroll);
			animation.add('redhold', [RED_NOTE], 1, false, false, ClientPrefs.downScroll);
			animation.add('bluehold', [BLUE_NOTE], 1, false, false, ClientPrefs.downScroll);
		}
		else
		{
			animation.add('greenScroll', [GREEN_NOTE + 4], 1, false);
			animation.add('redScroll', [RED_NOTE + 4], 1, false);
			animation.add('blueScroll', [BLUE_NOTE + 4], 1, false);
			animation.add('purpleScroll', [PURP_NOTE + 4], 1, false);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!ClientPrefs.ui.useClassicArrows && isSustainNote && animation.curAnim.name.endsWith('end') && !PlayState.isPixelStage)
		{
			offsetY = ClientPrefs.ui.downScroll ? 35 : -17.5;
		}

		if (mustPress)
		{
			// ok river
			if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
			{
				tooLate = true;
			}
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
			{
				if ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
			}
		}

		if (wasComboBreakHit)
		{
			if (alpha > 0.5)
			{
				alpha = 0.5;
				multAlpha = alpha;
			}
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
