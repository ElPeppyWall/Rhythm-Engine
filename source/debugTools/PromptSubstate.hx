package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PromptSubstate extends MusicBeatSubstate
{
	static var commandsEntered:Array<String> = [];

	var curSelected = 0;

	var promptInput:Prompt;

	public function new(?_closeCallback:Void->Void)
	{
		super();
		if (_closeCallback != null)
			closeCallback = _closeCallback;
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		promptInput = new Prompt();
		add(promptInput);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (commandsEntered.length >= 1)
		{
			if (KeyBinds.checkKey('UP'))
			{
				promptInput.text = commandsEntered[curSelected];
				promptInput.caretIndex = promptInput.text.length;
				curSelected++;
			}
			if (KeyBinds.checkKey('UP'))
			{
				promptInput.text = commandsEntered[curSelected];
				promptInput.caretIndex = promptInput.text.length;
				curSelected--;
			}
		}
		if (KeyBinds.checkKey('ENTER'))
		{
			commandsEntered.unshift(promptInput.text);
			var argsArray:Array<Dynamic> = promptInput.text.split('.');
			trace(argsArray);

			switch (argsArray[0])
			{
				case 'options': // ! options.setPref.downscroll.ture
					switch (argsArray[1])
					{
						case 'setPref':
							PreferencesMenu.setPref(argsArray[2], argsArray[3]);
						case 'getPref':
							trace('\u001b[96mpref ${argsArray[2]} = ${PreferencesMenu.getPref(argsArray[2])} (${CoolUtil.getVarType(PreferencesMenu.getPref(argsArray[2]))})\u001b[0m');
						case 'reset':
							PreferencesMenu.resetPrefs();
					}
				case 'PlayState': // ! PlayState.loadSong.blammed-hard
					switch (argsArray[1])
					{
						case 'loadSong':
							PlayState.loadSong(argsArray[2], 0, flixel.util.FlxColor.WHITE, false);
					}
				case 'binds': // ! binds.note.setBind.up.K
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
				default: // ! hi
					trace('unknown command! ${argsArray[0]}');
			}
			close();
		}
	}

	override public function close():Void
	{
		closeSubState();
		super.close();
	}
}
