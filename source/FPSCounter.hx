package;

import GameVars.engineVer;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.text.TextField;
import openfl.text.TextFormat;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	public var bitmap:Bitmap;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("VCR OSD Mono", 14, 0xFFed698a);
		text = "FPS: ";
		width += 200;

		cacheCount = 0;
		currentTime = 0;
		times = [];
		bitmap = ImageWithOutline.renderImage(this, 1, 0x000000, 1, true);
		(cast(Lib.current.getChildAt(0), Main)).addChild(bitmap);
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = 'FPS: $currentFPS\nrhythmEngine v$engineVer';
		}

		visible = true;

		(cast(Lib.current.getChildAt(0), Main)).removeChild(bitmap);

		bitmap = ImageWithOutline.renderImage(this, 2, 0x000000, 1);

		(cast(Lib.current.getChildAt(0), Main)).addChild(bitmap);

		visible = false;

		cacheCount = currentCount;
	}
}
// class BorderShader extends FlxShader
// {
// 	@:glFragmentSource('
// 		#pragma header
// 		void main() {
// 		vec4 color=flixel_texture2D(bitmap,openfl_TextureCoordv);
// 		float borderWidth=.002;
// 		if(color.a==0.) {
// 			if(flixel_texture2D(bitmap,vec2(openfl_TextureCoordv.x+borderWidth,openfl_TextureCoordv.y))==0.
// 			|| flixel_texture2D(bitmap,vec2(openfl_TextureCoordv.x-borderWidth,openfl_TextureCoordv.y))==0.
// 			|| flixel_texture2D(bitmap,vec2(openfl_TextureCoordv.x,openfl_TextureCoordv.y+borderWidth))==0.
// 			|| flixel_texture2D(bitmap,vec2(openfl_TextureCoordv.x,openfl_TextureCoordv.y-borderWidth))==0.){
// 				gl_FragColor=vec4(.7,.1,.5,1.);
// 			} else {
// 				gl_FragColor=color;
// 		}
// 	}else{
// 		gl_FragColor=color;
// 	}
// }
// 	')
// 	public function new()
// 		super();
// }
