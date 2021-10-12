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

class Weeks
{
	public static var librariesNames = ['tutorial', 'week1', 'week2', 'week3', 'week4', 'week5', 'week6'];
	public static var weeksNames = [
		'How To Funk',
		'Daddy Dearest',
		'Spooky Month!',
		'Go Pico!, yeah! yeah!',
		'Mommy Must Murder',
		'Red Snow',
		'dating simulator ft. moawling'
	];
	public static var weeksSongs = [
		['Tutorial'],
		['Bopeebo', 'Fresh', 'Dadbattle'],
		['Spookeez', 'South', "Monster"],
		['Pico', 'Philly', "Blammed"],
		['Satin-Panties', "High", "Milf"],
		['Cocoa', 'Eggnog', 'Winter-Horrorland'],
		['Senpai', 'Roses', 'Thorns']
	];
	public static var weeksFiles = ['tutorial', 'week1', 'week2', 'week3', 'week4', 'week5', 'week6'];
	public static var weeksCharacters = ['gf', 'dad', 'spooky', 'pico', 'mom', 'parents-christmas', 'senpai'];
	public static var weeksColors = [-7179779, -7179779, -14535868, -7072173, -223529, -6237697, -34625, -608764];
	public static var lockedWeeks = [-1];
}
