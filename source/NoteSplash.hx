package;

import flixel.FlxG;

class NoteSplash extends flixel.FlxSprite
{
	public function new(x:Float, y:Float, noteData:Int)
	{
		super(x, y);
		frames = getSparrowAtlas('noteSplashes', 'shared');
		var downscroll = getPref('downscroll');
		animation.addByPrefix("note0-0", "note impact 1 purple", 24, false, false, downscroll);
		animation.addByPrefix("note0-1", "note impact 2 purple", 24, false, false, downscroll);
		animation.addByPrefix("note1-0", "note impact 1 blue", 24, false, false, downscroll);
		animation.addByPrefix("note1-1", "note impact 2 blue", 24, false, false, downscroll);
		animation.addByPrefix("note2-0", "note impact 1 green", 24, false, false, downscroll);
		animation.addByPrefix("note2-1", "note impact 2 green", 24, false, false, downscroll);
		animation.addByPrefix("note3-0", "note impact 1 red", 24, false, false, downscroll);
		animation.addByPrefix("note3-1", "note impact 2 red", 24, false, false, downscroll);

		antialiasing = getPref('antialiasing');

		setupNoteSplash(x, y, noteData);
	}

	public function setupNoteSplash(x:Float, y:Float, noteData:Int):Void
	{
		setPosition(x, y);
		alpha = .6;
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
}
