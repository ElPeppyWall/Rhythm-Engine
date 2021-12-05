#if mobileC
package;

import PreferencesMenu.getPref;
import PreferencesMenu.setPref;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import haxe.Json;

using StringTools;

#if lime
import lime.system.Clipboard;
#end

class MobileControlsSubState extends MusicBeatSubstate
{
	var _pad:FlxVirtualPad;
	var _hb:Hitbox;

	var _saveconrtol:FlxSave;

	var controlModeTxt:FlxText;

	var changeKeyBindsButton:FlxUIButton;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var controlitems:Array<String> = ['Right', 'Left', 'Double', 'Keyboard', 'Custom', 'Hitbox'];

	var curSelected:Int = 0;

	var buttonistouched:Bool = false;

	var bindbutton:FlxButton;

	public function new()
	{
		super();

		curSelected = getPref('mobileControlsType');

		_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
		_pad.alpha = 0;

		_hb = new Hitbox();
		_hb.visible = false;

		controlModeTxt = new FlxText(125, 50, 0, controlitems[0], 48);
		controlModeTxt.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		controlModeTxt.borderSize = 1.25;

		var arrowsFrames = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		leftArrow = new FlxSprite(controlModeTxt.x - 60, controlModeTxt.y - 10);
		leftArrow.frames = arrowsFrames;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');

		rightArrow = new FlxSprite(controlModeTxt.x + controlModeTxt.width + 10, leftArrow.y);
		rightArrow.frames = arrowsFrames;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');

		var savebutton = new FlxUIButton(FlxG.width - 225, 25, "Exit and Save", exitAndSaveSelected);
		savebutton.resize(200, 50);
		savebutton.setLabelFormat("VCR OSD Mono", 18, FlxColor.WHITE, "center", OUTLINE, FlxColor.BLACK);
		savebutton.label.borderSize = 1.25;
		savebutton.label.offset.y += 10;

		changeKeyBindsButton = new FlxUIButton(FlxG.width - 825, 25, "KeyBinds", function()
		{
			FlxG.state.openSubState(new KeyBindsMenu(false));
		});
		changeKeyBindsButton.resize(150, 50);
		changeKeyBindsButton.setLabelFormat("VCR OSD Mono", 18, FlxColor.WHITE, "center", OUTLINE, FlxColor.BLACK);
		changeKeyBindsButton.label.borderSize = 1.25;
		changeKeyBindsButton.label.offset.y += 10;
		changeKeyBindsButton.visible = false;
		changeKeyBindsButton.active = changeKeyBindsButton.visible;

		add(_pad);
		add(_hb);
		add(savebutton);
		add(controlModeTxt);
		add(changeKeyBindsButton);
		add(leftArrow);
		add(rightArrow);

		changeSelection();
	}

	function exitAndSaveSelected():Void
	{
		save();
		FlxG.switchState(new OptionsMenu());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		rightArrow.x = controlModeTxt.x + controlModeTxt.width + 10;
		leftArrow.x = controlModeTxt.x - 60;

		if (MobileControls.androidBack)
			exitAndSaveSelected();
		#if windows
		if (FlxG.keys.justPressed.RIGHT)
			changeSelection(1);
		else if (FlxG.keys.justPressed.LEFT)
			changeSelection(-1);
		#end

		#if FLX_TOUCH
		for (touch in FlxG.touches.list)
		{
			arrowanimate(touch);

			if ((touch.overlaps(leftArrow) && touch.justPressed))
				changeSelection(-1);
			else if ((touch.overlaps(rightArrow) && touch.justPressed))
				changeSelection(1);

			if (curSelected != 5)
				trackbutton(touch);
		}
		#end
	}

	function changeSelection(change:Int = 0, ?forceChange:Int)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = controlitems.length - 1;
		if (curSelected >= controlitems.length)
			curSelected = 0;

		if (forceChange != null)
			curSelected = forceChange;

		controlModeTxt.text = controlitems[curSelected];

		if (forceChange != null)
		{
			if (curSelected == 3)
				_pad.visible = true;

			return;
		}

		_hb.visible = false;

