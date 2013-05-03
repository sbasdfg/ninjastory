package entities 
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import citrus.math.MathVector;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.box2d.Box2DShapeMaker;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	import entities.Enemy.Enemy;
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	
	import citrus.objects.Box2DPhysicsObject;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Player extends Box2DPhysicsObject
	{
		
		// Properties
		
		//Rate which the player speeds up when you move him
		[Inspectable(defaultValue = "1")]
		public var acceleration:Number = 1;
		
		//Fastest speed the player can move
		[Inspectable(defaultValue = "8")]
		public var maxVelocity:Number = 8;
		
		//Initial player jump velocity
		[Inspectable(defaultValue = "11")]
		public var jumpHeight:Number = 11;
		
		//The amount of jump float
		[Inspectable(defaultValue = ".03")]
		public var jumpAcceleration:Number = .03;
		
		//How long the player is in hurt mode in milliseconds
		[Inspectable(defaultValue = "1000")]
		public var hurtDuration:Number = 1000;
		
		//How far the player is thrown horizontally when hurt
		[Inspectable(defaultValue = "6")]
		public var hurtVelocityX:Number = 6;
		
		//How far the player is thrown veritcally when hurt
		[Inspectable(defaultValue = "10")]
		public var hurtVelocityY:Number = 10;
		
		//Defines which input Channel to listen to
		[Inspectable(defaultValue = "0")]
		public var inputChannel:uint = 0;
		
		/**
		 * Plugin attack variables below
		 */
		
		/**
		 * Plugin switch booleans below (i.e. - double jump)
		 */
		
		 
		// Events
		
		//Dispatched when the player jumps
		public var onJump:Signal;
		
		//Dispatched when the player takes damage
		public var onTakeDamage:Signal;
		
		//Dispatched when the player's animation changes
		public var onAnimationChange:Signal;
		
		/**
		 * Plugin other signals below
		 */
		
		
		
		// Protected variables
		// Should not be changed directly
		
		protected var _groundContacts:Array = [];
		protected var _enemyClass:Class = Enemy;
		protected var _onGround:Boolean = false;
		protected var _hurtTimeoutID:uint;
		protected var _hurt:Boolean = false;
		protected var _friction:Number = 0.75;
		protected var _movingPlayer:Boolean = false;
		protected var _controlsEnabled:Boolean = true;
		protected var _crouching:Boolean = false;
		protected var _lookingup:Boolean = false;
		protected var _combinedGroundAngle:Number = 0;
		
		/**
		 * Creates new player object
		 */
		
		public function Player(name:String, params:Object = null) 
		{
			updateCallEnabled = true;
			_preContactCallEnabled = true;
			_beginContactCallEnabled = true;
			_endContactCallEnabled = true;
			
			super(name, params);
			
			onJump = new Signal();
			onTakeDamage = new Signal();
			onAnimationChange = new Signal();
		}
		
		override public function destroy():void
		{
			clearTimeout(_hurtTimeoutID);
			onJump.removeAll();
			onTakeDamage.removeAll();
			onAnimationChange.removeAll();
			
			super.destroy();
		}
		
		/**
		 * Whether or not the player can move and jump
		 */
		public function get controlsEnabled():Boolean
		{
			return _controlsEnabled;
		}
		
		public function set controlsEnabled(value:Boolean):void
		{
			_controlsEnabled = value;
			
			if (!_controlsEnabled) _fixture.SetFriction(_friction);
		}
		
		/**
		 * Returns true if the player is on the ground and can jump
		 */
		public function get onGround():Boolean
		{
			return _onGround;
		}
		
		/**
		 * This is the amount of friction the player will have.  It's value is multiplied against
		 * the friction value of other physics objects
		 */
		public function get friction():Number
		{
			return _friction;
		}
		
		[Inspectable(defaultValue = "0.75")]
		public function set friction(value:Number):void
		{
			_friction = value;
			
			if (_fixture)
			{
				_fixture.SetFriction(_friction);
			}
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			// we get a reference to the actual velocity vector
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			
			if (controlsEnabled)
			{
				var moveKeyPressed:Boolean = false;
				
				_crouching = (_ce.input.isDoing("crouch", inputChannel) && _onGround)
				_lookingup = (_ce.input.isDoing("lookup", inputChannel) && _onGround)
				
				if (_ce.input.isDoing("right", inputChannel) && !_crouching && !_lookingup)
				{
					velocity.Add(getSlopeBasedMoveAngle());
					moveKeyPressed = true;
				}
				
				if (_ce.input.isDoing("left", inputChannel) && !_crouching && !_lookingup)
				{
					velocity.Subtract(getSlopeBasedMoveAngle());
					moveKeyPressed = true;
				}
				
				//If player just started moving this tick
				if (moveKeyPressed && !_movingPlayer)
				{
					_movingPlayer = true;
					_fixture.SetFriction(0); //Take away friction so he can move
				}
				//Player just stopped moving this tick
				else if (!moveKeyPressed && _movingPlayer)
				{
					_movingPlayer = false;
					_fixture.SetFriction(_friction); //Add friction so the player stops
				}
				
				if (_onGround && _ce.input.justDid("jump", inputChannel))
				{
					velocity.y = -jumpHeight;
					onJump.dispatch();
				}
				
				if (_ce.input.isDoing("jump", inputChannel) && !_onGround && velocity.y < 0)
				{
					velocity.y -= jumpAcceleration;
				}
				
				//Cap velocities
				if (velocity.x > (maxVelocity)) velocity.x = maxVelocity;
				else if (velocity.x < ( -maxVelocity)) velocity.x = -maxVelocity;
			}
			
			updateAnimation();
		}
				
		/**
		 * Returns the absolute walking speed, taking moving platfors into accout.
		 * Isn't performace-light, so use sparingly.
		 */
		public function getWalkingSpeed():Number
		{
			var groundVelocityX:Number = 0;
			for each(var groundContact:b2Fixture in _groundContacts)
			{
				groundVelocityX += groundContact.GetBody().GetLinearVelocity().x;
			}
			
			return _body.GetLinearVelocity().x - groundVelocityX;
		}
		
		public function hurt():void
		{
			_hurt = true;
			controlsEnabled = false;
			_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
			onTakeDamage.dispatch();
			
			if (_movingPlayer)
			{
				_movingPlayer = false;
				_fixture.SetFriction(_friction);
			}
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			
			_bodyDef.fixedRotation = true;
			_bodyDef.allowSleep = false;
		}
		
		override protected function createShape():void
		{
			_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.1);
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.friction = _friction;
			_fixtureDef.restitution = 0;
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("GoodGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAll();
		}
		
		override public function handlePreSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			var other:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			var heroTop:Number = y;
			var objectBottom:Number = other.y + (other.height / 2);
			
			if (objectBottom << heroTop) contact.SetEnabled(false);
		}
		
		override public function handleBeginContact(contact:b2Contact):void
		{
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			if (_enemyClass && collider is _enemyClass)
			{
				if (!_hurt) hurt();
				
				//fling the player
				var hurtVelocity:b2Vec2 = _body.GetLinearVelocity();
				hurtVelocity.y = -hurtVelocityY;
				hurtVelocity.x = hurtVelocityX;
				if (collider.x > x) hurtVelocity.x = -hurtVelocityX;
				_body.SetLinearVelocity(hurtVelocity);
			}
			
			//Collision angle if we don't touch a Sensor.
			if (contact.GetManifold().m_localPoint && !(collider is Sensor)) //The normal property doesn't come through all the time.  I think it doesn't come through against sensors.
			{
				var collisionAngle:Number = (((new MathVector(contact.normal.x, contact.normal.y).angle) * 180 / Math.PI) +360) % 360;
				
				if ((collisionAngle > 45 && collisionAngle < 135))
				{
					_groundContacts.push(collider.body.GetFixtureList());
					_onGround = true;
					updateCombinedGroundAngle();
				}
			}
			//trace(_onGround);
		}
		
		override public function handleEndContact(contact:b2Contact):void
		{
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this,contact);
			
			//Remove from ground contacts, if it is one.
			var index:int = _groundContacts.indexOf(collider.body.GetFixtureList());
			if (index != -1)
			{
				_groundContacts.splice(index, 1);
				if (_groundContacts.length == 0) _onGround = false;
				updateCombinedGroundAngle();
			}
		}
		
		protected function getSlopeBasedMoveAngle():b2Vec2
		{
			return Box2DUtils.Rotateb2Vec2(new b2Vec2(acceleration, 0), _combinedGroundAngle);
		}

		protected function updateCombinedGroundAngle():void
		{
			trace (_onGround);
			_combinedGroundAngle = 0;
			
			if (_groundContacts.length == 0) return;
			
			for each (var contact:b2Fixture in _groundContacts) var angle:Number = contact.GetBody().GetAngle();
			
			var turn:Number = 45 * Math.PI / 180;
			angle = angle % turn;
			_combinedGroundAngle += angle;
			_combinedGroundAngle /= _groundContacts.length;
			trace (_combinedGroundAngle);
		}
		
		protected function endHurtState():void
		{
			_hurt = false;
			controlsEnabled = true;
		}
		
		protected function updateAnimation():void
		{
			var prevAnimation:String = _animation;
			
			var walkingSpeed:Number = getWalkingSpeed();
			
			if (_hurt) _animation = "hurt";
			
			else if (!_onGround)
			{
				_animation = "jump";
				
				if (walkingSpeed < -acceleration)
					_inverted = true;
				else if (walkingSpeed > acceleration)
					_inverted = false;
			}
			else if (_crouching) _animation = "crouch";
			else if (_lookingup) _animation = "lookup";
			
			else
			{
				if (walkingSpeed < - acceleration)
				{
					_inverted = true;
					_animation = "walk";
				}
				else if (walkingSpeed > acceleration)
				{
					_inverted = false;
					_animation = "walk";
				}
				else
				{
					_animation = "idle";
				}
			}
			
			if (prevAnimation != _animation)
				onAnimationChange.dispatch();
		}
	}
}