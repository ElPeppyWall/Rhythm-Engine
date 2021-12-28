#if ALLOW_ALONE_FUNKIN
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class AloneFunkinState extends MusicBeatState
{
	override function create()
	{
		add(new MenuBG(DESAT_BORDER));

		final fullScreen = FlxG.fullscreen;
		FlxG.fullscreen = false;
		var textUI = new FlxText(125, 153, 'Drag and drop the chart of you want to play. The folder where the chart is located has to be like this:', 20);
		textUI.fieldWidth = 700;
		textUI.setFormat(Paths.font("vcr.ttf"), 52, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textUI.scrollFactor.set();
		textUI.borderSize = 1.25;
		add(textUI);

		var screenshot = new FlxSprite(textUI.x, textUI.y + 250, Paths.image('chartExample'));
		screenshot.setGraphicSize(Std.int(screenshot.width * 1.6));
		screenshot.updateHitbox();
		add(screenshot);

		var mapp:Map<String, String> = getPref('alone-funkin-recent-list');
		var listt:Array<String> = [''];
		for (song => paths in mapp)
			listt.push(song);
		var recentListDrop = new FlxUIDropDownMenu(100, 300, FlxUIDropDownMenu.makeStrIdLabelArray(listt, false), function(value:String)
		{
			onDropFile(mapp.get(value), fullScreen, false);
		});
		recentListDrop.selectedLabel = '';
		for (button in recentListDrop.list)
		{
			button.setLabelFormat("VCR OSD Mono", 18, FlxColor.WHITE, "center", OUTLINE, FlxColor.BLACK);
		}
		add(recentListDrop);

		var recentListClear = new FlxUIButton(200, 400, 'CLEAR RECENT LIST', function()
		{
			setPref('alone-funkin-recent-list', new Map<String, String>());
		});
		recentListClear.resize(200, 50);
		recentListClear.setLabelFormat("VCR OSD Mono", 18, FlxColor.WHITE, "center", OUTLINE, FlxColor.BLACK);
		recentListClear.label.borderSize = 1.25;
		recentListClear.label.offset.y += 10;
		add(recentListClear);

		lime.app.Application.current.window.onDropFile.add(function(path:String)
		{
			onDropFile(path, fullScreen, true);
		});

		super.create();
	}

	function onDropFile(path:String, fullScreen:Bool, dragged:Bool)
	{
		if (path.endsWith('.json'))
		{
			PlayState.loadSong(path, 0, flixel.util.FlxColor.WHITE, false, false, true);
			if (dragged)
			{
				var pathMap:Map<String, String> = getPref('alone-funkin-recent-list');
				var daArray = path.split('\\');
				var daArray2 = daArray[daArray.length - 1].split('.');
				daArray2.remove(daArray2[daArray2.length - 1]);
				pathMap[daArray2.join('')] = path;
				setPref('alone-funkin-recent-list', pathMap);
			}
			FlxG.fullscreen = fullScreen;
			lime.app.Application.current.window.onDropFile.removeAll();
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.fullscreen)
			FlxG.fullscreen = false;
		if (controls.BACK)
			switchState(FreeplayState);
		super.update(elapsed);
	}
}
#end
