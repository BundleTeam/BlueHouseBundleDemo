package funkin.system;

import lime.math.Vector2;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.FlxSubState;

class SnapshotMode extends MusicBeatSubstate
{
	var lastCameraPos:Vector2;
	var lastCameraZoom:Float;
	var lastCameraAngle:Float;

	public override function create()
	{
		FlxG.sound.music.pause();
		bgColor = 0x00FFFFFF;
		lastCameraPos = new Vector2(FlxG.camera.scroll.x, FlxG.camera.scroll.y);
		lastCameraZoom = FlxG.camera.zoom + 0; // +0 makes sure it saves it instead of storing the reference to the variable
		lastCameraAngle = FlxG.camera.angle + 0;

		_parentState.persistentDraw = true;
		_parentState.persistentUpdate = false;
		super.create();
	}

	public override function update(elapsed:Float)
	{
		if (FlxG.keys.pressed.W)
		{
			FlxG.camera.scroll.y -= 5 * (elapsed * 60);
		}
		if (FlxG.keys.pressed.S)
		{
			FlxG.camera.scroll.y += 5 * (elapsed * 60);
		}
		if (FlxG.keys.pressed.A)
		{
			FlxG.camera.scroll.x -= 5 * (elapsed * 60);
		}
		if (FlxG.keys.pressed.D)
		{
			FlxG.camera.scroll.x += 5 * (elapsed * 60);
		}
		if (FlxG.keys.pressed.UP)
		{
			FlxG.camera.zoom += 0.05 * (elapsed * 60);
		}
		if (FlxG.keys.pressed.DOWN)
		{
			FlxG.camera.zoom -= 0.05 * (elapsed * 60);
		}
		if (FlxG.keys.pressed.LEFT)
		{
			FlxG.camera.angle -= 1 * (elapsed * 60);
		}
		if (FlxG.keys.pressed.RIGHT)
		{
			FlxG.camera.angle += 1 * (elapsed * 60);
		}
		if (FlxG.keys.pressed.PERIOD)
		{
		}
		if (controls.BACK)
		{
			FlxG.sound.music.play();
			FlxG.camera.scroll.x = lastCameraPos.x;
			FlxG.camera.scroll.y = lastCameraPos.y;
			FlxG.camera.angle = lastCameraAngle;
			FlxG.camera.zoom = lastCameraZoom;

			close();
		}
		super.update(elapsed);
	}
}
