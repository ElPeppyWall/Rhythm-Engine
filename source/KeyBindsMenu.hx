import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class KeyBindsMenu extends MusicBeatSubstate
{
	var isPause:Bool;

	public function new(_isPause:Bool)
	{
		isPause = _isPause;
		super();

		if (isPause)
		{
			var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = .6;
			bg.scrollFactor.set();
			add(bg);
		}
	}
}
