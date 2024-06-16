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

class HealthBar extends FlxSpriteContainer implements IEditableHudGroup
{
	public var healthBarBG:FlxSprite;

	public var healthBar:FlxBar;

	public var iconP1:HealthIcon;

	public var iconP2:HealthIcon;

	public var scoreTxt:FlxText;

	private var defaultScoreTxtSize:Int = 17;

	public var scoreTxtTween:FlxTween;

	public var healthValue:Float = 1.0;
	public var displayHealthVal:Float = 1.0;

	public override function new(x:Int = 0, y:Int = 0)
	{
		super(x, y);
		healthBarBG = new FlxSprite();
		healthBarBG.makeGraphic(601, 19, FlxColor.BLACK);
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, FlxBarFillDirection.RIGHT_TO_LEFT, 593, 11, this, 'displayHealthVal', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);

		if (PlayState.instance != null)
			iconP1 = new HealthIcon(PlayState.instance.boyfriend.healthIcon, true);
		else
			iconP1 = new HealthIcon("bf", true);

		iconP1.updateHitbox();
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		if (PlayState.instance != null)
			iconP2 = new HealthIcon(PlayState.instance.dad.healthIcon, false);
		else
			iconP2 = new HealthIcon("mista", false);

		iconP2.updateHitbox();
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadColors();

		defaultScoreTxtSize = PlayState.isPixelStage ? 15 : 17;

		scoreTxt = new FlxText(0, healthBarBG.y - 36, 0, "Score: 0 | Misses: 0 | Rating: ?", defaultScoreTxtSize);
		scoreTxt.antialiasing = false;
		scoreTxt.wordWrap = false;

		if (PlayState.isPixelStage)
		{
			scoreTxt.setFormat(null, defaultScoreTxtSize, FlxColor.WHITE, CENTER, QualityPrefs.textShadow(), FlxColor.BLACK);
			scoreTxt.pixelPerfectPosition = true;
		}
		else
			scoreTxt.setFormat(Paths.font("vcr.ttf"), defaultScoreTxtSize, FlxColor.WHITE, CENTER, QualityPrefs.textShadow(), FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.1;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		// this.screenCenter(X);
		this.y = FlxG.height * 0.89;
		if (ClientPrefs.downScroll)
			this.y = 0.11 * FlxG.height;
	}

	public function reloadColors()
	{
		if (PlayState.instance != null)
		{
			healthBar.createFilledBar(FlxColor.fromRGB(PlayState.instance.dad.healthColorArray[0], PlayState.instance.dad.healthColorArray[1],
				PlayState.instance.dad.healthColorArray[2]),
				FlxColor.fromRGB(PlayState.instance.boyfriend.healthColorArray[0], PlayState.instance.boyfriend.healthColorArray[1],
					PlayState.instance.boyfriend.healthColorArray[2]));
		}
		else
		{
			healthBar.createFilledBar(FlxColor.fromRGB(0, 0, 255), FlxColor.fromRGB(255, 0, 0));
		}
		healthBar.updateBar();
	}

	var songPercent:Float = 0.0;

	var iconP1Offset:Int = 26;
	var iconP2Offset:Int = 26;

	private function updatePositions(elapsed:Float)
	{
		healthBar.numDivisions = Std.int(healthBar.width);
		healthBarBG.setGraphicSize(healthBar.width + 8, healthBar.height + 8);
		healthBarBG.copyAngle(healthBar);
		healthBarBG.copyAlpha(healthBar);
		healthBarBG.updateHitbox();
		healthBarBG.spriteCenter(healthBar, XY);
		scoreTxt.fieldWidth = healthBar.width;
		scoreTxt.y = healthBarBG.y - 36;
		scoreTxt.spriteCenter(healthBarBG, X);

		var mult:Float32 = FlxMath.lerp(iconP1.initialScale.x, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);

		var mult:Float32 = FlxMath.lerp(iconP2.initialScale.x, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);

		iconP1.spriteCenter(healthBar, Y);
		iconP2.spriteCenter(healthBar, Y);
		// todo: make this better and not have to define each sprite
		iconP1.copyAlpha(healthBar);
		iconP2.copyAlpha(healthBar);
		iconP1.visible = !ClientPrefs.ui.hideHealthIcons;
		iconP2.visible = !ClientPrefs.ui.hideHealthIcons;

		scoreTxt.copyAlpha(healthBar);
		/*
			iconP1.y = healthBar.y - 75;
			iconP2.y = healthBar.y - 75;
		 */
		if (!ClientPrefs.ui.useClassicHealthbar)
		{
			// if (iconP1.isTransitionable)
			//	iconP1.spriteCenterFrame(healthBar);
			// else
			iconP1.spriteCenter(healthBar);

			// if (iconP2.isTransitionable)
			// iconP2.spriteCenterFrame(healthBar);
			// else
			iconP2.spriteCenter(healthBar);
			iconP1.moveAngle((healthBar.width / 2) + iconP1Offset + (iconP1Offset / 2), healthBar.angle);
			if (iconP2.isTransitionable)
				iconP2.moveAngle(-((healthBar.width / 2) + ((iconP2Offset) + (iconP2Offset / 2)) * 1.35), healthBar.angle);
			else
				iconP2.moveAngle(-((healthBar.width / 2) + (iconP2Offset)), healthBar.angle);
		}
		else
		{
			// if (iconP2.isTransitionable)
			//	iconP2.spriteCenterFrame(healthBar);
			// else
			iconP2.spriteCenter(healthBar);
			if (iconP2.isTransitionable)
				iconP2.moveAngle(-((healthBar.width / 2) + (iconP2.width)), healthBar.angle);
			else
				iconP2.moveAngle(-((healthBar.width / 2) + (iconP2.width / 2)), healthBar.angle);

			iconP2.moveAngle((healthBar.width * FlxMath.remapToRange(healthBar.percent, 0, 100, 1.0, 0.0)) + iconP2Offset, healthBar.angle);
			iconP1.x = iconP2.x;
			iconP1.moveAngle(((iconP1.width / 2) + (iconP1Offset * 2)), healthBar.angle);
		}
	}

