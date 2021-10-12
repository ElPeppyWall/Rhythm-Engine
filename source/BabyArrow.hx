package;

import PlayState.notesColor;
import PlayState.notesDir;

class BabyArrow extends flixel.FlxSprite
{
	public var noteStyle:String = '';
	public var noteData:Int;

	public function new(y:Float, noteI:Int, _style:String, playerID:Int, fadeIn:Bool)
	{
		super(0, y);
		noteStyle = _style;
		noteData = noteI;
		var _noteDir = notesDir[noteData].toLowerCase();
		var downscroll = getPref('downscroll');
		switch (noteStyle)
		{
			default:
				frames = Paths.getSparrowAtlas('NOTE_assets');
				animation.addByPrefix(notesColor[noteData], 'arrow${notesDir[noteData]}');

				x += Note.swagWidth * noteData;
				animation.addByPrefix('static', 'arrow${_noteDir.toUpperCase()}', 24, false, false, downscroll);
				animation.addByPrefix('pressed', '$_noteDir press', 24, false, false, downscroll);
				animation.addByPrefix('confirm', '$_noteDir confirm', 24, false, false, downscroll);
				setGraphicSize(Std.int(width * 0.7));
			case 'pixel':
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
				animation.add('green', [6]);
				animation.add('red', [7]);
				animation.add('blue', [5]);
				animation.add('purplel', [4]);

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

				x += Note.swagWidth * noteData;
				animation.add('static', [noteData], 24, false, false, downscroll);
				animation.add('pressed', [4 + noteData, 8 + noteData], 12, false, false, downscroll);
				animation.add('confirm', [12 + noteData, 16 + noteData], 24, false, false, downscroll);
		}
		antialiasing = getPref('antialiasing') && noteStyle != 'pixel';
		updateHitbox();
		scrollFactor.set();
		if (fadeIn)
		{
			y -= 10;
			alpha = 0;
			flixel.tweens.FlxTween.tween(this, {y: this.y + 10, alpha: 1}, 1, {ease: flixel.tweens.FlxEase.circOut, startDelay: 0.5 + (0.2 * noteData)});
		}
		ID = noteData;
		animation.play('static');
		x += 50;
		x += ((flixel.FlxG.width / 2) * playerID);
	}
}
