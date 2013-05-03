package  
{
	import citrus.core.starling.StarlingState;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.physics.box2d.Box2D;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Level extends StarlingState 
	{
		
		public function Level() 
		{
			super();
		}
		
		override public function initialize():void
		{
			super.initialize();
			var box2d:Box2D = new Box2D("box2d");
			box2d.visible = true;
			add(box2d);
			
			var player:Hero = new Hero("player", { x:50, y:50 } );
			add(player);
		}
		
	}

}