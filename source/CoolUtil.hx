package;

import flixel.FlxG;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	static var difficultyArray:Array<Array<String>> = [['EASY', '-easy'], ['NORMAL', '-normal'], ['HARD', '-hard']];
	public static var difficultyColorArray:Array<Int> = [FlxColor.LIME, FlxColor.YELLOW, FlxColor.RED];

	public static inline function getDiffByIndex(index:Int, isAloneFunkin:Bool):String
		return isAloneFunkin ? 'JSON File' : difficultyArray[index][0];

	public static inline function getDiffName(index:Int, isAloneFunkin:Bool):String
		return isAloneFunkin ? langString('jsonFile') : langString('diffies')[index];

	public static function getDiffPause(index:Int):String
		return langString('pauseDiffies')[index];

	public static inline function getDiffForJSON(index:Int):String
		return difficultyArray[index][1];

	public static inline function formatSong(song:String, diff:Int):String
		return '${song.toLowerCase()}${CoolUtil.getDiffForJSON(diff)}';

	public static function switchState(state:Class<flixel.FlxState>, ?args:Array<Dynamic>)
	{
		if (args == null)
			args = [];
		trace('switchState -> $state');
		FlxG.switchState(Type.createInstance(state, args));
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static inline function camLerpShit(ratio:Dynamic):Dynamic
		return (FlxG.elapsed / 0.016666666666666666) * ratio;

	public static inline function coolLerp(a:Dynamic, b:Dynamic, ratio:Dynamic):Dynamic
		return a + CoolUtil.camLerpShit(ratio) * (b - a);
}
