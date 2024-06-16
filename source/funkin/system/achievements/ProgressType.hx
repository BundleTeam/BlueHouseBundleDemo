package funkin.system.achievements;

enum ProgressType
{
	CRITERIA; // example: Play April 17 on April 17, non-progressable, reaching a goal which isnt a countable one
	QUOTA; // example: Press W key 150 times, if it has been pressed 75 times it will show as 75/150 in the menu
	PERCENTAGE; // similar to Quota, but will show as "50%" rather than 75/150
}
