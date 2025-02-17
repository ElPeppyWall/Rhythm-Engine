package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 270; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	static var fpsCounter:FPSCounter;

	var gameLoop:GameLoop;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
		Lib.current.addChild(new Main());

	public function setFPSCap(cap:Int)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function new()
	{
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		gameLoop = new GameLoop();
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));
		fpsCounter = new FPSCounter(10, 3);
		addChild(fpsCounter);
	}

	@:noCompletion private override function __update(transformOnly:Bool, updateChildren:Bool):Void
	{
		gameLoop.update();
		super.__update(transformOnly, updateChildren);
	}

	public static inline function fpsCounterVisible(visible:Bool):Void
		fpsCounter.visible = visible;

	public function getFPS():Float
		return fpsCounter.currentFPS;
}
