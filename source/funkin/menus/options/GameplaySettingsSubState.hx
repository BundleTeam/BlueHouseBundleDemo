package funkin.menus.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import haxe.Json;
import funkin.menus.options.BaseOptionsMenu;

using StringTools;

#if desktop
#end
class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		var option:Option = new Option('Controller Mode', 'Check this if you want to play with\na controller instead of using your Keyboard.',
			'controllerMode', 'bool', false);
		addOption(option);
		/*

			// I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
			var option:Option = new Option('Downscroll', // Name
				'If checked, notes go Down instead of Up, simple enough.', // Description
				'downScroll', // Save data variable name
				'bool', // Variable type
				false); // Default value
			addOption(option);

			var option:Option = new Option('Middlescroll', 'If checked, your notes get centered.', 'middleScroll', 'bool', false);
			addOption(option);

			var option:Option = new Option('Opponent Notes', 'If unchecked, opponent notes get hidden.', 'opponentStrums', 'bool', true);
			addOption(option);

			var option:Option = new Option('Use Classic Notes', // Name
				'If checked, uses a blue version of the original FNF notes.', // Description
				'useClassicArrows', // Save data variable name
				'bool', // Variable type
				false); // Default value
			addOption(option);
			option.onChange = onChangeClassicNotes;

			var option:Option = new Option('Use Classic Icon Positioning', // Name
				'If checked, uses the classic positioning of character icons on the healthbar.', // Description
				'useClassicHealthbar', // Save data variable name
				'bool', // Variable type
				false); // Default value
			addOption(option);
		 */

		var option:Option = new Option('Ghost Tapping', "If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping', 'bool', true);
		addOption(option);

		var option:Option = new Option('Disable Reset Button', "If checked, pressing Reset won't do anything.", 'noReset', 'bool', false);
		addOption(option);

		var option:Option = new Option('Rating Offset', 'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			'ratingOffset', 'int', 0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window', 'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.', 'sickWindow', 'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 5;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window', 'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.', 'goodWindow', 'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 10;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window', 'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.', 'badWindow', 'int', 135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Safe Frames', 'Changes how many frames you have for\nhitting a note earlier or late.', 'safeFrames', 'float', 10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();

		Main.alertTray.alert("Downscroll, Middlescroll and related\noptions have moved to the UI Editor.", 4);
	}

	override function create()
	{
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
