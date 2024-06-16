package funkin.plugins;

import openfl.display.BitmapData;
import funkin.ui.notifications.AchievementNotification;
import funkin.ui.notifications.Notification;
import funkin.ui.notifications.NotificationManager;
import flixel.text.FlxText;
import flixel.FlxCamera;
import openfl.display.StageQuality;
import funkin.system.achievements.Achievements.Achievements;
import flixel.FlxG;
import flixel.FlxBasic;

class Global extends FlxBasic
{
	public override function update(elapsed:Float)
	{
		Achievements.globalCriteriaCheck();

		FlxG.stage.quality = QualityPrefs.stageQuality();

		FlxG.plugins.drawOnTop = true;
		FlxG.cameras.useBufferLocking = true;
		FlxG.mouse.useSystemCursor = FNK.stopDumbMouseParsecBugBecauseItsAnnoyingAsFuck;
		FlxG.sound.soundTrayEnabled = false;
		if (FlxG.keys.justPressed.F3)
		{
			ClientPrefs.showFPS = !ClientPrefs.showFPS;
			ClientPrefs.showMEM = ClientPrefs.showFPS;
			ClientPrefs.saveSettings();
		}
		// ShaderManager.get("gamma").shader.data.gamma.value = [FlxG.sound.volume];

		if (FlxG.keys.justPressed.F10)
			FlxG.state.openSubState(new SnapshotMode());

		if (FlxG.keys.justReleased.F12)
			Screenshot.screenshot();

		super.update(elapsed);
	}
}
