package funkin.menus;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxCamera;
import openfl.display.BitmapData;
import haxe.Http;
import haxe.Json;
import openfl.Lib;
import flixel.FlxSubState;
import flixel.FlxSprite;
import lime.net.HTTPRequest;
import lime.app.Future;

typedef NewsData =
{
	description:String,
	link:String,
	buttontitle:String,
	Text:String
}

// TODO: Make this not crash sometimes
class NewsSprite extends FlxTypedSpriteGroup<FlxSprite>
{
	private var dataRequest:HTTPRequest<String>;

	public static var newsJson:Dynamic;

	private var currentTab:Int = 1;

	private static var tab1Data:NewsData;

	private var tab1Circle:FlxSprite;

	private static var requester:HTTPRequest<haxe.io.Bytes>;

	private var tab1Banner:FlxSprite;

	private static var tab2Data:NewsData;

	private var tab2Circle:FlxSprite;

	private static var tab2Banner_req:HTTPRequest<haxe.io.Bytes>;

	private var tab2Banner:FlxSprite;

	private static var tab3Data:NewsData;

	private var tab3Circle:FlxSprite;

	private static var tab3Banner_req:HTTPRequest<haxe.io.Bytes>;

	private var tab3Banner:FlxSprite;

	private var tabPreviewGroup:FlxTypedSpriteGroup<FlxSprite>;
	private var tabSwitchTween:FlxTween;

	private var noInternet:Bool = false;

	private var newsCamera:FlxCamera;
	private var newsCameraOverlay:FlxCamera;

	public static var uiInitialized:Bool = false;

	private var tabOverlay:FlxSprite;

	private static var newsServer:String = 'http://cdn.jsdelivr.net/gh/letsgoawaydev/letsgoawaydev.github.io@master/news/bhb/';

	function switchToTab(tabNo:Int = 1)
	{
		// TODO: Make this better
		switch (tabNo)
		{
			case 1:
				currentTab = 1;
				if (tabSwitchTween != null)
					tabSwitchTween.cancel();

				tabSwitchTween = FlxTween.tween(tabPreviewGroup, {x: -(362 * 0)}, 0.35, {ease: FlxEase.expoOut});
			case 2:
				currentTab = 2;
				if (tabSwitchTween != null)
					tabSwitchTween.cancel();

				tabSwitchTween = FlxTween.tween(tabPreviewGroup, {x: -(362 * 1)}, 0.35, {ease: FlxEase.expoOut});
			case 3:
				currentTab = 3;
				if (tabSwitchTween != null)
					tabSwitchTween.cancel();

				tabSwitchTween = FlxTween.tween(tabPreviewGroup, {x: -(362 * 2)}, 0.35, {ease: FlxEase.expoOut});
		}
	}

	var slideTween:FlxTween;
	var isNewsTabOut:Bool = false;

	function slideIn()
	{
		if (!isNewsTabOut && uiInitialized)
		{
			isNewsTabOut = true;
			if (slideTween != null)
			{
				slideTween.cancel();
			}
			slideTween = FlxTween.tween(newsCamera, {x: FlxG.width - newsCamera.width}, 0.25, {
				ease: FlxEase.expoOut,
			});
			if (arrowTween != null)
			{
				arrowTween.cancel();
			}
			arrowTween = FlxTween.tween(tabSliderArrow, {angle: 180, "scale.y": arrowScale * 0.75}, 0.6, {ease: FlxEase.expoOut});
		}
	}

	function slideOut()
	{
		if (isNewsTabOut && uiInitialized)
		{
			isNewsTabOut = false;
			if (slideTween != null)
			{
				slideTween.cancel();
			}
			slideTween = FlxTween.tween(newsCamera, {x: FlxG.width}, 0.25, {
				ease: FlxEase.expoOut
			});
			if (arrowTween != null)
			{
				arrowTween.cancel();
			}
			arrowTween = FlxTween.tween(tabSliderArrow, {angle: 0}, 0.6, {ease: FlxEase.expoOut, onComplete: arrowTween2});
		}
	}

	var tabSlider:FlxSprite;
	var tabSliderArrow:FlxSprite;
	var arrowScale:Float = 0.00;

