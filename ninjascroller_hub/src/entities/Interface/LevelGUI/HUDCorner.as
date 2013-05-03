package entities.Interface.LevelGUI 
{
	import flash.display.Bitmap;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class HUDCorner extends Sprite 
	{
		
		protected var _posX:Number;
		protected var _posY:Number;
		protected var _position:String;
		
		public function HUDCorner(position:String) 
		{
			_position = position;
			addEventListener(Event.ADDED_TO_STAGE, initCornder);
		}
		
		protected function initCornder(e:Event):void
		{
			switch(_position)
			{
				case "upleft":
					_posX = stage.stageWidth - 60;
					_posY = -60;
					break;
				case "upright":
					_posX = -60;
					_posY = -60;
					break;
				case "downleft":
					_posX = stage.stageWidth - 60;
					_posY = stage.stageHeight - 60;
					break;
				case "downright":
					_posX = -60;
					_posY = stage.stageHeight - 60;
					break;
			}			
			
			var cornerbmp:Bitmap = new Assets.HUDCORNER();
			var cornertex:Texture = Texture.fromBitmap(cornerbmp);
			var cornerImage:Image = new Image(cornertex);
			
			cornerImage.x = _posX;
			cornerImage.y = _posY;
			
			addChild(cornerImage);
		}
		
	}

}