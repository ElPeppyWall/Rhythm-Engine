package;

class NoteJudements
{
	static var judementArray = [
		166, // - shit
		135, // - bad
		90, // - good
		45 // - sick
	];

	public static function getJudement(daNote:Note):String
	{
		var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);

		for (i in 0...judementArray.length)
		{
			var daTime = judementArray[i];
			var nextTime = i + 1 > judementArray.length - 1 ? 0 : judementArray[i + 1];
			if (noteDiff < daTime && noteDiff >= nextTime)
			{
				switch (i)
				{
					case 0:
						return "shit";
					case 1:
						return "bad";
					case 2:
						return "good";
					case 3:
						return "sick";
				}
			}
		}
		return "shit";
	}
}
