package;

typedef WeekClass =
{
	var library:String;
	var weekName:String;
	var weekSongs:Array<String>;
	var weekFile:String;
	var weekCharacter:String;
	var weekColor:flixel.util.FlxColor;
}

class WeekData
{
	/**
	 * + STORY MODE & FREEPLAY
	 */
	public static final weeksSongs = [
		['Tutorial'], // - TUTORIAL (WEEK 0)
		['Bopeebo', 'Fresh', 'Dad-Battle'], // - WEEK 1
		['Spookeez', 'South', "Monster"], // - WEEK 2
		['Pico', 'Philly-Nice', "Blammed"], // - WEEK 3
		['Satin-Panties', "High", "M.I.L.F"], // - WEEK 4
		['Cocoa', 'Eggnog', 'Winter-Horrorland'], // - WEEK 5
		['Senpai', 'Roses', 'Thorns'], // - WEEK 6
	];

	/**
	 * + FREEPLAY
	 */
	public static final onlyFreeplaySongs = [
		[], // - TUTORIAL (WEEK 0)
		[], // - WEEK 1
		[], // - WEEK 2
		[], // - WEEK 3
		[], // - WEEK 4
		[], // - WEEK 5
		[], // - WEEK 6
	];

	/**
	 * + STORY MODE & FREEPLAY
	 */
	public static final weeksCharacters = [
		'dad', // - TUTORIAL (WEEK 0)
		'dad', // - WEEK 1
		'spooky', // - WEEK 2
		'pico', // - WEEK 3
		'mom', // - WEEK 4
		'parents-christmas', // - WEEK 5
		'senpai', // - WEEK 6
	];

	/**
	 * + FREEPLAY
	 */
	public static final freeplayWeeksOverrideCharacters = [
		['gf'], // - TUTORIAL (WEEK 0)
		[], // - WEEK 1
		['spooky', 'spooky', 'monster'], // - WEEK 2
		[], // - WEEK 3
		[], // - WEEK 4
		['parents-christmas', 'parents-christmas', 'monster-christmas'], // - WEEK 4
		['senpai', 'senpai-angry', 'spirit'], // - WEEK 6
	];

	/**
	 * + STORY MODE & FREEPLAY
	 */
	public static final weeksColors = [ //// I HATE HAXE FORMATER
		- 7179779, // - TUTORIAL (WEEK 0)
		- 7179779, // - WEEK 1
		- 14535868, // - WEEK 2
		- 7072173, // - WEEK 3
		- 223529, // - WEEK 4
		- 6237697, // - WEEK 5
		- 34625, // - WEEK 6
		- 11022876, // - ALONE FUNKIN' (ONLY FREEPLAY)
	];

	/**
	 * + STORY MODE
	 */
	public static final weeksNames = [
		'How To Funk', // - TUTORIAL (WEEK 0)
		'Daddy Dearest', // - WEEK 1
		'Spooky Month!', // - WEEK 2
		'Go Pico!, yeah! yeah!', // - WEEK 3
		'Mommy Must Murder', // - WEEK 4
		'Red Snow', // - WEEK 5
		'dating simulator ft. moawling', // - WEEK 6
	];

	/**
	 * + STORY MODE & FREEPLAY
	 */
	public static final librariesNames = [
		'tutorial', // - TUTORIAL (WEEK 0)
		'week1', // - WEEK 1
		'week2', // - WEEK 2
		'week3', // - WEEK 3
		'week4', // - WEEK 4
		'week5', // - WEEK 5
		'week6', // - WEEK 6
	];

	/**
	 * + STORY MODE
	 */
	public static final weeksFiles = [
		'tutorial', // - TUTORIAL (WEEK 0)
		'week1', // - WEEK 1
		'week2', // - WEEK 2
		'week3', // - WEEK 3
		'week4', // - WEEK 4
		'week5', // - WEEK 5
		'week6', // - WEEK 6
	];

	/**
	 * + STORY MODE
	 */
	public static final lockedWeeks = [
		-1 // - NO LOCKED WEEKS
	];
}
