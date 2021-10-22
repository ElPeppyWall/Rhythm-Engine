package shaderslmfao;

class BuildingShaders
{
	public var shader:BuildingShader;

	public function new()
	{
		shader = new BuildingShader();
		shader.alphaShit.value = [0];
	}

	public function update(a:Float)
		shader.alphaShit.value[0] += a;

	public function reset()
		shader.alphaShit.value[0] = 0;
}
