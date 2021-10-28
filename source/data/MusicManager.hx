package;

import flixel.FlxG;

class MusicManager
{
	public static function playMainMusic(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music('freakyMenu'), volume);
		Conductor.changeBPM(BPMList.mainMenuStateBPM);
	}
}
