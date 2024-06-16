package funkin.menus;

import funkin.system.achievements.*;
#if (cpp && desktop)
import funkin.system.Discord;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class AchievementsMenuState extends MusicBeatState
{
	var options:Array<Achievement> = [];
	private var grpOptions:FlxTypedGroup<Alphabet>;

	private static var curSelected:Int32 = 0;

	private var achievementArray:Array<AttachedAchievement> = [];
	private var achievementIndex:Array<Int> = [];
	private var descText:FlxText;
	private var grid:GridBG;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('blue house'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		add(menuBG);

		grid = new GridBG();
		add(grid);
		grid.fadeIn();
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		Achievements.loadAchievements();
		for (i in 0...Achievements.achievementsStuff.length)
		{
			if (!Achievements.achievementsStuff[i].hidden
				|| Achievements.achievementsMap.exists(Achievements.achievementsStuff[i].savetag))
			{
				options.push(Achievements.achievementsStuff[i]);
				achievementIndex.push(i);
			}
		}

		for (i in 0...options.length)
		{
			var achieveSaveTag:String = Achievements.achievementsStuff[achievementIndex[i]].savetag;
			var optionText:Alphabet = new Alphabet(0, (100 * i) + 210,
				Achievements.isAchievementUnlocked(achieveSaveTag) ? Achievements.achievementsStuff[achievementIndex[i]].name : '?', false, false);
			optionText.isMenuItem = true;
			optionText.x += 280;
			optionText.xAdd = 200;
			optionText.targetY = i;
			grpOptions.add(optionText);

			var icon:AttachedAchievement = new AttachedAchievement(optionText.x - 105, optionText.y, achieveSaveTag);
			icon.sprTracker = optionText;
			achievementArray.push(icon);
			add(icon);
		}

		descText = new FlxText(150, 600, 980, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, QualityPrefs.textShadow(), FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);
		changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		descText.text = curAchievement.description;
		curAchievement.progressType = curAchievement.progressType ?? ProgressType.CRITERIA;
		switch (curAchievement.progressType)
		{
			case CRITERIA:
				if (Achievements.isAchievementUnlocked(curAchievement.savetag))
					descText.text += " | Completed";
				else
					descText.text += " | Not Completed";
			case QUOTA:
				var amount:Float = Achievements.achievementsProgress.get(curAchievement.savetag);
				if (amount >= curAchievement.progressMaximum)
				{
					amount = curAchievement.progressMaximum;
				}
				descText.text += ' | ${Math.round(amount)}' + '/${Math.round(curAchievement.progressMaximum)}';
			case PERCENTAGE:
				var amount:Float = Math.round(Achievements.achievementsProgress.get(curAchievement.savetag));
				var maximum:Float = curAchievement.progressMaximum;
				var percent:Int = Math.round((amount / maximum) * 100);
				if (percent >= 100)
					percent = 100;

				descText.text += ' | ${percent}%';
		}
	}

	var curAchievement:Achievement;

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}

		for (i in 0...achievementArray.length)
		{
			achievementArray[i].alpha = 0.6;
			if (i == curSelected)
			{
				achievementArray[i].alpha = 1;
			}
		}
		curAchievement = Achievements.achievementsStuff[achievementIndex[curSelected]];
		descText.text = curAchievement.description;
		curAchievement.progressType = curAchievement.progressType ?? ProgressType.CRITERIA;
		switch (curAchievement.progressType)
		{
			case CRITERIA:
				if (Achievements.isAchievementUnlocked(curAchievement.savetag))
					descText.text += " | Completed";
				else
					descText.text += " | Not Completed";
			case QUOTA:
				descText.text += ' | ${Math.round(Achievements.achievementsProgress.get(curAchievement.savetag))}'
					+ '/ ${Math.round(curAchievement.progressMaximum)}';
			case PERCENTAGE:
				var amount = Math.round(Achievements.achievementsProgress.get(curAchievement.savetag));
				var maximum = curAchievement.progressMaximum;
				var percent = Math.round((amount / maximum) * 100);

				descText.text += ' | ${percent}%';
		}
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}
}
