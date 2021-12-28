package;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class KeyBinds
{
	public static function setBind(dir:Int, key:String, isUI:Bool):Void
	{
		trace('binds lol >>aasda>');
		if (isUI)
			FlxG.save.data.uiBinds[dir] = key;
		else
			FlxG.save.data.noteBinds[dir] = key;
		FlxG.save.flush();
		PlayerSettings.player1.controls.refreshBinds();
	}

	static var defaultKeys = [FlxKey.A, FlxKey.S, FlxKey.W, FlxKey.D];

	public static function initBinds(firstTime:Bool = false):Void
	{
		if (FlxG.save.data.noteBinds == null)
			FlxG.save.data.noteBinds = defaultKeys;
		if (FlxG.save.data.uiBinds == null)
			FlxG.save.data.uiBinds = defaultKeys;

		for (i in 0...4)
		{
			if (FlxG.save.data.noteBinds[i] == null)
				FlxG.save.data.noteBinds[i] = defaultKeys[i];

			if (FlxG.save.data.uiBinds[i] == null)
				FlxG.save.data.uiBinds[i] = defaultKeys[i];
		}

		FlxG.save.flush();
		if (!firstTime)
			PlayerSettings.player1.controls.setKeyboardScheme();

		trace('noteBinds: ${FlxG.save.data.noteBinds}');
		trace('uiBinds: ${FlxG.save.data.uiBinds}');
	}
}
