import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class KeyBindsMenu extends MusicBeatSubstate
{
	var isPause:Bool;
	var playerStrums:FlxTypedGroup<BabyArrow>;
	var arrowGrp:ArrowGrp;
	var textStrums:FlxTypedGroup<FlxText>;
	var textArrows:FlxTypedGroup<FlxText>;
	var sprOpt:AlphabetList;
	var keysBlackList:Array<FlxKey> = [
		FlxKey.ALT,
		FlxKey.BACKSPACE,
		FlxKey.CAPSLOCK,
		FlxKey.CONTROL,
		FlxKey.ENTER,
		FlxKey.SHIFT,
		FlxKey.ESCAPE,
		FlxKey.SPACE,
		FlxKey.TAB
	];

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

		sprOpt = new AlphabetList([
			'NOTE LEFT',
			'NOTE DOWN',
			'NOTE UP',
			'NOTE RIGHT',
			'UI LEFT',
			'UI DOWN',
			'UI UP',
			'UI RIGHT'
		]);
		add(sprOpt);
		playerStrums = new FlxTypedGroup<BabyArrow>();
		add(playerStrums);
		textStrums = new FlxTypedGroup<FlxText>();
		add(textStrums);
		textArrows = new FlxTypedGroup<FlxText>();
		add(textArrows);
		for (i in 0...100)
			sprOpt.update(0);
		for (i in 0...4)
		{
			var babyArrow = new BabyArrow(50, i, 'normal', 1, false, true);
			var noteKeyText = new FlxText(babyArrow.getMidpoint().x - 22.5, babyArrow.getMidpoint().y + 20, 0, '');
			noteKeyText.setFormat(Paths.font("vcr.ttf"), 52, switch (i)
			{
				default:
					0xFFc24b99;
				case 1:
					0xFF00ffff;
				case 2:
					0xFF12fa05;
				case 3:
					0xFFf9393f;
			}, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			noteKeyText.borderSize = 1.25;
			noteKeyText.ID = i;
			textStrums.add(noteKeyText);

			var uiKeyText = new FlxText(965, 520, 0, '');
			uiKeyText.setFormat(Paths.font("vcr.ttf"), 52, 0xFF00ffff, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			uiKeyText.borderSize = 1.25;
			uiKeyText.ID = i;
			textArrows.add(uiKeyText);
			switch (i)
			{
				case 0:
				case 2:
					uiKeyText.x += 90;
					uiKeyText.y -= 100;
				case 3:
					uiKeyText.x += 85 + 100;
				case 1:
					uiKeyText.x += 95;
					uiKeyText.y += 95;
			}

			playerStrums.add(babyArrow);
		}

		arrowGrp = new ArrowGrp();
		add(arrowGrp);

		daBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		daBG.alpha = .6;
		daBG.scrollFactor.set();
		add(daBG);
		daBG.visible = false;
		if (isPause)
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		sprOpt.canChangeSel = !choosingKey;

		var noteArray:Array<Bool> = [
			controls.NOTE_LEFT_P,
			controls.NOTE_DOWN_P,
			controls.NOTE_UP_P,
			controls.NOTE_RIGHT_P
		];
		var noteHoldArray:Array<Bool> = [
			controls.NOTE_LEFT, //
			controls.NOTE_DOWN, //
			controls.NOTE_UP, //
			controls.NOTE_RIGHT //
		];

		var uiHoldArray:Array<Bool> = [
			controls.UI_LEFT, //
			controls.UI_DOWN, //
			controls.UI_UP, //
			controls.UI_RIGHT //
		];

		if (!choosingKey)
		{
			playerStrums.forEach(function(spr:BabyArrow)
			{
				if (noteArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				{
					if (checkKey('SHIFT', PRESSED))
						spr.playAnim('confirm');
					else
						spr.playAnim('pressed');
				}

				if (!noteHoldArray[spr.ID])
					spr.playAnim('static');
			});
			arrowGrp.forEach(function(spr:FlxSprite)
			{
				if (uiHoldArray[spr.ID])
				{
					textArrows.forEach(function(text:FlxText)
					{
						if (text.ID == spr.ID)
							text.color = 0xFFffffff;
					});
					spr.animation.play('press');
				}
				else
				{
					textArrows.forEach(function(text:FlxText)
					{
						if (text.ID == spr.ID)
							text.color = 0xFF00ffff;
					});
					spr.animation.play('idle');
				}
			});

			textStrums.forEach(function(spr:FlxText) spr.text = String.fromCharCode(FlxG.save.data.noteBinds[spr.ID]));
			textArrows.forEach(function(spr:FlxText) spr.text = String.fromCharCode(FlxG.save.data.uiBinds[spr.ID]));

			if (controls.ACCEPT)
			{
				choosingKey = true;
				if (isNote)
					FlxG.save.data.noteBinds[curSelected] = -1;
				else
					FlxG.save.data.uiBinds[curSelected % 4] = -1;

				daBG.visible = true;
			}
			if (controls.BACK)
				openSubState(new PreferencesMenu(isPause));
		}
		else
		{
			if (FlxG.keys.firstJustPressed() != -1)
			{
				if (isNote)
					FlxG.save.data.noteBinds[curSelected] = keysBlackList.contains(FlxG.keys.firstJustPressed()) ? null : FlxG.keys.firstJustPressed();
				else
					FlxG.save.data.uiBinds[curSelected % 4] = keysBlackList.contains(FlxG.keys.firstJustPressed()) ? null : FlxG.keys.firstJustPressed();
				choosingKey = false;
				daBG.visible = false;
				KeyBinds.initBinds();
			}
		}
	}

	var daBG:FlxSprite;

	var choosingKey:Bool = false;

	var curSelected(get, never):Int;

	inline function get_curSelected():Int
		return sprOpt.selectedIndex;

	var isNote(get, never):Bool;

	inline function get_isNote():Bool
		return sprOpt.textList[curSelected].contains('NOTE');
}
