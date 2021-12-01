package;

class CharactersData
{
	public static final characterNames:Map<String, String> = [
		// - DEFAULT GAME
		'bf' => 'Boyfriend',
		'gf' => 'Girlfriend',
		// - WEEK 1
		'dad' => 'Daddy Dearest',
		// - WEEK 2
		'spooky' => 'Skid & Pump',
		'monster' => 'Monster',
		// - WEEK 3
		'pico' => 'Pico',
		// - WEEK 4
		'bf-car' => 'Boyfriend',
		'gf-car' => 'Girlfriend',
		'mom-car' => 'Mommy Murderer',
		'mom' => 'Mommy Murderer',
		// - WEEK 5
		'bf-christmas' => 'Boyfriend',
		'gf-christmas' => 'Girlfriend',
		'parents-christmas' => 'Daddy & Mommy',
		'monster-christmas' => 'Monster',
		// - WEEK 6
		'bf-pixel' => 'Boyfriend',
		'gf-pixel' => 'Girlfriend',
		'senpai' => 'Senpai',
		'senpai-angry' => 'Senpai',
		'spirit' => '???Senpai???',
		// - ETC
		'none' => 'No one',
	];
	public static final characterWithoutAntialiasing = [
		// - WEEK 6
		'bf-pixel',
		'gf-pixel',
		'senpai',
		'senpai-angry',
		'spirit',
	];
	public static final characterDead:Map<String, String> = [
		// - WEEK 4
		'bf-car' => 'bf',
		// - WEEK 5
		'bf-christmas' => 'bf',
	];

	public static function getCharDead(char:String):String
	{
		if (characterDead.exists(char))
			return characterDead[char];
		else
			return char;
	}
}
