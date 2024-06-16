package funkin.editors.ui;

import flixel.ui.FlxButton;
import funkin.gameplay.hud.TimeBar;
import funkin.gameplay.hud.LatencyDisplay;
import openfl.Assets;
import flixel.util.FlxCollision;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.*;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteContainer;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import funkin.gameplay.Note;
import funkin.gameplay.NoteSplash;
import funkin.gameplay.StrumNote;
import funkin.gameplay.hud.HealthBar;
import funkin.gameplay.hud.IEditableHudGroup;
import funkin.menus.options.OptionsState;
import funkin.ui.*;
import funkin.music.Song.SwagSong;
import haxe.Json;
import lime.app.Event;
import openfl.events.KeyboardEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;

using StringTools;

// TODO: please dear god use anything but flixel ui -letsgoaway
class UIEditor extends MusicBeatState
{
	private var strumLine:FlxSprite;
	private var comboGroup:FlxTypedGroup<FlxSprite>;
	private var hitBoxSquare__LineStyle:LineStyle;

	public var strumLineNotes:FlxTypedSpriteGroup<StrumNote>;
	public var opponentStrums:FlxTypedSpriteGroup<StrumNote>;
	public var playerStrums:FlxTypedSpriteGroup<StrumNote>;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	var generatedMusic:Bool = false;

	var startOffset:Float32 = 0;
	var startPos:Float32 = 0;
	private var hitBoxSquare:FlxSprite;
	private var returnToPlayState:Bool = false;
	private var replayMusic:Bool = true;
	var tipText:FlxText;

	public function new(startPos:Float, returnToPlayState:Bool = false, replayMusic:Bool = true)
	{
		this.returnToPlayState = returnToPlayState;
		this.replayMusic = replayMusic;
		if (!replayMusic)
		{
			this.startPos = startPos;
			Conductor.songPosition = startPos - startOffset;
			startOffset = Conductor.crochet;
			timerToStart = startOffset;
		}

		super();
	}

	var timerToStart:Float32 = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();

	public static var instance:UIEditor;

	private var objects:Map<String, FlxSprite> = new Map<String, FlxSprite>();

	private var rating:FlxSprite;
	private var comboNums:FlxSpriteGroup;
	private var coolText:LatencyDisplay;
	private var healthBar:HealthBar;
	private var timeBar:TimeBar;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var camEditor:FlxCamera;

	var grid:GridBG;
	private var UI_box:FlxUITabMenu;

