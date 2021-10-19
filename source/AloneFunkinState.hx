package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class AloneFunkinState extends MusicBeatState
{
	override function create()
	{
		add(new MenuBG(DESAT_BORDER));

		var fullScreen = FlxG.fullscreen;
		FlxG.fullscreen = false;
		var textUI = new FlxText(4, FlxG.width - 125,
			'Drag and drop the chart of you want to play. The folder where the chart is located has to be like this:', 20);
		textUI.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textUI.autoSize = true;
		textUI.scrollFactor.set();
		textUI.borderSize = 1.25;
		textUI.screenCenter();
		add(textUI);

		var screenshot = new FlxSprite(textUI.x, textUI.y + 250, Paths.image('chartExample'));
		add(screenshot);

		lime.app.Application.current.window.onDropFile.add(function(path:String)
		{
			if (path.endsWith('.json'))
			{
				PlayState.loadSong(path, 0, false, false, true);
				FlxG.fullscreen = fullScreen;
				lime.app.Application.current.window.onDropFile.removeAll();
			}
		});

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
			switchState(FreeplayState);
		super.update(elapsed);
	}
}
