package funkin.menus.options;

import funkin.menus.options.AudioVisualsSubState;
import funkin.utils.CoolUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.user.PlayerSettings;
import funkin.plugins.input.*;
import funkin.editors.ui.UIEditor;

using StringTools;

#if (cpp && desktop)
import funkin.system.Discord.ArtAssets;
#if (cpp && desktop)
import funkin.system.Discord;
#end
#end
class OptionsState extends MusicBeatState
{
	private var returnToPlaystate = false;

	public function new(returnToPlaystate:Bool = false)
	{
		super();
		this.returnToPlaystate = returnToPlaystate;
	}

	var options:Array<String> = [
		'Note Colors',
		'Controls',
		'UI Editor',
		'Graphics',
		'Audio and Visuals',
		'Gameplay'
	];
	private var grpOptions:FlxTypedGroup<Alphabet>;

	public static var restart:Bool = false;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String)
	{
		switch (label)
		{
			case 'Note Colors':
				openSubState(new funkin.menus.options.NotesSubState());
			case 'Controls':
				openSubState(new funkin.menus.options.ControlsSubState());
			case 'UI Editor':
				MusicBeatState.switchState(new UIEditor(0, returnToPlaystate));
			case 'Graphics':
				openSubState(new funkin.menus.options.GraphicsSettingsSubState());
			case 'Audio and Visuals':
				openSubState(new AudioVisualsSubState());
			case 'Gameplay':
				openSubState(new funkin.menus.options.GameplaySettingsSubState());
		}
		persistentUpdate = false;
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	var bg:FlxSprite;
	var grid:GridBG;

	override function create()
	{
		Alphabet.spinCharsOnHover = true;

		bg = new FlxSprite();
		bg.loadGraphicWithAssetQuality('menuDesat');
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		add(bg);
		if (FlxG.width >= 720)
		{
			bg.setGraphicSize(FlxG.width, 0);
		}
		else
		{
			bg.setGraphicSize(FlxG.width, FlxG.height);
		}
		grid = new GridBG();
		add(grid);
		grid.fadeIn();
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true, false);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true, false);
		add(selectorRight);

		changeSelection(1);
		changeSelection(-1);

		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		changeSelection(FlxG.mouse.wheel);

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		var i:Int = 0;
		Alphabet.spinCharsOnHover = (Input.curType == InputTypes.MOUSE);
		if (Input.curType == InputTypes.MOUSE)
		{
			for (opt in grpOptions)
			{
				if (FlxG.mouse.overlaps(opt))
				{
					if (FlxG.mouse.justPressed)
					{
						openSelectedSubstate(options[i]);
					}
					setSelection(i);
				}
				i++;
			}
		}
		if (controls.BACK)
		{
			Alphabet.spinCharsOnHover = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			ClientPrefs.saveSettings();
			#if sys
			var args:Array<String> = [];
			if (restart)
			{
				args.push('-game');
				args.push('--window-vsync=${Std.string(ClientPrefs.vsync)}');
				args.push('-mainMenu'); // TODO: this shit
				args.push('-mainMenuMusicTime=${Std.string(FlxG.sound.music.time)}'); // TODO: this shit

				new sys.io.Process(Sys.programPath(), args);
				openfl.system.System.exit(0);
			}
			#end
			if (returnToPlaystate)
			{
				MusicBeatState.switchState(new PlayState());
			}
			else
			{
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		if (controls.ACCEPT)
		{
			openSelectedSubstate(options[curSelected]);
			Alphabet.spinCharsOnHover = false;
		}
	}

	function setSelection(id:Int = 0)
	{
		if (id != curSelected)
		{
			curSelected = id;
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
					selectorLeft.x = item.x - 63;
					selectorLeft.y = item.y;
					selectorRight.x = item.x + item.width + 15;
					selectorRight.y = item.y;
				}
			}
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
	}

	function changeSelection(change:Int = 0)
	{
		if (change != 0)
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
					selectorLeft.x = item.x - 63;
					selectorLeft.y = item.y;
					selectorRight.x = item.x + item.width + 15;
					selectorRight.y = item.y;
				}
			}
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
	}
}
