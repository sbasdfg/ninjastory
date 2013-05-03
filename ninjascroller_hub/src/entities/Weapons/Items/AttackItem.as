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
	public class AttackItem extends Box2DPhysicsObject 
	{
		
		/**
		 * In degrees, the angle that the missile will fire at. Right is zero degrees, going clockwise.
		 */
		[Inspectable(defaultValue="0")]
		public var angle:Number = 0;

		[Inspectable(defaultValue="1000")]
		public var explodeDuration:Number = 1000;
		
		[Inspectable(defaultValue = "0")]
		public var speed:Number = 0;

		public var rotateSpeed:Number = 0;

		/**
		 * Dispatched when the missile explodes. Passes two parameters:
		 * 		1. The Missile (Missile)
		 * 		2. The Object it exploded on (Box2DPhysicsObject)
		 */
		public var onExplode:Signal;
		
		protected var _velocity:b2Vec2;
		protected var _direction:String;
		protected var _exploded:Boolean = false;
		protected var _explodeTimeoutID:uint = 0;
		protected var _contact:IBox2DPhysicsObject;
		protected var _enemyWeapon:Boolean;
		
		protected var _initialXVeloctiy:Number = 11;
		protected var _initialYVelocity:Number = -5;
		
		/**
		 * Attack Items look for a particular class to ignore, for player weapons, this will be Player2
		 * For enemy items this will be Enemy
		 */
		
		protected var _ignoreClass:Vector.<Class> = new Vector.<Class>;
		
		public function AttackItem(name:String, direction:String, enemyWeapon:Boolean = false, params:Object = null) 
		{
			updateCallEnabled = true;
			_beginContactCallEnabled = true;
			
			_direction = direction;
			_enemyWeapon = enemyWeapon;
			
			if (_enemyWeapon) _ignoreClass.push(Enemy)
			else _ignoreClass.push(Player2)
			_ignoreClass.push(entities.Climbers.Rope)
			_ignoreClass.push(entities.Platforms.Rope)
			
			super(name, params);
			
			onExplode = new Signal(AttackItem, Box2DPhysicsObject);
			
			_velocity = new b2Vec2(_initialXVeloctiy + speed, 0);
			trace(angle);
			
			_velocity = Box2DUtils.Rotateb2Vec2(_velocity, angle);
			//trace(_velocity.x);
			//_velocity = new b2Vec2(_velocity.x, _initialYVelocity);
		}

		override public function addPhysics():void {
			super.addPhysics();

			_body.SetLinearVelocity(_velocity);

			updateAnimation();
		}
		
		override public function destroy():void
		{
			onExplode.removeAll();
			clearTimeout(_explodeTimeoutID);

			super.destroy();
		}

		override public function get rotation():Number
		{
			return angle;
		}

		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);

			if (_exploded)
				_body.SetLinearVelocity(new b2Vec2());
		}
		
		/**
		 * Explodes the missile, it shouldn't collide with anything anymore.
		 */
		public function explode():void
		{
			if (_exploded)
				return;

			_exploded = true;

			updateAnimation();

			//Not collideable with anything anymore.
			var filter:b2FilterData = new b2FilterData();
			filter.maskBits = PhysicsCollisionCategories.GetNone();
			_fixture.SetFilterData(filter);
			
			onExplode.dispatch(this, _contact);

			_explodeTimeoutID = setTimeout(killMissile, explodeDuration);
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
				for each(var ignclass:Class in _ignoreClass)
				{
					if (ignclass && _contact is ignclass)
					{
						return;
					}
				}
				explode();
			}
		}

		protected function updateAnimation():void
		{
			_animation = _exploded ? "exploded" : "normal";
		}

		protected function killMissile():void
		{
			kill = true;
		}
	}		
}