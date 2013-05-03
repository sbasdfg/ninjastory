package entities
{

	import Box2D.Collision.b2Manifold;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2WeldJoint;
	import Box2D.Dynamics.Joints.b2WeldJointDef;
	import citrus.core.CitrusEngine;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Sensor;
	import entities.Enemy.Enemy;
	import entities.Interface.LevelGUI.TextFlyby;
	import entities.Weapons.InventoryHandler;
	import entities.Weapons.MeleeWeapons.MeleeWeapon;
	import entities.Weapons.MeleeWeapons.Sword;
	import entities.Weapons.RangedWeapons.Shuriken;
	import feathers.motion.transitions.OldFadeNewSlideTransitionManager;
	import starling.display.Sprite;
	import flash.sampler.NewObjectSample;
	import org.osflash.signals.natives.base.SignalBitmap;

	import citrus.math.MathVector;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.box2d.Box2DShapeMaker;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;

	import org.osflash.signals.Signal;

	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;

	/**
	 * This is a common, simple, yet solid implementation of a side-scrolling Hero. 
	 * The hero can run, jump, get hurt, and kill enemies. It dispatches signals
	 * when significant events happen. The game state's logic should listen for those signals
	 * to perform game state updates (such as increment coin collections).
	 * 
	 * Don't store data on the hero object that you will need between two or more levels (such
	 * as current coin count). The hero should be re-created each time a state is created or reset.
	 */	
	public class Player2 extends Box2DPhysicsObject
	{
		//properties
		//This is the rate at which the hero speeds up when you move him left and right. 
		[Inspectable(defaultValue="1")]
		public var acceleration:Number = 1;
		
		//This is the rate the hero will slide if the hero can slide
		public var slideSpeed:Number = 6;
		
		//This rate which the hero will climb up a wall
		public var climbSpeed:Number = 5;

		//This is the fastest speed that the hero can move left or right. 
		[Inspectable(defaultValue="8")]
		public var maxVelocity:Number = 8;

		//This is the initial velocity that the hero will move at when he jumps.
		[Inspectable(defaultValue="11")]
		public var jumpHeight:Number = 11;
		
		//This is the amount of "float" that the hero has when the player holds the jump button while jumping. 
		[Inspectable(defaultValue="0.3")]
		public var jumpAcceleration:Number = 0.3;

		//This is the y velocity that the hero must be travelling in order to kill an Enemy.
		[Inspectable(defaultValue="3")]
		public var killVelocity:Number = 3;

		//The y velocity that the hero will spring when he kills an enemy. 
		[Inspectable(defaultValue="8")]
		public var enemySpringHeight:Number = 8;

		//The y velocity that the hero will spring when he kills an enemy while pressing the jump button. 
		[Inspectable(defaultValue="9")]
		public var enemySpringJumpHeight:Number = 9;

		//How long the hero is in hurt mode for. 
		[Inspectable(defaultValue="1000")]
		public var hurtDuration:Number = 1000;

		//The amount of kick-back that the hero jumps when he gets hurt.
		[Inspectable(defaultValue="6")]
		public var hurtVelocityX:Number = 6;

		//The amount of kick-back that the hero jumps when he gets hurt. 
		[Inspectable(defaultValue="10")]
		public var hurtVelocityY:Number = 10;
		
		/**
		 * Add special conditions below here
		 */

		//Determines whether or not the hero's ducking ability is enabled.
		[Inspectable(defaultValue="true")]
		public var canDuck:Boolean = true;
		
		//Determines whether or not the hero's double jump ability is enabled.
		[Inspectable(defaultValue = "true")]
		public var canDoubleJump:Boolean = true;
		
		public var canWallKick:Boolean = true;
		
		public var canUseSword:Boolean = true;
		
		public var canSpiderClimb:Boolean = true;

		//Defines which input Channel to listen to.
		[Inspectable(defaultValue = "0")]
		public var inputChannel:uint = 1;

		//events
		//Dispatched whenever the hero jumps.
		public var onJump:Signal;

		//Dispatched whenever the hero gives damage to an enemy. 	
		public var onGiveDamage:Signal;
		
		//Dispatched when player fires a ranged weapon
		public var onFireWeapon:Signal;
		
		//Dispatched when player swings a melee weapon
		public var onMeleeWeapon:Signal;

		//Dispatched whenever the hero takes damage from an enemy. 	
		public var onTakeDamage:Signal;

		//Dispatched whenever the hero's animation changes. 	
		public var onAnimationChange:Signal;
		
		//Dispatch when the player dies
		public var onDeath:Signal;
		
		//Dispatch when the player jumps off rope
		public var doneSwinging:Signal;
		
		public var onAttackItem:Signal;
		
		//Fall damage variables
		protected var _lastY:Number = 0;
		protected var _fallAmount:Number = 0;
		protected var _safeDistance:int = 15;
		protected var _fallDivisor:int = 25;

		protected var _groundContacts:Array = [];//Used to determine if he's on ground or not.
		protected var _enemyClass:Class = Enemy;
		protected var _onGround:Boolean = false;
		protected var _springOffEnemy:Number = -1;
		protected var _hurtTimeoutID:uint;
		protected var _offRopeTimeoutID:uint;
		public var _canSwingAgain:Boolean = true;
		protected var _hurt:Boolean = false;
		protected var _friction:Number = 0.75;
		protected var _gravity:Number;
		protected var _playerMovingHero:Boolean = false;
		protected var _controlsEnabled:Boolean = true;
		protected var _crouching:Boolean = false;
		protected var _lookingup:Boolean = false;
		protected var _combinedGroundAngle:Number = 0;
		protected var _isDoubleJumping:Boolean = false;
		protected var _isWallKicking:Boolean = false;
		protected var _isSliding:Boolean = false;
		protected var _isWallClimbing:Boolean = false;
		
		
		protected var _meleeWeapon:String = "sword";
		protected var _meleeJointDef:b2WeldJointDef;
		protected var _meleeJoint:b2WeldJoint;
		public var _usingMeleeWeapon:Boolean = false;
		public var _isSwinging:Boolean = false;
		protected var currentRope:*;
		protected var _specialTimeoutID:uint = 0;
		protected var _specialActive:Boolean = false;

		//Damage Flyby
		private var _damageContainer:CitrusSprite;
		
		//Inventroy Handler
		protected var _rangedWeapon:String = "shuriken";
		
		
		// Player Statistics
		protected var _hitpoints:int = Globals.playerHP;
			
		
		protected var _victory:Boolean = false;
		/**
		 * Creates a new hero object.
		 */		
		public function Player2(name:String, params:Object = null)
		{
			updateCallEnabled = true;
			_preContactCallEnabled = true;
			_beginContactCallEnabled = true;
			_endContactCallEnabled = true;
			
			super(name, params);
			
			onJump = new Signal();
			onGiveDamage = new Signal();
			onTakeDamage = new Signal(Box2DPhysicsObject, int);
			onAnimationChange = new Signal();
			onDeath = new Signal();
			onFireWeapon = new Signal(String, String, Boolean, Object);
			onMeleeWeapon = new Signal(String, String, Boolean, Boolean, Box2DPhysicsObject);
			onAttackItem = new Signal(String, String, Boolean, Object);
			doneSwinging = new Signal(Box2DPhysicsObject);
			//WeaponType:String, thrustDirection:String, enemyWeapon:Boolean, faceRight:Boolean, target:Box2DPhysicsObject
			
			_damageContainer = new CitrusSprite("dmgtxt", { view: new Sprite() } );
			_ce.state.add(_damageContainer);
			
			//exitSommersalt();
		}
		
		protected function killPlayer():void
		{
			trace("dead player");
			onDeath.dispatch();
		}
		
		override public function destroy():void
		{
			clearTimeout(_hurtTimeoutID);
			clearTimeout(_offRopeTimeoutID);
			onJump.removeAll();
			onGiveDamage.removeAll();
			onTakeDamage.removeAll();
			onAnimationChange.removeAll();
			onDeath.removeAll();
			onFireWeapon.removeAll();
			onMeleeWeapon.removeAll();
			doneSwinging.removeAll();
			onAttackItem.removeAll();
			
			super.destroy();
		}
		
		/**
		 * Whether or not the player can move and jump with the hero. 
		 */	
		public function get controlsEnabled():Boolean
		{
			return _controlsEnabled;
		}
		
		public function set controlsEnabled(value:Boolean):void
		{
			_controlsEnabled = value;
			
			if (!_controlsEnabled)
				_fixture.SetFriction(_friction);
		}
		
		public function get playerHP():int
		{
			return _hitpoints
		}
		
		public function set playerHP(hp:int):void
		{
			_hitpoints = hp;
		}
		
		/**
		 * Returns true if the hero is on the ground and can jump. 
		 */		
		public function get onGround():Boolean
		{
			return _onGround;
		}
		
		/**
		 * The Hero uses the enemyClass parameter to know who he can kill (and who can kill him).
		 * Use this setter to to pass in which base class the hero's enemy should be, in String form
		 * or Object notation.
		 * For example, if you want to set the "Enemy" class as your hero's enemy, pass
		 * "citrus.objects.platformer.Enemy", or Enemy (with no quotes). Only String
		 * form will work when creating objects via a level editor.
		 */
		[Inspectable(defaultValue="citrus.objects.platformer.box2d.Enemy",type="String")]
		public function set enemyClass(value:*):void
		{
			if (value is String)
				_enemyClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
				_enemyClass = value;
		}
		
		/**
		 * This is the amount of friction that the hero will have. Its value is multiplied against the
		 * friction value of other physics objects.
		 */	
		public function get friction():Number
		{
			return _friction;
		}
		
		[Inspectable(defaultValue="0.75")]
		public function set friction(value:Number):void
		{
			_friction = value;
			
			if (_fixture)
			{
				_fixture.SetFriction(_friction);
			}
		}
		
		protected function setCanSwingAgain():void
		{
			_canSwingAgain = true;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			// we get a reference to the actual velocity vector
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			
			if (controlsEnabled)
			{
				var moveKeyPressed:Boolean = false;
				
				if (_ce.input.isDoing("right", inputChannel) && !_isSliding && !_isWallKicking && !_lookingup && !_crouching && !_isWallClimbing)
				{
					velocity.Add(getSlopeBasedMoveAngle());
					moveKeyPressed = true;
				}
				
				if (_ce.input.isDoing("right", inputChannel) && _ce.input.isDoing("crouch", inputChannel) && _onGround && Math.abs(velocity.x) > 0)
				{
					velocity.Add(getSlopeBasedMoveAngle());
					moveKeyPressed = true;
					if (!_isSliding) slideHero();
				}
				
				
				if (_ce.input.isDoing("left", inputChannel) && !_isSliding && !_isWallKicking && !_lookingup && !_crouching && !_isWallClimbing)
				{
					velocity.Subtract(getSlopeBasedMoveAngle());
					moveKeyPressed = true;
				}
				
				if (_ce.input.isDoing("left", inputChannel) && _ce.input.isDoing("crouch", inputChannel) && _onGround && Math.abs(velocity.x) > 0)
				{
					velocity.Subtract(getSlopeBasedMoveAngle());
					moveKeyPressed = true;
					if (!_isSliding) slideHero();
				}
				
				if ((!_ce.input.isDoing("crouch", inputChannel) || Math.abs(velocity.x) <0.5) && _isSliding) unslideHero();
				
				if (_isWallClimbing)
				{
					if (_ce.input.isDoing("crouch", inputChannel)) velocity.y = climbSpeed;
					else if (_ce.input.isDoing("lookup", inputChannel)) velocity.y = -climbSpeed;
					else velocity.y = 0;
					moveKeyPressed = true;
				}
				
				//trace("Movekey: " + moveKeyPressed + " Sliding: " + _isSliding);

				//If player just started moving the hero this tick.
				if (moveKeyPressed && !_playerMovingHero)
				{
					_playerMovingHero = true;
					_fixture.SetFriction(0); //Take away friction so he can accelerate.
				}
				//Player just stopped moving the hero this tick.
				else if (!moveKeyPressed && _playerMovingHero)
				{
					_playerMovingHero = false;
					_fixture.SetFriction(_friction); //Add friction so that he stops running
				}
				
				if (_ce.input.isDoing("lookup", inputChannel) && _onGround && !_crouching) _lookingup = true;
				else _lookingup = false;
				
				if (_ce.input.isDoing("lookup", inputChannel) && _isSwinging) currentRope.startClimbing(true);
				else if (_ce.input.isDoing("crouch", inputChannel) && _isSwinging) currentRope.startClimbing(false);
				else if (_isSwinging) currentRope.stopClimbing();
				
				if (_ce.input.isDoing("crouch", inputChannel) && _onGround && !_lookingup && !_isSliding) _crouching = true;
				else _crouching = false;
				
				if (_onGround && _ce.input.justDid("jump", inputChannel))
				{
					velocity.y = -jumpHeight;
					onJump.dispatch();
					_isDoubleJumping = false;
				}
				
				if (_ce.input.isDoing("jump", inputChannel) && !_onGround && velocity.y < 0 && !_isWallClimbing)
				{
					velocity.y -= jumpAcceleration;
				}
				
				if (velocity.y > 0 && !_isWallKicking)
				{
					if (_lastY == 0) _lastY = y;
					_fallAmount += (y - _lastY);
					if (_fallAmount < 0) _fallAmount = 0;
					_lastY = y;
				}
				
				if (_ce.input.justDid("jump", inputChannel) && !_onGround && canDoubleJump && !_isDoubleJumping && !_isWallKicking && !_isWallClimbing)
				{
					velocity.y = -jumpHeight;
					onJump.dispatch();
					_isDoubleJumping = true;
				}
				
				if (_ce.input.justDid("jump", inputChannel) && (_isWallKicking || _isWallClimbing) && !_onGround)
				{
					body.SetLinearDamping(0);
					velocity.y = -jumpHeight;
					if (_inverted) velocity.x += jumpHeight;
					else velocity.x -= jumpHeight;
					_isWallKicking = false;
					_isWallClimbing = false;
				}
				
				if (_ce.input.justDid("jump", inputChannel) && _isSwinging)
				{
					doneSwinging.dispatch(currentRope);
					_canSwingAgain = false;
					_isSwinging = false;
					_isDoubleJumping = false;
					_offRopeTimeoutID = setTimeout(setCanSwingAgain, 1000);
					//velocity.x = maxVelocity;
					//velocity.y = -jumpHeight;
				}
				
				if (_ce.input.justDid("shoot", inputChannel) && !_isSliding && !_isSwinging && !_isWallKicking)
				{
					var rangedWeaponParams:Object;
					var direction:String;
					
					if (_crouching) direction = "down";
					else if (_lookingup) direction = "up";
					else direction = "normal";
					
					if (!_inverted) 
					{
						rangedWeaponParams =  { x:x +width, y:y, width:25, height:25, speed:15, angle:0, explodeDuration:20, fuseDuration:5000 };
					}
					else
					{
						rangedWeaponParams =  { x:x -width, y:y, width:25, height:25, speed:15, angle:180, explodeDuration:20, fuseDuration:5000 };
					}
					onFireWeapon.dispatch("shuriken", direction, false, rangedWeaponParams);
				}
				
				if (_ce.input.justDid("1", inputChannel) && !_isSliding && !_isSwinging && !_isWallKicking && !_specialActive)
				{
					var attackItemParams:Object;
					var itemDirection:String;
					
					if (!_inverted)
					{
						attackItemParams = { x:x + width, y:y, width:25, height:25, angle:345, explodeDuration:100, speed:Math.abs(velocity.x/2) };
					}
					else
					{
						attackItemParams = { x:x - width, y:y, width:25, height:25, angle:-15, explodeDuration:100, speed:Math.abs(velocity.x/2) };
					}
					_specialActive = true;
					_specialTimeoutID = setTimeout(resetSpecial, 100);
					onAttackItem.dispatch("flashbomb", itemDirection, false, attackItemParams);
				}
				
				
				if (_ce.input.justDid("melee", inputChannel)) //trace (canUseSword, _usingMeleeWeapon);
				if (canUseSword && _ce.input.justDid("melee", inputChannel) && !_usingMeleeWeapon && !_isSwinging && !_isWallKicking)
				{
					//trace("Swing Sword", _lookingup);
					_usingMeleeWeapon = true;
					if (!_playerMovingHero && !_crouching && !_lookingup && _onGround) 
					{
						onMeleeWeapon.dispatch(_meleeWeapon, "striaght", false, !_inverted, this);
						_controlsEnabled = false;
					}
					else if (_playerMovingHero && _onGround)
					{
						onMeleeWeapon.dispatch(_meleeWeapon, "straight", false, !_inverted, this);
						_controlsEnabled = false;
					}
					else if (!_playerMovingHero && _lookingup)
					{
						onMeleeWeapon.dispatch(_meleeWeapon, "up", false, !_inverted, this);
						_controlsEnabled = false;
					}
					else if (!_playerMovingHero && _crouching)
					{
						onMeleeWeapon.dispatch(_meleeWeapon, "down", false, !_inverted, this);
						_controlsEnabled = false;
					}
					else if (!_onGround)
					{
						onMeleeWeapon.dispatch(_meleeWeapon, "sweep", false, !_inverted, this);
					}
					else _usingMeleeWeapon = false;
					
					//else _usingMeleeWeapon = false;
				}
				
				//Cap velocities
				if (velocity.x > (maxVelocity))
					velocity.x = maxVelocity;
				else if (velocity.x < (-maxVelocity))
					velocity.x = -maxVelocity;
			}
			
			if (!_usingMeleeWeapon && !_hurt && !_victory)
			{
				_controlsEnabled = true;
			}
			
			updateAnimation();
		}
		
		public function resetSpecial():void
		{
			_specialActive = false;
		}
		
		public function grabRope(rope:*):void
		{
			_isSwinging = true;
			currentRope = rope;
		}
		
		public function slideHero():void
		{
			if (!_inverted) body.SetAngle(4.8);
			else body.SetAngle(1.5);
			//y += this.height / 2;
			_isSliding = true;
		}
		
		public function unslideHero():void
		{
			body.SetAngle(0);
			y -= this.height / 3;
			_isSliding = false;
		}
		
		public function climbWall():void
		{
			_isWallClimbing = true;
		}
		
		/**
		 * Returns the absolute walking speed, taking moving platforms into account.
		 * Isn't super performance-light, so use sparingly.
		 */
		public function getWalkingSpeed():Number
		{
			var groundVelocityX:Number = 0;
			for each (var groundContact:b2Fixture in _groundContacts)
			{
				groundVelocityX += groundContact.GetBody().GetLinearVelocity().x;
			}

			return _body.GetLinearVelocity().x - groundVelocityX;
		}

		/**
		 * Hurts the hero, disables his controls for a little bit, and dispatches the onTakeDamage signal. 
		 */		
		public function hurt(damage:int, targetX:int):void
		{
			_hurt = true;
			controlsEnabled = false;
			_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
			
			//trace(_height);
			
			//Makes sure that the hero is not frictionless while his control is disabled
			if (_playerMovingHero)
			{
				_playerMovingHero = false;
				_fixture.SetFriction(_friction);
			}
			
			_hitpoints -= damage;
			onTakeDamage.dispatch(this, damage);
			if (_hitpoints <= 0) killPlayer();
			//fling the hero
			var hurtVelocity:b2Vec2 = _body.GetLinearVelocity();
			hurtVelocity.y = -hurtVelocityY;
			hurtVelocity.x = hurtVelocityX;
			if (targetX > x)
				hurtVelocity.x = -hurtVelocityX;
			_body.SetLinearVelocity(hurtVelocity);

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
			var otherType:String = (other as Box2DPhysicsObject).name;

			if (_victory) contact.SetEnabled(false);
			if (otherType == "ropewalk" && !Globals.canTightRopeWalk) contact.SetEnabled(false);
			//trace(otherType);
		}

		override public function handleBeginContact(contact:b2Contact):void {

			var collider:Box2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact) as Box2DPhysicsObject;
			var colliderType:String = (collider.name)
			
			if (collider is _enemyClass)
			{
				if (!_hurt)
				{
					hurt(Globals.playerHP / 10, collider.x);

				}
			}

			//Collision angle if we don't touch a Sensor.
			if (contact.GetManifold().m_localPoint && !(collider is Sensor)) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
			{				
				var collisionAngle:Number = (((new MathVector(contact.normal.x, contact.normal.y).angle) * 180 / Math.PI) + 360) % 360;// 0º <-> 360º

				if ((collisionAngle > 45 && collisionAngle < 135))
				{
					_groundContacts.push(collider.body.GetFixtureList());
					_onGround = true;
					if (_isWallKicking)
					{
						_isWallKicking = false;
						body.SetLinearDamping(0);
					}
					if (_fallAmount / _fallDivisor > _safeDistance)
					{
						var hurtDirection:int;
						if (_inverted) hurtDirection = x + 1;
						else hurtDirection = x -1;
						hurt(int(_fallAmount / _fallDivisor - _safeDistance), hurtDirection);
					}
					_fallAmount = 0;
					updateCombinedGroundAngle();
				}
				else if (colliderType == "wall" && canWallKick && !_onGround) grabWall();
				else if (colliderType == "climbwall" && canSpiderClimb && !_onGround) climbWall();
			}
			//if (colliderType == "ground" && !_onGround) trace ("");
		}


		override public function handleEndContact(contact:b2Contact):void {

			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);

			//Remove from ground contacts, if it is one.
			var index:int = _groundContacts.indexOf(collider.body.GetFixtureList());
			if (index != -1)
			{
				_groundContacts.splice(index, 1);
				if (_groundContacts.length == 0)
					_onGround = false;
				updateCombinedGroundAngle();
			}
		}
		
		protected function grabWall():void
		{
			trace("Grab Wall");
			_isWallKicking = true;
			_fallAmount = 0;
			_isDoubleJumping = false;
			body.SetLinearDamping(8);
		}

		protected function getSlopeBasedMoveAngle():b2Vec2
		{
			return Box2DUtils.Rotateb2Vec2(new b2Vec2(acceleration, 0), _combinedGroundAngle);
		}

		protected function updateCombinedGroundAngle():void
		{
			_combinedGroundAngle = 0;

			if (_groundContacts.length == 0)
				return;

			for each (var contact:b2Fixture in _groundContacts)
				var angle:Number = contact.GetBody().GetAngle();

			var turn:Number = 45 * Math.PI / 180;
			angle = angle % turn;
			_combinedGroundAngle += angle;
			_combinedGroundAngle /= _groundContacts.length;
		}

		protected function endHurtState():void {

			_hurt = false;
			controlsEnabled = true;
		}
		
		public function setVictory():void
		{
			_controlsEnabled = false;
			_body.SetLinearDamping(500);
			_victory = true;
			
		}

		protected function updateAnimation():void {

			var prevAnimation:String = _animation;

			var walkingSpeed:Number = getWalkingSpeed();

			if (_hurt)
				_animation = "hurt";

			else if (!_onGround) {

				_animation = "jump";

				if (walkingSpeed < -acceleration)
					_inverted = true;
				else if (walkingSpeed > acceleration)
					_inverted = false;
			}

			else {

				if (walkingSpeed < -acceleration) {
					_inverted = true;
					_animation = "walk";

				} else if (walkingSpeed > acceleration) {

					_inverted = false;
					_animation = "walk";

				} else
					_animation = "idle";
			}

			if (prevAnimation != _animation)
				onAnimationChange.dispatch();
		}
	}
}