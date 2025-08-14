package objects;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	public var isPlayer:Bool = false;
	private var char:String = '';
	public var ox:Int;

	public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public function changeIcon(char:String, ?allowGPU:Bool = true)
	{
		if (this.char != char)
		{
			var name:String = 'icons/' + char;
			if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char;
			if (!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face';
			
			var graphic = Paths.image(name, allowGPU);

			var frameCount:Int = 2; // predeterminado
			if (graphic.width % graphic.height == 0)
			{
				frameCount = Std.int(graphic.width / graphic.height);
				if (frameCount < 2) frameCount = 2; // mínimo 2
			}

			loadGraphic(graphic, true, Math.floor(graphic.width / frameCount), Math.floor(graphic.height));

			iconOffsets[0] = (width - 150) / frameCount;
			iconOffsets[1] = (height - 150) / frameCount;

			updateHitbox();

			animation.add(char, [for (i in 0...frames.frames.length) i], 0, false, isPlayer);
			animation.play(char);

			this.char = char;

			if (char.endsWith('-pixel'))
				antialiasing = false;
			else
				antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String
	{
		return char;
	}
}