	public function init()
	{
		uiInitialized = false;
		newsCamera = new FlxCamera();
		newsCamera.width = 362;
		newsCamera.height = 190;
		// newsCamera.x = FlxG.width - 392;
		newsCamera.x = FlxG.width;
		newsCamera.y = FlxG.height - 217;
		newsCamera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(newsCamera, false);

		newsCameraOverlay = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		newsCameraOverlay.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(newsCameraOverlay, false);

		tabSlider = new FlxSprite().loadGraphic(Paths.image('mainmenu/news/newsTabNew'));
		tabSlider.setGraphicSize(0, 190);
		tabSlider.updateHitbox();
		tabSlider.x = newsCamera.x - tabSlider.width;
		tabSlider.y = newsCamera.y;
		add(tabSlider);

		tabSliderArrow = new FlxSprite().loadGraphic(Paths.image('mainmenu/news/newsTabArrow'));
		tabSliderArrow.setGraphicSize(0, 50);
		tabSliderArrow.updateHitbox();
		tabSliderArrow.spriteCenter(tabSlider, Y);
		tabSliderArrow.x = tabSlider.x - 20;
		add(tabSliderArrow);
		arrowScale = tabSliderArrow.scale.y;
		arrowTween1();

		tabPreviewGroup = new FlxTypedSpriteGroup<FlxSprite>();
		tabPreviewGroup.cameras = [newsCamera];
		add(tabPreviewGroup);

		dataRequest = new HTTPRequest<String>();
		dataRequest.method = lime.net.HTTPRequestMethod.GET;
		var future:Future<String> = dataRequest.load('${newsServer}news.json');
		future.onComplete((?dat) ->
		{
			if (newsJson == null)
				newsJson = Json.parse(dat).news;

			tab1Data = newsJson.tab1;
			tab2Data = newsJson.tab2;
			tab3Data = newsJson.tab3;
			loadTab1();
		});
		future.onError((err) ->
		{
			noInternet = true;
			if (newsJson == null)
				newsJson = Json.parse('{
				"news": {
					"tab1": {
						"title": "No Internet",
						"description": "Please connect to the internet to get the latest news.",
						"link": "",
						"buttonText": ""
					},
					"tab2": {
						"title": "No Internet",
						"description": "Please connect to the internet to get the latest news.",
						"link": "",
						"buttonText": ""
					},
					"tab3": {
						"title": "No Internet",
						"description": "Please connect to the internet to get the latest news.",
						"link": "",
						"buttonText": ""
					}
				}
			}
			')
					.news;

			tab1Data = newsJson.tab1;
			tab2Data = newsJson.tab2;
			tab3Data = newsJson.tab3;
			loadTab1();
		});
	}

	function loadTab1()
	{
		if (!noInternet)
		{
			requester = new HTTPRequest<haxe.io.Bytes>();
			requester.method = lime.net.HTTPRequestMethod.GET;
			var future:Future<haxe.io.Bytes> = requester.load('${newsServer}images/tab1/banner.png');
			future.onComplete((?dat) ->
			{
				BitmapData.loadFromBytes(dat).onComplete((dat) ->
				{
					tab1Banner = new FlxSprite().loadGraphic(dat);
					tab1Banner.x = newsCamera.x - 362;
					tab1Banner.y = newsCamera.y;
					tab1Banner.setGraphicSize(362, 190);
					tab1Banner.updateHitbox();
					tabPreviewGroup.add(tab1Banner);
					loadTab2();
				});
			});
			future.onError((err) ->
			{
				noInternet = true;
				tab1Banner = new FlxSprite().loadGraphic(Paths.image('mainmenu/news/noInternetBanner'));
				tab1Banner.x = newsCamera.x - 362;
				tab1Banner.y = newsCamera.y;
				tab1Banner.setGraphicSize(362, 190);
				tab1Banner.updateHitbox();
				tabPreviewGroup.add(tab1Banner);
				loadTab2();
			});
		}
		else
		{
			tab1Banner = new FlxSprite().loadGraphic(Paths.image('mainmenu/news/noInternetBanner'));
			tab1Banner.x = newsCamera.x - 362;
			tab1Banner.y = newsCamera.y;
			tab1Banner.setGraphicSize(362, 190);
			tab1Banner.updateHitbox();
			tabPreviewGroup.add(tab1Banner);
			loadTab2();
		}
	}

