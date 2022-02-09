#if ALLOW_ALONE_FUNKIN
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;

using StringTools;

class AloneFunkinState extends MusicBeatState
{
	override function create()
	{
		add(new MenuBG(DESAT_BORDER));

		final fullScreen = FlxG.fullscreen;
		FlxG.fullscreen = false;
		var textUI = new FlxText(125, 130,
			'Drag and drop the chart of you want to play.\nThe folder where the chart is located has to be like this:' /*' or just browse to find it:'*/, 20);
		textUI.fieldWidth = 700;
		textUI.setFormat(Paths.font("vcr.ttf"), 52, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textUI.scrollFactor.set();
		textUI.borderSize = 1.25;
		add(textUI);

		var screenshot = new FlxSprite(textUI.x, textUI.y + 250, Paths.image('chartExample'));
		screenshot.setGraphicSize(Std.int(screenshot.width * 1.6));
		screenshot.updateHitbox();
		add(screenshot);

		/*var browseButton = new FlxUIButton(600, 400, 'BROWSE', function()
			{
				var _file = new FileReference();
				_file.browse([new FileFilter('Chart File (*.json)', '*.json')]);
				_file.addEventListener(Event.SELECT, function(_)
				{
					trace(_);
					_file.load();
					trace(_file);
				});
			});
			browseButton.resize(200, 50);
			browseButton.setLabelFormat("VCR OSD Mono", 18, FlxColor.WHITE, "center", OUTLINE, FlxColor.BLACK);
			browseButton.label.borderSize = 1.25;
			browseButton.label.offset.y += 10;
			add(browseButton); */

		var recentListTxt = new FlxText(1000, 500, 0, 'RECENT LIST');
		recentListTxt.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		recentListTxt.borderSize = 1.25;
		add(recentListTxt);
		var recentListCategoryLine = new FlxSprite(recentListTxt.x, recentListTxt.y + 40).makeGraphic(recentListTxt.width.int(), 4);
		add(recentListCategoryLine);
		var mapp:Map<String, String> = getPref('alone-funkin-recent-list');
		var listt:Array<String> = [''];
		for (song => paths in mapp)
			listt.push(song);
		var recentListDrop = new FlxUIDropDownMenu(recentListCategoryLine.x, recentListCategoryLine.y + 30,
			FlxUIDropDownMenu.makeStrIdLabelArray(listt, false), function(value:String)
		{
			onDropFile(mapp.get(value), fullScreen, false);
		});
		recentListDrop.selectedLabel = '';
		for (button in recentListDrop.list)
		{
			button.setLabelFormat("VCR OSD Mono", 15, FlxColor.BLACK, "center");
		}

		var recentListClear = new FlxUIButton(recentListCategoryLine.x, recentListCategoryLine.y + 60, 'CLEAR RECENT LIST', function()
		{
			setPref('alone-funkin-recent-list', new Map<String, String>());
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			switchState(AloneFunkinState);
		});
		recentListClear.resize(200, 50);
		recentListClear.setLabelFormat("VCR OSD Mono", 18, FlxColor.WHITE, "center", OUTLINE, FlxColor.BLACK);
		recentListClear.label.borderSize = 1.25;
		recentListClear.label.offset.y += 10;
		add(recentListClear);
		add(recentListDrop);

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
