package;

import flixel.FlxG;
import flixel.system.FlxSound;

class PlayStateUtils
{
	public static function getInst():flixel.system.FlxAssets.FlxSoundAsset
	{
		if (!PlayState.isAloneFunkin)
			return Paths.inst(PlayState.SONG.song);
		else
		{
			var x = PlayState.songPath.split('\\');
			x.remove(x[x.length - 1]);
			return openfl.media.Sound.fromFile(x.join('\\') + '\\Inst.ogg');
		}
	}

	public static function getVocals():FlxSound
	{
		if (PlayState.SONG.needsVoices)
		{
			if (!PlayState.isAloneFunkin)
				return new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			else
			{
				var x = PlayState.songPath.split('\\');
				x.remove(x[x.length - 1]);
				return new FlxSound().loadEmbedded(openfl.media.Sound.fromFile(x.join('\\') + '\\Voices.ogg'));
			}
		}
		else
			return new FlxSound();
	}

	var playState(get, never):PlayState;

	inline function get_playState():PlayState
		return PlayState.instance;
}
