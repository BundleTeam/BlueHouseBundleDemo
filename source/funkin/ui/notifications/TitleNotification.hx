package funkin.ui.notifications;

import funkin.plugins.WindowMode;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class TitleNotification extends Notification
{
	public function new()
	{
		super();
	}

	private var title:FlxText;
	private var windowMode:Float->Void;

	public override function create()
	{
		title = new FlxText();
		title.text = "";
		title.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER);
		title.antialiasing = false;
		title.textField.sharpness = -400;
		title.textField.border = false;
		title.x = 0;
		title.fieldWidth = 250;
		// title.y = -30;
		title.y = 20;
		// FlxTween.tween(title, {y: 10}, 0.2, {startDelay: 0.5, ease: FlxEase.expoOut});
		add(title);

		super.create();
	}

	public function setText(text:String)
	{
		title.text = text;
		time = 2;
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public override function destroy()
	{
		super.destroy();
	}
}