	override function create()
	{ // Cameras
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camEditor = new FlxCamera();

		Conductor.changeBPM(128.0);
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;
		camEditor.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.add(camEditor, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;
		if (replayMusic)
		{
			FlxG.sound.music.loadEmbedded(Paths.music('psync'), true);
			FlxG.sound.music.play();
		}
		instance = this;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = FlxColor.fromHSB(FlxG.random.int(0, 359), FlxG.random.float(0, 0.8), FlxG.random.float(0.3, 1));
		bg.cameras = [camGame];
		add(bg);

		grid = new GridBG();
		add(grid);
		grid.fadeIn();

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if (ClientPrefs.downScroll)
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		comboGroup = new FlxTypedGroup<FlxSprite>();
		add(comboGroup);

		strumLineNotes = new FlxTypedSpriteGroup<StrumNote>();
		opponentStrums = new FlxTypedSpriteGroup<StrumNote>();
		playerStrums = new FlxTypedSpriteGroup<StrumNote>();
		add(strumLineNotes);
		strumLineNotes.cameras = [camHUD];
		opponentStrums.cameras = [camHUD];
		playerStrums.cameras = [camHUD];

		rating = new FlxSprite().loadGraphic(Paths.image('sick'));
		rating.cameras = [camHUD];
		rating.setGraphicSize(Std.int(rating.width));
		rating.updateHitbox();
		objects.set("rating", rating);
		add(rating);

		comboNums = new FlxSpriteGroup();
		comboNums.cameras = [camHUD];
		add(comboNums);
		objects.set("comboNums", comboNums);

		coolText = new LatencyDisplay();
		coolText.cameras = [camHUD];
		add(coolText);
		coolText.showText('69.42ms', false);
		objects.set("coolText", coolText);

		healthBar = new HealthBar();
		healthBar.cameras = [camHUD];
		add(healthBar);
		objects.set("healthBar", healthBar);

		timeBar = new TimeBar();
		timeBar.cameras = [camHUD];
		add(timeBar);
		objects.set("timeBar", timeBar);

		var seperatedScore:Array<Int> = [];
		for (i in 0...3)
		{
			seperatedScore.push(FlxG.random.int(0, 9));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite(43 * daLoop).loadGraphic(Paths.image('num' + i));
			numScore.cameras = [camHUD];
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();

			comboNums.add(numScore);
			daLoop++;
		}

		generateStaticArrows(0);
		generateStaticArrows(1);
		/*if(ClientPrefs.middleScroll) {
			opponentStrums.forEachAlive(function (note:StrumNote) {
				note.visible = false;
			});
		}*/

		tipText = new FlxText(10, FlxG.height - 64, 0,
			'Press ESC to Go Back to Options\nClick And Drag To Adjust Postion | Press Tab to Toggle Properties Menu', 16);
		tipText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, QualityPrefs.textShadow(), FlxColor.BLACK);
		tipText.borderSize = 2;
		tipText.scrollFactor.set();
		add(tipText);
		tipText.cameras = [camEditor];
		FlxG.mouse.visible = true;

		// sayGo();
		hitBoxSquare = new FlxSprite();
		hitBoxSquare__LineStyle = new format.gfx.LineStyle();
		hitBoxSquare__LineStyle.thickness = 4.0;
		hitBoxSquare__LineStyle.color = 0xFFFF0000;

		hitBoxSquare.makeGraphic(Std.int(rating.width), Std.int(rating.height + 1), 0x00000000);
		hitBoxSquare.cameras = [camEditor];
		FlxSpriteUtil.drawRect(hitBoxSquare, 0, 0, rating.width, rating.height, 0x00000000, hitBoxSquare__LineStyle);
		hitBoxSquare.setPosition(rating.x, rating.y);
		add(hitBoxSquare);

		for (object in objects.keyValueIterator())
		{
			UIData.getAndApplyToSprite(object.key, object.value);
		}
		super.create();
		var tabs = [{name: "Layout", label: "Layout"}, {name: "Properties", label: 'Properties'}];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.resize(300, 400);
		UI_box.x = FlxG.width - 300;
		UI_box.y = 25;
		UI_box.scrollFactor.set();
		UI_box.cameras = [camEditor];
		UI_box.alpha = 1;
		@:privateAccess
		add(UI_box);
		initPropertiesUI();
		initLayoutUI();
	}

	private var UI_properties:FlxUI;
	var UI_properties_selectAnObjectText:FlxUIText;
	var UI_properties_objectsList:FlxUIDropDownMenuCustom;
	var UI_properties_opacity:FlxUIMultipleSlider;
	var alphaSliderValue:Float = 1.0;
	var UI_properties_scalex:FlxUIMultipleSlider;
	var scaleXSliderValue:Float = 1.0;
	var UI_properties_scaley:FlxUIMultipleSlider;
	var scaleYSliderValue:Float = 1.0;
	var UI_properties_rotate:FlxUIMultipleSlider;
	var rotateSliderValue:Float = 0.0;

	var UI_properties_position:FlxUIDropDownMenuCustom;

	var null_int:Null<Int> = null;

	public override function beatHit()
	{
		healthBar.beatHit();
		super.beatHit();
	}

