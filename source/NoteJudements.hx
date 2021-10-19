package;

class NoteJudements
{
	public static function getJudement(daNote:Note):String
	{
		var daRating:String = 'sick';
		var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
			daRating = 'shit';
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
			daRating = 'bad';
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
			daRating = 'good';
		else
			daRating = 'sick';

		return daRating;
	}
}
