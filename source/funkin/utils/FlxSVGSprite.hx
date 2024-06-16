package funkin.utils;

import funkin.fx.Filters;
import openfl.display.BitmapData;
import openfl.Lib;
import openfl.display.Sprite;
import flixel.FlxG;
import openfl.display.Graphics;
import format.svg.SVGData;
import format.SVG;
import flixel.FlxSprite;

class FlxSVGSprite extends FlxSprite
{
	private var svg:SVG;
	private var sprite:Sprite = new Sprite();
	private var svgBuffer:BitmapData = new BitmapData(0, 0);

	public function new(X:Float, Y:Float)
	{
		super(X, Y);
	}

	public function loadSVGGraphic(svgFileText:String)
	{
		svg = new SVG(svgFileText);

		this.width = svg.data.width * (FlxG.stage.window.width / 1280);
		this.height = svg.data.height * (FlxG.stage.window.width / 720);
		svgBuffer = new BitmapData(Std.int(this.width), Std.int(this.height), true, 0x00FFFFFF);
		svg.render(sprite.graphics, 0, 0, Std.int(this.width), Std.int(this.height));
		svgBuffer.drawWithQuality(sprite, null, null, null, null, ClientPrefs.globalAntialiasing, Filters.stageQualityPref());
		this.pixels = svgBuffer;
		this.setGraphicSize(Std.int(svg.data.width), Std.int(svg.data.height));
	}
}
