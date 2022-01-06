package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class WeekMenuCharacter extends FlxSprite
{
	public var character:String;

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		this.character = character;

		var texArray:Array<String> = [];

		for (char in ['bf', 'bf-hey', 'gf'])
			texArray.push('storyCharacters/$char');
		for (char in ['bf-car', 'bf-car-hey', 'gf-car'])
			texArray.push('storyCharacters/$char');
		for (char in ['bf-christmas', 'bf-christmas-hey', 'gf-christmas'])
			texArray.push('storyCharacters/$char');

		for (char in WeekData.weeksCharacters)
			texArray.push('storyCharacters/$char');

		frames = Character.joinFrames(texArray, 'preload');

		for (char in ['bf', 'bf-hey', 'gf'])
			animation.addByPrefix(char, '${char}0', 24, true);
		for (char in ['bf-car', 'bf-car-hey', 'gf-car'])
			animation.addByPrefix(char, '${char}0', 24, true);
		for (char in ['bf-christmas', 'bf-christmas-hey', 'gf-christmas'])
			animation.addByPrefix(char, '${char}0', 24, true);

		for (char in WeekData.weeksCharacters)
			animation.addByPrefix(char, '${char}0', 24, true, char == 'pico');

		animation.play(character);
		antialiasing = getPref('antialiasing');
		updateHitbox();
	}

	public inline function changeCharacter(char:String):Void
	{
		if (curCharacter != char)
		{
			animation.play(char);
			FlxTween.color(this, CoolUtil.camLerpShit(.25), this.color, 0xFFF9CF51);
			// HealthIconsData.getIconColor(HealthIconsData.getCharIcon(this.curCharacter))
		}
	}

	public var curCharacter(get, never):String;

	private inline function get_curCharacter():String
		return animation.curAnim.name;
}
