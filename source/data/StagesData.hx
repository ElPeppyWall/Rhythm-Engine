package;

class StagesData
{
	public static var stageNames:Map<String, String>;

	public static function init():Void
	{
		stageNames = new Map<String, String>();

		stageNames['stage'] = 'on The Stage';
		stageNames['spooky'] = 'in the Girlfriend’s House';
		stageNames['philly'] = 'on Newgrounds Office Roof';
		stageNames['limo'] = 'on The Limousine';
		stageNames['mall'] = 'in The Mall';
		stageNames['mallEvil'] = 'in The Mall??';
		stageNames['school'] = 'inside The Dating Simulator';
	}
}
