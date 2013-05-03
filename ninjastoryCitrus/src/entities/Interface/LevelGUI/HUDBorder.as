package entities.Interface.LevelGUI 
{
	import flash.display.Bitmap;
	import starling.events.Event;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class HUDBorder extends Sprite
	{
		
		public function HUDBorder() 
		{			
			//var topBar:Image = Image.fromBitmap(new Assets.HUDBARHORZ());
			//var bottomBar:Image = Image.fromBitmap(new Assets.HUDBARHORZ());
			//var leftBar:Image = Image.fromBitmap(new Assets.HUDBARVERT());
			//var rightBar:Image = Image.fromBitmap(new Assets.HUDBARVERT());
			
			addEventListener(Event.ADDED_TO_STAGE, borderInit);
			
		}
		
		private function borderInit(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, borderInit);
			
			var barHorz:Bitmap = new Assets.HUDBARHORZ();
			var barVert:Bitmap = new Assets.HUDBARVERT();
			var barHorzTex:Texture = Texture.fromBitmap(barHorz);
			var barVertText:Texture = Texture.fromBitmap(barVert);
			
			var topBar:Image = new Image(barHorzTex);
			var bottomBar:Image = new Image(barHorzTex);
			var leftBar:Image = new Image(barVertText)
			var rightBar:Image = new Image(barVertText);
			
			topBar.x = 0;
			topBar.y = 0;
			bottomBar.x = 0;
			bottomBar.y = stage.stageHeight - 20;
			leftBar.x = stage.stageWidth - 20;
			leftBar.y = 0;
			rightBar.x = 0;
			rightBar.y = 0;
			
			addChild(topBar);
			addChild(bottomBar);
			addChild(leftBar);
			addChild(rightBar);			
		}
		
	}

}