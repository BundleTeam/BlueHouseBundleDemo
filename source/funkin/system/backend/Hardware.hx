package funkin.system.backend;

import openfl.system.System;
import openfl.display3D.Context3D;
import flixel.math.FlxMath;
import haxe.Json;
import lime.graphics.opengl.GL;
import haxe.io.Bytes;
import flixel.FlxG;
import openfl.Lib;
import Xml;

using StringTools;

typedef GPUData =
{
	name:String,
	vendor:String,
	renderer:String,
	memoryMB:Int,
}

typedef CPUData =
{
	name:String,
	cores:Int,
	logicalCores:Int,
	speedGHZ:Float
}

typedef RAMData =
{
	memoryMB:Float,
	speedMHZ:Float,
}

enum OS
{
	Windows;
	MacOS;
	Linux;
	Android;
	iOS;
	Web;
	RaspberryPI;
	Unknown;
}

enum MemType
{
	RAM;
	VRAM;
}

class Hardware
{
	public static var GPU:GPUData = {
		name: 'Unknown',
		vendor: 'Unknown',
		renderer: 'Unknown',
		memoryMB: 0
	}
	public static var CPU:CPUData = {
		name: 'Unknown',
		cores: -1,
		logicalCores: 1,
		speedGHZ: 0.0,
	}
	public static var RAM:RAMData = {
		memoryMB: 0,
		speedMHZ: 0.0,
	}
	public static var graphicsapi:String = "";
	public static var os:OS = Unknown;
	public static var isMobile:Bool = false;

	public static function gatherSpecs()
	{
		#if html5
		___getJSSpecs();
		#elseif (windows && !hl)
		___getWindowsSpecs(); // may not do this on release due to
		// how the function works and because its not open source people may call
		// it a virus
		#elseif sys
		___getSYSSpecs();
		#end
		___getIsMobile();

		graphicsapi = Lib.application.window.context.type;
	}

	public static function ___getIsMobile()
	{
		#if html5
		isMobile = FlxG.html5.onMobile;
		#elseif android
		isMobile = true;
		#elseif ios
		isMobile = true;
		#else
		isMobile = false;
		#end
	}

	public static function ___getOS()
	{
		#if windows
		os = Windows;
		#elseif mac
		os = MacOS;
		#elseif linux
		os = Linux;
		#elseif (html5 || js)
		os = Web;
		#else
		os = Unknown;
		#end
	}

	#if sys
	private static function ___getSYSSpecs()
	{
		GPU.name = GL.getString(GL.RENDERER);
		GPU.vendor = GL.getString(GL.VENDOR);
	}
	#end

	#if windows
	// private static function ____getDataBetweenTags(tagName:String, tagData:String):String
	// {
	//	return tagData.replace('<${tagName}>', "").replace('</${tagName}>', '');
	// }

	private static function ___getWindowsSpecs()
	{
		___getSYSSpecs();
		GPU.renderer = FlxG.stage.context3D.driverInfo;
		Funkin.log(GL.getExtension("NVX_gpu_memory_info"));
		Hardware.CPU.name = new sys.io.Process('wmic cpu get name').stdout.readAll().toString().split('\n')[1].trim();
		Hardware.CPU.speedGHZ = Std.parseInt(new sys.io.Process('wmic cpu get maxclockspeed').stdout.readAll().toString().split('\n')[1].trim()) / 1000;
		Hardware.CPU.cores = Std.parseInt(new sys.io.Process('wmic cpu get numberofcores').stdout.readAll().toString().split('\n')[1].trim());
		Hardware.CPU.logicalCores = Std.parseInt(new sys.io.Process('wmic cpu get ThreadCount').stdout.readAll().toString().split('\n')[1].trim());
		Hardware.RAM.speedMHZ = Std.parseInt(new sys.io.Process('wmic memorychip get speed').stdout.readAll().toString().split('\n')[1].trim());

		var capacitys:Array<String> = new sys.io.Process('wmic memorychip get Capacity').stdout.readAll().toString().trim().split('\n');
		capacitys = capacitys.splice(1, capacitys.length - 1);
		Funkin.log(capacitys);

		var memoryArr:Array<Float> = [];
		for (str in capacitys)
		{
			memoryArr.push(Std.parseFloat(str) / 1049000); // using int can exceed the 32 bit int limit
		}
		Funkin.log(memoryArr);
		Hardware.RAM.memoryMB = 0;
		for (memorymb in memoryArr)
		{
			Hardware.RAM.memoryMB += memorymb;
		}
		Hardware.RAM.memoryMB = FlxMath.roundDecimal(Hardware.RAM.memoryMB, 2);
		@:privateAccess
		Hardware.GPU.memoryMB = Context3D.__glMemoryTotalAvailable;
	}
	#end

	#if html5
	private static function ___getJSSpecs()
	{
		// GPU //
		var gl:lime.graphics.WebGLRenderContext = Lib.application.window.context;
		var extension:js.html.webgl.extension.WEBGLDebugRendererInfo = gl.getExtension(js.html.webgl.Extension.WEBGL_debug_renderer_info);
		var rendererString:String = gl.getParameter(js.html.webgl.extension.WEBGLDebugRendererInfo.UNMASKED_RENDERER_WEBGL);
		if (rendererString.startsWith('ANGLE ('))
		{
			rendererString = rendererString.split('ANGLE (')[1];
			var gpuInfo:Array<String> = rendererString.substr(0, rendererString.length - 1).split(", ");
			GPU.vendor = gpuInfo[0];
			GPU.name = gpuInfo[1];
			GPU.renderer = gpuInfo[2] + " | angle";
		}
		else
		{
			GPU.name = rendererString;
			GPU.vendor = gl.getParameter(js.html.webgl.extension.WEBGLDebugRendererInfo.UNMASKED_VENDOR_WEBGL);
			GPU.renderer = FlxG.stage.window.context.type;
		}
		// MEM //
		var mem:Float = js.Syntax.code("(()=>{if (!!navigator.deviceMemory){return navigator.deviceMemory;}else{return 0.2;}})()");

		RAM.memoryMB = Std.int(mem * 1000);
		// CPU //
		CPU.logicalCores = js.Browser.navigator.hardwareConcurrency;
		CPU.cores = Std.int(CPU.logicalCores / 2); // estimated cores amount
		CPU.speedGHZ = 1.0; // we cant get cpu ghz in javascript
	}
	#end

	/*
		*
		returns megabytes of n as a float
		*
	 */
	private static function bytesToMB(n:Int):Float
	{
		return Math.abs(FlxMath.roundDecimal(n / 1000000, 1));
	}

	public static function getMemory(memType:MemType):Float
	{
		switch (memType : MemType)
		{
			case MemType.RAM:
				#if cpp
				return bytesToMB(cpp.vm.Gc.memUsage());
				#else
				return bytesToMB(System.totalMemory);
				#end
			case MemType.VRAM:
				if (FlxG.stage != null && Lib.current.stage.context3D != null)
					return bytesToMB(Lib.current.stage.context3D.totalGPUMemory);
				else
					return 0.00;
		}
		return 0.00;
	}
}
