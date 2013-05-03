package 
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class GameLoader extends Sprite
	{
		
		private var myLoader:Loader = new Loader();
		private var childSWF:Object;
		private var currentArea:String = "hub";
		private var url:URLRequest;
		private var levelType:String = "hub";
		
		public function GameLoader():void 
		{
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			
			switchAreas();
			myLoader.load(url);
			
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, doneLoading);
			myLoader.contentLoaderInfo.addEventListener(Event.INIT, swfInit);
		}
		
		public function swfInit(e:Event):void
		{
			myLoader.contentLoaderInfo.removeEventListener(Event.INIT, swfInit);
			//trace(MovieClip(myLoader.content).playerHP);
			
		}
		
		public function doneLoading(e:Event):void
		{
			trace("Done Loading");
			myLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, doneLoading);
			addChild(myLoader);
			addEventListener(Event.ENTER_FRAME, update);
			
		}
		
		public function update(e:Event):void
		{
			var mySWF:Object = myLoader.content
			var nextArea:String;
			if (mySWF.nextArea) nextArea = mySWF.nextArea;
			else nextArea = "null";
			
			if (nextArea != "null")
			{
				trace(nextArea);
			}
		}
		
		public function switchAreas():void
		{
			switch(currentArea)
			{
				case "hub":
					url = new URLRequest("levels/ninjascrollerhub.swf");
					currentArea = "null";
					break;
			}
		}
		
	}
	
}