	function loadTab2()
	{
		if (!noInternet)
		{
			requester = new HTTPRequest<haxe.io.Bytes>();
			requester.method = lime.net.HTTPRequestMethod.GET;
			var future:Future<haxe.io.Bytes> = requester.load('${newsServer}images/tab2/banner.png');
			future.onComplete((?dat2) ->
			{
				BitmapData.loadFromBytes(dat2).onComplete((dat2) ->
				{
					tab2Banner = new FlxSprite().loadGraphic(dat2);
					tab2Banner.setGraphicSize(362, 190);
					tab2Banner.updateHitbox();
					tab2Banner.x = tab1Banner.x + tab1Banner.width;
					tab2Banner.y = tab1Banner.y;
					tabPreviewGroup.add(tab2Banner);
					loadTab3();
				});
			});
			future.onError((err) ->
			{
				noInternet = true;
				tab2Banner = new FlxSprite().loadGraphic(Paths.image('mainmenu/news/noInternetBanner'));
				tab2Banner.setGraphicSize(362, 190);
				tab2Banner.updateHitbox();
				tab2Banner.x = tab1Banner.x + tab1Banner.width;
				tab2Banner.y = tab1Banner.y;
				tabPreviewGroup.add(tab2Banner);
				loadTab3();
			});
		}
		else
		{
			tab2Banner = new FlxSprite().loadGraphic(Paths.image('mainmenu/news/noInternetBanner'));
			tab2Banner.setGraphicSize(362, 190);
			tab2Banner.updateHitbox();
			tab2Banner.x = tab1Banner.x + tab1Banner.width;
			tab2Banner.y = tab1Banner.y;
			tabPreviewGroup.add(tab2Banner);
			loadTab3();
		}
	}

	function loadTab3()
	{
		if (!noInternet)
		{
			requester = new HTTPRequest<haxe.io.Bytes>();
			requester.method = lime.net.HTTPRequestMethod.GET;
			var future:Future<haxe.io.Bytes> = requester.load('${newsServer}images/tab3/banner.png');
			future.onComplete((?dat3) ->
			{
				BitmapData.loadFromBytes(dat3).onComplete((dat3) ->
				{
					tab3Banner = new FlxSprite().loadGraphic(dat3);

					tab3Banner.setGraphicSize(362, 190);
					tab3Banner.updateHitbox();
					tab3Banner.x = tab2Banner.x + tab2Banner.width;
					tab3Banner.y = tab2Banner.y;
					tabPreviewGroup.add(tab3Banner);
					initUI();
				});
			});
			future.onError((err) ->
			{
				noInternet = true;
				tab3Banner = new FlxSprite().loadGraphic(Paths.image('mainmenu/news/noInternetBanner'));

				tab3Banner.setGraphicSize(362, 190);
				tab3Banner.updateHitbox();
				tab3Banner.x = tab2Banner.x + tab2Banner.width;
				tab3Banner.y = tab2Banner.y;
				tabPreviewGroup.add(tab3Banner);
				initUI();
			});
		}
		else
		{
			tab3Banner = new FlxSprite().loadGraphic(Paths.image('mainmenu/news/noInternetBanner'));

			tab3Banner.setGraphicSize(362, 190);
			tab3Banner.updateHitbox();
			tab3Banner.y = tab2Banner.y;
			tab3Banner.x = tab2Banner.x + tab2Banner.width;
			tabPreviewGroup.add(tab3Banner);
			initUI();
		}
	}

	var tabBorder:FlxSprite;
	var tabTextOverlay:FlxSprite;

	function initUI()
	{
		tabOverlay = new FlxSprite();
		tabOverlay.cameras = [newsCameraOverlay];
		tabOverlay.makeGraphic(362, 59, 0x19000000);
		tabOverlay.x = newsCamera.x;
		tabOverlay.y = (newsCamera.y + newsCamera.height) - (tabOverlay.height);
		add(tabOverlay);

		tabTextOverlay = new FlxSprite();
		tabTextOverlay.cameras = [newsCameraOverlay];
		tabTextOverlay.loadGraphic(Paths.image('mainmenu/news/newsTextShadow'));
		tabTextOverlay.setGraphicSize(362, 190);
		tabTextOverlay.updateHitbox();
		tabTextOverlay.x = newsCamera.x;
		tabTextOverlay.y = newsCamera.y;
		add(tabTextOverlay);

		tabBorder = new FlxSprite();
		tabBorder.cameras = [newsCameraOverlay];
		tabBorder.loadGraphic(Paths.image('mainmenu/news/newsBorder'));
		tabBorder.x = newsCamera.x;
		tabBorder.y = newsCamera.y;
		add(tabBorder);

		tab1Circle = new FlxSprite();
		tab1Circle.cameras = [newsCameraOverlay];
		tab1Circle.loadGraphic(Paths.image('mainmenu/news/circle'));
		tab1Circle.setGraphicSize(10, 10);
		tab1Circle.updateHitbox();
		tab1Circle.setPosition(tabOverlay.x + 146, tabOverlay.y);
		add(tab1Circle);

		tab2Circle = new FlxSprite();
		tab2Circle.cameras = [newsCameraOverlay];
		tab2Circle.loadGraphicFromSprite(tab1Circle);
		tab2Circle.setGraphicSize(10, 10);
		tab2Circle.updateHitbox();
		tab2Circle.setPosition(tab1Circle.x + 30, tab1Circle.y);
		add(tab2Circle);

		tab3Circle = new FlxSprite();
		tab3Circle.cameras = [newsCameraOverlay];
		tab3Circle.loadGraphicFromSprite(tab2Circle);
		tab3Circle.setGraphicSize(10, 10);
		tab3Circle.updateHitbox();
		tab3Circle.setPosition(tab2Circle.x + 30, tab1Circle.y);
		add(tab3Circle);

		uiInitialized = true;
	}

