package;

import PlayState.notesDir;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

/**
 * TODO: Rework all characters
 */
class Character extends flixel.FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var characterArgs:Array<String> = [];
	public var characterAttribs:Array<CharacterAttrib> = [];
	public var altNoteAnim = '';
	public var altAnim = '';
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public function new(x:Float, y:Float, character:String, _characterArgs:Array<String>, _isPlayer:Bool = false)
	{
		super(x, y);

		characterArgs = _characterArgs;

		animOffsets = new Map<String, Array<Dynamic>>();

		curCharacter = character;
		isPlayer = _isPlayer;

		antialiasing = getPref('antialiasing');

		if (!getPref('ultra-optimize'))
			switch (curCharacter)
			{
				case 'bf':
					frames = getCharacterFrames('BOYFRIEND_ASSETS/BOYFRIEND', 'shared');

					addAnim('BF idle dance', {
						name: 'idle',
						offsets: [-5, 0],
						playerOffsets: [-5, 0],
					});

					var singOffsets = [[-38, -6], [-40, -50], [1, 27], [32, -7]];
					var singOffsetsPlayer = [[12, -6], [-10, -50], [-29, 27], [-38, -7]];
					for (dir in 0...4)
						addAnim('BF NOTE ${notesDir[dir]}0', {
							name: 'sing${notesDir[dir]}',
							offsets: singOffsets[dir],
							playerOffsets: singOffsetsPlayer[dir],
						});

					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);

					animation.addByPrefix('firstDeath', "BF dies", 24, false);
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

					animation.addByPrefix('scared', 'BF idle shaking', 24);

					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
					addOffset('firstDeath', 37, 11);
					addOffset('deathLoop', 37, 5);
					addOffset('deathConfirm', 37, 69);
					addOffset('scared', -4);

					playAnim('idle');

					flipX = true;
				case 'gf':
					frames = getCharacterFrames('GF_assets');
					animation.addByPrefix('cheer', 'GF Cheer', 24, false);
					animation.addByPrefix('singLEFT', 'GF left note', 24, false);
					animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
					animation.addByPrefix('singUP', 'GF Up Note', 24, false);
					animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
					animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
					animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
					animation.addByPrefix('scared', 'GF FEAR', 24);

					addOffset('cheer');
					addOffset('sad', -2, -2);
					addOffset('danceLeft', 0, -9);
					addOffset('danceRight', 0, -9);

					addOffset("singUP", 0, 4);
					addOffset("singRIGHT", 0, -20);
					addOffset("singLEFT", 0, -19);
					addOffset("singDOWN", 0, -20);
					addOffset('hairBlow', 45, -8);
					addOffset('hairFall', 0, -9);

					addOffset('scared', -2, -17);

					playAnim('danceRight');

				case 'spooky':
					frames = getCharacterFrames('spooky_kids_assets', 'week2');
					animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
					animation.addByPrefix('singLEFT', 'note sing left', 24, false);
					animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
					animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
					animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

					addOffset('danceLeft');
					addOffset('danceRight');

					addOffset("singUP", -20, 26);
					addOffset("singRIGHT", -130, -14);
					addOffset("singLEFT", 130, -10);
					addOffset("singDOWN", -50, -130);

					playAnim('danceRight');
				case 'monster':
					frames = getCharacterFrames('Monster_Assets', 'week2');
					animation.addByPrefix('idle', 'monster idle', 24, false);
					animation.addByPrefix('singUP', 'monster up note', 24, false);
					animation.addByPrefix('singDOWN', 'monster down', 24, false);
					animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
					animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

					addOffset('idle');
					addOffset("singUP", -20, 50);
					addOffset("singRIGHT", -51);
					addOffset("singLEFT", -30);
					addOffset("singDOWN", -30, -40);
					playAnim('idle');

				case 'pico':
					frames = getCharacterFrames('Pico_FNF_assetss', 'week3');

					addAnim('Pico Idle Dance', {
						name: 'idle',
					});

					var singOffsets = [[57, 0], [192, -83], [-36, 20], [-86, -11]];
					for (dir in 0...4)
						addAnim('Pico Note ${notesDir[dir]}0', {
							name: 'sing${notesDir[dir]}',
							offsets: singOffsets[dir],
						});

					playAnim('idle');

					flipX = true;

				case 'bf-car':
					var tex = getCharacterFrames('bfCar', 'week4');
					frames = tex;
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					playAnim('idle');

					flipX = true;
				case 'gf-car':
					frames = getCharacterFrames('gfCar', 'week4');
					animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24,
						false);
					animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "",
						24, false);

					addOffset('danceLeft', 0);
					addOffset('danceRight', 0);

					playAnim('danceRight');
				case 'mom-car':
					frames = getCharacterFrames('momCar', 'week4');

					animation.addByPrefix('idle', "Mom Idle", 24, false);
					animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
					animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
					animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
					// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
					// CUZ DAVE IS DUMB!
					animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

					addOffset('idle');
					addOffset("singUP", 14, 71);
					addOffset("singRIGHT", 10, -60);
					addOffset("singLEFT", 250, -23);
					addOffset("singDOWN", 20, -160);

					playAnim('idle');
				case 'mom':
					frames = getCharacterFrames('Mom_Assets', 'week4');

					animation.addByPrefix('idle', "Mom Idle", 24, false);
					animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
					animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
					animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
					// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
					// CUZ DAVE IS DUMB!
					animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

					addOffset('idle');
					addOffset("singUP", 14, 71);
					addOffset("singRIGHT", 10, -60);
					addOffset("singLEFT", 250, -23);
					addOffset("singDOWN", 20, -160);

					playAnim('idle');

				case 'bf-christmas':
					var tex = getCharacterFrames('christmas/bfChristmas', 'week5');
					frames = tex;
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);

					playAnim('idle');

					flipX = true;
				case 'gf-christmas':
					frames = getCharacterFrames('christmas/gfChristmas', 'week5');
					animation.addByPrefix('cheer', 'GF Cheer', 24, false);
					animation.addByPrefix('singLEFT', 'GF left note', 24, false);
					animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
					animation.addByPrefix('singUP', 'GF Up Note', 24, false);
					animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
					animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
					animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
					animation.addByPrefix('scared', 'GF FEAR', 24);

					addOffset('cheer');
					addOffset('sad', -2, -2);
					addOffset('danceLeft', 0, -9);
					addOffset('danceRight', 0, -9);

					addOffset("singUP", 0, 4);
					addOffset("singRIGHT", 0, -20);
					addOffset("singLEFT", 0, -19);
					addOffset("singDOWN", 0, -20);
					addOffset('hairBlow', 45, -8);
					addOffset('hairFall', 0, -9);

					addOffset('scared', -2, -17);

					playAnim('danceRight');
				case 'parents-christmas':
					frames = getCharacterFrames('christmas/mom_dad_christmas_assets', 'week5');
					animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
					animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
					animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
					animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
					animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

					animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

					animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
					animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
					animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

					addOffset('singRIGHT-alt', -1, -24);
					addOffset('singDOWN', -39, -24);
					addOffset('singLEFT-alt', -30, 15);
					addOffset('singUP', -43, 25);
					addOffset('idle', 0, 0);
					addOffset('singDOWN-alt', -30, -27);
					addOffset('singRIGHT', 0, -20);
					addOffset('singLEFT', -28, 20);
					addOffset('singUP-alt', -47, 24);

					playAnim('idle');
				case 'monster-christmas':
					frames = getCharacterFrames('christmas/monsterChristmas', 'week5');
					animation.addByPrefix('idle', 'monster idle', 24, false);
					animation.addByPrefix('singUP', 'monster up note', 24, false);
					animation.addByPrefix('singDOWN', 'monster down', 24, false);
					animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
					animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

					addOffset('idle');
					addOffset("singUP", -20, 50);
					addOffset("singRIGHT", -51);
					addOffset("singLEFT", -30);
					addOffset("singDOWN", -40, -94);
					playAnim('idle');

				case 'bf-pixel':
					frames = getCharacterFrames('weeb/bfPixel', 'week6');
					animation.addByPrefix('idle', 'BF IDLE', 24, false);
					animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
					animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
					animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
					animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

					addOffset('idle');
					addOffset("singUP");
					addOffset("singRIGHT");
					addOffset("singLEFT");
					addOffset("singDOWN");
					addOffset("singUPmiss");
					addOffset("singRIGHTmiss");
					addOffset("singLEFTmiss");
					addOffset("singDOWNmiss");

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					playAnim('idle');

					width -= 100;
					height -= 100;

					antialiasing = false;

					flipX = true;
				case 'bf-pixel-dead':
					frames = getCharacterFrames('weeb/bfPixelsDEAD', 'week6');
					animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
					animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
					animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
					animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
					animation.play('firstDeath');

					addOffset('firstDeath');
					addOffset('deathLoop', -37);
					addOffset('deathConfirm', -37);
					playAnim('firstDeath');
					// pixel bullshit
					setGraphicSize(Std.int(width * 6));
					updateHitbox();
					antialiasing = false;
					flipX = true;
				case 'gf-pixel':
					frames = getCharacterFrames('weeb/gfPixel', 'week6');
					animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
					animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

					addOffset('danceLeft', 0);
					addOffset('danceRight', 0);

					playAnim('danceRight');

					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
					antialiasing = false;
				case 'senpai':
					frames = getCharacterFrames('weeb/senpai', 'week6');
					animation.addByPrefix('idle', 'Senpai Idle', 24, false);
					animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
					animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
					animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

					addOffset('idle');
					addOffset("singUP", 5, 37);
					addOffset("singRIGHT");
					addOffset("singLEFT", 40);
					addOffset("singDOWN", 14);

					playAnim('idle');

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					antialiasing = false;
				case 'senpai-angry':
					frames = getCharacterFrames('weeb/senpai', 'week6');
					animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
					animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
					animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
					animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

					addOffset('idle');
					addOffset("singUP", 5, 37);
					addOffset("singRIGHT");
					addOffset("singLEFT", 40);
					addOffset("singDOWN", 14);
					playAnim('idle');

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					antialiasing = false;
				case 'spirit':
					frames = Paths.getPackerAtlas('weeb/spirit', 'week6');
					animation.addByPrefix('idle', "idle spirit_", 24, false);
					animation.addByPrefix('singUP', "up_", 24, false);
					animation.addByPrefix('singRIGHT', "right_", 24, false);
					animation.addByPrefix('singLEFT', "left_", 24, false);
					animation.addByPrefix('singDOWN', "spirit down_", 24, false);

					addOffset('idle', -220, -280);
					addOffset('singUP', -220, -240);
					addOffset("singRIGHT", -220, -280);
					addOffset("singLEFT", -200, -280);
					addOffset("singDOWN", 170, 110);

					setGraphicSize(Std.int(width * 6));
					updateHitbox();

					playAnim('idle');

					antialiasing = false;
			}

		if (frames == null)
		{
			if (curCharacter != 'dad' && !getPref('ultra-optimize'))
				trace('failed to load \'$curCharacter\' character, loading \'dad\'');

			curCharacter = 'dad';
			frames = getCharacterFrames('DADDY_DEAREST');
			addAnim('Dad idle dance', {name: 'idle'});

			var singOffsets = [[-6, 10], [-3, -31], [-7, 51], [-5, 27]];
			for (dir in 0...4)
				addAnim('Dad Sing Note ${notesDir[dir]}', {name: 'sing${notesDir[dir]}', offsets: singOffsets[dir]});

			playAnim('idle');
		}
		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	function addAnim(animOnXML:String, animClass:Anims.Anim)
	{
		animClass = Anims.animFilter(animClass);
		if (animClass.useIndices)
			animation.addByIndices(animClass.name, animOnXML, animClass.indices, '', 24, animClass.loop);
		else
			animation.addByPrefix(animClass.name, animOnXML, animClass.frameRate, animClass.loop);

		if (!isPlayer)
			addOffset(animClass.name, animClass.offsets[0], animClass.offsets[1]);
		else
			addOffset(animClass.name, animClass.playerOffsets[0], animClass.playerOffsets[1]);
	}

	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-christmas':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-car':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName + altAnim, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function sing(daNote:Note, ?playState:PlayState)
	{
		playAnim('sing${notesDir[daNote.noteData]}$altNoteAnim', !daNote.isSustainNote);
		// true -> !daNote.isSustainNote since character shakes with double notes with trail

		if (playState != null)
		{
			switch (curCharacter)
			{
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];

	private static function joinFrames(spriteArray:Array<String>, ?library:String):FlxAtlasFrames
	{
		var framesArray:Array<FlxAtlasFrames> = [];
		var returnFrames = Paths.getSparrowAtlas(spriteArray[0], library);
		spriteArray.remove(spriteArray[0]);
		for (sprite in spriteArray)
			framesArray.push(Paths.getSparrowAtlas(sprite, library));

		for (sprite in framesArray)
		{
			for (frame in sprite.frames)
				returnFrames.pushFrame(frame);
		}

		return returnFrames;
	}

	private function getCharacterFrames(key:String, ?library:String):FlxAtlasFrames
	{
		var spriteName = [key];
		for (i in characterArgs)
			spriteName.push('${spriteName[0]}_${i}');

		if (spriteName.contains('DEAD'))
			spriteName = ['${key}_DEAD'];

		return joinFrames(spriteName, library);
	}
}

enum CharacterAttrib
{
	PIXEL;
	USE_DANCE_DIRS;
	HAS_DEAD;
}
