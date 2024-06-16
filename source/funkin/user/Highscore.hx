package funkin.user;

import funkin.utils.CoolUtil;
import flixel.FlxG;

using StringTools;

class Highscore
{
	public static var highscores:Map<String, SongScore> = new Map();
	private static var placeholder:SongScore = {
		score: 0,
		rank: "?",
		accuracy: 0,
		misses: 0,
		shits: 0,
		bads: 0,
		goods: 0,
		sicks: 0,
		comboBreaks: 0
	};

	public static function resetScore(song:String)
	{
		song = Paths.formatToSongPath(song);
		highscores.set(song, placeholder);
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if (decimals < 1)
		{
			return Math.floor(value);
		}

		var tempMult:Float = 1;
		for (i in 0...decimals)
		{
			tempMult *= 10;
		}
		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	public static function saveScore(song:String, score:SongScore):Void
	{
		song = Paths.formatToSongPath(song);
		var curScore:SongScore = highscores.get(song);
		if (curScore == null)
			curScore = placeholder;
		if (score.score > curScore.score)
			curScore = score;

		highscores.set(song, curScore);
		save();
	}

	public static function save():Void
	{
		FlxG.save.data.highscores = highscores;
		FlxG.save.flush();
	}

	public static function getScore(song:String):SongScore
	{
		song = Paths.formatToSongPath(song);
		var score:SongScore = highscores.get(song);
		if (score == null)
			return placeholder;

		return score;
	}

	public static function load():Void
	{
		if (FlxG.save.data.highscores != null)
		{
			highscores = FlxG.save.data.highscores;
		}
	}
}
