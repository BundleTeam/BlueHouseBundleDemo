package funkin.system.achievements;

import funkin.ui.notifications.NotificationManager;
import funkin.ui.notifications.AchievementNotification;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class Achievements
{
	public static var achievementsStuff:Array<Achievement> = [
		{
			name: 'W Game (We Love You)',
			description: "Press W 100 times",
			savetag: 'w_game',
			progressType: ProgressType.QUOTA,
			progressMaximum: 100,
		},
		{
			name: 'L Game (Your Evil)',
			description: "Press L 100 times",
			savetag: 'l_game',
			progressType: ProgressType.QUOTA,
			progressMaximum: 100,
		},
	];
	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();
	public static var achievementsProgress:Map<String, Float> = new Map<String, Float>();

	public static var henchmenDeath:Int = 0;

	public static function unlockAchievement(savetag:String):Void
	{
		FlxG.log.add('Completed achievement "' + savetag + '"');
		achievementsMap.set(savetag, true);
		for (achievement in achievementsStuff)
		{
			if (achievement.savetag == savetag)
			{
				achievementsProgress.set(savetag, achievement.progressMaximum);
				break;
			}
		}

		NotificationManager.notify(new AchievementNotification(savetag));
		FlxG.save.data.achievementsMap = achievementsMap;
		FlxG.save.data.achievementsProgress = achievementsProgress;
		FlxG.save.flush();
	}

	public static function addProgressToAchievement(savetag:String, value:Float):Void
	{
		for (achievement in achievementsStuff)
		{
			if (achievement.savetag == savetag && achievement.progressType != ProgressType.CRITERIA)
			{
				var newValue:Float = achievementsProgress.get(savetag) + value;
				if (newValue > achievement.progressMaximum)
				{
					return;
				}
				achievementsProgress.set(savetag, newValue);
				break;
			}
		}
		FlxG.save.data.achievementsProgress = achievementsProgress;
		FlxG.save.flush();
	}

	public static function setProgressToAchievement(savetag:String, value:Float):Void
	{
		for (achievement in achievementsStuff)
		{
			if (achievement.savetag == savetag && achievement.progressType != ProgressType.CRITERIA)
			{
				achievementsProgress.set(savetag, value);
				break;
			}
		}
		FlxG.save.data.achievementsProgress = achievementsProgress;
		FlxG.save.flush();
	}

	public static function isAchievementUnlocked(savetag:String)
	{
		if (achievementsMap.exists(savetag) && achievementsMap.get(savetag))
		{
			return true;
		}
		return false;
	}

	public static function getAchievementIndex(savetag:String)
	{
		for (i in 0...achievementsStuff.length)
		{
			if (achievementsStuff[i].savetag == savetag)
			{
				return i;
			}
		}
		return -1;
	}

	public static function loadAchievements():Void
	{
		if (FlxG.save.data != null)
		{
			if (FlxG.save.data.achievementsMap != null)
			{
				achievementsMap = FlxG.save.data.achievementsMap;
			}
			if (henchmenDeath == 0 && FlxG.save.data.henchmenDeath != null)
			{
				henchmenDeath = FlxG.save.data.henchmenDeath;
			}
			achievementsProgress = FlxG.save.data.achievementsProgress ?? new Map<String, Float>();
			for (achievement in achievementsStuff)
			{
				achievement.progressType = achievement.progressType ?? ProgressType.CRITERIA;
				achievement.progressMaximum = achievement.progressMaximum ?? 1.0;

				if (!achievementsProgress.exists(achievement.savetag))
				{
					achievementsProgress.set(achievement.savetag, 0);
				}
			}
			FlxG.save.data.achievementsProgress = achievementsProgress;
			FlxG.save.flush();
		}
	}

	public static function globalCriteriaCheck()
	{
		if (LoadingState.loadedShared)
		{
			for (achievement in achievementsStuff)
			{
				switch (achievement.savetag)
				{
					case 'l_game':
						if (FlxG.keys.justPressed.L)
						{
							Achievements.addProgressToAchievement('l_game', 1);
						}
					case 'w_game':
						if (FlxG.keys.justPressed.W)
						{
							Achievements.addProgressToAchievement('w_game', 1);
						}
				}
				if (achievementsProgress.get(achievement.savetag) >= achievement.progressMaximum
					&& !Achievements.isAchievementUnlocked(achievement.savetag)
					&& achievement.progressType != ProgressType.CRITERIA)
				{
					Achievements.unlockAchievement(achievement.savetag);
					NotificationManager.notify(new AchievementNotification(achievement.savetag));
					Funkin.log('Giving achievement ' + achievement.savetag);
				}
			}
		}
	} // for acheivements that can be done anywhere (press button x amount of times) etc and checking if criterias are met
}