	private function initPropertiesUI()
	{
		UI_properties = new FlxUI(null, UI_box);
		UI_properties.name = "Properties";

		UI_properties_selectAnObjectText = new FlxUIText(0, 100);
		UI_properties_selectAnObjectText.text = "Select an object to edit!";
		UI_properties_selectAnObjectText.alignment = FlxTextAlign.CENTER;
		UI_properties_selectAnObjectText.fieldWidth = 300;
		UI_properties_selectAnObjectText.name = "unselected";
		UI_properties.add(UI_properties_selectAnObjectText);

		var objNames:Array<String> = [""];
		for (name in objects.keys())
		{
			objNames.push(name);
		}
		UI_properties_objectsList = new FlxUIDropDownMenuCustom(10, 10, FlxUIDropDownMenuCustom.makeStrIdLabelArray(objNames, false), (str) ->
		{
			var sprite:FlxSprite = objects.get(str);
			if (sprite is IEditableHudGroup)
				selectedObject = cast(sprite, IEditableHudGroup).getSprite();
			else
				selectedObject = sprite;
			lastObject = selectedObject;
			updatePropertiesUIWithNewValues(str);
		});
		UI_properties_objectsList.name = "alwaysShow";
		UI_properties.add(UI_properties_objectsList);

		UI_properties_opacity = new FlxUIMultipleSlider(this, "alphaSliderValue", 65, 40, 0.0, 1.0, 150, null_int, 5, FlxColor.WHITE, FlxColor.BLACK);
		UI_properties_opacity.multiple = 0.05;
		UI_properties_opacity.nameLabel.text = "Opacity";
		UI_properties_opacity.value = 1.0;
		UI_properties.add(UI_properties_opacity);

		UI_properties_scalex = new FlxUIMultipleSlider(this, "scaleXSliderValue", UI_properties_opacity.x, UI_properties_opacity.y + 50, 0.0, 3.5, 150,
			null_int, 5, FlxColor.WHITE, FlxColor.BLACK);
		UI_properties_scalex.multiple = 0.05;
		UI_properties_scalex.nameLabel.text = "X Scale";
		UI_properties_scalex.value = 1.0;
		UI_properties_scalex.decimals = 2;
		UI_properties.add(UI_properties_scalex);

		UI_properties_scaley = new FlxUIMultipleSlider(this, "scaleYSliderValue", UI_properties_scalex.x, UI_properties_scalex.y + 50, 0.0, 3.5, 150,
			null_int, 5, FlxColor.WHITE, FlxColor.BLACK);
		UI_properties_scaley.multiple = 0.05;
		UI_properties_scaley.nameLabel.text = "Y Scale";
		UI_properties_scaley.value = 1.0;
		UI_properties_scalex.decimals = 2;
		UI_properties.add(UI_properties_scaley);

		UI_properties_rotate = new FlxUIMultipleSlider(this, "rotateSliderValue", UI_properties_scaley.x, UI_properties_scaley.y + 50, -180, 180, 150,
			null_int, 5, FlxColor.WHITE, FlxColor.BLACK);
		UI_properties_rotate.multiple = 5;
		UI_properties_rotate.nameLabel.text = "Rotation";
		UI_properties_rotate.value = 0.0;
		UI_properties_rotate.decimals = 0;
		UI_properties.add(UI_properties_rotate);

		UI_properties_position = new FlxUIDropDownMenuCustom(UI_properties_scaley.x, UI_box.height - 50, FlxUIDropDownMenuCustom.makeStrIdLabelArray([
			"Top Left",
			"Top Center",
			"Top Right",
			"Middle Left",
			"Screen Center",
			"Middle Right",
			"Bottom Left",
			"Bottom Center",
			"Bottom Right"
		], false), (str) ->
			{
				if (lastObject != null)
				{
					switch (str)
					{
						case "Top Left":
							lastObject.x = 0;
							lastObject.y = 0;
						case "Top Center":
							lastObject.screenCenter(X);
							lastObject.y = 0;
						case "Top Right":
							lastObject.x = FlxG.width - lastObject.width;
							lastObject.y = 0;
						case "Middle Left":
							lastObject.x = 0;
							lastObject.screenCenter(Y);
						case "Screen Center":
							lastObject.screenCenter();
						case "Middle Right":
							lastObject.x = FlxG.width - lastObject.width;
							lastObject.screenCenter(Y);
						case "Bottom Left":
							lastObject.x = 0;
							lastObject.y = FlxG.height - lastObject.height;
						case "Bottom Center":
							lastObject.screenCenter(X);
							lastObject.y = FlxG.height - lastObject.height;
						case "Bottom Right":
							lastObject.x = FlxG.width - lastObject.width;
							lastObject.y = FlxG.height - lastObject.height;
					}
				}
			});
		UI_properties.add(UI_properties_position);

		UI_box.addGroup(UI_properties);
		@:privateAccess
		UI_box.set_selected_tab_id("Properties");
	}

