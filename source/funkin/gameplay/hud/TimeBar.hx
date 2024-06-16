package funkin.gameplay.hud;

import flixel.tweens.FlxEase;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.group.FlxSpriteContainer;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import funkin.user.Highscore;
import flixel.util.FlxStringUtil;

class TimeBar extends FlxSpriteContainer implements IEditableHudGroup
{
	public var timeTxt:FlxText;

	public var timeBarBG:FlxSprite;

	public var timeBar:FlxBar;

	public function new()
	{
		super();

		timeBarBG = new FlxSprite();
		timeBarBG.loadGraphic(Paths.image('timeBar'));
		timeBarBG.scrollFactor.set();
		timeBarBG.color = FlxColor.BLACK;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'displayBarValue', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = Std.int(timeBarBG.width);

		if (PlayState.instance != null)
		{
			timeBar.alpha = 0.0;
		}
		add(timeBar);

		timeTxt = new FlxText(0, 0, 400, "", 26);
		if (PlayState.instance != null && PlayState.isPixelStage)
		{
			timeTxt.setFormat(null, 26, FlxColor.WHITE, CENTER, QualityPrefs.textShadow(), FlxColor.BLACK);
			timeTxt.antialiasing = false;
			timeTxt.pixelPerfectPosition = true;
		}
		else
			timeTxt.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, CENTER, QualityPrefs.textShadow(), FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.borderSize = 2;
		if (ClientPrefs.ui.timeBarType == 'Song Name')
		{
			timeTxt.text = PlayState.SONG.song;
			timeTxt.size = 24;
			timeTxt.y += 3;
		}
		add(timeTxt);
	}

	public var barValue:Float = 0.0;

	public var displayBarValue:Float = 0.0;

	private var displayTween:FlxTween;

	private var lastBarValue:Float = 1.0;

	public override function update(elapsed:Float)
	{
		this.visible = true;
		timeBar.numDivisions = Std.int(timeBarBG.width);

		var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
		if (curTime < 0)
			curTime = 0;
		var songPercent = (curTime / FlxG.sound.music.length);
		barValue = songPercent;

		switch (ClientPrefs.ui.timeBarType)
		{
			//	case 'Time Left' is just default
			case 'Time Elapsed':
				var secondsTotal:Int = Math.floor((curTime / 1000) / PlayState.playbackSpeed);
				if (secondsTotal < 0)
					secondsTotal = 0;
				timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
			case 'Song Name':
				if (PlayState.SONG != null)
					timeTxt.text = PlayState.SONG.song;
				else
					timeTxt.text = "song-name";
			case 'Accuracy':
				if (PlayState.instance != null)
					barValue = PlayState.instance.ratingPercent;
				else
					barValue = 0.6942;
				timeTxt.text = Highscore.floorDecimal(barValue * 100, 2) + "%";
			case 'Disabled':
				this.visible = false;
			default:
				var songCalc:Float = (FlxG.sound.music.length - curTime);
				var secondsTotal:Int = Math.floor((songCalc / 1000) / PlayState.playbackSpeed);
				if (secondsTotal < 0)
					secondsTotal = 0;
				timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
		}

		if (lastBarValue != barValue)
		{
			if (displayTween != null)
				displayTween.cancel();
			displayTween = FlxTween.tween(this, {displayBarValue: barValue}, 0.10, {ease: FlxEase.sineOut});
		}

		timeBar.value = displayBarValue;
		lastBarValue = barValue;
		updatePositions();
		super.update(elapsed);
	}

	function updatePositions()
	{
		timeBarBG.setGraphicSize(timeBar.width + 8, timeBar.height + 8);
		timeBarBG.spriteCenter(timeBar);
		timeTxt.spriteCenter(timeBarBG);
		timeBarBG.copyAlpha(timeBar);
		timeBarBG.copyAngle(timeBar);
		timeTxt.copyAlpha(timeBar);
	}

	public function getSprite():FlxSprite
	{
		return timeBar;
	}
}
