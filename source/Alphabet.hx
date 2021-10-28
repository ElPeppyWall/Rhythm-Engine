package;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends flixel.group.FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var type:Array<AlphabetType> = [];

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false)
	{
		super(x, y);

		_finalText = text;
		this.text = text;
		isBold = bold;

		if (text != "")
		{
			if (typed)
				startTypedText();
			else
				addText();
		}
	}

	public function addText()
	{
		doSplitWords();

		var xPos:Float = 0;
		for (character in splitWords)
		{
			if (character == " " || character == "-")
			{
				lastWasSpace = true;
			}

			if (AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1)
				// if (AlphaCharacter.alphabet.contains(character.toLowerCase()))
			{
				if (lastSprite != null)
				{
					xPos = lastSprite.x + lastSprite.width;
				}

				if (lastWasSpace)
				{
					xPos += 40;
					lastWasSpace = false;
				}

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0, isBold);

				letter.create(character);

				add(letter);

				lastSprite = letter;
			}

			// loopNum += 1;
		}
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	public var personTalking:String = 'gf';

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		new FlxTimer().start(0.05, function(tmr:FlxTimer)
		{
			// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				xPos = 0;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
			{
				lastWasSpace = true;
			}

			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[loopNum]);

			// if (AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1 || isNumber || isSymbol)
			// if (AlphaCharacter.alphabet.contains(splitWords[loopNum].toLowerCase()) || isNumber || isSymbol)

			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
					// if (isBold)
					// xPos -= 80;
				}
				else
				{
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}
				// trace(_finalText.fastCodeAt(loopNum) + " " + _finalText.charAt(loopNum));

				// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti, isBold);
				letter.row = curRow;
				letter.create(splitWords[loopNum]);
				if (!isBold)
					letter.x += 90;

				if (FlxG.random.bool(40))
				{
					var daSound:String = "GF_";
					FlxG.sound.play(Paths.soundRandom(daSound, 1, 4));
				}

				add(letter);

				lastSprite = letter;
			}

			loopNum += 1;

			tmr.time = FlxG.random.float(0.04, 0.09);
		}, splitWords.length);
	}

	override function update(elapsed:Float)
	{
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

		if (!type.contains(IGNORE_Y))
			y = CoolUtil.coolLerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.16);
		if (!type.contains(IGNORE_X))
			x = CoolUtil.coolLerp(x, (targetY * 20) + 90, 0.16);
		else
			screenCenter(X);

		super.update(elapsed);
	}
}

enum AlphabetType
{
	IGNORE_Y;
	IGNORE_X;
}

class AlphaCharacter extends flixel.FlxSprite
{
	public static inline var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static inline var numbers:String = "1234567890";

	public static inline var symbols:String = "-:;<=>@[]^_.,'!?";

	public var row:Int = 0;

	public var isBold:Bool = false;

	public function new(x:Float, y:Float, _isBold:Bool)
	{
		super(x, y);
		isBold = _isBold;
		frames = Paths.getSparrowAtlas('fonts/${isBold ? 'bold' : 'default'}');
		antialiasing = getPref('antialiasing');
	}

	public function create(letter:String)
	{
		animation.addByPrefix(letter, getAnimPrefix(letter), 24);
		animation.play(letter);
		updateHitbox();

		if (!isBold)
		{
			y = (110 - height);
			y += row * 60;
		}
	}

	function getAnimPrefix(letter:String):String
		switch (letter)
		{
			case "!":
				return "-exclamation point-";
			case "'":
				return "-apostraphie-";
			case "*":
				return "-multiply x-";
			case ",":
				return "-comma-";
			case "-":
				return "-dash-";
			case ".":
				return "-period-";
			case "/":
				return "-forward slash-";
			case "?":
				return "-question mark-";
			case "\\":
				return "-back slash-";
			case "\u201c":
				return "-start quote-";
			case "\u201d":
				return "-end quote-";
			default:
				return isBold ? letter.toUpperCase() : letter;
		}
}
