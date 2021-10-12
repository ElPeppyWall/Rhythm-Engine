package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var scoreBG:FlxSprite;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var coolColors = [-7179779, -7179779, -14535868, -7072173, -223529, -6237697, -34625, -608764];
	var bg = new MenuBG(DESAT);

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("In the Menus", null);
		#end

		addWeek(['Tutorial'], 0, ['gf']);
		addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad']);
		addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky', 'spooky', 'monster']);
		addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico']);
		addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);
		addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);
		addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit']);

		bg.color = -7179779;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			// songText.type = [IGNORE_X];
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			songText.x -= 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
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

		changeSelection();
		changeDiff();

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

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

	function positionHighscore():Void
	{
		scoreText.x = (FlxG.width - scoreText.width - 6);
		scoreBG.scale.x = (FlxG.width - scoreText.x + 6);
		scoreBG.x = (FlxG.width - scoreBG.scale.x / 2);
		diffText.x = (Std.int(scoreBG.x + scoreBG.width / 2));
		var a = diffText;
		a.x = (a.x - diffText.width / 2);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.4);

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		changeBGColor();
		scoreText.text = "PERSONAL BEST:" + lerpScore;
		positionHighscore();
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
			switchState(MainMenuState);

		if (accepted)
		{
			var poop:String = CoolUtil.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(PlayState);
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

		diffText.text = '< ${CoolUtil.getDiffByIndex(curDifficulty)} >';
		FlxTween.color(diffText, CoolUtil.camLerpShit(.45), diffText.color, CoolUtil.difficultyColorArray[curDifficulty]);
		positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		#if false
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	private function changeBGColor():Void
	{
		var a:Dynamic = bg;
		var b = bg.color;
		var c = coolColors[songs[curSelected].week % coolColors.length];
		var d = CoolUtil.camLerpShit(0.045);
		var e = Std.int((((c >> 16) & 255) - ((b >> 16) & 255)) * d + ((b >> 16) & 255));
		var f = Std.int((((c >> 8) & 255) - ((b >> 8) & 255)) * d + ((b >> 8) & 255));
		var h = Std.int(((c & 255) - (b & 255)) * d + (b & 255));
		c = Std.int((((c >> 24) & 255) - ((b >> 24) & 255)) * d + ((b >> 24) & 255));
		b = new FlxColor();
		b = (((b & -16711681) | ((255 < e ? 255 : 0 > e ? 0 : e) << 16)) & -65281) | ((255 < f ? 255 : 0 > f ? 0 : f) << 8);
		b &= -256;
		b |= 255 < h ? 255 : 0 > h ? 0 : h;
		b &= 16777215;
		b |= (255 < c ? 255 : 0 > c ? 0 : c) << 24;
		a.set_color(b);
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
