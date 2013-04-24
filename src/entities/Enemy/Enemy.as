package entities.Enemy 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	import citrus.math.MathVector;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.box2d.Box2DShapeMaker;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	import entities.Player2;
	import entities.Weapons.RangedWeapons.RangedWeapon;
	import flash.geom.Point;
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Enemy extends Box2DPhysicsObject 
	{
		
		[Inspectable(defaultValue = "1.3")]
		public var speed:Number = 1.3;
		
		[Inspectable(defaultValue = "3")]
		public var enemyKillVelocity:Number = 3;
		
		[Inspectable(defaultValue = "6")]
		public var hurtVelocityX:Number = 6;
		
		[Inspectable(defaultValue = "10")]
		public var hurtVelocityY:Number = 10;
		
		[Inspectable(defaultValue = "left", enumeration = "left, right")]
		public var startingDirection:String = "left";
		
		[Inspectable(defaultValue = "400")]
		public var hurtDuration:Number = 400;
		
		[Inspectable(defaultValue = "-100000")]
		public var leftBound:Number = -100000;
		
		[Inspectable(defaultValue = "100000")]
		public var rightBound:Number = 100000;
		
		[Inspectable(defaultValue = "10")]
		public var wallSensorOffset:Number = 10;
		
		[Inspectable(defaultValue = "2")]
		public var wallSensorWidth:Number = 2;
		
		[Inspectable(defaultValue = "2")]
		public var wallSensorHeight:Number = 2;
		
		protected var _hurtTimeoutID:uint = 0;
		protected var _hurt:Boolean = false;
		protected var _enemyClass:* = Player2
		protected var _hitpoints:int = 0;
		
		protected var _leftSensorShape:b2PolygonShape;
		protected var _rightSensorShape:b2PolygonShape;
		protected var _leftSensorFixture:b2Fixture;
		protected var _rightSensorFixture:b2Fixture;
		protected var _sensorFixtureDef:b2FixtureDef;
		
		public function Enemy(name:String, params:Object = null) 
		{
			updateCallEnabled = true;
			_beginContactCallEnabled = true;
			
			super(name, params);
			
			if (startingDirection == "left") _inverted = true;
		}
		
		override public function destroy():void
		{
			clearTimeout(_hurtTimeoutID);
			
			super.destroy();
		}
		
		public function get enemyClass():*
		{
			return _enemyClass;
		}
		
		[Inspectable(defaultValue = "entities.Player2", type = "String")]
		public function set enemyClass(value:*):void
		{
			if (value is String) _enemyClass = getDefinitionByName(value) as Class;
			else if (value is Class) _enemyClass = value;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			var position:b2Vec2 = _body.GetPosition();
			
			//Turn around when they pass their left/right bounds
			if ((_inverted && position.x * _box2D.scale < leftBound) || (!_inverted && position.x * _box2D.scale > rightBound)) turnAround();
			
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			
			if (!_hurt) velocity.x = _inverted ? -speed : speed;
			else velocity.x = 0;
			
			updateAnimation();
		}
		
		/**
		 * The enemy is hurt, start the time out with hurtDuration
		 */
		public function hurt(damage:int, targetX:int):void
		{
			_hurt = true;
			_hitpoints -= damage
			trace (_hitpoints);
			if (_hitpoints <= 0) kill = true;
			_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);

			//fling enemy
			var hurtVelocity:b2Vec2 = _body.GetLinearVelocity();
			hurtVelocity.y = -hurtVelocityY;
			hurtVelocity.x = hurtVelocityX;
			if (targetX > x) hurtVelocity.x = -hurtVelocityX;
			_body.SetLinearVelocity(hurtVelocity);

		}
		
		/**
		 * Change enemy's direction
		 */
		public function turnAround():void
		{
			_inverted = !_inverted;
		}
		
		override protected function createBody():void
		{
			super.createBody();
			_body.SetFixedRotation(true);
		}
		
		override protected function createShape():void
		{
			_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.2);
			
			var sensorWidth:Number = wallSensorWidth / _box2D.scale;
			var sensorHeight:Number = wallSensorHeight / _box2D.scale;
			var sensorOffset:b2Vec2 = new b2Vec2( -_width / 2 - (sensorWidth / 2), _height / 2 - (wallSensorOffset / _box2D.scale));
			
			_leftSensorShape = new b2PolygonShape();
			_leftSensorShape.SetAsOrientedBox(sensorWidth, sensorHeight, sensorOffset);
			
			sensorOffset.x = -sensorOffset.x;
			_rightSensorShape = new b2PolygonShape();
			_rightSensorShape.SetAsOrientedBox(sensorWidth, sensorHeight, sensorOffset);
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.friction = 0;
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("BadGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("Items");
			
			_sensorFixtureDef = new b2FixtureDef();
			_sensorFixtureDef.shape = _leftSensorShape;
			_sensorFixtureDef.isSensor = true;
			_sensorFixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("BadGuys");
			_sensorFixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAllExcept("Items");
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			
			_leftSensorFixture = body.CreateFixture(_sensorFixtureDef);
			
			_sensorFixtureDef.shape = _rightSensorShape;
			_rightSensorFixture = body.CreateFixture(_sensorFixtureDef);
		}
		
		override public function handleBeginContact(contact:b2Contact):void
		{
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			if (collider is _enemyClass) 
			{
				hurt(Globals.playerHP / 10, collider.x);
			}
				

			if (_body.GetLinearVelocity().x < 0 && (contact.GetFixtureA() == _rightSensorFixture || contact.GetFixtureB() == _rightSensorFixture)) return;
			if (_body.GetLinearVelocity().x < 0 && (contact.GetFixtureA() == _leftSensorFixture || contact.GetFixtureB() == _leftSensorFixture)) return;
			if (contact.GetManifold().m_localPoint)
			{
				var normalPoint:Point = new Point(contact.GetManifold().m_localPoint.x, contact.GetManifold().m_localPoint.y);
				var collisionAngle:Number = new MathVector(normalPoint.x, normalPoint.y).angle * 180 / Math.PI;
				
			if ((collider is Platform && collisionAngle != 90) || collider is Enemy) turnAround();
			}
		}
		
		protected function updateAnimation():void
		{
			_animation = "walk";
		}
		
		protected function endHurtState():void
		{
			_hurt = false;
		}
		
	}

}