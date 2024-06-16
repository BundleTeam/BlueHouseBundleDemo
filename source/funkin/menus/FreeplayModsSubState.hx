package funkin.menus;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.GlowFilter;
import flixel.math.FlxMath;
import flixel.FlxG;
import openfl.filters.BitmapFilter;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.FlxSubState;
import flixel.FlxSprite;
#if sys
import sys.thread.Thread;
#end

class ModItem extends FlxSpriteGroup
{
	public var text:Alphabet = new Alphabet(0, 0, "", false, false, 99999, 1);
	public var modName:String = "";
	public var mod:String = "";
	public var image:FlxSprite = new FlxSprite(0, 0);
	public var isSelected:Bool = false;

	public function new(x:Float, y:Float, mod:String, modName:String)
	{
		super(x, y);
		this.modName = modName;
		text.text = modName;
		text.text = mod;
		text.x = this.x;
		text.y = this.y;

		alpha = 0.5;

		this.add(text);
	}

	public override function update(elapsed:Float)
	{
		text.y = this.y;
		if (this.isSelected)
		{
			text.alpha = 1;
		}
		else
		{
			text.alpha = 0.5;
		}
		super.update(elapsed);
	}

	public override function destroy()
	{
		text.destroy();
		super.destroy();
	}
}

class FreeplayModsSubState extends MusicBeatSubstate
{
	var modsTab:FlxSprite;

	var faderBG:FlxSprite;
	var inMenu:Bool = false;

	var modsDragging:Bool = false;
	var freeplaystate:FreeplayState;

	function attemptAsync(func:Dynamic)
	{
		#if sys
		Thread.create(() ->
		{
			func();
		});
		#else
		func();
		#end
	}

	var mouseSprite:FlxSprite;

	public override function create():Void
	{
		mouseSprite = new FlxSprite().makeGraphic(1, 1); // use a flxsprite because theres no mouse pixel perfect collision function (bruh)
		add(mouseSprite);
		mouseSprite.alpha = 1;
		_parentState.persistentDraw = true;
		_parentState.persistentUpdate = true;
		faderBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		faderBG.alpha = 0;
		faderBG.screenCenter();
		add(faderBG);
		modsTab = new FlxSprite();
		modsTab.loadGraphic(Paths.image('freeplay/mods'));
		modsTab.y = FlxG.height - 100;
		modsTab.setGraphicSize(FlxG.width, 0);
		add(modsTab);
	}

	var tabTween:FlxTween;
	var faderTween:FlxTween;

	function modsMenuOpen()
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		modsTab.setColorTransform(1, 1, 1, 1);
		inMenu = true;
		_parentState.persistentUpdate = false;
		if (tabTween != null)
		{
			tabTween.cancel();
		}
		tabTween = FlxTween.tween(modsTab, {y: FlxG.height - modsTab.height,}, 0.4, {ease: FastEase.sineOut});
		if (faderTween != null)
		{
			faderTween.cancel();
		}
		faderTween = FlxTween.tween(faderBG, {alpha: 0.2}, 0.4, {ease: FastEase.sineOut});
	}

	public override function update(dt:Float):Void
	{
		mouseSprite.setPosition(FlxG.mouse.x, FlxG.mouse.y);
		if (!inMenu)
		{
			if (FlxG.keys.justReleased.CONTROL)
			{
				modsMenuOpen();
			}
			if (FlxG.mouse.overlaps(modsTab))
			{
				mouseSprite.alpha = 1;
				if (FlxG.pixelPerfectOverlap(mouseSprite, modsTab))
				{
					modsTab.setColorTransform(1.0, 1.0, 1.0, 1.0);
					if (FlxG.mouse.justReleased)
					{
						modsMenuOpen();
					}
				}
			}
			else
			{
				mouseSprite.alpha = 0;
				if (FlxG.keys.pressed.CONTROL)
				{
					modsTab.setColorTransform(1.0, 1.0, 1.0, 1.0);
				}
				else
				{
					modsTab.setColorTransform(0.9, 0.9, 0.9, 1);
				}
			}
		}
		else
		{
			if (controls.BACK || (!FlxG.mouse.overlaps(modsTab) && FlxG.mouse.justReleased))
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				if (tabTween != null)
				{
					tabTween.cancel();
				}
				tabTween = FlxTween.tween(modsTab, {y: FlxG.height - 100,}, 0.6, {ease: FlxEase.bounceOut});
				if (faderTween != null)
				{
					faderTween.cancel();
				}
				faderTween = FlxTween.tween(faderBG, {alpha: 0}, 0.4, {
					ease: FastEase.sineOut,
					onComplete: (?_) ->
					{
						_parentState.persistentUpdate = true;
						inMenu = false;
					}
				});
			}
		}
		super.update(dt);
	}
}
