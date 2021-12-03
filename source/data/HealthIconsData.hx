package;

import flixel.util.FlxColor;

class HealthIconsData
{
	public static final healthIconsForCharacter:Map<String, String> = [
		// - WEEK 4
		'bf-car' => 'bf',
		'gf-car' => 'gf',
		'mom-car' => 'mom',
		// - WEEK 5
		'bf-christmas' => 'bf',
		'gf-christmas' => 'gf',
		'parents-christmas' => 'parents',
		'monster-christmas' => 'monster',
		// - WEEK 6
		'gf-pixel' => 'gf',
		'senpai-angry' => 'senpai',
		// - ETC
		'bf-hey' => 'bf', // + STORY MODE BF HEY COLOR
		'bf-car-hey' => 'bf', // + STORY MODE BF CAR HEY COLOR
		'bf-christmas-hey' => 'bf', // + STORY MODE BF CHRISTMAS HEY COLOR
	];
	public static final healthIconsBarColors:Map<String, Int> = [
		// - DEFAULT GAME
		'bf' => 0xFF31b0d1,
		'bf-old' => 0xFFe9ff48,
		'gf' => 0xFFa5004d,
		// - WEEK 1
		'dad' => 0xFFaf66ce,
		// - WEEK 2
		'spooky' => 0xFFb4b4b4,
		'monster' => 0xFFf3ff6e,
		// - WEEK 3
		'pico' => 0xFFb7d855,
		// - WEEK 4
		'mom' => 0xFFd8558e,
		// - WEEK 5
		'parents' => 0xFFaf66ce,
		// - WEEK 6
		'bf-pixel' => 0xFF7bd6f6,
		'senpai' => 0xFFffaa6f,
		'spirit' => 0xFFff3c6e,
		// - ETC
		'face' => 0xFFa1a1a1,
		'none' => FlxColor.GRAY,
	];
	public static final charsWithWinningIcons = [
		// example: ['agoti']
	];

	public static function getCharIcon(char:String):String
	{
		if (healthIconsForCharacter.exists(char))
			return healthIconsForCharacter[char];
		else
			return char;
	}

	public static function getIconColor(char:String):Int
	{
		if (healthIconsBarColors.exists(char))
			return healthIconsBarColors[char];
		else
		{
			trace('$char DOESN\'T HAVE A ICON COLOR!!!');
			return 0xffffff;
		}
	}
}