	private function updatePropertiesUI()
	{
		if (!(UI_box.selected_tab_id == "Properties"))
			return;
		for (member in UI_properties.members)
		{
			if (member == UI_properties)
			{
				continue;
			}
			member.alpha = UI_box.alpha;
			if (UI_properties_objectsList.dropPanel.visible)
			{
				if (member != UI_properties_objectsList)
				{
					member.visible = false;
				}
			}
			else
			{
				try
				{
					var widget:IFlxUIWidget = cast(member, IFlxUIWidget);
					if (widget.name == "unselected")
					{
						member.visible = !hitBoxSquare.visible;
						continue;
					}
					else if (widget.name == "alwaysShow")
					{
						member.visible = true;
						continue;
					}
				}
				catch (ignored)
				{
					if ((member is FlxUIText))
					{
						member.visible = !hitBoxSquare.visible;
						continue;
					}
				}
				member.visible = hitBoxSquare.visible;
			}
		}

		if (lastObject == null)
			return;

		lastObject.alpha = Std.parseFloat(UI_properties_opacity.valueLabel.text);
		if (!(lastObject is FlxSpriteGroup) && !(lastObject is FlxSpriteContainer))
		{
			lastObject.scale.x = Std.parseFloat(UI_properties_scalex.valueLabel.text);
			lastObject.scale.y = Std.parseFloat(UI_properties_scaley.valueLabel.text);
			lastObject.angle = Std.parseFloat(UI_properties_rotate.valueLabel.text);
			lastObject.updateHitbox();
		}
		hitBoxSquare.setPosition(lastObject.x, lastObject.y);
		hitBoxSquare.setGraphicSize(Std.int(lastObject.width), Std.int(lastObject.height));
		hitBoxSquare.angle = lastObject.angle;
		hitBoxSquare.updateHitbox();
	}

	private function updatePropertiesUIWithNewValues(name:String = "")
	{
		@:privateAccess
		UI_properties_objectsList.set_selectedId(name);
		@:privateAccess
		UI_box.set_selected_tab_id("Properties");

		if (name == "")
		{
			return;
		}

		hitBoxSquare.makeGraphic(Std.int(selectedObject.width), Std.int(selectedObject.height + 1), 0x00000000);
		FlxSpriteUtil.drawRect(hitBoxSquare, 0, 0, selectedObject.width, selectedObject.height, 0x00000000, hitBoxSquare__LineStyle);
		hitBoxSquare.setPosition(selectedObject.x, selectedObject.y);

		UI_properties_opacity.value = selectedObject.alpha;
		alphaSliderValue = selectedObject.alpha;
		if ((selectedObject is FlxSpriteGroup) && (selectedObject is FlxSpriteContainer))
		{
			return;
		}
		UI_properties_scalex.value = selectedObject.scale.x;
		scaleXSliderValue = selectedObject.scale.x;
		UI_properties_scaley.value = selectedObject.scale.y;
		scaleYSliderValue = selectedObject.scale.y;
		UI_properties_rotate.value = selectedObject.angle;
		rotateSliderValue = selectedObject.angle;
	}

	private var UI_Layout:FlxUI;
	private var UI_Layout_downScroll:FlxUICheckBox;
	private var UI_Layout_middleScroll:FlxUICheckBox;
	private var UI_Layout_opponentNotes:FlxUICheckBox;
	private var UI_Layout_useClassicArrows:FlxUICheckBox;
	private var UI_Layout_useClassicHealthbar:FlxUICheckBox;
	private var UI_Layout_hideHealthbarIcons:FlxUICheckBox;
	private var UI_Layout_scoreTextZoom:FlxUICheckBox;

	private var UI_Layout_classicStrumline:FlxUICheckBox;
	private var UI_Layout_timeBarType:FlxUIDropDownMenuCustom;

	private var UI_Layout_profileSelector:FlxUIDropDownMenuCustom;
	private var UI_Layout_save:FlxButton;
	private var UI_Layout_load:FlxButton;
	private var uiProfiles:UIProfilesData;

