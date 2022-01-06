package;

import Alphabet.AlphaCharacter.alphabet;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class PreferencesMenu extends MusicBeatSubstate
{
	public static var preferences:Map<String, Dynamic> = [];

	var descriptionBG:FlxSprite;
	var prefBG:FlxSprite;
	var descriptionTxt:FlxTypeText;
	var prefTxt:FlxText;
	var menuCamera:FlxCamera;
	var sprOpt:AlphabetList;

	static final preferencesList:Array<Preference> = [
		{ // - controls
			name: 'controls',
			prettyName: 'Controls',
			description: 'Change your controls.',
			type: CUSTOM,
			defaultValue: null,
			hideFromOptionsMenu: false,
			disableOnPause: false,
			minValue: 0,
			maxValue: 0,
		},
		{ // - downscroll
			name: 'downscroll',
			prettyName: 'Downscroll',
			description: 'Places gray notes at bottom of the screen.',
			type: TOGGLE,
			defaultValue: false,
			hideFromOptionsMenu: false,
			disableOnPause: false,
			minValue: 0,
			maxValue: 0,
		},
		{ // - midscroll
			name: 'midscroll',
			prettyName: 'Midscroll',
			description: 'Centers gray notes.',
			type: TOGGLE,
			defaultValue: false,
			hideFromOptionsMenu: false,
			disableOnPause: false,
			minValue: 0,
			maxValue: 0,
		},
		{ // - ghostTapping
			name: 'ghostTapping',
			prettyName: 'Ghost Tapping',
			description: "If you press a key and there aren't notes to press, you miss.",
			type: TOGGLE,
			defaultValue: true,
			hideFromOptionsMenu: false,
			disableOnPause: false,
			minValue: 0,
			maxValue: 0,
		},
		{ // - fpsCap
			name: 'fpsCap',
			prettyName: 'FPS Cap',
			description: "Change the game framerate limit.",
			type: INT,
			defaultValue: 120,
			hideFromOptionsMenu: false,
			disableOnPause: false,
			minValue: 60,
			maxValue: 270,
		},
		{ // - hitsound
			name: 'hitsound',
			prettyName: 'HitSound',
			description: "When you press a note, a satisfying sound plays.",
			type: TOGGLE,
			defaultValue: false,
			hideFromOptionsMenu: false,
			disableOnPause: false,
			minValue: 0,
			maxValue: 0,
		},
		{ // - ultra-optimize
			name: 'ultra-optimize',
			prettyName: 'Ultra Optimize',
			description: "Deletes the characters and the background for better performance.",
			type: TOGGLE,
			defaultValue: false,
			hideFromOptionsMenu: false,
			disableOnPause: true,
			minValue: 0,
			maxValue: 0,
		},
		{ // - note-splashes
			name: 'note-splashes',
			prettyName: 'Note Splashes',
			description: 'Spawns a fancy splash when you hit a "Sick".',
			type: TOGGLE,
			defaultValue: true,
			hideFromOptionsMenu: false,
			disableOnPause: false,
			minValue: 0,
			maxValue: 0,
		},
		{ // - background-opacity
			name: 'background-opacity',
			prettyName: 'Background Opacity',
			description: 'Adds a black screen behind your notes to hide the background to see them better.',
			type: FLOAT_WITH_PERCENTAGE,
			defaultValue: 0,
			hideFromOptionsMenu: false,
			disableOnPause: false,
			minValue: 0,
			maxValue: 1,
		},
		{ // - flashing-menu
			name: 'flashing-menu',
			prettyName: 'Flashing Lights',
			description: 'Toggle the flashing lights for photosensitive people.',
			type: TOGGLE,
			defaultValue: true,
			hideFromOptionsMenu: false,
			disableOnPause: false,
			minValue: 0,
			maxValue: 0,
		},
		{ // - antialiasing
			name: 'antialiasing',
			prettyName: 'Antialiasing',
			description: 'Without antialiasing, theres better performance but the game looks worse.',
			type: TOGGLE,
			defaultValue: true,
			hideFromOptionsMenu: false,
			disableOnPause: true,
			minValue: 0,
			maxValue: 0,
		},
		{ // - camera-zoom
			name: 'camera-zoom',
			prettyName: 'Camera Beats',
			description: 'Toggle the camera zooms on a song beat.',
			type: TOGGLE,
			defaultValue: true,
			hideFromOptionsMenu: false,
			disableOnPause: false,
			minValue: 0,
			maxValue: 0,
		},
		{ // - auto-pause
			name: 'auto-pause',
			prettyName: 'Auto Pause',
			description: "Auto pauses the game when it doesn't have focus.",
			type: TOGGLE,
			defaultValue: false,
			hideFromOptionsMenu: false,
			disableOnPause: false,
			minValue: 0,
			maxValue: 0,
		},
		{ // - allow-reset
			name: 'allow-reset',
			prettyName: 'Allow Reset',
			description: "Allow die on game with the R key.",
			type: TOGGLE,
			defaultValue: false,
			hideFromOptionsMenu: false,
			disableOnPause: false,
			minValue: 0,
			maxValue: 0,
		},
		{ // - alone funkin recent list
			name: 'alone-funkin-recent-list',
			prettyName: 'alone-funkin-recent-list',
			description: 'alone-funkin-recent-list',
			type: TOGGLE,
			defaultValue: new Map<String, String>(),
			hideFromOptionsMenu: true,
			disableOnPause: false,
			minValue: 0,
			maxValue: 0,
		},
		#if mobileC
		{ // - mobileControlsType
			name: 'mobileControlsType',
			prettyName: 'mobileControlsType',
			description: "mobileControlsType",
			type: CUSTOM,
			defaultValue: 0,
			hideFromOptionsMenu: true,
			disableOnPause: true,
			minValue: 0,
			maxValue: 100,
		}, { // - mobileCustomPositions
			name: 'mobileCustomPositions',
			prettyName: 'mobileCustomPositions',
			description: "mobileCustomPositions",
			type: CUSTOM,
			defaultValue: [
				new FlxPoint(FlxG.width - 86 * 3, FlxG.height - 66 - 116 * 3),
				new FlxPoint(FlxG.width - 130 * 3, FlxG.height - 66 - 81 * 3),
				new FlxPoint(FlxG.width - 44 * 3, FlxG.height - 66 - 81 * 3),
				new FlxPoint(FlxG.width - 86 * 3, FlxG.height - 66 - 45 * 3),
			],
			hideFromOptionsMenu: true,
			disableOnPause: true,
			minValue: 0,
			maxValue: 0,
		},
		#end
	];

	var isPause:Bool;

	public function new(_isPause:Bool)
	{
		super();
		isPause = _isPause;

		if (isPause)
		{
			var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = .6;
			bg.scrollFactor.set();
			add(bg);
		}

		sprOpt = new AlphabetList(optionsNameList);
		add(sprOpt);

		descriptionBG = new FlxSprite(0.7 * FlxG.width - 6, 0).makeGraphic(1, Std.int(FlxG.height / 2), FlxColor.BLACK);
		descriptionBG.alpha = 0.6;
		descriptionBG.y = FlxG.height - descriptionBG.height;
		add(descriptionBG);

		descriptionTxt = new FlxTypeText(0.7 * FlxG.width, descriptionBG.y + 10, Std.int(FlxG.width / 2) - 300, "", 32);
		descriptionTxt.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descriptionTxt.borderSize = 1.25;
		descriptionTxt.sounds = [FlxG.sound.load(Paths.sound('generic2'), 0.6)];
		add(descriptionTxt);

		prefBG = new FlxSprite(0.7 * FlxG.width - 6, 0).makeGraphic(1, 66, FlxColor.WHITE);
		add(prefBG);

		prefTxt = new FlxText(0.7 * FlxG.width, prefBG.y + 10, Std.int(FlxG.width / 2) - 300, "", 32);
		prefTxt.setFormat(Paths.font("vcr.ttf"), 38, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		prefTxt.borderSize = 1.25;
		add(prefTxt);

		sprOpt._changeSelection = function(lol:Bool):Void
		{
			if (lol)
			{
				descriptionTxt.resetText(preferencesList[curSelected].description);
				descriptionTxt.start(.04, true);
			}
			if (preferencesList[curSelected].type != CUSTOM)
				prefTxt.text = prefValueToText();
			var daColor = new FlxColor(switch (prefTxt.text)
			{
				case 'OFF':
					FlxColor.RED;
				case 'ON':
					FlxColor.LIME;
				case 'UNKNOWN':
					FlxColor.GRAY;
				default:
					FlxColor.ORANGE;
			});
			daColor.alphaFloat = .6;
			var alphaAAAAA = 1;
			switch (preferencesList[curSelected].name)
			{
				case 'controls', 'reset options':
					daColor.alphaFloat = 0;
					alphaAAAAA = 0;
			}
			FlxTween.color(prefBG, CoolUtil.camLerpShit(.45), prefBG.color, daColor);
			FlxTween.tween(prefTxt, {alpha: alphaAAAAA}, CoolUtil.camLerpShit(.45));
		}

		sprOpt.changeSelection(0, false);

		#if mobileC
		key_shift = new FlxSprite(prefBG.x, prefBG.y + 100, Paths.image('mobileControls/key_shift', 'shared'));
		add(key_shift);
		#end
		if (isPause)
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	#if mobileC
	var key_shift:FlxSprite;
	#end

	var optionsNameList(get, never):Array<String>;

	inline function get_optionsNameList():Array<String>
	{
		var optionsList:Array<String> = [];
		for (i in preferencesList)
			if (!i.hideFromOptionsMenu)
				optionsList.push(i.prettyName);

		return optionsList;
	}

	var curSelected(get, never):Int;

	inline function get_curSelected():Int
		return sprOpt.selectedIndex;

	function prefValueToText():String
	{
		switch (preferencesList[curSelected].type)
		{
			case TOGGLE:
				return switch (getPref(preferencesList[curSelected].name))
				{
					case true:
						'ON';
					case false:
						'OFF';
				}
			case FLOAT, INT:
				return '${getPref(preferencesList[curSelected].name)}';
			case FLOAT_WITH_PERCENTAGE:
				return '${cast (getPref(preferencesList[curSelected].name), Float) * 100}%';
			default:
				return 'UNKNOWN';
				// 	case 'background-opacity':
				// 	case 'language':
				// 		return value.toUpperCase();
				// 	default:
				// 		if (Std.isOfType(value, Bool))

				// 		else if (Std.isOfType(value, Int) || Std.isOfType(value, Float))
				// 			return Std.string(value);
				// 		else
				// 			return 'UNKNOWN';
		}
	}

	function accept():Void
	{
		switch (preferencesList[curSelected].type)
		{
			case TOGGLE:
				toggleOption(preferencesList[curSelected].name);
				sprOpt._changeSelection(false);

			case CUSTOM:
				switch (preferencesList[curSelected].name)
				{
					case 'controls':
						#if mobileC
						if (!isPause)
							FlxG.state.openSubState(new MobileControlsSubState());
						else
							makeAnError();
						#else
						FlxG.state.openSubState(new KeyBindsMenu(isPause));
						#end
				}

			default:
		}
	}

	override function update(elapsed:Float)
	{
		var up = false,
			down = false,
			left = false,
			right = false,
			accept = false,
			back = false;
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
				if (-135 < swipe.startPosition.angleBetween(swipe.endPosition)
					&& -45 > swipe.startPosition.angleBetween(swipe.endPosition))
					left = true;
				if (45 < swipe.startPosition.angleBetween(swipe.endPosition) && 135 > swipe.startPosition.angleBetween(swipe.endPosition))
					right = true;
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
		if (sprOpt.canChangeSel)
		{
			if (up)
				sprOpt.changeSelection(-1);
			if (down)
				sprOpt.changeSelection(1);
		}
		#else
		up = controls.UI_UP_P;
		down = controls.UI_DOWN_P;
		left = controls.UI_LEFT_P;
		right = controls.UI_RIGHT_P;
		back = controls.BACK;
		accept = controls.ACCEPT;
		#end
		if (cast(accept, Bool))
			this.accept();

		if (left)
			leftOrRight(-1);
		if (right)
			leftOrRight(1);

		if (cast(back, Bool))
			this.back();

		descriptionTxt.x = (FlxG.width - descriptionTxt.width - 6);
		prefTxt.x = (FlxG.width - descriptionTxt.width - 6);
		descriptionBG.scale.x = (FlxG.width - descriptionTxt.x + 6);
		descriptionBG.x = (FlxG.width - descriptionBG.scale.x / 2);
		prefBG.scale.x = (FlxG.width - descriptionTxt.x + 6);
		prefBG.x = (FlxG.width - descriptionBG.scale.x / 2);
		super.update(elapsed);
	}

	function leftOrRight(dir:Int):Void
	{
		var floatChange = dir / 100;
		if (FlxG.keys.pressed.SHIFT)
		{
			dir *= 10;
			floatChange *= 10;
		}
		switch (preferencesList[curSelected].type)
		{
			case INT:
				setPref(preferencesList[curSelected].name, getPref(preferencesList[curSelected].name) + dir);
			case FLOAT, FLOAT_WITH_PERCENTAGE:
				setPref(preferencesList[curSelected].name, getPref(preferencesList[curSelected].name) + floatChange);
			case TOGGLE:
				toggleOption(preferencesList[curSelected].name);
			default:
		}
		sprOpt._changeSelection(false);
	}

	function back():Void
	{
		close();
		if (!isPause)
			CoolUtil.switchState(MainMenuState);
		else
			FlxG.state.openSubState(new PauseSubState(PlayState.instance.boyfriend.getScreenPosition().x, PlayState.instance.boyfriend.getScreenPosition().y,
				true));
	}

	function toggleOption(daPref:String)
	{
		var preferenceData = getPrefDataByName(daPref);
		if (isPause && preferenceData.disableOnPause)
			makeAnError();
		else
		{
			setPref(daPref, !getPref(daPref));
			switch (daPref)
			{
				case 'antialiasing':
					sprOpt.forEach(function(spr:Alphabet)
					{
						spr.forEach(function(char:FlxSprite)
						{
							char.antialiasing = getPref('antialiasing');
						});
					});
			}
		}
	}

	function makeAnError():Void
	{
		for (item in sprOpt.members)
			if (item.targetY == 0)
			{
				FlxG.sound.play(Paths.sound('errorMenu'));
				sprOpt.canChangeSel = false;
				FlxTween.color(item, .5, FlxColor.WHITE, FlxColor.RED, {
					onComplete: function(twn:FlxTween)
					{
						FlxTween.color(item, .1, FlxColor.RED, FlxColor.WHITE, {
							onComplete: function(twn:FlxTween)
							{
								sprOpt.canChangeSel = true;
							}
						});
					}
				});
			}
	}

	public static function getPref(preference:String):Dynamic
		return preferences[preference];

	public static function getPrefDataByName(name:String):Preference
	{
		for (preference in preferencesList)
			if (preference.name == name)
				return preference;

		trace(null);
		return null;
	}

	public static function setPref(preference:String, value:Dynamic, ?isPrefCheck:Bool = false):Void
	{
		var preferenceData = getPrefDataByName(preference);

		if ([FLOAT, FLOAT_WITH_PERCENTAGE, INT].contains(preferenceData.type))
		{
			value = FlxMath.roundDecimal(value, 2);
			if (value >= preferenceData.maxValue)
				value = preferenceData.maxValue;
			if (value <= preferenceData.minValue)
				value = preferenceData.minValue;
		}

		trace('\u001b[96m' + 'setPref (${preference}) to: ${value}\u001b[0m');
		preferences[preference] = value;
		FlxG.save.data.prefs = preferences;
		FlxG.save.flush();
		checkPrefValue(preference);
	}

	public static function resetPrefs():Void
	{
		FlxG.save.data.prefs = null;
		FlxG.save.flush();
		initPrefs();
	}

	public static function preferenceCheck(preference:String, defValue:Dynamic):Void
	{
		if (preferences[preference] == null)
			setPref(preference, defValue, true);
		else
			checkPrefValue(preference);
	}

	public static function initPrefs():Void
	{
		if (FlxG.save.data.prefs == null)
			FlxG.save.data.prefs = new Map<String, Dynamic>();
		preferences = FlxG.save.data.prefs;

		for (preference in preferencesList)
			if (preference.defaultValue != null)
				preferenceCheck(preference.name, preference.defaultValue);

		FlxG.save.flush();
	}

	public static function checkPrefValue(preference:String):Void
	{
		switch (preference)
		{
			case 'fps-counter':
				Main.fpsCounterVisible(getPref('fps-counter'));
			case 'fpsCap':
				cast(openfl.Lib.current.getChildAt(0), Main).setFPSCap(getPref('fpsCap'));
			case 'auto-pause':
				FlxG.autoPause = getPref("auto-pause");
		}
	}
}

typedef Preference =
{
	var name:String;
	var prettyName:String;
	var description:String;
	var type:PreferenceType;
	var defaultValue:Dynamic;
	var hideFromOptionsMenu:Bool;
	var disableOnPause:Bool;
	var minValue:Float;
	var maxValue:Float;
}

enum PreferenceType
{
	TOGGLE;
	INT;
	FLOAT;
	FLOAT_WITH_PERCENTAGE;
	CUSTOM;
}
