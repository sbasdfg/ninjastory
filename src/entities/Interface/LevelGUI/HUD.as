package entities.Interface.LevelGUI 
{
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class HUD extends Sprite 
	{
		
		public var hudBorder:HUDBorder = new HUDBorder();
		public var hudCornerUL:HUDCorner = new HUDCorner("upleft");
		public var hudCornerUR:HUDCorner = new HUDCorner("upright");
		public var hudCornerDL:HUDCorner = new HUDCorner("downleft");
		public var hudCornerDR:HUDCorner = new HUDCorner("downright");
		public var hudSkillbar:HUDSkillBar = new HUDSkillBar();
		public var enemyInfo:HUDInfoBar = new HUDInfoBar(true);
		public var playerInfo:HUDInfoBar = new HUDInfoBar(false);
		public var hudmarque:HUDMarque = new HUDMarque();
		
		public var playerHP:int = 0;
		public var playerMaxHP:int = Globals.playerHP;
		
		public var enemyName:String = "null";
		public var enemyHP:int;
		public var enemyMaxHP:int;
		
		public function HUD() 
		{
			addChild(hudBorder);
			addChild(hudmarque);
			addChild(enemyInfo);
			addChild(playerInfo);
			addChild(hudSkillbar);
			addChild(hudCornerDL);
			addChild(hudCornerDR);
			addChild(hudCornerUL);
			addChild(hudCornerUR);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		public function update(e:Event):void
		{
			playerInfo.updateText(playerHP);
			if (enemyName != "null")
			{
				enemyInfo.updateText(enemyHP, enemyMaxHP, enemyName);
				enemyName = "null";
			}
		}
		
		public function marqueUpdate(message:String):void
		{
			hudmarque.addMessage(message);
		}
		
	}

}