package;

import flixel.FlxG;

class GameLoop
{
	public function new()
		trace('Init Game Loop');

	public function update():Void
	{
		if (FlxG.keys != null)
			if (FlxG.keys.justPressed.F11)
				FlxG.fullscreen = !FlxG.fullscreen;
	}
}
