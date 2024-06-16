package funkin.gameplay.stages;

import flixel.FlxObject;
import funkin.music.StageData;
import flixel.FlxSprite;

// TODO: FUTURE STAGE SHIT
class BaseStage extends FlxObject
{
	public function new()
	{
		super();
		create();
	}

	public function create()
	{
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	/**
	 * Adds a sprite to the stage.
	 * @param sprite Sprite to add 
	 * @param front Add infront of everything in the game camera, not the arrow cam
	 * @param frontOfGF Add infront of GF but not infront of the players (ignores `front`)
	 */
	private function addStageSprite(sprite:FlxSprite, front:Bool = false, ?frontOfGF:Bool = false)
	{
		if (frontOfGF)
			PlayState.instance.frontOfGfSprites.push(sprite);
		else if (front)
			PlayState.instance.frontSprites.push(sprite);
		else
			PlayState.instance.add(sprite);
	}
}
