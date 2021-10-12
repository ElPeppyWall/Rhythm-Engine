package;

/**
 * `this` is a simplified version of `FlxSprite` especially designed to be a Background Sprite.
 * @param spriteName [0] = SpriteName, [1] = Library
 * @param spriteArgs like pixel or something like that
 * @param x posX
 * @param y posY
 * @param scrollFactorX
 * @param scrollFactorY 
 * @param anims is the array than contains all anims from the .XML file
 * @param loop if the anims are looped
 */
class BGSprite extends flixel.FlxSprite
{
	var anims:Map<String, Anims.Anim> = [];
	var firstAnim:Anims.Anim;
	var spriteArgs:Array<SpriteArgs>;
	var haveAnims:Bool = true;

	public function new(spriteName:Array<String>, _spriteArgs:Array<SpriteArgs>, x:Float = 0, y:Float = 0, scrollFactorX:Float = 1, scrollFactorY:Float = 1,
			?_anims:Array<Anims.Anim>):Void
	{
		super(x, y);
		if (_anims == null)
		{
			haveAnims = false;
			_anims = [];
		}

		spriteArgs = _spriteArgs;
		for (anim in _anims)
			anims[anim.name] = anim;

		firstAnim = _anims[0];

		if (haveAnims)
		{
			frames = Paths.getSparrowAtlas(spriteName[0], spriteName[1]);
			for (anim in anims)
			{
				if (!anim.useIndices)
					animation.addByPrefix(anim.name, anim.name, anim.frameRate, anim.loop);
				else
					animation.addByIndices(anim.name, anim.name, anim.indices, '', anim.frameRate, anim.loop);
			}

			playAnim(firstAnim.name);
		}
		else
		{
			loadGraphic(Paths.image(spriteName[0], spriteName[1]));
			active = false;
		}

		scrollFactor.set(scrollFactorX, scrollFactorY);
		antialiasing = getPref('antialiasing') && !spriteArgs.contains(PIXEL);
	}

	public inline function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);
		offset.set(anims[AnimName].offsets[0], anims[AnimName].offsets[1]);
	}

	public inline function dance(force:Bool = false):Void
		playAnim(firstAnim.name, force);

	override public function setGraphicSize(Width:Dynamic = 0, Height:Dynamic = 0)
	{
		if (Std.isOfType(Width, Float))
			Width = Std.int(Width);
		if (Std.isOfType(Height, Float))
			Height = Std.int(Height);

		super.setGraphicSize(Width, Height);
		if (!spriteArgs.contains(NO_UPDATEHITBOX))
			updateHitbox();
	}
}

enum SpriteArgs
{
	PIXEL;
	NO_UPDATEHITBOX;
}
