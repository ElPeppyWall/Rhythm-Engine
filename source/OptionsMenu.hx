package;

class OptionsMenu extends MusicBeatState
{
	override function create()
	{
		add(new MenuBG(OPTIONS));
		openSubState(new PreferencesMenu(false));
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (subState == null)
			openSubState(new PreferencesMenu(false));
	}
}