		switch (curSelected)
		{
			case 0:
				remove(_pad);
				_pad = null;
				_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
				_pad.alpha = 0.75;
				add(_pad);
			case 1:
				remove(_pad);
				_pad = null;
				_pad = new FlxVirtualPad(FULL, NONE);
				_pad.alpha = 0.75;
				add(_pad);
			case 2:
				remove(_pad);
				_pad = null;
				_pad = new FlxVirtualPad(DOUBLE_FULL, NONE);
				_pad.alpha = 0.75;
				add(_pad);
			case 3:
				_pad.alpha = 0;
				changeKeyBindsButton.visible = true;
				changeKeyBindsButton.active = changeKeyBindsButton.visible;
			case 4:
				remove(_pad);
				_pad = null;
				_pad = new FlxVirtualPad(RIGHT_FULL, NONE);
				add(_pad);
				_pad.alpha = 0.75;
				loadcustom();
			case 5:
				_pad.alpha = 0;
				_hb.visible = true;
		}
	}

	#if FLX_TOUCH
	function arrowanimate(touch:flixel.input.touch.FlxTouch)
	{
		for (arrow in [leftArrow, rightArrow])
		{
			if (touch.overlaps(arrow) && touch.pressed)
				arrow.animation.play('press');

			if (touch.released)
				arrow.animation.play('idle');
		}
	}

	function trackbutton(touch:flixel.input.touch.FlxTouch)
	{
		if (buttonistouched)
		{
			if (bindbutton.justReleased && touch.justReleased)
			{
				bindbutton = null;
				buttonistouched = false;
			}
			else
				movebutton(touch, bindbutton);
		}
		else
			for (button in [_pad.buttonUp, _pad.buttonDown, _pad.buttonRight, _pad.buttonLeft])
				if (button.justPressed)
				{
					if (curSelected != 4 && curSelected != 5)
						changeSelection(0, 4);

					movebutton(touch, button);
				}
	}

	function movebutton(touch:flixel.input.touch.FlxTouch, button:flixel.ui.FlxButton)
	{
		button.x = touch.x - _pad.buttonUp.width / 2;
		button.y = touch.y - _pad.buttonUp.height / 2;
		bindbutton = button;
		buttonistouched = true;
	}
	#end

	function save()
	{
		setPref('mobileControlsType', curSelected);

		savecustom();
	}

	function savecustom()
	{
		var tempSaveData = new Array();

		var customPos:Array<FlxPoint> = cast(getPref('mobileCustomPositions'));
		tempSaveData = customPos;

		if (tempSaveData == null)
			for (buttons in _pad)
				tempSaveData.push(FlxPoint.get(buttons.x, buttons.y));
		else
		{
			var tempCount:Int = 0;
			for (buttons in _pad)
			{
				tempSaveData[tempCount] = FlxPoint.get(buttons.x, buttons.y);
				tempCount++;
			}
		}

		setPref('mobileCustomPositions', tempSaveData);
	}

	function loadcustom():Void
	{
		var customPos:Array<FlxPoint> = cast(getPref('mobileCustomPositions'));
		if (customPos != null)
		{
			var tempCount:Int = 0;

			for (buttons in _pad)
			{
				buttons.x = customPos[tempCount % 4].x;
				buttons.y = customPos[tempCount % 4].y;
				tempCount++;
			}
		}
	}

	function resizebuttons(vpad:FlxVirtualPad, ?int:Int = 200)
	{
		for (button in vpad)
		{
			button.setGraphicSize(260);
			button.updateHitbox();
		}
	}

	function saveToClipboard(pad:FlxVirtualPad)
	{
		var json = {
			buttonsarray: []
		};

		var tempCount:Int = 0;
		var buttonsarray = new Array<FlxPoint>();

		for (buttons in pad)
		{
			buttonsarray[tempCount] = FlxPoint.get(buttons.x, buttons.y);
			tempCount++;
		}

		json.buttonsarray = buttonsarray;

		var data:String = Json.stringify(json);

		openfl.system.System.setClipboard(data.trim());
	}

	function loadFromClipboard(pad:FlxVirtualPad):Void
	{
		if (curSelected != 4)
			changeSelection(0, 4);

		var cbtext:String = Clipboard.text; // this not working on android 10 or higher

		if (!cbtext.endsWith("}"))
			return;

		var json = Json.parse(cbtext);

		var tempCount:Int = 0;

		for (buttons in pad)
		{
			buttons.x = json.buttonsarray[tempCount].x;
			buttons.y = json.buttonsarray[tempCount].y;
			tempCount++;
		}
	}

	override function destroy()
		super.destroy();
}
#end
