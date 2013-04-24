package 
{
	import citrus.core.starling.StarlingCitrusEngine;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import tilemap.TileMap;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Main extends StarlingCitrusEngine
	{
		
		public function Main():void 
		{
			setUpStarling(true);
			state = new TileMap();
			//var loader:Loader = new Loader();
			//loader.load(new URLRequest("assets/xml/levels/maptest.tmx"));
			//loader.contentLoaderInfo.addEventListener(Event.COMPLETE, levelLoaded, false, 0, true);
		}
		
		public function levelLoaded(e:Event):void
		{
			var levelXML:XML = e.target.loader.content;
			trace(levelXML);
			state = new TileMap();
		}

		
	}
	
}