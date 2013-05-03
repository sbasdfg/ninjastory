package entities.Weapons.Items 
{
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.Contacts.b2Contact;
	import citrus.physics.PhysicsCollisionCategories;
	import entities.Climbers.Rope;
	import entities.Platforms.Rope;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.getDefinitionByName;
	import org.osflash.signals.Signal;
	
	import Box2D.Common.Math.b2Vec2;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import entities.Enemy.Enemy;
	import entities.Player2;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class LootDrop extends Box2DPhysicsObject 
	{
		
		/**
		 * In degrees, the angle that the missile will fire at. Right is zero degrees, going clockwise.
		 */
		[Inspectable(defaultValue="0")]
		public var angle:Number = 0;
		
		[Inspectable(defaultValue = "0")]
		public var speed:Number = 0;
		
		[Incepctable(defaultValue = "junk")]
		public var lootType:String = "junk";

		public var onPickup:Signal;
		
		protected var _velocity:b2Vec2;
		protected var _contact:IBox2DPhysicsObject;

		
		protected var _playerClass:Class = Player2
		
		public function LootDrop(name:String, params:Object = null) 
		{
			updateCallEnabled = true;
			_beginContactCallEnabled = true;
						
			super(name, params);
			
			onPickup = new Signal(LootDrop, Box2DPhysicsObject);
			
			_velocity = new b2Vec2(speed, 0);

			_velocity = Box2DUtils.Rotateb2Vec2(_velocity, angle);
		}

		override public function addPhysics():void {
			super.addPhysics();

			_body.SetLinearVelocity(_velocity);

			updateAnimation();
		}
		
		override public function destroy():void
		{
			onPickup.removeAll();

			super.destroy();
		}

		override public function get rotation():Number
		{
			return angle;
		}

		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
		}
				
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.angle = angle * Math.PI / 180;
			_bodyDef.fixedRotation = false;
			_bodyDef.allowSleep = false;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			//_fixtureDef.isSensor = true;
			_fixtureDef.friction = 0;
			_fixtureDef.restitution = 0;
		}
		
		override public function handleBeginContact(contact:b2Contact):void
		{

			_contact = Box2DUtils.CollisionGetOther(this, contact);
			trace(contact);

			if (!contact.GetFixtureA().IsSensor() && !contact.GetFixtureB().IsSensor())
			{
				if (_playerClass && _contact is _playerClass)
				{
					onPickup.dispatch(this, _contact);
				}
			}
		}

		protected function updateAnimation():void
		{

		}
	}		
}