	private var displayTween:FlxTween;
	private var lastHealthValue:Float = 1.0;

	public override function update(elapsed:Float)
	{
		if (PlayState.instance != null)
			healthValue = PlayState.instance.health;
		else
			healthValue = 1.0;
		if (lastHealthValue != healthValue)
		{
			if (displayTween != null)
				displayTween.cancel();
			displayTween = FlxTween.tween(this, {displayHealthVal: healthValue}, 0.10, {ease: FlxEase.sineOut});
		}
		lastHealthValue = healthValue;
		// displayHealthVal = healthValue;
		/*
			if (FNKMath.roundToMultiple(displayHealthVal, 0.05) != FNKMath.roundToMultiple(healthValue, 0.05))
			{
				if (healthValue > displayHealthVal)
					displayHealthVal += 0.01 * (elapsed * 30);
				else
					displayHealthVal -= 0.01 * (elapsed * 30);
			}
		 */
		updatePositions(elapsed);
		updateScoreText();

		iconP1.flipX = healthBar.angle > 90 || healthBar.angle < -90 || healthBar.angle == -90;
		iconP2.flipX = (healthBar.angle > 90 || healthBar.angle < -90) || healthBar.angle == 90;
		if (healthBar.percent < 20)
			iconP1.playAnim(1);
		else if (healthBar.percent > 80)
			iconP1.playAnim(2);
		else
			iconP1.playAnim(0);

		if (healthBar.percent > 80)
			iconP2.playAnim(1);
		else if (healthBar.percent < 20)
			iconP2.playAnim(2);
		else
			iconP2.playAnim(0);

		super.update(elapsed);
	}

	public function onOpponentNoteHit(note:Note):Void
	{
		if (note.isSustainNote)
		{
			iconP2.scale.x += (iconP2.initialScale.x * .05);
			iconP2.scale.y += (iconP2.initialScale.y * .05);
		}
		else
		{
			iconP2.scale.set((iconP2.initialScale.x * 1.2), (iconP2.initialScale.x * 1.2));
		}
	}

	public function goodNoteHit(note:Note):Void
	{
		if (note.isSustainNote)
		{
			iconP1.scale.x += (iconP1.initialScale.x * .05);
			iconP1.scale.y += (iconP1.initialScale.y * .05);
		}
		else
		{
			iconP1.scale.set(iconP1.initialScale.x * 1.2, iconP1.initialScale.y * 1.2);
		}
	}

	public function beatHit()
	{
		if (PlayState.instance != null)
		{
			if (PlayState.instance.boyfriend.animation.curAnim.name == 'idle'
				|| PlayState.instance.boyfriend.animation.curAnim.name == 'idle-alt')
				iconP1.scale.set((iconP1.initialScale.x * 1.2), (iconP1.initialScale.y * 1.2));

			if (PlayState.instance.dad.animation.curAnim.name == 'idle' || PlayState.instance.dad.animation.curAnim.name == 'idle-alt')
				iconP2.scale.set((iconP2.initialScale.x * 1.2), (iconP2.initialScale.y * 1.2));
		}
		else
		{
			iconP1.scale.set((iconP1.initialScale.x * 1.2), (iconP1.initialScale.y * 1.2));
			iconP2.scale.set((iconP2.initialScale.x * 1.2), (iconP2.initialScale.y * 1.2));
		}
	}

	private var scoreItems:Array<String> = ["Score: 0", "Misses: 0", "Rating: ?"];

	private var scoreItemSep:String = " | ";

	public function updateScore(miss:Bool = false)
	{
		if (PlayState.instance != null)
		{
			scoreItems = [];
			scoreItems.push('Score: ${PlayState.instance.songScore}');
			scoreItems.push('Misses: ${PlayState.instance.songMisses}');
			if (PlayState.instance.ratingName != "?")
				scoreItems.push('Rating: ${PlayState.instance.ratingName} (${Highscore.floorDecimal(PlayState.instance.ratingPercent * 100, 2)}%) - ${PlayState.instance.ratingFC}');
			else
				scoreItems.push('Rating: ${PlayState.instance.ratingName}');
			if (ClientPrefs.ui.scoreTextZoom && !miss && !PlayState.instance.cpuControlled)
			{
				if (scoreTxtTween != null)
					scoreTxtTween.cancel();

				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween)
					{
						scoreTxtTween = null;
					}
				});
			}
		}

		updateScoreText();
	}

	public function updateScoreText()
	{
		@:privateAccess
		scoreTxt._autoHeight = FlxMath.inBounds(healthBarBG.angle, -135, -45) || FlxMath.inBounds(healthBarBG.angle, 45, 135);
		@:privateAccess
		if (scoreTxt._autoHeight)
			scoreItemSep = "\n";
		else
			scoreItemSep = " | ";
		scoreTxt.text = scoreItems.join(scoreItemSep);
	}

	public function getSprite():FlxSprite
	{
		return this.healthBar;
	}
}
