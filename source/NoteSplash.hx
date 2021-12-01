package;

import flixel.FlxG;

class NoteSplash extends flixel.FlxSprite
{
	public function new(x:Float, y:Float, noteData:Int)
	{
		super(x, y);
		frames = getSparrowAtlas('noteSplashes', 'shared');
		var downscroll = getPref('downscroll');
		var notesArray = [];
		for (i in PlayState.notesDir)
			notesArray.push(i.toLowerCase());

		for (i in notesArray)
		{
			final index = notesArray.indexOf(i);
			animation.addByPrefix('note$index-0', 'note impact 1 $i', 24, false, false, downscroll);
			animation.addByPrefix('note$index-1', 'note impact 1 $i', 24, false, false, downscroll);
		}

		antialiasing = getPref('antialiasing');

		setupNoteSplash(x, y, noteData);
	}

	public function setupNoteSplash(x:Float, y:Float, noteData:Int):Void
	{
		setPosition(x, y);
		alpha = .8;
		animation.play('note${noteData}-${FlxG.random.int(0, 1)}', true);
		animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		updateHitbox();
		offset.set(.3 * width, .3 * height);
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}

	public static function spawnSplash(playState:PlayState, daNote:Note, player:Int):Void
	{
		if (!getPref('note-splashes') || daNote.isSustainNote)
			return;
		if (player == 2 && getPref('midscroll'))
			return;

		var splash = playState.grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
		playState.grpNoteSplashes.add(splash);
	}
}
