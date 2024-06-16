package funkin.menus;

import flixel.text.FlxText;
import flixel.FlxG;
import funkin.fx.shaders.GaussianBlur;
import openfl.filters.BlurFilter;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;

class HTML5PlaystateLoader extends FlxSubState
{
	var loaderCharSprite:FlxSprite;

	public static var statusText = "";

	var coolThing:FlxBackdrop;

	var text:FlxText;

	public function new()
	{
		super();

		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d);
		add(bg);

		var funkay = new FlxSprite(0, 0); // .loadGraphic(Paths.getPath('images/funkay.png', IMAGE));
		funkay.loadGraphicWithAssetQuality('funkay');
		funkay.setGraphicSize(0, FlxG.height);
		funkay.updateHitbox();
		add(funkay);
		funkay.scrollFactor.set();
		funkay.screenCenter();

		loaderCharSprite = new FlxSprite();
		add(loaderCharSprite);
		loaderCharSprite.frames = Paths.getSparrowAtlas('spinnys/mistashitty');
		loaderCharSprite.animation.addByPrefix("spin", "mistashitty_spin", 40);
		loaderCharSprite.scale.set(0.35, 0.35);
		loaderCharSprite.updateHitbox();
		loaderCharSprite.y = 0;
		loaderCharSprite.x = FlxG.width - loaderCharSprite.width;
		loaderCharSprite.animation.play("spin");

		coolThing = new FlxBackdrop();
		coolThing.loadGraphic(Paths.image('coolthing'));
		coolThing.x = 0;
		coolThing.repeatAxes = X;
		add(coolThing);
		coolThing.y = FlxG.height - coolThing.height;
		coolThing.velocity.set(-60, 0);
		text = new FlxText();
		text.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, QualityPrefs.textShadow(), FlxColor.BLACK);
		add(text);
	}

	public override function update(elapsed:Float)
	{
		text.text = statusText;
		super.update(elapsed);
	}
}
