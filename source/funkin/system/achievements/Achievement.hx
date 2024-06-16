package funkin.system.achievements;

typedef Achievement =
{
	name:String,
	description:String,
	savetag:String,
	?hidden:Bool,
	?progressType:ProgressType,
	?progressMaximum:Float,
}
