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
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.box2d.Box2DShapeMaker;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	import entities.Player2;
	//import entities.Weapons.RangedWeapons.RangedWeapon;
	import org.osflash.signals.Signal;
	
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
		
		public var acceleration:Number = 1;
		public var maxVelocity:Number = 8;
		public var jumpHeight:Number = 11;
		public var jumpAcceleration:Number = .03;
		
		
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
		public var target:* = null;
		protected var _hitpoints:int = 0;
		protected var _maxHitpoints:int = 0;
		protected var _enemyName:String = "null";
		
		protected var _leftSensorShape:b2PolygonShape;
		protected var _rightSensorShape:b2PolygonShape;
		protected var _leftSensorFixture:b2Fixture;
		protected var _rightSensorFixture:b2Fixture;
		protected var _sensorFixtureDef:b2FixtureDef;
		
		// What our enemy is allowed to do
		protected var _looksForPlayer:Boolean = false;
		protected var _canMove:Boolean = false;
		protected var _canRanged:Boolean = false;
		protected var _canMelee:Boolean = false;
		protected var _canJump:Boolean = false;		
		
		// Flags to determine what the enemy is doing
		protected var _isMoving:Boolean = false;
		protected var _onGround:Boolean = true;
		
		// If the enemy is allowed to look for the player
		protected var _visionVertical:Number = 0;
		protected var _visionHorizontal:Number = 0;
		protected var _canSeePlayer:Boolean = false;

		// If the enemy is allowed to move
		protected var _chasingTime:Number = 0;
		protected var _chasingTimer:Number = 0;
		protected var _isChasing:Boolean = false;
		
		// If the enemy is allowed to melee Attack
		public var _usingMeleeWeapon:Boolean = false;
		public var onMeleeWeapon:Signal;
		protected var meleeWeapon:String = "null";
		protected var _isMeleeActive:Boolean = true;
		protected var _activeMeleeTimout:uint = 0;
		
		// If the enemy is alloed to ranged Attack
		protected var _usingRangedWeapon:Boolean = false;
		public var onRangedWeapon:Signal;
		protected var _rangedWeapon:String = "null";
		protected var _rangedDelay:Number;
		protected var _activeRangedTimeout:uint = 0;
		
		public var onTakeDamage:Signal;
		public var onDeath:Signal;
		public var onLoot:Signal;
		
		protected var _groundContacts:Array = [];
		protected var _friction:Number = 0.75;
		protected var _combinedGroundAngle:Number = 0;
		
		//Fall damage variables
		protected var _lastY:Number = 0;
		protected var _fallAmount:Number = 0;
		protected var _safeDistance:int = 15;
		protected var _fallDivisor:int = 25;
		
		//Loot Drops
		protected var _loot:Vector.<String> = new Vector.<String>;
		protected var _lootType:Vector.<String> = new Vector.<String>;
		protected var deadTimeoutID:uint = 0;

		
		public function Enemy(name:String, params:Object = null) 
		{
			updateCallEnabled = true;
			_preContactCallEnabled = true;
			_beginContactCallEnabled = true;
			_endContactCallEnabled = true;
			
			super(name, params);
			
			
			onTakeDamage = new Signal(Box2DPhysicsObject, int);
			onDeath = new Signal(Enemy);
			onLoot = new Signal(String, Object);
			onMeleeWeapon = new Signal(String, String, Boolean, Boolean, Box2DPhysicsObject);
			onRangedWeapon = new Signal(String, String, Boolean, Object);
			
			if (startingDirection == "left") _inverted = true;
		}
		
		public function killEnemy():void
		{
			var i:int = 0;
			for each(var loot:String in _loot)
			{
				var lootAngle:Number = (Math.random() * 90) + 225;
				var lootSpeed:Number = (Math.random() * 3) + 3;
				onLoot.dispatch(loot, { x:x, y:y, width:25, height:25, angle: lootAngle, speed:lootSpeed, lootType:_lootType[i] } );
				i++;
			}
			onDeath.dispatch(this);			
		}
		
		override public function destroy():void
		{
			clearTimeout(_hurtTimeoutID);
			onTakeDamage.removeAll();
			onDeath.removeAll();
			
			super.destroy();
		}
		
		public function get enemyClass():*
		{
			return _enemyClass;
		}
		
		public function get hitpoints():int
		{
			return _hitpoints
		}
		
		public function set hitpoints(newHP:int):void
		{
			_hitpoints = newHP
		}
		
		public function get maxHitpoints():int
		{
			return _maxHitpoints;
		}
		
		public function get enemyName():String
		{
			return _enemyName;
		}
		
		public function set enemyName(enemyName:String):void
		{
			_enemyName = enemyName;
		}
		
		public function set maxHitPoints(newMaxHP:int):void
		{
			_maxHitpoints = newMaxHP;
		}
		
		[Inspectable(defaultValue = "entities.Player2", type = "String")]
		public function set enemyClass(value:*):void
		{
			if (value is String) _enemyClass = getDefinitionByName(value) as Class;
			else if (value is Class) _enemyClass = value;
		}
		
		public function get onGround():Boolean
		{
			return _onGround;
		}
		

		public function get friction():Number
		{
			return _friction;
		}
		
		[Inscpetable(defaultValue = "0.75")]
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

			var velocity:b2Vec2 = _body.GetLinearVelocity();			
			
			var playSeen:Boolean = false;
			_isMoving = false;
			
			if (_looksForPlayer && _chasingTimer < .2) playSeen = checkLOS();
			//trace(playSeen, _chasingTimer);
			if (playSeen)
			{
				if (_canMove)
				{
					_chasingTimer = _chasingTime;
					_isChasing = true;
				}
			}
			
			if (_isChasing)
			{
				_chasingTimer -= timeDelta;
				if (_chasingTimer < 0) _isChasing = false;
				if (target.x < x) moveLeft(velocity);
				else moveRight(velocity);
			}
			

			if (_canMelee && !_usingMeleeWeapon &&_isMeleeActive && target != null)
			{
				if (checkLOS())
				{
					//trace(_inverted, x, target.x);
					if (_inverted)
					{
						if (x < target.x + 100) 
						{
							onMeleeWeapon.dispatch(meleeWeapon, "straight", true, !_inverted, this)
							_usingMeleeWeapon = true;
							_isMeleeActive = false;
							//trace("Swing Weapon");
						}
					}
					else
					{
						if (x > target.x - 100) 
						{
							onMeleeWeapon.dispatch(meleeWeapon, "straight", true, !_inverted, this)
							_usingMeleeWeapon = true;
							_isMeleeActive = false;
							//trace("Swing Weapon");
						}
					}
				}
			}
			
			var rangedWeaponParams:Object;
			
			if (_canRanged && !_usingRangedWeapon)
			{
				trace("Ranged Attack");
				if (checkLOS())
				{
					if (!_inverted)
					{
						rangedWeaponParams =  { x:x +width, y:y, width:25, height:25, speed:15, angle:0, explodeDuration:100, fuseDuration:5000 };
					}
					else
					{
						rangedWeaponParams =  { x:x -width, y:y, width:25, height:25, speed:15, angle:180, explodeDuration:100, fuseDuration:5000 };
					}
					onRangedWeapon.dispatch(_rangedWeapon, "normal", true, rangedWeaponParams);
					_usingRangedWeapon = true;
					_activeRangedTimeout = setTimeout(resetRanged, _rangedDelay);
				}
			}
			
			//trace(_usingMeleeWeapon, _isMeleeActive);
			
			if (!_usingMeleeWeapon && !_isMeleeActive)
			{
				_activeMeleeTimout = setTimeout(resetMelee, 500);
			}
			
			//trace(_isChasing);
			if (_isMoving) _fixture.SetFriction(0);
			else _fixture.SetFriction(_friction);
			
			//trace(velocity.x);
			
			
			if (velocity.x > maxVelocity) velocity.x = maxVelocity;
			else if (velocity.x < -maxVelocity) velocity.x = -maxVelocity;
			
			updateAnimation();
		}
		
		protected function resetRanged():void
		{
			_usingRangedWeapon = false;
		}
		
		protected function resetMelee():void
		{
			_isMeleeActive = true;
		}
		
		protected function moveRight(velocity:b2Vec2):b2Vec2
		{
			if (_onGround)
			{
				_isMoving = true;
				velocity.Add(getSlopeBasedMoveAngle());
			}
			return velocity;
		}
		
		protected function moveLeft(velocity:b2Vec2):b2Vec2
		{
			if (_onGround)
			{
				_isMoving = true;
				velocity.Subtract(getSlopeBasedMoveAngle());
			}
			return velocity;
		}
		
		public function getWalkingSpeed():Number
		{
			var groundVelocityX:Number = 0;
			for each (var groundContact:b2Fixture in _groundContacts)
			{
				groundVelocityX += groundContact.GetBody().GetLinearVelocity().x;
			}

			return _body.GetLinearVelocity().x - groundVelocityX;
		}
		
		protected function checkLOS():Boolean
		{
			var playerXRange:Boolean = false;
			var playerYRange:Boolean = false;
			var playerLOS:Boolean = false;
			if (target != null){
			if (_inverted)
			{
				if (target.x < this.x && Math.abs(target.x - this.x) < _visionHorizontal) playerXRange = true;
			}
			else
			{
				if (target.x > this.x && Math.abs(target.x - this.x) < _visionHorizontal) playerXRange = true;
			}
			
			if (playerXRange)
			{
				if (Math.abs(target.y - (this.y + (this._height / 2))) < _visionVertical)
				{
					var check:Vector.<b2Fixture> = (_box2D.world.RayCastAll(new b2Vec2(x / _box2D.scale, y / _box2D.scale), new b2Vec2(target.x / _box2D.scale, target.y / _box2D.scale)));
					var returnTrue:Boolean = true;
					
					for each(var thisCheck:b2Fixture in check)
					{
						var fixtureName:String = thisCheck.GetBody().GetUserData().name;
						if (fixtureName != "hero") returnTrue = false;
					}
					
					if (returnTrue) playerLOS = true;
				}
			}			}
			//trace(playerLOS);
			return playerLOS;
		}
		
		protected function rayCastCheck(fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Number):Number
		{
			return fraction;
		}
		
		/**
		 * The enemy is hurt, start the time out with hurtDuration
		 */
		public function hurt(damage:int, targetX:int):void
		{
			_hurt = true;
			_hitpoints -= damage
			//trace (_hitpoints);
			if (_hitpoints <= 0) 
			{
				kill = true;
				deadTimeoutID = setTimeout(killEnemy, 50);
			}
			_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
			
			onTakeDamage.dispatch(this, damage);

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
		
		override protected function defineBody():void
		{
			super.defineBody();

			_bodyDef.fixedRotation = true;
			_bodyDef.allowSleep = false;
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
			_fixtureDef.friction = _friction;
			_fixtureDef.restitution = 0;
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
			
			if (contact.GetManifold().m_localPoint && !(collider is Sensor)) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
			{				
				var collisionAngle:Number = (((new MathVector(contact.normal.x, contact.normal.y).angle) * 180 / Math.PI) + 360) % 360;// 0º <-> 360º

				if ((collisionAngle > 45 && collisionAngle < 135))
				{
					_groundContacts.push(collider.body.GetFixtureList());
					_onGround = true;
					
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
			}
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
		
		public function setVictory():void
		{
			_body.SetLinearDamping(500);
		}
		
		protected function updateAnimation():void
		{
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

			//if (prevAnimation != _animation)
				//onAnimationChange.dispatch();		
		}
		
		protected function endHurtState():void
		{
			_hurt = false;
		}
		
	}

}