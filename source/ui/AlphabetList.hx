package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class AlphabetList extends FlxSpriteGroup
{
	var selectedIndex:Int;
	var textList(default, set):Array<String> = [];
	var iconArray:Array<HealthIcon> = [];
	var iconList:Array<String> = [];

	function set_textList(value:Array<String>):Array<String>
	{
		return textList = value;
		restartList();
	}

	public function new(_textList:Array<String>, _iconList:Array<String>)
	{
		super();
		if (_iconList == null)
			_iconList = [];
		iconList = _iconList;
		_textList = textList;
	}

	public function restartList():Void
	{
		forEach(function(spr:FlxSprite) remove(spr));

		for (i in 0...textList.length)
		{
			var text = new Alphabet(0, (70 * i) + 30, textList[i], true, false);
			text.targetY = i;
			add(text);

			var icon = new HealthIcon(iconList[i]);
			icon.sprTracker = text;
			iconArray.push(icon);
			if (iconList[i] != null)
				add(icon);
		}
	}
}
