package;

import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

using StringTools;

#if desktop
import Discord.DiscordClient;
#end

class PlayState extends MusicBeatState
{
	public static var notesColor = ['purple', 'blue', 'green', 'red'];
	public static var notesDir = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var instance:PlayState;
	public static var deathCounter:Int;
	public static var practiceMode:Bool = false;

	var vocals:FlxSound;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<BabyArrow>;
	private var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	private var playerStrums:FlxTypedGroup<BabyArrow>;

	private var camZooming:Bool = false;

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camGame:FlxCamera;
	private var camHUD:FlxCamera;
	private var camNOTES:FlxCamera;
	private var camPAUSE:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var trainSound:FlxSound;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	override public function create()
	{
		instance = this;
		curStage = '';
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camNOTES = new FlxCamera();
		camNOTES.bgColor.alpha = 0;
		camPAUSE = new FlxCamera();
		camPAUSE.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camNOTES);
		FlxG.cameras.add(camPAUSE);
		FlxCamera.defaultCameras = [camGame];

		if (getPref("background-opacity") > 0)
		{
			var backgroundShit = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			backgroundShit.alpha = getPref("background-opacity");
			backgroundShit.cameras = [camHUD];
			add(backgroundShit);
		}

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var noteSplash = new NoteSplash(100, 100, 0);
		noteSplash.alpha = 0;
		grpNoteSplashes.add(noteSplash);
		new FlxTimer().start(1.5, function(tmr:FlxTimer) // before this code exists, a random splash spawned in the air
		{
			noteSplash.alpha = .6;
		});
		if (getPref('downscroll'))
			camNOTES.flashSprite.scaleY = -1;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		if (!getPref('ultra-optimize'))
			loadStage();

		switch (curStage)
		{
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		gf = new Character(400, 130, gfVersion, gfArgs, false);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, dadVersion, dadArgs, false);

		boyfriend = new Boyfriend(770, 450, bfVersion, bfArgs);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		if (!getPref('ultra-optimize'))
		{
			switch (SONG.player2)
			{
				case 'gf':
					dad.setPosition(gf.x, gf.y);
					gf.visible = false;
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
					}

				case "spooky":
					dad.y += 200;
				case "monster":
					dad.y += 100;
				case 'monster-christmas':
					dad.y += 130;
				case 'dad':
					camPos.x += 400;
				case 'pico':
					camPos.x += 600;
					dad.y += 300;
				case 'parents-christmas':
					dad.x -= 500;
				case 'senpai':
					dad.x += 150;
					dad.y += 360;
					camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
				case 'senpai-angry':
					dad.x += 150;
					dad.y += 360;
					camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
				case 'spirit':
					dad.x -= 150;
					dad.y += 100;
					camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			}

			// REPOSITIONING PER STAGE
			switch (curStage)
			{
				case 'limo':
					boyfriend.y -= 220;
					boyfriend.x += 260;

				case 'mall':
					boyfriend.x += 200;

				case 'mallEvil':
					boyfriend.x += 320;
					dad.y -= 80;
				case 'school':
					boyfriend.x += 200;
					boyfriend.y += 220;
					gf.x += 180;
					gf.y += 300;
				case 'schoolEvil':
					var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
					add(evilTrail);

					boyfriend.x += 200;
					boyfriend.y += 220;
					gf.x += 180;
					gf.y += 300;
			}

