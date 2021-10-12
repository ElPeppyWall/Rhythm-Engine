package;

class MenuBG extends flixel.FlxSprite
{
	public function new(type:MenuBGType = NORMAL, x = 0.0, y = 0.0)
	{
		super(x, y, Paths.image('menu' + switch (type)
		{
			case NORMAL:
				'BG';
			case BLUE:
				'BGBlue';
			case MAGENTA:
				'BGMagenta';
			case DESAT:
				'Desat';
		}));

		scrollFactor.set();
		updateHitbox();
		screenCenter();
		antialiasing = getPref('antialiasing');
	}

	public function setNewSize(size:Float = 0)
	{
		setGraphicSize(Std.int(size));
		updateHitbox();
	}
}

private enum MenuBGType
{
	NORMAL;
	BLUE;
	MAGENTA;
	DESAT;
}
