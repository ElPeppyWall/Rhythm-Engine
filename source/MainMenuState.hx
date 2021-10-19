package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

using StringTools;

#if (windows && !hl)
import Discord.DiscordClient;
#end

class MainMenuState extends MusicBeatState
{
	static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if (windows && !hl)
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));

		persistentUpdate = persistentDraw = true;

		var bg = new FlxSprite(0, 0, Paths.image('menuBG/menuBG'));
		bg.scrollFactor.set(0, .17);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = getPref('antialiasing');
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(0, 0, Paths.image('menuBG/menuDesat'));
		magenta.scrollFactor.set(0, .17);
		magenta.setGraphicSize(Std.int(bg.width));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = getPref('antialiasing');
		magenta.color = 0xFFfd719b;
		if (getPref('flashing-menu'))
			add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = getPref('antialiasing');
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit = new FlxText(5, FlxG.height - 20, 0, 'Better Funkin\' v${GameVars.engineVer}', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.borderSize = 1.25;
		versionShit.screenCenter(X);
		add(versionShit);

		if (getPref("first-time"))
		{
			FlxG.fullscreen = false;
			Application.current.window.alert('This game contains flashing lights! Make sure check your options before play!', 'Alert!!');
		}

		changeItem();
		promptInput = new flixel.addons.ui.FlxUIInputText(10, 10, FlxG.width, '', 32, FlxColor.BLACK, 0x64FFFFFF);
		promptInput.setFormat(Paths.font("CascadiaCode.ttf"), 42, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		promptInput.borderSize = 1.25;
		promptInput.scrollFactor.set();
		promptInput.screenCenter();
		promptInput.y = FlxG.height - 60;
		promptInput.antialiasing = getPref('antialiasing');

		super.create();
	}

	var promptInput:flixel.addons.ui.FlxUIInputText;
	var lastPrompt = '';
	var writing = false;
	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.F7)
		{
			promptInput.caretIndex = 0;
			if (writing)
			{
				readPrompt();
				writing = false;
				remove(promptInput);
			}
			else
			{
				add(promptInput);
				promptInput.hasFocus = true;
				writing = true;
			}

			if (writing)
			{
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeUpKeys = [];
				FlxG.sound.volumeDownKeys = [];
			}
			else
			{
				FlxG.sound.muteKeys = [ZERO];
				FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
				FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
			}
		}

		if (FlxG.keys.justPressed.UP && writing)
		{
			promptInput.text = lastPrompt;
			promptInput.caretIndex = promptInput.text.length;
		}
		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.06);
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin && !writing)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				switchState(TitleState);
			}

			if (checkKey('I'))
				Prompt.open();

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							var finishFunc = function(flick:Dynamic)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										switchState(StoryMenuState);
									case 'freeplay':
										switchState(FreeplayState);
									case 'options':
										FlxTransitionableState.skipNextTransIn = true;
										FlxTransitionableState.skipNextTransOut = true;
										switchState(OptionsMenu);
								}
							};
							if (getPref('flashing-menu'))
								FlxFlicker.flicker(spr, 1, 0.06, false, false, finishFunc);
							else
								new FlxTimer().start(1, finishFunc);
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}

	function readPrompt():Void
	{
		var argsArray:Array<Dynamic> = promptInput.text.split('.');
		trace(argsArray);

		switch (argsArray[0])
		{
			case 'options':
				switch (argsArray[1])
				{
					case 'setPref':
						setPref(argsArray[2], argsArray[3]);
					case 'getPref':
						trace('\u001b[96m' + 'pref ${argsArray[2]} = ${getPref(argsArray[2])} (${CoolUtil.getVarType(getPref(argsArray[2]))})\u001b[0m');
					case 'reset':
						PreferencesMenu.resetPrefs();
				}
			case 'PlayState':
				switch (argsArray[1])
				{
					case 'loadSong':
						PlayState.loadSong(argsArray[2], 0, false);
				}
			case 'binds': // ! "binds.note.setBind.up.K"
				var dir:Int = switch (argsArray[3])
				{
					default:
						0;
					case 'down':
						1;
					case 'up':
						2;
					case 'right':
						3;
				}
				switch (argsArray[1])
				{
					case 'note':
						switch (argsArray[2])
						{
							case 'setBind':
								KeyBinds.setBind(dir, argsArray[4].toUpperCase(), false);
							case 'getBind':
								trace('\u001b[96m'
									+ 'bind ${argsArray[1].toUpperCase()}_${argsArray[3].toUpperCase()} = ${FlxG.save.data.noteBinds[dir]}\u001b[0m');
						}
					case 'ui':
						switch (argsArray[2])
						{
							case 'setBind':
								KeyBinds.setBind(dir, argsArray[4].toUpperCase(), true);
							case 'getBind':
								trace('\u001b[96m' + 'bind ${argsArray[1]}_${argsArray[2]} = ${FlxG.save.data.uiBinds[dir]}\u001b[0m');
						}
				}

			default:
				trace('unknown command! ${argsArray[0]}');
		}
		lastPrompt = promptInput.text;
		promptInput.text = '';
	}
}
// class MainMenuList extends MenuTypedList
// {
// 	public function createItem(a = 0, b = 0, c, d, e = false)
// 	{
// 		var item = new MainMenuItem(a, b, c, atlas, d);
// 		item.fireInstantly = e;
// 		a.ID = length;
// 		return addItem(c, a);
// 	}
// }
// class MainMenuItem
// {
// }
