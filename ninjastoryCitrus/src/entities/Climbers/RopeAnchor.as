package entities.Climbers 
{
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import citrus.objects.Box2DPhysicsObject;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class RopeAnchor extends Box2DPhysicsObject 
	{
		
		public function RopeAnchor(name:String, params:Object = null) 
		{
			updateCallEnabled = true;
			
			super(name, params);
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			
			_bodyDef.type = b2Body.b2_staticBody;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			
			_fixtureDef.isSensor = true;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			//trace(name, y);
		}
	}

}