			add(gf);
			funcAfterAddGF();
			add(dad);
			funcAfterAddDAD();
			add(boyfriend);
			funcAfterAddALL();
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<BabyArrow>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<BabyArrow>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(openfl.Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9, Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		if (getPref('downscroll'))
			healthBarBG.y = (0.1 * FlxG.height);
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		add(healthBar);

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);
		var iconP1_Char = !getPref('ultra-optimize') ? boyfriend.curCharacter : SONG.player1;
		var iconP2_Char = !getPref('ultra-optimize') ? dad.curCharacter : SONG.player2;
		iconP1 = new HealthIcon(iconP1_Char, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(iconP2_Char, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		healthBar.createFilledBar(HealthIconsData.getIconColor(iconP2.char), HealthIconsData.getIconColor(iconP1.char));

		grpNoteSplashes.cameras = [camNOTES];
		strumLineNotes.cameras = [camNOTES];
		notes.cameras = [camNOTES];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		if (!getPref('midscroll'))
			generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (swagCounter != 4)
			{
				dad.dance();
				gf.dance();
				boyfriend.dance();
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					ready.cameras = [camHUD];
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					set.cameras = [camHUD];
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					// var go = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					// go.scrollFactor.set();

					// if (curStage.startsWith('school'))
					// 	go.setGraphicSize(Std.int(go.width * daPixelZoom));

					// go.updateHitbox();

					// go.screenCenter();
					// add(go);

					var go = new FlxSprite();
					go.frames = Paths.getSparrowAtlas('go_anim');
					go.animation.addByPrefix('go', 'GO!!', 24, false);
					go.animation.play('go');
					go.cameras = [camHUD];
					go.animation.finishCallback = function(name:String)
					{
						go.destroy();
					};
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					go.scrollFactor.set();
					go.updateHitbox();
					go.screenCenter();
					add(go);
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1]);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] % (4 * 2) >= 4)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2; // general offset
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	private function generateStaticArrows(player:Int, ?style:String):Void
	{
		if (style == null)
			style = Note.getNoteStyle();
		for (i in 0...4)
		{
			var babyArrow = new BabyArrow(strumLine.y, i, style, player, !isStoryMode);

			if (getPref('midscroll'))
				babyArrow.x -= 275;
			if (player == 1)
				playerStrums.add(babyArrow);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		stageUpdate(elapsed);

		if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
			healthBar.createFilledBar(HealthIconsData.getIconColor(iconP2.char), HealthIconsData.getIconColor(iconP1.char));
		}

		super.update(elapsed);

		scoreTxt.text = "Score:" + songScore;
		scoreTxt.screenCenter(X);

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
				switchState(GitarooPause);
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			switchState(ChartingState);
			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(150 + 0.85 * (iconP1.width - 150)));
		iconP2.setGraphicSize(Std.int(150 + 0.85 * (iconP2.width - 150)));
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		iconP1.x = (healthBar.x + (0.01 * healthBar.width * FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) - 26));
		iconP2.x = (healthBar.x + 0.01 * healthBar.width * FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) - (iconP2.width - 26));

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			cameraRightSide = PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection;
			cameraMovement();
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong() == 'fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
			}
		}

		if (curSong() == 'bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0 && !practiceMode)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.mustPress && getPref('midscroll'))
					daNote.alpha = 0;

				var xPoint:Float = 0;
				if (daNote.mustPress)
					xPoint = playerStrums.members[daNote.noteData].x;
				else
					xPoint = strumLineNotes.members[daNote.noteData].x;

				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (.45 * FlxMath.roundDecimal(SONG.speed, 2)));
				daNote.x = xPoint;

				if (daNote.isSustainNote)
					daNote.x += daNote.width / 2 + 20;

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;
					if (!getPref('midscroll') && !daNote.isSustainNote)
					{
						var splash = grpNoteSplashes.recycle(NoteSplash);
						splash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
						grpNoteSplashes.add(splash);
					}
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.y < -daNote.height)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						health -= 0.0475;
						vocals.volume = 0;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	public function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				switchState(StoryMenuState);

				// if ()

				Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
			}
			else
			{
				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(CoolUtil.formatSong(PlayState.storyPlaylist[0].toLowerCase(), storyDifficulty), PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(PlayState);
			}
		}
		else
			switchState(FreeplayState);
	}

	var endingSong:Bool = false;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
		}
		else if (getPref('note-splashes'))
		{
			var splash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
			grpNoteSplashes.add(splash);
		}

		if (!practiceMode)
			songScore += score;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = (FlxG.width * 0.55) - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.cameras = [camHUD];

		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = getPref('antialiasing');
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
		}

		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];
		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = rating.x + (43 * daLoop) - 50;
			numScore.y = rating.y + 100;
			numScore.cameras = [camHUD];

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = getPref('antialiasing');
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;

		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;
		var downP = controls.NOTE_DOWN_P;
		var leftP = controls.NOTE_LEFT_P;

		var upR = controls.NOTE_UP_R;
		var rightR = controls.NOTE_RIGHT_R;
		var downR = controls.NOTE_DOWN_R;
		var leftR = controls.NOTE_LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		if (generatedMusic)
		{
			notes.forEachAlive(function(c:Note)
			{
				if (c.isSustainNote && c.canBeHit && c.mustPress && controlArray[c.noteData])
					goodNoteHit(c);
			});
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (controlArray.contains(true) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!getPref('ghostTapping') && !inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
						noteCheck(controlArray[daNote.noteData], daNote);
					else
					{
						for (coolNote in possibleNotes)
							noteCheck(controlArray[coolNote.noteData], coolNote);
					}
				}
				else // regular notes?
					noteCheck(controlArray[daNote.noteData], daNote);
			}
			else if (!getPref('ghostTapping'))
				badNoteCheck();
		}

		if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();

		playerStrums.forEach(function(spr:BabyArrow)
		{
			switch (spr.ID)
			{
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (leftR)
						spr.animation.play('static');
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (downR)
						spr.animation.play('static');
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (upR)
						spr.animation.play('static');
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (rightR)
						spr.animation.play('static');
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if (!practiceMode)
				songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;
		var downP = controls.NOTE_DOWN_P;
		var leftP = controls.NOTE_LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', !note.isSustainNote);
				case 1:
					boyfriend.playAnim('singDOWN', !note.isSustainNote);
				case 2:
					boyfriend.playAnim('singUP', !note.isSustainNote);
				case 3:
					boyfriend.playAnim('singRIGHT', !note.isSustainNote);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	var startedMoving:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		stageStep();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		stageBeat();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
		}

		if (dad.animation.curAnim.name.startsWith('sing'))
		{
			if (dad.animation.curAnim.finished)
				dad.dance();
		}
		else
			dad.dance();
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (getPref('camera-zoom'))
		{
			if (curSong() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
			boyfriend.dance();

		if (curBeat % 8 == 7 && curSong() == 'bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && curSong() == 'tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();
		}
	}

	var cameraRightSide = false;

	function characterSing(char:Character, daNote:Note, altString:String):Void
	{
		char.playAnim('sing${notesDir[daNote.noteData]}');
	}

	function cameraMovement():Void
	{
		if (camFollow.getPosition() != getCamDadPos() && !cameraRightSide)
		{
			camFollow.setPosition(getCamDadPos().x, getCamDadPos().y);

			if (curSong() == 'tutorial')
				tweenCamIn();
		}
		if (camFollow.getPosition() != getCamBFPos() && cameraRightSide)
		{
			camFollow.setPosition(getCamBFPos().x, getCamBFPos().y);

			if (curSong() == 'tutorial')
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
		}
	}

	function getCamDadPos():FlxPoint
	{
		var camDadPos = new FlxPoint(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
		switch (dad.curCharacter)
		{
			case 'mom':
				camDadPos.y = dad.getMidpoint().y;
				vocals.volume = 1;
			case 'senpai', 'senpai-angry':
				camDadPos.y = dad.getMidpoint().y - 430;
				camDadPos.x = dad.getMidpoint().x - 100;
		}

		return camDadPos;
	}

	function getCamBFPos():FlxPoint
	{
		var camBFPos = new FlxPoint((boyfriend.getMidpoint().x - 100), boyfriend.getMidpoint().y - 100);

		switch (curStage)
		{
			case 'limo':
				camBFPos.x = boyfriend.getMidpoint().x - 300;
			case 'mall':
				camBFPos.y = boyfriend.getMidpoint().y - 200;
			case 'school':
				camBFPos.x = boyfriend.getMidpoint().x - 200;
				camBFPos.y = boyfriend.getMidpoint().y - 200;
			case 'schoolEvil':
				camBFPos.x = boyfriend.getMidpoint().x - 200;
				camBFPos.y = boyfriend.getMidpoint().y - 200;
		}

		return camBFPos;
	}

	var curLight:Int = 0;
	var stageSing = function(PLAYER:String):Void
	{
	};
	var stageBeat = function():Void
	{
	};
	var stageStep = function():Void
	{
	};
	var stageUpdate = function(elapsed:Float):Void
	{
	};

	var gfVersion = 'gf';
	var gfArgs = [];
	var bfVersion = SONG.player1;
	var bfArgs = [];
	var dadVersion = SONG.player2;
	var dadArgs = [];
	var funcAfterAddGF = function():Void
	{
	};
	var funcAfterAddALL = function():Void
	{
	};
	var funcAfterAddDAD = function():Void
	{
	};

	var funcAfterAddStage = function():Void
	{
	};

	function loadStage():Void
	{
		switch (SONG.song.toLowerCase())
		{
			default:
				{
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg = new BGSprite(['stageback', 'shared'], [], -600, -200, .9, .9);
					add(bg);

					var stageFront = new BGSprite(['stagefront', 'shared'], [], -650, 600, .9, .9);
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					add(stageFront);

					var stageCurtains = new BGSprite(['stagecurtains', 'shared'], [], -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					add(stageCurtains);
				}
			case 'spookeez', 'south', 'monster':
				{
					curStage = 'spooky';
					var halloweenBG = new BGSprite(['halloween_bg', 'week2'], [], -200, -90, 1, 1, [
						{
							name: 'halloweem bg0',
							frameRate: 24,
							loop: false,
							offsets: [0, 0],
							playerOffsets: [0, 0],
							useIndices: false,
							indices: [0]
						},
						{
							name: 'halloweem bg lightning strike',
							frameRate: 24,
							loop: false,
							offsets: [0, 0],
							playerOffsets: [0, 0],
							useIndices: false,
							indices: [0]
						}
					]);
					add(halloweenBG);
					stageBeat = function():Void
					{
						if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
						{
							FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
							halloweenBG.animation.play('halloweem bg lightning strike');

							lightningStrikeBeat = curBeat;
							lightningOffset = FlxG.random.int(8, 24);

							boyfriend.playAnim('scared', true);
							gf.playAnim('scared', true);
						}
					};
				}
			case 'pico', 'philly', 'blammed':
				{
					curStage = 'philly';

					var bg = new BGSprite(['philly/sky', 'week3'], [], -100, 0, 0.1, 0.1);
					add(bg);

					var city = new BGSprite(['philly/city', 'week3'], [], -10, 0, 0.3, 0.3);
					city.setGraphicSize(city.width * 0.85);
					add(city);

					var phillyCityLights = new FlxTypedGroup<BGSprite>();
					add(phillyCityLights);

					for (i in 0...5)
					{
						var light = new BGSprite(['philly/win' + i, 'week3'], [], city.x, 0, 0.3, 0.3);
						light.alpha = 0;
						light.setGraphicSize(light.width * 0.85);
						phillyCityLights.add(light);
					}

					var streetBehind = new BGSprite(['philly/behindTrain', 'week3'], [], -40, 50);
					add(streetBehind);

					var phillyTrain = new BGSprite(['philly/train', 'week3'], [], 2000, 360);
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					var street = new BGSprite(['philly/street', 'week3'], [], -40, streetBehind.y);
					add(street);

					stageUpdate = function(elapsed):Void
					{
						if (trainMoving)
						{
							trainFrameTiming += elapsed;

							if (trainFrameTiming >= 1 / 24)
							{
								{
									if (trainSound.time >= 4700)
									{
										startedMoving = true;
										gf.playAnim('hairBlow');
									}

									if (startedMoving)
									{
										phillyTrain.x -= 400;

										if (phillyTrain.x < -2000 && !trainFinishing)
										{
											phillyTrain.x = -1150;
											trainCars -= 1;

											if (trainCars <= 0)
												trainFinishing = true;
										}

										if (phillyTrain.x < -4000 && trainFinishing)
										{
											gf.playAnim('hairFall');
											phillyTrain.x = FlxG.width + 200;
											trainMoving = false;
											// trainSound.stop();
											// trainSound.time = 0;
											trainCars = 8;
											trainFinishing = false;
											startedMoving = false;
										};
									}
								}
								trainFrameTiming = 0;
							}
							phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
						}
					};

					stageBeat = function():Void
					{
						if (!trainMoving)
							trainCooldown += 1;

						if (curBeat % 4 == 0)
						{
							phillyCityLights.forEach(function(light:FlxSprite)
							{
								light.alpha = 0;
							});

							curLight = FlxG.random.int(0, phillyCityLights.length - 1);

							phillyCityLights.members[curLight].alpha = 1;
						}

						if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
						{
							trainCooldown = FlxG.random.int(-4, 0);
							{
								trainMoving = true;
								if (!trainSound.playing)
									trainSound.play(true);
							}
						}
					};
				}
			case 'milf' | 'satin-panties' | 'high':
				{
					curStage = 'limo';
					defaultCamZoom = 0.90;

					var skyBG = new BGSprite(['limo/limoSunset', 'week4'], [], -120, -50, .1, .1);
					add(skyBG);

					var bgLimo = new BGSprite(['limo/bgLimo', 'week4'], [], -200, 480, .4, .4, [
						{
							name: 'background limo pink',
							frameRate: 24,
							loop: true,
							offsets: [0, 0],
							playerOffsets: [0, 0],
							useIndices: false,
							indices: [0]
						}
					]);
					add(bgLimo);

					var grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					var overlayShit = new BGSprite(['limo/limoOverlay', 'week4'], [], -500, -600);
					overlayShit.alpha = 0.5;

					var limo = new BGSprite(['limo/limoDrive', 'week4'], [], -120, 550, 1, 1, [
						{
							name: 'Limo stage',
							frameRate: 24,
							loop: true,
							offsets: [0, 0],
							playerOffsets: [0, 0],
							useIndices: false,
							indices: [0]
						}
					]);

					var fastCar = new BGSprite(['limo/fastCarLol', 'week4'], [], -300, 160);
					fastCar.x = -12600;
					fastCar.y = FlxG.random.int(140, 250);
					fastCar.velocity.x = 0;
					fastCarCanDrive = true;
					add(fastCar);

					gfVersion = 'gf-car';
					funcAfterAddGF = function():Void
					{
						add(limo);
					}
					stageBeat = function():Void
					{
						grpLimoDancers.forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});

						if (FlxG.random.bool(10) && fastCarCanDrive)
						{
							FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

							fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
							fastCarCanDrive = false;
							new FlxTimer().start(2, function(tmr:FlxTimer)
							{
								fastCar.x = -12600;
								fastCar.y = FlxG.random.int(140, 250);
								fastCar.velocity.x = 0;
								fastCarCanDrive = true;
							});
						}
					};
				}
			case 'cocoa' | 'eggnog':
				{
					curStage = 'mall';

					defaultCamZoom = 0.80;

					var bg = new BGSprite(['christmas/bgWalls', 'week5'], [], -1000, -500, .2, .2);
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					add(bg);

					var upperBoppers = new BGSprite(['christmas/upperBop', 'week5'], [], -240, -90, .33, .33, [
						{
							name: 'Upper Crowd Bob',
							frameRate: 24,
							loop: false,
							offsets: [0, 0],
							playerOffsets: [0, 0],
							useIndices: false,
							indices: [0]
						}
					]);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					add(upperBoppers);

					var bgEscalator = new BGSprite(['christmas/bgEscalator', 'week5'], [], -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					add(bgEscalator);

					var tree = new BGSprite(['christmas/christmasTree', 'week5'], [], -370, -250, .4, .4);
					add(tree);

					var bottomBoppers = new BGSprite(['christmas/bottomBop', 'week5'], [], -300, 140, .9, .9, [
						{
							name: 'Bottom Level Boppers',
							frameRate: 24,
							loop: false,
							offsets: [0, 0],
							playerOffsets: [0, 0],
							useIndices: false,
							indices: [0]
						}
					]);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					add(bottomBoppers);

					var fgSnow = new BGSprite(['christmas/fgSnow', 'week5'], [], -600, 700);
					add(fgSnow);

					var santa = new BGSprite(['christmas/santa', 'week5'], [], -840, 150, 1, 1, [
						{
							name: 'santa idle in fear',
							frameRate: 24,
							loop: false,
							offsets: [0, 0],
							playerOffsets: [0, 0],
							useIndices: false,
							indices: [0]
						}
					]);
					add(santa);

					stageBeat = function():Void
					{
						upperBoppers.dance(true);
						bottomBoppers.dance(true);
						santa.dance(true);
					}
				}
			case 'winter-horrorland':
				{
					curStage = 'mallEvil';
					var bg = new BGSprite(['christmas/evilBG', 'week5'], [], -400, -500, .2, .2);
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					add(bg);

					var evilTree = new BGSprite(['christmas/evilTree', 'week5'], [], 300, -300, .2, .2);
					add(evilTree);

					var evilSnow = new BGSprite(["christmas/evilSnow", 'week5'], [], -200, 700);
					add(evilSnow);
				}
			case 'senpai' | 'roses':
				{
					curStage = 'school';

					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (SONG.song.toLowerCase() == 'roses')
					{
						bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}
			case 'thorns':
				{
					curStage = 'schoolEvil';

					var bg:FlxSprite = new FlxSprite(400, 200);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);
				}
		}
	}
}
