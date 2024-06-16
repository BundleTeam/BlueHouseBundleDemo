package funkin.ui;

import flixel.addons.effects.chainable.FlxShakeEffect;
import funkin.fx.shaders.GrayscaleShader;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.menus.FreeplayState;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteContainer;

using StringTools;

class AlbumArtDisplay extends FlxSpriteContainer
{
	public var previewSprite:FlxSprite;

	public var lockSprite:LockSprite;
	public var cd:FlxSprite;
	public var locked:Bool = false;

	public var lockIsAngy:Bool = false;

	private var lockshader:GrayscaleShader;
	private var cdTween:FlxTween;

	var superEpicProMistaShitty:FlxSprite;

	public function loadPreviewGraphic(song:String)
	{
		song = song.replace("-erect", "").replace("-megamix", "");
		var lastPreviewSpriteGraphic:String = previewSprite.graphic.assetsKey;
		if (Paths.image('freeplay/previews/${song}', "shared") != null)
		{
			previewSprite.loadGraphic(Paths.image('freeplay/previews/${song}'));
		}
		else
		{
			previewSprite.loadGraphic(Paths.image('freeplay/previews/blank'));
		}
		if (song == "lunacy")
		{
			cd.loadGraphicWithAssetQuality('freeplay/CD', 0.1);
			cd.antialiasing = false;
			cd.setGraphicSize(168, 168);
			cd.updateHitbox();
		}
		else
		{
			cd.loadGraphicWithAssetQuality('freeplay/CD');
			cd.antialiasing = ClientPrefs.globalAntialiasing;
			cd.setGraphicSize(168, 168);
			cd.updateHitbox();
		}
		previewSprite.setGraphicSize(197, 197);
		previewSprite.updateHitbox();
		if (lastPreviewSpriteGraphic != previewSprite.graphic.assetsKey)
		{
			cd.spriteCenter(previewSprite);
			if (cdTween != null)
				cdTween.cancel();
			cdTween = FlxTween.tween(cd, {x: cd.x - 98}, 0.5, {ease: FlxEase.bounceOut});
		}
	}

	public function create()
	{
		cd = new FlxSprite();
		cd.loadGraphicWithAssetQuality('freeplay/CD');
		cd.setGraphicSize(168, 168);
		cd.updateHitbox();
		add(cd);

		previewSprite = new FlxSprite();
		previewSprite.loadGraphic(Paths.image('freeplay/previews/blank'));
		previewSprite.setGraphicSize(197, 197);
		previewSprite.updateHitbox();
		add(previewSprite);
		lockshader = new GrayscaleShader(false);
		previewSprite.shader = lockshader;
		cd.spriteCenter(previewSprite);
		cd.x -= 98;

		superEpicProMistaShitty = new FlxSprite();
		superEpicProMistaShitty.frames = Paths.getSparrowAtlas('freeplay/previews/fp_gameing');
		add(superEpicProMistaShitty);
		if (ClientPrefs.flashing)
		{
			superEpicProMistaShitty.animation.addByPrefix('seziure', 'seziure', 55);
			superEpicProMistaShitty.animation.addByPrefix('epicSeziure', 'epicSeziure', 55);
		}
		else
		{
			superEpicProMistaShitty.animation.addByPrefix('seziure', 'seziure', 5);
			superEpicProMistaShitty.animation.addByPrefix('epicSeziure', 'epicSeziure', 5);
		}
		superEpicProMistaShitty.animation.play('seziure');
		superEpicProMistaShitty.screenCenter();
		superEpicProMistaShitty.x = 973;
		superEpicProMistaShitty.y = 35;
		superEpicProMistaShitty.scale.set(0.5, 0.5);
		superEpicProMistaShitty.shader = lockshader;

		lockSprite = new LockSprite();
		lockSprite.spriteCenter(previewSprite);
		lockSprite.visible = locked;
		add(lockSprite);
	}

	public override function update(elapsed:Float)
	{
		cd.angle += 1 * (elapsed * 60);

		cd.spriteCenter(previewSprite, Y);

		lockSprite.spriteCenter(previewSprite);
		lockSprite.visible = locked;
		lockshader.enabled.value = [locked];

		superEpicProMistaShitty.spriteCenter(previewSprite);
		if (FreeplayState.currentlySelectedSong.replace("-erect", "").replace("-megamix", "") == 'gameing')
		{
			superEpicProMistaShitty.visible = true;
			if (FreeplayState.erectMode)
				superEpicProMistaShitty.animation.play('epicSeziure');
			else
				superEpicProMistaShitty.animation.play('seziure');
		}
		else
		{
			superEpicProMistaShitty.visible = false;
		}

		lockSprite.centerOffsets();
		if (lockIsAngy)
		{
			lockSprite.offset.x -= FlxG.random.int(-5, 5);
			lockSprite.offset.y -= FlxG.random.int(-5, 5);
		}
		super.update(elapsed);
	}
}
