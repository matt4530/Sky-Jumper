package 
{
	import com.profusiongames.states.Game;
	import flash.display.Sprite;
	import flash.events.Event;
	import starling.core.Starling;

	/**
	 * ...
	 * @author UnknownGuardian
	 */
	[Frame(factoryClass="Preloader")]
	public class Main extends Sprite 
	{
		private var starlingStage:Starling;
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			starlingStage = new Starling(Game, stage, null, null, "auto", "baseline");
			starlingStage.start();
			starlingStage.showStatsAt("left", "bottom");
		}

	}

}