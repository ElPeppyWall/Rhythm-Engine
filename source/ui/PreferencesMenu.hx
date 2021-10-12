package;

import Alphabet.AlphaCharacter.alphabet;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class PreferencesMenu
{
	public static var preferences:Map<String, Dynamic> = [];

	var checkboxes:Array<FlxSprite>;

	public static function getPref(preference:String):Dynamic
		return preferences[preference];

	public static function setPref(preference:String, value:Dynamic, ?isPrefCheck:Bool = false):Void
	{
		if (!isPrefCheck)
			switch (value.toLowerCase())
			{
				case 'false':
					value = null;
					value = false;
				case 'true':
					value = null;
					value = true;

				default:
					var boolArray:Array<Bool> = [];
					var a:String = value;
					for (i in 0...a.length)
						boolArray.push(alphabet.contains(a.charAt(i)));

					trace(boolArray);
					if (!boolArray.contains(true))
					{
						var tempValue:String = value;
						value = null;
						if (!a.contains(','))
							value = Std.parseInt(tempValue);
						else
						{
							var elpepe = tempValue.split(',').join('.');
							value = Std.parseFloat(elpepe);
						}
					}
			}
		trace('\u001b[96m' + 'setPref (${preference}) to: ${value} (${CoolUtil.getVarType(value)})\u001b[0m');
		preferences[preference] = value;
		FlxG.save.data.prefs = preferences;
		FlxG.save.flush();
		checkPrefValue(preference);
	}

	public static function resetPrefs():Void
	{
		FlxG.save.data.prefs = null;
		FlxG.save.flush();
		initPrefs();
	}

	public static function preferenceCheck(preference:String, defValue:Dynamic):Void
	{
		if (preferences[preference] == null)
			setPref(preference, defValue, true);
		else
			checkPrefValue(preference);
	}

	public static function initPrefs():Void
	{
		if (FlxG.save.data.prefs == null)
			FlxG.save.data.prefs = new Map<String, Dynamic>();
		preferences = FlxG.save.data.prefs;

		{
			// gameplay
			preferenceCheck("downscroll", false);
			preferenceCheck("midscroll", false);
			preferenceCheck("ghostTapping", true);
			preferenceCheck("fpsCap", Main.getHZ());
			preferenceCheck("ultra-optimize", false);
			// apparence
			preferenceCheck("note-splashes", true);
			preferenceCheck("background-opacity", 0.0);
			// etc
			preferenceCheck("flashing-menu", true);
			preferenceCheck("censor-naughty", true);
			preferenceCheck("antialiasing", true);
			preferenceCheck("camera-zoom", true);
			preferenceCheck("fps-counter", true);
			preferenceCheck("auto-pause", false);
		}
	}

	public static function checkPrefValue(preference:String):Void
	{
		switch (preference)
		{
			case 'fps-counter':
				if (!getPref('fps-counter'))
					openfl.Lib.current.stage.removeChild(Main.fpsCounter);
				else
					openfl.Lib.current.stage.addChild(Main.fpsCounter);
			case 'fpsCap':
				(cast(openfl.Lib.current.getChildAt(0), Main)).setFPSCap(getPref('fpsCap'));
			case 'auto-pause':
				FlxG.autoPause = getPref("auto-pause");
		}
	}
}
