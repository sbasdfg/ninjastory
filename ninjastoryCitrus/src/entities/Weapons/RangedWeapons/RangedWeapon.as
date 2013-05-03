package entities.Weapons.RangedWeapons 
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2FilterData;
	import entities.Enemy.Enemy;
	import entities.Player2;

	import citrus.objects.Box2DPhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;

	import org.osflash.signals.Signal;

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.utils.getDefinitionByName;

	/**
	 * A missile is an object that moves at a particular trajectory and speed, and explodes when it comes into contact with something.
	 * Often you will want the object that it exploded on to also die (or at least get hurt), such as a hero or an enemy.
	 * Since the missile can potentially be used for any purpose, by default the missiles do not do any damage or kill the object that
	 * they collide with. You will have to handle this manually using the onExplode() handler.
	 * 
	 * <ul>Properties:
	 * <li>angle - In degrees, the angle that the missile will fire at. Right is zero degrees, going clockwise.</li>
	 * <li>speed - The speed that the missile moves at.</li>
	 * <li>fuseDuration - In milliseconds, how long the missile lasts before it explodes if it doesn't touch anything.</li>
	 * <li>explodeDuration - In milliseconds, how long the explode animation lasts before the missile object is destroyed.</li></ul>
	 * 
	 * <ul>Events:
	 * <li>onExplode - Dispatched when the missile explodes. Passes two parameters:
	 * 		1. The Missile (Missile)
	 * 		2. The Object it exploded on (Box2DPhysicsObject)</li></ul>
	 */
	public class RangedWeapon extends Box2DPhysicsObject 
	{
		/**
		 * The speed that the missile moves at.
		 */
		[Inspectable(defaultValue="2")]
		public var speed:Number = 2;

		/**
		 * In degrees, the angle that the missile will fire at. Right is zero degrees, going clockwise.
		 */
		[Inspectable(defaultValue="0")]
		public var angle:Number = 0;

		/**
		 * In milliseconds, how long the explode animation lasts before the missile object is destroyed.
		 */
		[Inspectable(defaultValue="1000")]
		public var explodeDuration:Number = 1000;

		/**
		 * In milliseconds, how long the missile lasts before it explodes if it doesn't touch anything.
		 */
		[Inspectable(defaultValue="10000")]
		public var fuseDuration:Number = 10000;
		
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
		protected var _fuseDurationTimeoutID:uint = 0;
		protected var _contact:IBox2DPhysicsObject;
		protected var _damage:int;
		protected var _enemyWeapon:Boolean = false
		
		/**
		 * Like in the Player class, Weapons look for an "Enemy" that they are supposed to hit.  If they come in contact with
		 * their "Enemy" class they will do damage.  If they collide with a wall, they will simply destroy themselves.
		 */
		protected var _enemyClass:Class;

		public function RangedWeapon(name:String, direction:String, enemyWeapon:Boolean = false, params:Object = null)
		{
			updateCallEnabled = true;
			_beginContactCallEnabled = true;
			_enemyWeapon = enemyWeapon
			_direction = direction;

			if (enemyWeapon) _enemyClass = Player2;
			else _enemyClass = Enemy;			
			
			super("rangedweapon", params);

			onExplode = new Signal(RangedWeapon, Box2DPhysicsObject);
			_inverted = speed < 0;
			//trace(speed);
			_velocity = new b2Vec2(speed, 0);
			_velocity = Box2DUtils.Rotateb2Vec2(_velocity, angle * Math.PI / 180);
			if (direction == "down") _velocity.y = speed;
			if (direction == "up") _velocity.y = -speed;
			}
		
		[Inspectable(defaultValue="citrus.objects.platformer.box2d.Enemy",type="String")]
		public function set enemyClass(value:*):void
		{
			if (value is String)
				_enemyClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
				_enemyClass = value;
				
				
		}

		override public function addPhysics():void {
			super.addPhysics();

			_fuseDurationTimeoutID = setTimeout(killMissile, fuseDuration);
			_body.SetLinearVelocity(_velocity);

			updateAnimation();
		}

		override public function destroy():void
		{
			onExplode.removeAll();
			clearTimeout(_explodeTimeoutID);
			clearTimeout(_fuseDurationTimeoutID);

			super.destroy();
		}

		override public function get rotation():Number
		{
			return angle;
		}

		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);

			var removeGravity:b2Vec2 = new b2Vec2();
			removeGravity.Subtract(_box2D.world.GetGravity());
			removeGravity.Multiply(body.GetMass());

			_body.ApplyForce(removeGravity, _body.GetWorldCenter());

			if (_exploded)
				_body.SetLinearVelocity(new b2Vec2());
			else
				_body.SetLinearVelocity(_velocity);
			
			angle += rotateSpeed * Math.PI / 180;
				
			if (rotateSpeed > 0) _body.SetAngle(angle);
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

			clearTimeout(_fuseDurationTimeoutID);
			_explodeTimeoutID = setTimeout(killMissile, explodeDuration);
		}
		
		public function getDamage():int
		{
			return _damage;
		}

		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.bullet = true;
			_bodyDef.angle = angle * Math.PI / 180;
			_bodyDef.fixedRotation = true;
			_bodyDef.allowSleep = false;
		}

		override public function handleBeginContact(contact:b2Contact):void {

			_contact = Box2DUtils.CollisionGetOther(this, contact);

			if (!contact.GetFixtureA().IsSensor() && !contact.GetFixtureB().IsSensor())
			{
				if (_enemyClass && _contact is _enemyClass)
				{
					explode();
				}
				else killMissile();
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