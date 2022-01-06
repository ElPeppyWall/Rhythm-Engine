package;

import openfl.Lib;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPSCounter extends TextField
{
	public var currentFPS(default, null):Int;

	private var times:Array<Float>;
	private var memPeak:Float = 0;

	public function new(_x:Float = 10, _y:Float = 10)
	{
		super();

		x = _x;
		y = _y;

		selectable = false;
		defaultTextFormat = new TextFormat("VCR OSD Mono", 16, GameInfo.engineColor);
		text = "FPS: ";
		width += 200;

		times = [];
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}

	// Event Handlers
	private function onEnterFrame(_)
	{
		var now = haxe.Timer.stamp();
		times.push(now);

		while (times[0] < now - 1)
			times.shift();

		currentFPS = times.length;
		var mem:Float = Math.round(openfl.system.System.totalMemory / 1024 / 1024 * 100) / 100;

		if (mem > memPeak)
			memPeak = mem;

		text = 'FPS: $currentFPS\nMEM: $mem mb\n${GameInfo.engineWatermark}';
	}
}