	private function initLayoutUI()
	{
		UI_Layout = new FlxUI(null, UI_box);
		UI_Layout.name = "Layout";
		uiProfiles = Json.parse(Assets.getText(Paths.json('uiProfiles')));
		var profileNames:Array<String> = [];
		profileNames.push("----------");
		for (profile in uiProfiles.profiles)
			profileNames.push(profile.title);

		UI_Layout_profileSelector = new FlxUIDropDownMenuCustom(120, 10, FlxUIDropDownMenuCustom.makeStrIdLabelArray(profileNames, false), (str) ->
		{
			if (str != "----------")
			{
				for (profile in uiProfiles.profiles)
				{
					if (profile.title == str)
					{
						loadUILayoutStr(Assets.getText(Paths.ui(profile.id)));
						break;
					}
				}
			}
		});
		UI_Layout_profileSelector.selectedLabel = "----------";
		UI_Layout.add(UI_Layout_profileSelector);

		UI_Layout_save = new FlxButton(200, UI_box.height - 100, "Save", () ->
		{
			saveLayout();
		});
		UI_Layout.add(UI_Layout_save);

		UI_Layout_load = new FlxButton(200, UI_box.height - 50, "Load", () ->
		{
			loadLayout();
		});
		UI_Layout.add(UI_Layout_load);

		UI_Layout_downScroll = new FlxUICheckBox(10, 10, null, null, "Downscroll");
		UI_Layout_downScroll.callback = () ->
		{
			ClientPrefs.downScroll = UI_Layout_downScroll.checked;
			var ylevel:Float32 = 0.00;
			if (ClientPrefs.downScroll)
				ylevel = FlxG.height - 150;
			else
				ylevel = 50;
			var x:UInt8 = 0;
			for (arrow in strumLineNotes)
			{
				FlxTween.tween(arrow, {"y": ylevel}, 0.2, {ease: FlxEase.expoOut, startDelay: (0.05 * x)});
				x++;
			}
		}
		UI_Layout_downScroll.checked = ClientPrefs.downScroll;
		UI_Layout.add(UI_Layout_downScroll);

		UI_Layout_middleScroll = new FlxUICheckBox(10, 40, null, null, "Middlescroll");
		UI_Layout_middleScroll.callback = () ->
		{
			ClientPrefs.middleScroll = UI_Layout_middleScroll.checked;
			generateStaticArrows(0);
			generateStaticArrows(1);
		}
		UI_Layout_middleScroll.checked = ClientPrefs.middleScroll;
		UI_Layout.add(UI_Layout_middleScroll);

		UI_Layout_opponentNotes = new FlxUICheckBox(10, 70, null, null, "Show Opponent Notes");
		UI_Layout_opponentNotes.callback = () ->
		{
			ClientPrefs.opponentStrums = UI_Layout_opponentNotes.checked;
			generateStaticArrows(0);
			generateStaticArrows(1);
		}
		UI_Layout_opponentNotes.checked = ClientPrefs.opponentStrums;
		UI_Layout.add(UI_Layout_opponentNotes);

		UI_Layout_useClassicArrows = new FlxUICheckBox(10, 100, null, null, "Use Classic Style Notes");
		UI_Layout_useClassicArrows.callback = () ->
		{
			ClientPrefs.ui.useClassicArrows = UI_Layout_useClassicArrows.checked;
			generateStaticArrows(0);
			generateStaticArrows(1);
		}
		UI_Layout_useClassicArrows.checked = ClientPrefs.ui.useClassicArrows;
		UI_Layout.add(UI_Layout_useClassicArrows);

		UI_Layout_useClassicHealthbar = new FlxUICheckBox(10, 130, null, null, "Use Classic Healthbar Positioning");
		UI_Layout_useClassicHealthbar.callback = () ->
		{
			ClientPrefs.ui.useClassicHealthbar = UI_Layout_useClassicHealthbar.checked;
		}
		UI_Layout_useClassicHealthbar.checked = ClientPrefs.ui.useClassicHealthbar;
		UI_Layout.add(UI_Layout_useClassicHealthbar);

		UI_Layout_hideHealthbarIcons = new FlxUICheckBox(10, 160, null, null, "Hide Health Icons");
		UI_Layout_hideHealthbarIcons.callback = () ->
		{
			ClientPrefs.ui.hideHealthIcons = UI_Layout_hideHealthbarIcons.checked;
		}
		UI_Layout_hideHealthbarIcons.checked = ClientPrefs.ui.hideHealthIcons;
		UI_Layout.add(UI_Layout_hideHealthbarIcons);

		UI_Layout_scoreTextZoom = new FlxUICheckBox(10, 190, null, null, "Score Text Zoom on Note Hit");
		UI_Layout_scoreTextZoom.callback = () ->
		{
			ClientPrefs.ui.scoreTextZoom = UI_Layout_scoreTextZoom.checked;
		}
		UI_Layout_scoreTextZoom.checked = ClientPrefs.ui.scoreTextZoom;
		UI_Layout.add(UI_Layout_scoreTextZoom);

		UI_Layout_classicStrumline = new FlxUICheckBox(10, 220, null, null, "Classic Style Strumline");
		UI_Layout_classicStrumline.callback = () ->
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			ClientPrefs.ui.classicStrumline = UI_Layout_classicStrumline.checked;
			reloading = true;
			MusicBeatState.switchState(new UIEditor(0, returnToPlayState, false));
		}
		UI_Layout_classicStrumline.checked = ClientPrefs.ui.classicStrumline;
		UI_Layout.add(UI_Layout_classicStrumline);

