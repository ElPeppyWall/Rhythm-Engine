package;

#if (windows && cpp)
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	var yellowBG:FlxSprite;
	var scoreText:FlxText;
	var weeks:Array<WeekData.WeekClass> = [];

	static var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;

	static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		for (weekNum in 0...WeekData.weeksSongs.length)
			weeks.push({
				weekFile: WeekData.weeksFiles[weekNum],
				weekName: WeekData.weeksNames[weekNum],
				weekCharacter: WeekData.weeksCharacters[weekNum],
				weekCharacterBF: Std.isOfType(WeekData.storymodeWeeksOverrideCharacters[weekNum][0],
					String) ? WeekData.storymodeWeeksOverrideCharacters[weekNum][0] : 'bf',
				weekCharacterGF: Std.isOfType(WeekData.storymodeWeeksOverrideCharacters[weekNum][1],
					String) ? WeekData.storymodeWeeksOverrideCharacters[weekNum][1] : 'gf',
				library: WeekData.librariesNames[weekNum],
				weekSongs: WeekData.weeksSongs[weekNum],
				weekColor: WeekData.weeksColors[weekNum]
			});

		MusicManager.checkPlaying();

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if (windows && cpp)
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...weeks.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = getPref('antialiasing');
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (WeekData.lockedWeeks.contains(i))
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = getPref('antialiasing');
				grpLocks.add(lock);
			}
		}

		for (char in 0...3)
		{
			var weekCharacterThing = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, switch (char)
			{
				case 1:
					'bf';
				case 2:
					'gf';
				default:
					'dad';
			});
			weekCharacterThing.y += 70;
			weekCharacterThing.antialiasing = getPref('antialiasing');
			switch (weekCharacterThing.character)
			{
				case 'dad':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();

				case 'bf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
					weekCharacterThing.x -= 80;
				case 'gf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();
			}

			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		changeWeek();
		changeDifficulty(1);
		changeDifficulty(-1);

		super.create();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = CoolUtil.coolLerp(lerpScore, intendedScore, 0.5);

		scoreText.text = "WEEK SCORE:" + Math.round(lerpScore);

		txtWeekTitle.text = weeks[curWeek].weekName;
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		difficultySelectors.visible = !WeekData.lockedWeeks.contains(curWeek);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			var up = false, down = false, left = false, right = false, accept = false;
			#if mobileC
			for (swipe in FlxG.swipes)
			{
				var f = swipe.startPosition.x - swipe.endPosition.x;
				var g = swipe.startPosition.y - swipe.endPosition.y;
				if (25 <= Math.sqrt(f * f + g * g))
				{
					if ((-45 <= swipe.startPosition.angleBetween(swipe.endPosition)
						&& 45 >= swipe.startPosition.angleBetween(swipe.endPosition)))
						down = true;
					if (-135 < swipe.startPosition.angleBetween(swipe.endPosition)
						&& -45 > swipe.startPosition.angleBetween(swipe.endPosition))
						left = true;
					if (45 < swipe.startPosition.angleBetween(swipe.endPosition)
						&& 135 > swipe.startPosition.angleBetween(swipe.endPosition))
						right = true;
					if (-180 <= swipe.startPosition.angleBetween(swipe.endPosition)
						&& -135 >= swipe.startPosition.angleBetween(swipe.endPosition)
						|| (135 <= swipe.startPosition.angleBetween(swipe.endPosition)
							&& 180 >= swipe.startPosition.angleBetween(swipe.endPosition)))
						up = true;
				}
				else
					accept = true;
			}
			#else
			up = controls.UI_UP_P;
			down = controls.UI_DOWN_P;
			left = controls.UI_LEFT_P;
			right = controls.UI_RIGHT_P;
			accept = controls.ACCEPT;
			#end
			if (!selectedWeek)
			{
				if (up)
					changeWeek(-1);

				if (down)
					changeWeek(1);

				#if !mobileC
				if (controls.UI_RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.UI_LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');
				#end

				if (right)
					changeDifficulty(1);
				if (left)
					changeDifficulty(-1);
			}

			if (accept)
				selectWeek();
		}

		var back:Bool = false;
		#if mobileC
		if (MobileControls.androidBack)
			back = true;
		#else
		back = controls.BACK;
		#end
		if (back && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			switchState(MainMenuState);
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		trace('elpepe');
		grpWeekCharacters.forEach(function(char:MenuCharacter)
		{
			char.animation.play(char.curCharacter, true);
		});
	}

	var movedBack:Bool = false;

	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!WeekData.lockedWeeks.contains(curWeek))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				bfChar.animation.play(bfChar.curCharacter + '-hey');
				stopspamming = true;
			}

			var elpepe:Array<String> = [];
			for (song in weeks[curWeek].weekSongs)
				elpepe.push(song);
			PlayState.storyPlaylist = cast(elpepe);
			selectedWeek = true;

			PlayState.curDifficulty = curDifficulty;

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				PlayState.loadSong(CoolUtil.formatSong(PlayState.storyPlaylist[0].toLowerCase(), curDifficulty), curWeek, flixel.util.FlxColor.WHITE, true,
					true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		if (change != 0)
			sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		if (change != 0)
			sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		if (change != 0)
			FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));
		curWeek += change;

		if (curWeek >= weeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weeks.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && !WeekData.lockedWeeks.contains(curWeek))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		changeDifficulty();
		updateText();
	}

	var enemyChar(get, never):MenuCharacter;

	inline function get_enemyChar():MenuCharacter
		return grpWeekCharacters.members[0];

	var bfChar(get, never):MenuCharacter;

	inline function get_bfChar():MenuCharacter
		return grpWeekCharacters.members[1];

	var gfChar(get, never):MenuCharacter;

	inline function get_gfChar():MenuCharacter
		return grpWeekCharacters.members[2];

	function updateText()
	{
		enemyChar.changeCharacter(weeks[curWeek].weekCharacter);
		bfChar.changeCharacter(weeks[curWeek].weekCharacterBF);
		gfChar.changeCharacter(weeks[curWeek].weekCharacterGF);

		for (char in grpWeekCharacters.members)
			FlxTween.color(char, CoolUtil.camLerpShit(.25), char.color, HealthIconsData.getIconColor(HealthIconsData.getCharIcon(char.curCharacter)));

		// FlxTween.color(yellowBG, CoolUtil.camLerpShit(.25), yellowBG.color, weeks[curWeek].weekColor);

		switch (enemyChar.curCharacter)
		{
			default:
				enemyChar.offset.set(100, 100);
				enemyChar.setGraphicSize(Std.int(enemyChar.width * 1));

			case 'dad':
				enemyChar.offset.set(140, 200);
				enemyChar.setGraphicSize(Std.int(enemyChar.width * 1));

			case 'spooky':
				enemyChar.offset.set(225, 100);
				enemyChar.setGraphicSize(Std.int(enemyChar.width * 1.2));

			case 'pico':
				enemyChar.offset.set(200, 75);
				enemyChar.setGraphicSize(Std.int(enemyChar.width * 1.4));

			case 'mom', 'mom-car':
				enemyChar.offset.set(200, 210);
				enemyChar.setGraphicSize(Std.int(enemyChar.width * 1));

			case 'parents-christmas':
				enemyChar.offset.set(300, 200);
				enemyChar.setGraphicSize(Std.int(enemyChar.width * 2));

			case 'senpai':
				enemyChar.offset.set(130, 0);
				enemyChar.setGraphicSize(Std.int(enemyChar.width * 1.4));
		}

		txtTracklist.text = "Tracks\n";
		var stringThing = weeks[curWeek].weekSongs;

		for (i in stringThing)
		{
			txtTracklist.text += "\n" + i;
		}

		txtTracklist.text += "\n" + stringThing[stringThing.length - 1];

		// txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
