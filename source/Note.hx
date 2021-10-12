package;

using StringTools;

#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

class Note extends flixel.FlxSprite
{
	public static final swagWidth:Float = 160 * 0.7;

	public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var noteJSONData:Int = 0;
	public var noteType:Int = 0;
	public var noteStyle:String = '';
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var isAlt = false;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public function new(_strumTime:Float, _noteData:Int, ?_prevNote:Note, ?_sustainNote:Bool = false, ?isChartingNote:Bool = false)
	{
		super();
		noteStyle = getNoteStyle();

		if (prevNote == null)
			prevNote = this;

		prevNote = _prevNote;
		isSustainNote = _sustainNote;

		x += 50;
		y -= 2000;

		strumTime = _strumTime;

		noteData = _noteData % 4;
		noteJSONData = _noteData;
		noteType = Std.int(noteJSONData / 8);

		var downscroll = getPref('downscroll') && !isChartingNote;
		switch (noteStyle)
		{
			default:
				frames = Paths.getSparrowAtlas('NOTE_assets');

				var note = PlayState.notesColor[noteData];
				animation.addByPrefix('${note}Scroll', '${note}0', 24, false, false, downscroll);
				animation.addByPrefix('${note}holdend', '${note} hold end', 24, false);
				animation.addByPrefix('${note}hold', '${note} hold piece', 24, false);

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();

			case 'pixel':
				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);

				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);
				animation.add('blueScroll', [5]);
				animation.add('purpleScroll', [4]);

				if (isSustainNote)
				{
					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);
					animation.add('blueholdend', [5]);

					animation.add('purplehold', [0]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
					animation.add('bluehold', [1]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
		}

		antialiasing = getPref('antialiasing') && noteStyle != 'pixel';

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			x += width / 2;

			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (noteStyle == 'pixel')
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	public static function getNoteStyle():String
	{
		var _noteStyle = '';
		switch (curSong())
		{
			default:
				_noteStyle = 'normal';
		}
		switch (PlayState.curStage)
		{
			case 'school', 'schoolEvil':
				_noteStyle = 'pixel';
			default:
				_noteStyle = 'normal';
		}
		return _noteStyle;
	}
}
