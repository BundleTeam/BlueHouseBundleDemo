package funkin.ui.notifications;

import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import openfl.text.AntiAliasType;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import funkin.system.achievements.*;
import flixel.FlxSprite;

class AchievementNotification extends Notification
{
	private var icon:FlxSprite;
	private var title:FlxText;

	private var desc1:FlxText;
	private var desc2:FlxText;

	private var savetag:String = 'w_game';

	public function new(saveTag:String = 'w_game')
	{
		this.savetag = saveTag;
		super();
	}

	public override function create()
	{
		soundToPlay = Paths.sound("achievement");
		adjustMusicVolumeOnSoundPlay = true;
		soundVol = 1;
		var id:Int = Achievements.getAchievementIndex(savetag);
		title = new FlxText();
		title.text = "Achievement Complete!";
		title.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER);
		title.antialiasing = false;
		title.textField.sharpness = -400;
		title.textField.border = false;
		title.x = 29;
		// title.y = -30;
		title.y = 10;
		// FlxTween.tween(title, {y: 10}, 0.2, {startDelay: 0.5, ease: FlxEase.expoOut});
		add(title);

		icon = new FlxSprite(15, 30);
		icon.loadGraphic(Paths.image('achievements/${savetag}'));
		icon.setGraphicSize(66, 66);
		icon.updateHitbox();
		icon.setPosition(15, 30);
		icon.alpha = 0;
		FlxTween.tween(icon, {alpha: 1}, 0.3, {startDelay: 0.7});
		add(icon);

		desc1 = new FlxText();
		desc1.text = Achievements.achievementsStuff[id].name;
		desc1.setFormat("VCR OSD Mono", 14, FlxColor.WHITE, CENTER);
		if (desc1.text.length >= 20)
			desc1.size = Math.round(desc1.text.length - (desc1.text.length / 2.7));
		desc1.autoSize = false;
		desc1.fieldWidth = 175;
		// desc1.alpha = 0;
		desc1.antialiasing = false;
		desc1.textField.sharpness = -400;
		desc1.textField.border = false;
		desc1.x = 75;
		desc1.y = 75;
		if (Achievements.achievementsStuff[id].description.length >= 65)
			// FlxTween.tween(desc1, {y: 55, alpha: 1}, 0.3, {startDelay: 0.7, ease: FlxEase.linear});
			desc1.y = 55;
		else
			desc1.y = 45;
		// FlxTween.tween(desc1, {y: 45, alpha: 1}, 0.3, {startDelay: 0.7, ease: FlxEase.linear});
		add(desc1);

		if (!(Achievements.achievementsStuff[id].description.length >= 65))
		{
			desc2 = new FlxText();
			desc2.text = Achievements.achievementsStuff[id].description;
			desc2.setFormat("VCR OSD Mono", 10, FlxColor.WHITE, CENTER);
			desc2.autoSize = false;
			desc2.fieldWidth = 175;
			// desc2.alpha = 0;
			desc2.antialiasing = false;
			desc2.textField.sharpness = -400;
			desc2.textField.border = false;
			desc2.x = 75;
			// desc2.y = 75;
			desc2.y = 65;
			// FlxTween.tween(desc2, {y: 65, alpha: 1}, 0.3, {startDelay: 0.9, ease: FlxEase.linear});
			add(desc2);
		}

		super.create();
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
