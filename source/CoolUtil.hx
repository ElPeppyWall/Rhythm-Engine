package;

import flixel.FlxG;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	static var difficultyArray:Array<String> = ['EASY', 'NORMAL', 'HARD'];
	public static var difficultyColorArray:Array<Int> = [FlxColor.LIME, FlxColor.YELLOW, FlxColor.RED];

	public static function _trace():Void
	{
		trace('a');
	}

	public static function getVarType(f:Dynamic):Dynamic
	{
		return switch (Reflect.getType(f))
		{
			default:
				Dynamic;
			case 0xff:
				Int;
			case null:
				null;
			case 1:
				Float;
			case 2:
				Bool;
			case 3:
				String;
			case 5:
				Array;
			case 6:
				'Function';
			case 7:
				Enum;
			case 8:
				Class;
		};
	}

	public static inline function getDiffByIndex(index:Int, isPath:Bool):String
		return isPath ? 'JSON File' : difficultyArray[index];

	public static inline function diffForJSON(index:Int):String
		return '-${getDiffByIndex(index, false).toLowerCase()}';

	public static inline function formatSong(song:String, diff:Int):String
		return '${song.toLowerCase()}${CoolUtil.diffForJSON(diff)}';

	public static function switchState(state:Class<flixel.FlxState>, ?args:Array<Dynamic>)
	{
		if (args == null)
			args = [];
		trace('switchState -> $state');
		curState = Type.createInstance(state, args);
		FlxG.switchState(curState);
	}

	public static var curState:flixel.FlxState;

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

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

	// !capitalize shit
	public static var splited:Array<String> = [];

	public static var shitOutput:Array<String> = [];
	public static var tempI:String;
	public static final capitalizeBlackList:Array<String> = ['M.I.L.F']; // these words must be upper case

	public static function capitalize(input:String, spliter:String = ' '):String
	{
		if (!capitalizeBlackList.contains(input.toUpperCase()))
		{ // !RESET SHIT
			splited = [];
			shitOutput = [];
			tempI = '';
			CoolUtil.splited = input.split(spliter);
			for (i in splited)
			{
				// convert each letter into lower case
				CoolUtil.tempI = i.toLowerCase();
				// Convert the first char upper case and join with the rest letters of word.
				CoolUtil.tempI = CoolUtil.tempI.charAt(0).toUpperCase() + CoolUtil.tempI.substring(1);
				// store the word in the array
				CoolUtil.shitOutput.push(CoolUtil.tempI);
			}
			// join the words
			return CoolUtil.shitOutput.join(spliter);
		}
		else
			return input.toUpperCase();
	}

	// private static function getTraceColor(type:TraceType):String
	// {
	// 	return switch (type)
	// 	{
	// 		case ITALIC:
	// 			'3';
	// 		case UNDERLINE:
	// 			'4';
	// 		case BLINK:
	// 			'6';
	// 		case BLACK:
	// 			'8';
	// 		case DOUBLELINE:
	// 			'21';
	// 		case RED:
	// 			'91';
	// 	}
	// }
}

enum TraceType
{
	// ? TEXT TYPE
	ITALIC;
	UNDERLINE;
	BLINK;
	BLACK;
	DOUBLELINE;

	// - TEXT COLOR
	RED;
	DARK_RED;
	GREEN;
	DARK_GREEN;
	GOLD;
	LIGHT_GOLD;
	BLUE;
	DARK_BLUE;
	LIGHT_BLUE;
	CYAN;
	PURPLE;
	PINK;
	WHITE;
	// ! TEXT BACKGROUND
	DARK_RED_BG;
	RED_BG;
	GREEN_BG;
	DARK_GREEN_BG;
	GOLD_BG;
	LIGHT_GOLD_BG;
	BLUE_BG;
	DARK_BLUE_BG;
	CYAN_BG;
	PURPLE_BG;
	PINK_BG;
	WHITE_BG;
}