		UI_Layout_timeBarType = new FlxUIDropDownMenuCustom(10, UI_box.height - 50,
			FlxUIDropDownMenuCustom.makeStrIdLabelArray(['Time Left', 'Time Elapsed', 'Song Name', 'Accuracy', 'Disabled'], false), (str) ->
			{
				ClientPrefs.ui.timeBarType = str;
			});
		UI_Layout_timeBarType.selectedLabel = ClientPrefs.ui.timeBarType;
		UI_Layout.add(UI_Layout_timeBarType);

		UI_box.addGroup(UI_Layout);
	}

	function updateLayoutUI()
	{
		if (!(UI_box.selected_tab_id == "Layout"))
			return;
		for (member in UI_Layout.members)
		{
			member.alpha = UI_box.alpha;
		}
	}

	/*
		override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
		{
			super.getEvent(id, sender, data, params);
			if (id == "change_slider")
			{
				if (sender == UI_properties_opacity && (sender is FlxUISlider))
				{
					if (cast(sender, FlxUISlider) == UI_properties_opacity)
					{
						alphaSliderValue = UI_properties_opacity.value;
					}
				}
			}
		}
	 */
	function sayGo()
	{
		var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('go'));
		go.scrollFactor.set();

		go.updateHitbox();

		go.screenCenter();
		add(go);
		FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				go.destroy();
			}
		});
		FlxG.sound.play(Paths.sound('introGo'), 0.6);
	}

	public function saveLayout()
	{
		var json:BEUIFormat = {
			elements: ClientPrefs.ui.elements,
			downScroll: ClientPrefs.downScroll, //
			useClassicArrows: ClientPrefs.ui.useClassicArrows,
			useClassicHealthbar: ClientPrefs.ui.useClassicHealthbar,
			opponentStrums: ClientPrefs.opponentStrums, //
			middleScroll: ClientPrefs.middleScroll, //
			hideHealthIcons: ClientPrefs.ui.hideHealthIcons,
			scoreTextZoom: ClientPrefs.ui.scoreTextZoom,
			timeBarType: ClientPrefs.ui.timeBarType,
			noteHSV: ClientPrefs.ui.noteHSV,
			classicStrumline: ClientPrefs.ui.classicStrumline,
		}

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			var _file = new FileReference();
			// _file.addEventListener(Event.COMPLETE, onSaveComplete);
			// _file.addEventListener(Event.CANCEL, onSaveCancel);
			// _file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, "profile.beui");
		}
	}

	public function loadUILayoutStr(str)
	{
		var json:BEUIFormat = Json.parse(str);
		if (Reflect.hasField(json, "elements"))
			ClientPrefs.ui.elements = json.elements;

		if (Reflect.hasField(json, "downScroll"))
			ClientPrefs.downScroll = json.downScroll;

		if (Reflect.hasField(json, "useClassicArrows"))
			ClientPrefs.ui.useClassicArrows = json.useClassicArrows;

		if (Reflect.hasField(json, "useClassicHealthbar"))
			ClientPrefs.ui.useClassicHealthbar = json.useClassicHealthbar;

		if (Reflect.hasField(json, "opponentStrums"))
			ClientPrefs.opponentStrums = json.opponentStrums;

		if (Reflect.hasField(json, "middleScroll"))
			ClientPrefs.middleScroll = json.middleScroll;

		if (Reflect.hasField(json, "hideHealthIcons"))
			ClientPrefs.ui.hideHealthIcons = json.hideHealthIcons;

		if (Reflect.hasField(json, "scoreTextZoom"))
			ClientPrefs.ui.scoreTextZoom = json.scoreTextZoom;

		if (Reflect.hasField(json, "timeBarType"))
			ClientPrefs.ui.timeBarType = json.timeBarType;

		if (Reflect.hasField(json, "noteHSV"))
			ClientPrefs.ui.noteHSV = json.noteHSV;

		if (Reflect.hasField(json, "classicStrumline"))
			ClientPrefs.ui.classicStrumline = json.classicStrumline;

		ClientPrefs.ui.downScroll = ClientPrefs.downScroll;
		ClientPrefs.ui.opponentStrums = ClientPrefs.opponentStrums;
		ClientPrefs.ui.middleScroll = ClientPrefs.middleScroll;

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		reloading = true;
		MusicBeatState.switchState(new UIEditor(0, returnToPlayState, false));
	}

	public function loadLayout():Void
	{
		FileFunctions.load((str) ->
		{
			loadUILayoutStr(str);
		}, ["BundleEngine UI Layout (.beui)", "beui"], true);
	}

	function exit()
	{
		ClientPrefs.saveSettings();
		MusicBeatState.switchState(new OptionsState(returnToPlayState));
	}

	function midPointOfSprite(sprite:FlxSprite)
	{
		return new FlxPoint(sprite.x + (sprite.width / 2), sprite.y + (sprite.height / 2));
	}

	private function updateSpriteSavedPos(sprite:FlxSprite, id:String)
	{
		if (sprite is IEditableHudGroup)
			sprite = cast(sprite, IEditableHudGroup).getSprite();
		if (selectedObject == sprite)
		{
			sprite.x += FlxG.mouse.deltaX;
			sprite.y += FlxG.mouse.deltaY;

			hitBoxSquare.setGraphicSize(Std.int(sprite.width), Std.int(sprite.height));
			hitBoxSquare.updateHitbox();
			hitBoxSquare.setPosition(sprite.x, sprite.y);

			if (!FlxG.mouse.pressed || mouseOverlapsUIBox)
			{
				selectedObject = null;
				UIData.getAndApplyToSprite(id, sprite);
			}
		}
		if ((lastObject == sprite || selectedObject == sprite) && !reloading)
		{
			UIData.set(id, sprite);
		}
	}

	var lastObject:FlxSprite = null;
	var selectedObject:FlxSprite = null;
	var UI_box_tween:FlxTween = null;
	var UI_box_out:Bool = true;
	var reloading = false;

	private function mouseOverlaps(sprite:FlxSprite):Bool
	{
		return FlxG.mouse.overlaps(sprite) || sprite.pixelsOverlapPoint(FlxG.mouse.getPosition());
	}

	private function mouseOverlapsGraphic(sprite:FlxSprite):Bool
	{
		return sprite.pixelsOverlapPoint(FlxG.mouse.getPosition());
	}

	var mouseOverlapsUIBox:Bool = false;

	override function update(elapsed:Float)
	{
		hitBoxSquare.visible = lastObject != null;
		tipText.visible = UI_box_out;
		if (UI_properties_position.dropPanel.visible || UI_Layout_timeBarType.dropPanel.visible)
			mouseOverlapsUIBox = mouseOverlaps(UI_box);
		else if (!UI_properties_position.dropPanel.visible)
			mouseOverlapsUIBox = mouseOverlaps(UI_box) && !mouseOverlaps(UI_properties_position.dropPanel);
		else if (!UI_Layout_timeBarType.dropPanel.visible)
			mouseOverlapsUIBox = mouseOverlaps(UI_box) && !mouseOverlaps(UI_Layout_timeBarType.dropPanel);

		UI_box.alpha = mouseOverlapsUIBox ? 1.0 : 0.75;
		if (FlxG.keys.justPressed.ESCAPE)
			exit();

		if (FlxG.keys.justPressed.TAB)
			toggleUIBox();

		if (FlxG.mouse.justReleasedRight && !mouseOverlapsUIBox)
		{
			if (mouseOverlaps(strumLineNotes))
			{
				if (!UI_box_out)
				{
					toggleUIBox();
				}
				@:privateAccess
				UI_box.set_selected_tab_id("Layout");
			}
			else
			{
				var objectName:String = "";
				for (object in objects.keyValueIterator())
				{
					if (mouseOverlaps(object.value))
					{
						if (object.value is IEditableHudGroup)
							selectedObject = cast(object.value, IEditableHudGroup).getSprite();
						else
							selectedObject = object.value;
						objectName = object.key;
						break;
					}
				}

				updatePropertiesUIWithNewValues(objectName);
				lastObject = selectedObject;
				if (objectName != "" && !UI_box_out)
				{
					@:privateAccess
					UI_box.set_selected_tab_id("Properties");
					toggleUIBox();
				}
				else if (objectName == "" && UI_box_out)
				{
					toggleUIBox();
				}
			}
		}

		if (FlxG.mouse.justPressed && !mouseOverlapsUIBox)
		{
			if (mouseOverlaps(strumLineNotes))
			{
				@:privateAccess
				UI_box.set_selected_tab_id("Layout");
			}
			else
			{
				var objectName:String = "";
				for (object in objects.keyValueIterator())
				{
					if (mouseOverlaps(object.value))
					{
						if (object.value is IEditableHudGroup)
							selectedObject = cast(object.value, IEditableHudGroup).getSprite();
						else
							selectedObject = object.value;
						objectName = object.key;
						break;
					}
				}

				updatePropertiesUIWithNewValues(objectName);
				lastObject = selectedObject;
			}
		}
		if (lastObject != null)
		{
			if (FlxG.keys.justPressed.UP)
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					lastObject.y -= 1;
				}
				else
				{
					lastObject.y = FNKMath.roundToMultiple(lastObject.y, 5);
					lastObject.y -= 5;
				}
			}
			if (FlxG.keys.justPressed.LEFT)
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					lastObject.x -= 1;
				}
				else
				{
					lastObject.x = FNKMath.roundToMultiple(lastObject.x, 5);
					lastObject.x -= 5;
				}
			}
			if (FlxG.keys.justPressed.DOWN)
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					lastObject.y += 1;
				}
				else
				{
					lastObject.y = FNKMath.roundToMultiple(lastObject.y, 5);
					lastObject.y += 5;
				}
			}
			if (FlxG.keys.justPressed.RIGHT)
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					lastObject.x += 1;
				}
				else
				{
					lastObject.x = FNKMath.roundToMultiple(lastObject.x, 5);
					lastObject.x += 5;
				}
			}
		}
		hitBoxSquare.alpha = 1;
		for (object in objects.keyValueIterator())
		{
			updateSpriteSavedPos(object.value, object.key);
		}

		updatePropertiesUI();
		updateLayoutUI();
		if (hitBoxSquare.visible && !UI_properties_objectsList.dropPanel.visible)
		{
			var showIF:Bool = !(lastObject is FlxSpriteGroup) && !(lastObject is FlxSpriteContainer);
			UI_properties_scalex.visible = showIF;
			UI_properties_scaley.visible = showIF;
			UI_properties_rotate.visible = showIF;
		}

		super.update(elapsed);
		Conductor.songPosition = FlxG.sound.music.time;
	}

	function toggleUIBox()
	{
		UI_box_out = !UI_box_out;
		if (UI_box_tween != null)
			UI_box_tween.cancel();
		var gotoX:Float = FlxG.width - 300;
		if (!UI_box_out)
			gotoX = FlxG.width;
		UI_box_tween = FlxTween.tween(UI_box, {x: gotoX}, 0.5, {ease: FlxEase.expoOut});
	}

	override function stepHit()
	{
		super.stepHit();
	}

	var combo:Int = 0;

	private function generateStaticArrows(player:Int):Void
	{
		if (ClientPrefs.downScroll)
			strumLine.y = FlxG.height - 150;
		else
			strumLine.y = 50;
		if (strumLineNotes.members.length > 0 && player == 0)
		{
			for (arrow in strumLineNotes)
			{
				arrow.destroy();
				strumLineNotes.remove(arrow);
			}
		}

		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if (!ClientPrefs.opponentStrums)
					targetAlpha = 0;
				else if (ClientPrefs.middleScroll)
					targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;

			babyArrow.alpha = 0;
			babyArrow.visible = targetAlpha != 0;
			if (!babyArrow.visible)
			{
				continue;
			}
			FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: (0.2 * i)});

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if (ClientPrefs.middleScroll)
				{
					babyArrow.x = PlayState.STRUM_X_MIDDLESCROLL + 310;
					if (i > 1)
					{ // Up and Right
						// babyArrow.x += FlxG.width / 2 + 25; // this code line from psych broke it on different resolutions,
						// but thats fine because on psych its only
						// made for 720p -letsgoaway
						babyArrow.x = FlxG.width + (PlayState.STRUM_X_MIDDLESCROLL * 2) - 20;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float)
	{
		var spr:StrumNote = null;

		if (isDad)
			spr = strumLineNotes.members[id];
		else
			spr = playerStrums.members[id];

		if (spr != null)
		{
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	override function destroy()
	{
		if (!reloading && !returnToPlayState)
		{
			FlxG.sound.music.loadEmbedded(Paths.music(Main.MainMenuTheme), true);
			FlxG.sound.music.play();
		}
		super.destroy();
	}
}
