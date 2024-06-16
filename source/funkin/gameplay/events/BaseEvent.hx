package funkin.gameplay.events;

// TODO: FUTURE EVENT REWRITE SHIT
class BaseEvent
{
	private var data:EventData;

	public function new(data:EventData)
	{
		this.data = data;
	}

	public function onCreate()
	{
	}

	public function update(elapsed:Float)
	{
	}

	public function onEvent(value1:String, value2:String)
	{
	}
}
