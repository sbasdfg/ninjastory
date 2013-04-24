package entities.Weapons.MeleeWeapons 
{
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.Contacts.b2Contact;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	import entities.Enemy.Enemy;
	import entities.Player2;
	import flash.display.NativeMenuItem;
	import org.osflash.signals.Signal;

	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class MeleeWeapon extends Box2DPhysicsObject 
	{
		
		protected var _thrustUp:Boolean = false;
		protected var _thrustDown:Boolean = false;
		protected var _thrustSwing:Boolean = false;
		protected var _thrustStraight:Boolean = false;
		
		protected var _angle:Number = 0;
		
		protected var _enemyClass:Class = Enemy;
		protected var _target:Box2DPhysicsObject;
		protected var _contact:IBox2DPhysicsObject;
		protected var _damage:int;
		
		protected var _faceRight:Boolean = true;
		protected var _boundryX:Number;
		protected var _thrustSpeed:Number;
		protected var _activeDuration:Number = 300;
		protected var _activeTimeoutID:uint;
		protected var _struck:Boolean = false;
		
		protected var _enemyWeapon:Boolean
		
		/**
		 * Pass two paramaters, self object and target object.  Both as Box2DPhysicsObjects
		 * 
		 * Valid Box2DPhysic Objects
		 * - Enemy/Player:       Make a damage/hurt call
		 * - Wall:               Make a sound call for hitting the wall and destroy MeleeWeapon
		 * - Breakable Wall:     Make a BreakableWall call to destroy wall
		 */
		public var onStrike:Signal;
		
		/**
		 * Pass on calling object (target) to allow them to swing their weapon again
		 */
		public var onDestroy:Signal;
		
		public function MeleeWeapon(thrustDirection:String, weaponX:int, weaponY:int, target:Box2DPhysicsObject, enemyWeapon:Boolean = false, params:Object = null, faceRight:Boolean = false) 
		{
			_enemyWeapon = enemyWeapon
			_target = target;
			_faceRight = faceRight;
			
			switch(thrustDirection)
			{
				case "normal":
					_thrustStraight = true;
					break;
				case "up":
					_thrustUp = true;
					break
				case "down":
					_thrustDown = true;
					break;
				case "sweep":
					_thrustSwing = true;
					break;
			}

			updateCallEnabled = true;
			_beginContactCallEnabled = true;
			
			if (enemyWeapon) _enemyClass = Player2
			else _enemyClass = Enemy;
			
			super("meleeweapon", params);
			
			//trace(_faceRight);
			if (_thrustUp)
			{
				if (_faceRight) _angle -= 30;
				else _angle += 30;
				y -= 20;
			}
			if (_thrustDown)
			{
				if (_faceRight) _angle += 30;
				else _angle -= 30;
				y += 20;
			}
			
			onStrike = new Signal(MeleeWeapon, Box2DPhysicsObject);
			onDestroy = new Signal(Box2DPhysicsObject);
			
			_activeTimeoutID = setTimeout(destroyWeapon, _activeDuration);
		}
		
		public function strikeOpponent():void
		{
			if (_struck) return;
			_struck = true;
			
			updateAnimation();
			
			//Not collidable with anything anymore
			var filter:b2FilterData = new b2FilterData();
			filter.maskBits = PhysicsCollisionCategories.GetNone();
			_fixture.SetFilterData(filter);
			
			onStrike.dispatch(this, _contact);
		}
		
		override public function handleBeginContact(contact:b2Contact):void 
		{
			_contact = Box2DUtils.CollisionGetOther(this, contact);
			var contactCast:Box2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact) as Box2DPhysicsObject;
			var contactType:String = contactCast.name;
			
			//trace(contactType);

			if (!contact.GetFixtureB().IsSensor())
			{
				if (_enemyClass && _contact is _enemyClass)
				{
					strikeOpponent();
				}
				if (contactType == "wall" || contactType == "breakwall" || contactType == "climbwall" || contactType == "shadowwall")
				{
					strikeOpponent();
				}
				
			}
		}		
		
		protected function destroyWeapon():void
		{
			onDestroy.dispatch(_target);
			kill = true;
		}
		
		public function getDamage():int
		{
			return _damage;
		}
		
		override public function destroy():void
		{
			clearTimeout(_activeTimeoutID);
			onStrike.removeAll();
			
			super.destroy();
		}
		
		override protected function defineFixture():void
		{	
			super.defineFixture();
			
			_fixtureDef.isSensor = true;
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			
			//trace(_angle);
			//_bodyDef.fixedRotation = true;
			_bodyDef.angle = degreesToRads(_angle);
		}
		
		public function updateAnimation():void
		{
			
		}
				
		protected function degreesToRads(degrees:Number):Number
		{
			return (degrees * Math.PI / 180);
		}
	}
}