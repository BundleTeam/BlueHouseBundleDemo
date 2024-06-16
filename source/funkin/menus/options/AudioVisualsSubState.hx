package funkin.menus.options;

import haxe.Json;
import flixel.FlxG;
import flixel.sound.FlxSound;

using StringTools;

class AudioVisualsSubState extends BaseOptionsMenu
{
	public function new()
	{
		var option:Option = new Option('Pause Song:', "What song do you prefer for the Pause Screen?", 'pauseMusic', 'string', 'Default', [
			'None',
			'Default',
			'Long Pause',
			'Gallery',
			'Shitread Melody',
			'The Mista (Leaks!)',
			'Breakfast',
			'Tea Time',
			'Psync'
		]);
		addOption(option);
		option.onChange = onChangePauseMusic;

		var option:Option = new Option('Hitsound', 'Funny notes does \"Tick!\" when you hit them."', 'hitsound', 'string', 'default',
			Json.parse(Paths.getTextFromFile('hitsounds/sounds.json')).sounds);
		addOption(option);
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option('Hitsound Volume', 'Changes how loud the \"Tick!\" is.', 'hitsoundVolume', 'percent', 0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;
		var option:Option = new Option('Note Offset', 'Changes the delay of the audio.', 'noteOffset', 'int', 0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -1000;
		option.maxValue = 1000;
		option.changeValue = 1;
		addOption(option);

		var option:Option = new Option('Note Splashes', "If unchecked, hitting \"Sick!\" notes won't show particles.", 'noteSplashes', 'bool', true);
		addOption(option);
		// TODO: remove options from clientprefs like hideHud and health bar transparency
		/*
				var option:Option = new Option('Hide HUD', 'If checked, hides most HUD elements.', 'hideHud', 'bool', false);
				addOption(option);

			var option:Option = new Option('Time Bar:', "What should the Time Bar display?", 'timeBarType', 'string', 'Time Left',
				['Time Left', 'Time Elapsed', 'Song Name', 'Disabled']);
			addOption(option);
		 */

		var option:Option = new Option('Flashing Lights', "Uncheck this if you're sensitive to flashing lights!", 'flashing', 'bool', true);
		addOption(option);

		var option:Option = new Option('Camera Zooms', "If unchecked, the camera won't zoom in on a beat hit.", 'camZooms', 'bool', true);
		addOption(option);
		/*
			var option:Option = new Option('Score Text Zoom on Hit', "If unchecked, disables the Score text zooming\neverytime you hit a note.", 'scoreZoom',
				'bool', true);
			addOption(option);
				var option:Option = new Option('Health Bar Transparency', 'How much transparent should the health bar and icons be.', 'healthBarAlpha', 'percent', 1);
				option.scrollSpeed = 1.6;
				option.minValue = 0.0;
				option.maxValue = 1;
				option.changeValue = 0.1;
				option.decimals = 1;
				addOption(option);
		 */
		#if html5
		if (FlxG.onMobile)
		{
			var option:Option = new Option('Low Quality Audio',
				"Audio is played at almost half the quality for less crashes\nand improved performance on mobile.", 'lowQualityAudio', 'bool', true);
			addOption(option);
		}
		else
		{
			var option:Option = new Option('Low Quality Audio',
				"Audio is played at almost half the quality for less crashes\nand improved performance on mobile.", 'lowQualityAudio', 'bool', false);
			addOption(option);
		}
		#end

		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates', 'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates', 'bool', true);
		addOption(option);
		#end

		super();
	}

	var changedMusic:Bool = false;

	function onChangePauseMusic()
	{
		if (ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	var hitsound:FlxSound = new FlxSound();

	function onChangeHitsoundVolume()
	{
		if (hitsound.playing)
			hitsound.stop();

		hitsound = FlxG.sound.play(Paths.hitsound(ClientPrefs.hitsound), ClientPrefs.hitsoundVolume);
	}

	override function destroy()
	{
		if (changedMusic)
			FlxG.sound.playMusic(Paths.music(Main.MainMenuTheme));
		super.destroy();
	}
}
