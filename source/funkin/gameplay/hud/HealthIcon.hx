package funkin.gameplay.hud;

import lime.math.Vector2;
import openfl.Vector;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var initialScale:Vector2 = new Vector2(1.0, 1.0);

	private var isOldIcon:Bool = false;

	public var isPlayer:Bool = false;

	private var char:String = '';

	public function new(char:String = 'nb', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
		animation.finishCallback = (name) ->
		{
			if ((name == "winning" || name == "loosing") && animation.curAnim.reversed)
			{
				animation.play("normal");
			}
		};
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (PlayState.isPixelStage)
		{
			antialiasing = false;
		}
		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
		if (isTransitionable)
		{
			setSize(120, 120);
			centerOffsets();
			offset.y -= iconOffsets[1];
		}
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public var isTransitionable = false;

	public function changeIcon(char:String)
	{
		if (this.char != char)
		{
			isTransitionable = false;
			var name:String = 'icons/' + char;
			if (!Paths.fileExists('images/' + name + '.png', IMAGE))
				name = 'icons/icon-' + char; // Older versions of psych engine's support
			if (!Paths.fileExists('images/' + name + '.png', IMAGE))
				name = 'icons/icon-face'; // Prevents crash from missing icon
			if (Paths.fileExists("images/" + name + ".xml", TEXT))
			{
				isTransitionable = true;
				this.frames = Paths.getSparrowAtlas(name);
				animation.addByPrefix("normal", "normal", 30, false, isPlayer);
				// loosing because nicebon is dumb asf -letsgoaway
				animation.addByPrefix("loosing", "loosing", 30, false, isPlayer);

				animation.addByPrefix("winning", "winning", 30, false, isPlayer);
				animation.play("loosing");
				setGraphicSize(Math.ceil(frameWidth * Math.max(100 / frameWidth, 100 / frameHeight)),
					Math.ceil(frameHeight * Math.max(100 / frameWidth, 100 / frameHeight)));

				//				setGraphicSize(0, Math.ceil(frameHeight * Math.max(100 / frameWidth, 100 / frameHeight)));
				// iconOffsets[0] = (frameWidth - 65) / 3;
				iconOffsets[1] = -10;

				animation.play("normal");
			}
			else
			{
				var file:Dynamic = Paths.image(name);

				loadGraphic(file); // Load stupidly first for getting the file size
				loadGraphic(file, true, Math.floor(width / 3), Math.floor(height)); // Then load it
				iconOffsets[0] = (width - 150) / 3;
				iconOffsets[1] = (width - 150) / 3; // TODO: get this stupid fucking fuck fucking bad fuck work with big sprite thanks

				animation.add(char, [0, 1, 2], 0, false, isPlayer);
				animation.play(char);
				setGraphicSize(0, 175);
			}

			updateHitbox();
			if (isTransitionable)
			{
				initialScale.x = scale.x;
				initialScale.y = scale.y;
			}
			else
			{
				initialScale.x = scale.x * 0.8;
				initialScale.y = scale.y * 0.8;
			}
			this.char = char;
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		if (isTransitionable)
			return;
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String
	{
		return char;
	}

	public var anim:Int = 0;

	public function playAnim(id:Int)
	{
		if (id != anim)
		{
			if (isTransitionable)
			{
				if (id == 0 && anim == 2)
					animation.play("winning", false, true);
				else if (id == 2 && anim == 0)
					animation.play("winning", false, false);

				if (id == 0 && anim == 1)
					animation.play("loosing", false, true);
				else if (id == 1 && anim == 0)
					animation.play("loosing", false, false);
			}
			else
			{
				animation.curAnim.curFrame = id;
			}

			anim = id;
		}
	}
}
