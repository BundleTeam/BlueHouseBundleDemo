package funkin.system;

// code file that has been here since the day i started working on bhb :)
// from itll be fine
import openfl.utils.ByteArray;
import lime.ui.FileDialog;
import openfl.net.FileFilter;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import haxe.Json;
import openfl.net.FileReference;
import funkin.utils.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.addons.display.FlxExtendedSprite;

var _file:FileReference;

function onSaveComplete(_):Void
{
	_file.removeEventListener(Event.COMPLETE, onSaveComplete);
	_file.removeEventListener(Event.CANCEL, onSaveCancel);
	_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
	_file = null;
	FlxG.log.notice("Successfully saved file.");
}

function onSaveCancel(_):Void
{
	_file.removeEventListener(Event.COMPLETE, onSaveComplete);
	_file.removeEventListener(Event.CANCEL, onSaveCancel);
	_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
	_file = null;
	FlxG.log.notice("User canceled save.");
}

function onSaveError(_):Void
{
	_file.removeEventListener(Event.COMPLETE, onSaveComplete);
	_file.removeEventListener(Event.CANCEL, onSaveCancel);
	_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
	_file = null;
	FlxG.log.error("Unknown error saving dialogue data....");
}

function save(data:Dynamic, name = "file", extension = "txt"):Void
{
	extension = "." + extension;
	if ((data != null) && (data.length > 0))
	{
		_file = new FileReference();
		_file.addEventListener(Event.COMPLETE, onSaveComplete);
		_file.addEventListener(Event.CANCEL, onSaveCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file.save(data, name + extension);
	}
}

function saveImage(data:ByteArray, name = "file", extension = "txt"):Void
{
	extension = "." + extension;
	if ((data != null) && (data.length > 0))
	{
		_file = new FileReference();
		_file.addEventListener(Event.COMPLETE, onSaveComplete);
		_file.addEventListener(Event.CANCEL, onSaveCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file.save(data, name + extension);
	}
}

class FileFunctions
{
	public static function load(?callOnLoad:Dynamic->Void, ?filefilter:Null<Array<String>>, ?loadAsString:Bool, ?useOldMethod:Bool):Void
	{
		#if html5
		// tf
		filefilter[1] = "*." + filefilter[1];
		var filetoload = new FileReference();
		function loadComplete(?_)
		{
			callOnLoad(filetoload.data);
		}
		function loadFile(?_)
		{
			filetoload.load();
			filetoload.addEventListener(Event.COMPLETE, loadComplete);
		}
		filetoload.browse([new FileFilter(filefilter[0], filefilter[1])]);
		filetoload.addEventListener(Event.SELECT, loadFile);
		#end
		#if desktop
		var fileDialog = new FileDialog();
		fileDialog.open(filefilter[1], null, filefilter[0]);
		if (!loadAsString)
		{
			fileDialog.onOpen.add(file -> callOnLoad((file : haxe.io.Bytes)));
		}
		else
		{
			fileDialog.onOpen.add(file -> callOnLoad((file : haxe.io.Bytes).toString()));
		}
		#end
	}
}
