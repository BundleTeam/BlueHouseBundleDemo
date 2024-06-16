package funkin.plugins;

import flixel.FlxG;
import funkin.ui.notifications.NotificationManager;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteContainer;

class InfoDisplay extends FlxText
{
	public function new()
	{
		super();
		this.setFormat("VCR OSD Mono", 12, FlxColor.WHITE, LEFT, QualityPrefs.textShadow(), FlxColor.BLACK);
		this.scrollFactor.set();
		this.pixelPerfectPosition = true;
		this.pixelPerfectRender = true;
		this.x = 5;
		this.y = 5;
	}

	public override function destroy()
	{
		super.destroy();
	}

	private var txt:String = "";
	private var scoreSaved:Bool = false;

	public override function draw()
	{
		if (this.txt == "")
			return;
		super.draw();
	}

	// this fix should be in flixel by default but they are silly
	public override function regenGraphic()
	{
		if (this.frame != null && this.frame.sourceSize != null)
		{
			@:privateAccess
			if (this.graphic.assetsKey == "flixel/images/logo/default.png")
				_regen = true; // flixel logo fix because shit is stupid
			super.regenGraphic();
		}
	}

	public override function update(elapsed:Float)
	{
		if (PlayState.instance != null)
			this.visible = !PlayState.recordMode;
		else
			this.visible = true;
		this.antialiasing = ClientPrefs.globalAntialiasing;
		this.cameras = NotificationManager.instance.cameras;
		this.borderStyle = QualityPrefs.textShadow();
		txt = "";
		scoreSaved = true;

		if (ClientPrefs.showFPS)
			txt += 'FPS: ${Main.currentFPS}';
		if (#if sys Sys.args().contains("--window-vsync=true") #else Hardware.os.equals(Hardware.OS.Web) #end)
			txt += ' (VSYNC)';
		if (txt != "")
			txt += "\n";
		if (ClientPrefs.showMEM)
			txt += 'MEM: ${FlxMath.roundDecimal(Hardware.getMemory(RAM), 2)}MB\n';

		if (PlayState.recordMode)
			scoreSaved = false;
		if (PlayState.instance != null && PlayState.playbackSpeed != 1.0)
		{
			txt += '${PlayState.playbackSpeed}x\n';
			scoreSaved = false;
		}
		if (PlayState.instance != null && PlayState.instance.cpuControlled)
		{
			txt += "BOTPLAY\n";
			scoreSaved = false;
		}
		if (PlayState.instance != null && PlayState.instance.instakillOnMiss)
			txt += "INSTAKILL ON MISS\n";

		if (PlayState.instance != null && PlayState.instance.noFail)
		{
			txt += "NO FAIL\n";
			scoreSaved = false;
		}

		if (PlayState.instance != null && PlayState.instance.tauntMode)
		{
			txt += "TAUNT MODE\n";
			scoreSaved = false;
		}
		if (PlayState.instance != null && PlayState.instance.healthGain != 1.0)
		{
			txt += 'HG: ${PlayState.instance.healthGain}\n';
			scoreSaved = false;
		}
		if (PlayState.instance != null && PlayState.instance.healthLoss != 1.0)
		{
			txt += 'HL: ${PlayState.instance.healthLoss}\n';
			scoreSaved = false;
		}
		if (PlayState.instance != null && !scoreSaved)
		{
			txt += "SCORE NOT SAVED\n";
			scoreSaved = false;
		}
		this.text = txt;

		super.update(elapsed);
	}
}
