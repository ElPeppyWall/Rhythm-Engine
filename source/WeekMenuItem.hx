package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class WeekMenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var weekNum:Int;
	public var weekColor:Int;
	public var flashingInt:Int = 0;

	public function new(x:Float, y:Float, _weekNum:Int = 0)
	{
		super(x, y);
		weekNum = _weekNum;
		weekColor = WeekData.weeksColors[weekNum];
		week = new FlxSprite().loadGraphic(Paths.image('storymenu/week' + weekNum));
		week.antialiasing = getPref('antialiasing');
		add(week);
	}

	private var isFlashing:Bool = false;

	inline public function startFlashing():Void
	{
		isFlashing = true;
		new FlxTimer().start(0.075, function(tmr:FlxTimer)
		{
			if (flashWasWhite)
				week.color = weekColor;
			else
				week.color = -1;

			flashWasWhite = !flashWasWhite;
			tmr.reset();
		});
	}

	private var flashWasWhite = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = CoolUtil.coolLerp(y, (targetY * 120) + 480, 0.17);
	}
}
