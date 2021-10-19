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

	public static function initBinds():Void
	{
		if (FlxG.save.data.noteBinds == null)
			FlxG.save.data.noteBinds = ['A', 'S', 'W', 'D'];
		if (FlxG.save.data.uiBinds == null)
			FlxG.save.data.uiBinds = ['A', 'S', 'W', 'D'];

		FlxG.save.flush();
	}

	public static function checkKey(key:String, ?inputType:flixel.input.FlxInput.FlxInputState = JUST_PRESSED):Bool
		return FlxG.keys.checkStatus(FlxKey.fromString(key.toUpperCase()), inputType);
}