	var arrowTween:FlxTween;

	function arrowTween1(?_:FlxTween)
	{
		if (slideTween != null)
		{
			if (slideTween.finished)
			{
				if (!isNewsTabOut)
				{
					arrowTween = FlxTween.tween(tabSliderArrow, {x: tabSlider.x - 30, "scale.y": arrowScale * 1.00}, 0.3,
						{ease: FlxEase.linear, onComplete: arrowTween2});
				}
			}
		}
		else
		{
			if (!isNewsTabOut)
			{
				arrowTween = FlxTween.tween(tabSliderArrow, {x: tabSlider.x - 30, "scale.y": arrowScale * 1.00}, 0.3,
					{ease: FlxEase.linear, onComplete: arrowTween2});
			}
		}
	}

	function arrowTween2(?_:FlxTween)
	{
		if (slideTween != null)
		{
			if (slideTween.finished)
			{
				arrowTween = FlxTween.tween(tabSliderArrow, {x: tabSlider.x - 40, "scale.y": arrowScale * 0.75}, 0.3,
					{ease: FlxEase.linear, onComplete: arrowTween1});
			}
		}
		else
		{
			arrowTween = FlxTween.tween(tabSliderArrow, {x: tabSlider.x - 40, "scale.y": arrowScale * 0.75}, 0.3,
				{ease: FlxEase.linear, onComplete: arrowTween1});
		}
	}

	public override function update(elapsed:Float):Void
	{
		if (uiInitialized)
		{
			if (currentTab == 1)
			{
				tab1Circle.alpha = 1;
				tab2Circle.alpha = 0.5;
				tab3Circle.alpha = 0.5;
			}
			else if (currentTab == 2)
			{
				tab1Circle.alpha = 0.5;
				tab2Circle.alpha = 1;
				tab3Circle.alpha = 0.5;
			}
			else if (currentTab == 3)
			{
				tab1Circle.alpha = 0.5;
				tab2Circle.alpha = 0.5;
				tab3Circle.alpha = 1;
			}
			if (!FlxG.mouse.overlaps(tabOverlay) && FlxG.mouse.overlaps(tabTextOverlay))
			{
				tabTextOverlay.alpha = 0.5;
			}
			else
			{
				tabTextOverlay.alpha = 0;
			}
			if (FlxG.mouse.overlaps(tab1Circle))
			{
				if (FlxG.mouse.justReleased)
				{
					switchToTab(1);
				}
			}
			else if (FlxG.mouse.overlaps(tab2Circle))
			{
				if (FlxG.mouse.justReleased)
				{
					switchToTab(2);
				}
			}
			else if (FlxG.mouse.overlaps(tab3Circle))
			{
				if (FlxG.mouse.justReleased)
				{
					switchToTab(3);
				}
			}
			tabOverlay.x = newsCamera.x;
			tabOverlay.y = (newsCamera.y + newsCamera.height) - (tabOverlay.height);
			tab1Circle.setPosition(tabOverlay.x + 146, tabOverlay.y + 25);
			tab2Circle.setPosition(tab1Circle.x + 30, tab1Circle.y);
			tab3Circle.setPosition(tab2Circle.x + 30, tab1Circle.y);
			tabTextOverlay.x = newsCamera.x;
			tabTextOverlay.y = newsCamera.y;
			tabBorder.x = newsCamera.x;
			tabBorder.y = newsCamera.y;
			if (slideTween != null)
			{
				if (!slideTween.finished)
				{
					tabSliderArrow.x = tabSlider.x - 30;
				}
			}
		}
		if (FlxG.mouse.overlaps(tabSlider))
		{
			if (!isNewsTabOut)
			{
				slideIn();
			}
		}
		if (isNewsTabOut)
		{
			if (tabBorder != null)
			{
				if (!FlxG.mouse.overlaps(tabBorder))
				{
					if (!FlxG.mouse.overlaps(tabSlider))
					{
						slideOut();
					}
				}
			}
		}
		tabSlider.x = newsCamera.x - tabSlider.width;

		super.update(elapsed);
	}

	public override function destroy()
	{
		if (arrowTween != null)
		{
			arrowTween.cancel();
		}
		super.destroy();
	}
}
