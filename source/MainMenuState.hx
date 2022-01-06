package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

using StringTools;

#if (windows && cpp)
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

	var defCam = new FlxCamera();
	var camBG = new FlxCamera();

	override function create()
	{
		FlxG.cameras.reset();
		FlxG.cameras.add(camBG);
		FlxG.cameras.add(defCam);
		camBG.bgColor.alpha = 0;
		defCam.bgColor.alpha = 0;

		FlxCamera.defaultCameras = [defCam];
		#if (windows && cpp)
		DiscordClient.changePresence("In the Menus", null);
		#end

		MusicManager.checkPlaying();

		var bg = new FlxSprite(0, 0, Paths.image('menuBG/menuBG'));
		bg.scrollFactor.set(0, .17);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = getPref('antialiasing');
		bg.cameras = [camBG];
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
		magenta.cameras = [camBG];
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

		camBG.follow(camFollow, null, 0.04);

		var versionShit = new FlxText(5, FlxG.height - 50, 0, '${GameInfo.engineWatermark}', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.borderSize = 3;
		versionShit.borderQuality = 3;
		versionShit.screenCenter(X);
		versionShit.scrollFactor.set();
		add(versionShit);

		changeItem();
		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		camBG.followLerp = CoolUtil.camLerpShit(0.04);
		if (FlxG.keys.justPressed.SEVEN)
		{
		}
		if (!selectedSomethin)
		{
			var up = false, down = false, accept = false, back = false;
			#if mobileC
			for (swipe in FlxG.swipes)
			{
				var f = swipe.startPosition.x - swipe.endPosition.x;
				var g = swipe.startPosition.y - swipe.endPosition.y;
				if (25 <= Math.sqrt(f * f + g * g))
				{
					if ((-45 <= swipe.startPosition.angleBetween(swipe.endPosition)
						&& 45 >= swipe.startPosition.angleBetween(swipe.endPosition)))
						down = true;
					if (-180 <= swipe.startPosition.angleBetween(swipe.endPosition)
						&& -135 >= swipe.startPosition.angleBetween(swipe.endPosition)
						|| (135 <= swipe.startPosition.angleBetween(swipe.endPosition)
							&& 180 >= swipe.startPosition.angleBetween(swipe.endPosition)))
						up = true;
				}
				else
					accept = true;
			}
			if (MobileControls.androidBack)
				back = true;
			#else
			up = controls.UI_UP_P;
			down = controls.UI_DOWN_P;
			back = controls.BACK;
			accept = controls.ACCEPT;
			#end

			if (up)
				changeItem(-1);

			if (down)
				changeItem(1);

			if (back)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
				switchState(TitleState);
			}

			if (accept)
				selectItem();
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function selectItem():Void
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

	function changeItem(huh:Int = 0, force:Bool = false)
	{
		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += huh;

		if (!force)
		{
			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		else
			curSelected = huh;

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
