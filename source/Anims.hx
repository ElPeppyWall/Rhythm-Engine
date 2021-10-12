typedef Anim =
{
	var name:String; // Anim Name
	var frameRate:Int; // Anim Frame Rate
	var loop:Bool; // Anim Looped
	var offsets:Array<Int>; // Anim Offsets
	var playerOffsets:Array<Int>; // Anim Player Offsets (only for a Character)
	var useIndices:Bool; // Anim Use Indices
	var indices:Array<Int>; // Anim Indices
}
