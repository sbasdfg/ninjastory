package entities.Sensors 
{
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.Contacts.b2Contact;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import entities.Player2;
	import org.osflash.signals.natives.base.SignalBitmap;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class InfoPoint extends Box2DPhysicsObject 
	{
		
		public var onContact:Signal;
		
		protected var _target:* = Player2
		protected var _contact:IBox2DPhysicsObject;
		
		
		public function InfoPoint(name:String, params:Object = null) 
		{
			_beginContactCallEnabled = true;
			
			super (name, params);
			
			onContact = new Signal();
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
		
		override public function destroy():void
		{
			onContact.removeAll();
			
			super.destroy();
		}
		
		override public function handleBeginContact(contact:b2Contact):void
		{
			_contact = Box2DUtils.CollisionGetOther(this, contact);
			
			if (_target && _contact is _target)
			{
				onContact.dispatch();
			}
		}
		
	}

}