package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.Shader;

using StringTools;

#if (windows && cpp)
import Discord.DiscordClient;
#end

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var vocals:FlxSound;
	var songPlaying:Int;

	static var curSelected:Int = 0;
	static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var scoreBG:FlxSprite;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var coolColors = [-7179779, -7179779, -14535868, -7072173, -223529, -6237697, -34625, -608764];
	var bg = new MenuBG(DESAT);
	var fromPlayState:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public function new(?fromPlayState:Bool = false)
	{
		this.fromPlayState = fromPlayState;
		super();
	}

	override function create()
	{
		#if (windows && cpp)
		DiscordClient.changePresence("In the Menus", null);
		#end

		addWeek(['Tutorial'], 0, ['gf']);
		addWeek(['Bopeebo', 'Fresh', 'Dad-Battle'], 1, ['dad']);
		addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky', 'spooky', 'monster']);
		addWeek(['Pico', 'Philly-Nice', 'Blammed'], 3, ['pico']);
		addWeek(['Satin-Panties', 'High', 'M.I.L.F'], 4, ['mom']);
		addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);
		addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit']);
		#if ALLOW_ALONE_FUNKIN
		addWeek(['Alone-Funkin\''], 0, ['']);
		#end

		bg.color = coolColors[0];
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, true);
			songText.targetY = i;
			songText.ID = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			if (songs[i].songCharacter != '')
				add(icon);
		}

		scoreText = new FlxText(0.7 * FlxG.width, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 1.5;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, FlxColor.BLACK);
		scoreBG.antialiasing = (false);
		scoreBG.alpha = (0.6);
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		diffText.borderSize = 1.5;
		add(diffText);

		add(scoreText);

		var playBG = new FlxSprite(0, FlxG.height - 35).makeGraphic(FlxG.width, 35, FlxColor.BLACK);
		playBG.active = false;
		playBG.alpha = 0.6;
		add(playBG);

		var playTxt = new FlxText(0, playBG.y, 0, langString('freeplayPlay'));
		playTxt.active = false;
		playTxt.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		playTxt.screenCenter(X);
		add(playTxt);

		changeSelection();
		changeDiff();

		MusicManager.checkPlaying();
		if (fromPlayState)
			MusicManager.playMainMusic();
		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
		songs.push(new SongMetadata(songName, weekNum, songCharacter));

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	inline function positionHighscore():Void
	{
		scoreText.x = (FlxG.width - scoreText.width - 6);
		scoreBG.scale.x = (FlxG.width - scoreText.x + 6);
		scoreBG.x = (FlxG.width - scoreBG.scale.x / 2);
		diffText.x = (Std.int(scoreBG.x + scoreBG.width / 2));
		diffText.x = (diffText.x - diffText.width / 2);
	}

	var testInt:Int = 0;

	inline function checkTest():Void
	{
		if (checkKey('T'))
			if (testInt == 0)
				testInt = 1;
			else if (testInt == 3)
				PlayState.loadSong('test-normal', 0, FlxColor.WHITE, false);
			else
				testInt = 0;

		if (checkKey('E'))
			if (testInt == 1)
				testInt = 2;
			else
				testInt = 0;

		if (checkKey('S'))
			if (testInt == 2)
				testInt = 3;
			else
				testInt = 0;
	}

	function resyncVocals():Void
	{
		vocals.pause();
		FlxG.sound.music.play();
		vocals.time = FlxG.sound.music.time;
		vocals.play();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		checkTest();
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (vocals != null)
			vocals.volume = FlxG.sound.music.volume;

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		FlxTween.color(bg, CoolUtil.camLerpShit(.25), bg.color, coolColors[songs[curSelected].week]);

		// ninjamuffin color change sucks in windows lol
		// var color2 = coolColors[songs[curSelected].week % coolColors.length];
		// if (bg.color != color2)
		// 	bg.color = FlxColor.interpolate(bg.color, color2, CoolUtil.camLerpShit(.045));

		scoreText.text = '${langString('personalBest')}:' + lerpScore;
		positionHighscore();
		if (FlxG.mouse.wheel != 0)
			changeSelection(FlxG.mouse.wheel == 1 ? -1 : 1);

		for (item in grpSongs)
		{
			if (FlxG.mouse.overlaps(item) && item.ID == curSelected && FlxG.mouse.justPressed)
				enterSong();
		}

		if (checkKey('SPACE') && songPlaying != curSelected)
		{
			if (vocals != null)
			{
				vocals.stop();
				vocals.volume = 0;
				vocals.destroy();
			}
			songPlaying = curSelected;

			FlxG.sound.music.loadEmbedded(Paths.inst(songs[curSelected].songName));
			FlxG.sound.music.volume = 0;
			FlxG.sound.music.play(false, FlxG.sound.music.length / 2);

			vocals = new FlxSound().loadEmbedded(Paths.voices(songs[curSelected].songName));
			vocals.volume = 0;
			vocals.play(false, FlxG.sound.music.time);
			FlxG.sound.list.add(vocals);
			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				resyncVocals();
			});
		}

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxTween.cancelTweensOf(bg);
			switchState(MainMenuState);
		}

		if (controls.ACCEPT)
			enterSong();
	}

	function enterSong():Void
	{
		FlxTween.cancelTweensOf(bg);
		switch (songs[curSelected].songName.toLowerCase())
		{
			#if ALLOW_ALONE_FUNKIN
			case 'alone-funkin\'':
				switchState(AloneFunkinState);
			#end
			default:
				PlayState.loadSong(CoolUtil.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty), songs[curSelected].week,
					coolColors[songs[curSelected].week], false);
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		diffText.text = '< ${CoolUtil.getDiffName(curDifficulty, false)} >';
		FlxTween.color(diffText, CoolUtil.camLerpShit(.45), diffText.color, CoolUtil.difficultyColorArray[curDifficulty]);
		positionHighscore();
	}

	function changeSelection(change:Int = 0, force:Bool = false)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if (force)
			change = curSelected;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0.6;

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
