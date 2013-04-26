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
	public class HUDSkillBar extends Sprite 
	{
		
		public function HUDSkillBar() 
		{
			addEventListener(Event.ADDED_TO_STAGE, initSkillBar);
		}
		
		protected function initSkillBar(e:Event):void
		{
			var barbmp:Bitmap = new Assets.HUDSKILLBAR();
			var bartex:Texture = Texture.fromBitmap(barbmp);
			var barImage:Image = new Image(bartex);
			
			barImage.x = 50;
			barImage.y = stage.stageHeight - 60;
			
			addChild(barImage);
		}
	}

}