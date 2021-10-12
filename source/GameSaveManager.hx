class GameSaveManager
{
	public static var gameSave:GameSave;

	public static function initGameSave():Void
	{
		if (gameSave == null)
		{
			// gameSave = {};
		}
	}
}

typedef GameSave =
{
	var offset:Int;
	var downscroll:Bool;
	var midscroll:Bool;
	var noteSplash:Bool;
	var naughtyness:Bool;
	var flashingLights:Bool;
	var cam:Bool;
}
