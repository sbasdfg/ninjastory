package entities.Climbers 
{
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.physics.box2d.Box2DUtils;
	import entities.Player2;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import org.osflash.signals.Signal;
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Rope extends Box2DPhysicsObject 
	{
		
		public var onHang:Signal;
		public var onHangEnd:Signal;
		
		/**
		 * The object where the rope is attached
		 */
		public var anchor:Box2DPhysicsObject;
		public var ropeLength:uint = 200;
		public var numSegments:uint = 9;
		public var widthSegment:uint = 5;
		public var useTextrue:Boolean = false;
		
		/**
		 * Texture for the segments
		 */
		public var segmentTexture:Texture;
		
		/**
		 * The position where the hero is connected, relative to his origin
		 */
		public var heroAnchorOffset:b2Vec2;
		
		/**
		 * The Impulse applied to the hero's center of mass when jump off the rope
		 */
		public var leaveImpulse:b2Vec2;
		public var maxSwingVelocity:Number;
		
		private var hero:Player2;
		private var ws:Number = 30;  //worldscale;
		private var heightSegment:uint;
		private var maxV:Number;
		
		private var _vecBodyDefRope:Vector.<b2BodyDef>;
		private var _vecBodyRope:Vector.<b2Body>;
		private var _vecFixtureDefRope:Vector.<b2FixtureDef>;
		private var _vecRevoluteJointDef:Vector.<b2RevoluteJointDef>;
		private var _vecSprites:Vector.<CitrusSprite>;
		private var _shapeRope:b2Shape;
		
		private var connectingJoint:b2Joint;
		private var targetJointIndex:int;
		
		private var displayReady:Boolean = false;
		private var ropeAdded:Boolean = false;
		private var up:Boolean;
		private var moveTimer:Timer;

		public function Rope(name:String, params:Object = null, newLength:Number = 200, ropeSegments:Number = 9) 
		{
			updateCallEnabled = true;
			_preContactCallEnabled = true;
			
			ropeLength = newLength;
			numSegments = ropeSegments;
			
			trace(ropeLength);
			trace(numSegments);
			
			super(name, params);
			
			onHang = new Signal(Box2DPhysicsObject);
			onHangEnd = new Signal();
			
			moveTimer = new Timer(50, 0);
			moveTimer.addEventListener(TimerEvent.TIMER, onMoveTimer);
		}
		
		override public function destroy():void
		{
			onHang.removeAll();
			onHangEnd.removeAll();
			
			var i:uint = 0;
			for each (var bodyRope:b2Body in _vecBodyRope)
			{
				_box2D.world.DestroyBody(bodyRope);
				_ce.state.remove(_vecSprites[i]);
				i++;
			}
			super.destroy();
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			if (displayReady) updateSegmentDisplay();
			//trace(y);
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			
			heightSegment = ropeLength / numSegments;
			if (useTextrue)
			{
				initDisplay();
			}
			_vecBodyDefRope = new Vector.<b2BodyDef>();
			var bodyDefRope:b2BodyDef;
			for (var i:uint = 0; i < numSegments; i++)
			{
				bodyDefRope = new b2BodyDef();
				bodyDefRope.type = b2Body.b2_dynamicBody;
				bodyDefRope.position.Set(anchor.x / ws, anchor.y / ws + anchor.height / 2 / ws + i * heightSegment / ws);
				_vecBodyDefRope.push(bodyDefRope);
			}
		}
		
		override protected function createBody():void
		{
			super.createBody();
			_vecBodyRope = new Vector.<b2Body>();
			var bodyRope:b2Body;
			for each (var bodyDefRope:b2BodyDef in _vecBodyDefRope)
			{
				bodyRope = _box2D.world.CreateBody(bodyDefRope);
				bodyRope.SetUserData(this);
				_vecBodyRope.push(bodyRope);
			}
		}
		
		override protected function createShape():void
		{
			super.createShape();
			_shapeRope = new b2PolygonShape();
			b2PolygonShape(_shapeRope).SetAsBox(5 / _box2D.scale, 25 / _box2D.scale);
			//trace (widthSegment);
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_vecFixtureDefRope = new Vector.<b2FixtureDef>();
			var fixtureDefRope:b2FixtureDef;
			for (var i:uint = 0; i < numSegments; i++)
			{
				fixtureDefRope = new b2FixtureDef();
				fixtureDefRope.shape = _shapeRope;
				fixtureDefRope.density = 35;
				fixtureDefRope.restitution = 0;
				fixtureDefRope.userData = { name:i };
				_vecFixtureDefRope.push(fixtureDefRope);
			}
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			var i:uint = 0;
			for each (var fixtureDefRope:b2FixtureDef in _vecFixtureDefRope)
			{
				_vecBodyRope[i].CreateFixture(fixtureDefRope);
				i++;
			}
		}
		
		override protected function defineJoint():void
		{
			_vecRevoluteJointDef = new Vector.<b2RevoluteJointDef>();
			for (var i:uint = 0; i < numSegments; i++)
			{
				if (i == 0) revolutionJoint(anchor.body, _vecBodyRope[i], new b2Vec2(0, anchor.height / 2 / ws), new b2Vec2(0, -heightSegment / ws));
				else revolutionJoint(_vecBodyRope[i - 1], _vecBodyRope[i], new b2Vec2(0, (heightSegment - 2) / ws), new b2Vec2(0, -heightSegment / ws));
				
			}
		}
		
		private function revolutionJoint(bodyA:b2Body, bodyB:b2Body, anchorA:b2Vec2, anchorB:b2Vec2):void
		{
			var revolutionJointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			revolutionJointDef.localAnchorA.Set(anchorA.x, anchorA.y);
			revolutionJointDef.localAnchorB.Set(anchorB.x, anchorB.y);
			revolutionJointDef.bodyA = bodyA;
			revolutionJointDef.bodyB = bodyB;
			revolutionJointDef.motorSpeed = 0;
			revolutionJointDef.enableMotor = true;
			revolutionJointDef.maxMotorTorque = 0.1;
			revolutionJointDef.collideConnected = false;
			revolutionJointDef.enableLimit = true;
			revolutionJointDef.lowerAngle = deg2rad(0);
			revolutionJointDef.upperAngle = deg2rad(180);
			_vecRevoluteJointDef.push(revolutionJointDef);
		}
		
		override protected function createJoint():void
		{
			for each (var revolutionJointDef:b2RevoluteJointDef in _vecRevoluteJointDef)
			{
				_box2D.world.CreateJoint(revolutionJointDef);
			}
			if (heroAnchorOffset == null) heroAnchorOffset = new b2Vec2();
			else heroAnchorOffset.Multiply(1 / 30);
			if (leaveImpulse == null) leaveImpulse = new b2Vec2();
			_body.SetActive(false);
			hero = _ce.state.getFirstObjectByType(Player2) as Player2;
			maxV = hero.maxVelocity;
		}
		
		override public function handlePreSolve(contact:b2Contact, oldManifold:b2Manifold):void
		{
			contact.SetEnabled(false);
			if (Box2DUtils.CollisionGetOther(this, contact) is Player2)
			{
				if (!ropeAdded && !hero.body.GetJointList() && hero._canSwingAgain)
				{
					targetJointIndex = int(((hero.getBody().GetPosition().y * ws - (hero.height) / 2) - _vecBodyRope[0].GetPosition().y * ws) / (heightSegment * 2 - 2));
					if (targetJointIndex < 1) targetJointIndex = 1;
					else if (targetJointIndex > _vecBodyRope.length - 1) targetJointIndex = _vecBodyRope.length - 1;
					
					revolutionJoint(_vecBodyRope[targetJointIndex], hero.body, new b2Vec2(0, heightSegment / ws), heroAnchorOffset);
					connectingJoint = _box2D.world.CreateJoint(_vecRevoluteJointDef[_vecRevoluteJointDef.length - 1]);
					//hero.body.SetFixedRotation(false);
					hero.maxVelocity = maxSwingVelocity;
					onHang.dispatch(this);
					/**
					 * if you don't want to us signals put the necessary assignments here
					 * e.g. hero.isHanging = true; (hero as yourHeroClass).currentRope = this.name;
					 */
				}
			}
		}
		
		/**
		 * When startClimbing() is called, a timer starts and onTick the hero travels up or down
		 * until he reaches end of the rope or stopClimbing() is called
		 */
		protected function onMoveTimer(event:TimerEvent):void
		{
			if (up && targetJointIndex >= 2)
			{
				moveTimer.delay = 150;
				_box2D.world.DestroyJoint(connectingJoint);
				_vecRevoluteJointDef[_vecRevoluteJointDef.length - 1] = null;
				revolutionJoint(_vecBodyRope[targetJointIndex - 1], hero.body, new b2Vec2(0, heightSegment / ws), heroAnchorOffset);
				connectingJoint = _box2D.world.CreateJoint(_vecRevoluteJointDef[_vecRevoluteJointDef.length - 1]);
				targetJointIndex--;
			}
			else if (up && targetJointIndex == 0)
			{
				_box2D.world.DestroyJoint(connectingJoint);
				_vecRevoluteJointDef[_vecRevoluteJointDef.length -1] = null;
				revolutionJoint(anchor.body, hero.body, new b2Vec2(0, anchor.height / 2 / ws), heroAnchorOffset);
				connectingJoint = _box2D.world.CreateJoint(_vecRevoluteJointDef[_vecRevoluteJointDef.length - 1]);
			}
			else if  (!up && targetJointIndex < _vecBodyRope.length -1)
			{
				moveTimer.delay = 50;
				_box2D.world.DestroyJoint(connectingJoint);
				_vecRevoluteJointDef[_vecRevoluteJointDef.length - 1] = null;
				revolutionJoint(_vecBodyRope[targetJointIndex + 1], hero.body, new b2Vec2(0, heightSegment / ws), heroAnchorOffset);
				connectingJoint = _box2D.world.CreateJoint(_vecRevoluteJointDef[_vecRevoluteJointDef.length - 1]);
				targetJointIndex++;
			}
		}
		
		/**
		 * pass in the direction true:up, false:down
		 */
		public function startClimbing(upwards:Boolean):void
		{
			up = upwards;
			//onMoveTimer();
			moveTimer.start();
			trace(up);
		}
		
		public function stopClimbing():void
		{
			moveTimer.reset();
		}
		
		public function removeJoint():void
		{
			_box2D.world.DestroyJoint(connectingJoint);
			_vecRevoluteJointDef[_vecRevoluteJointDef.length - 1] = null;
			connectingJoint = null;
			
			/**
			 * TO MANAGE IN YOUR HERO CLASS
			 * (hero as HeroSnowman).isHanging = false;
			 */
			
			 onHangEnd.dispatch();
			 hero.body.ApplyImpulse(leaveImpulse, hero.body.GetWorldCenter());
			 hero.body.SetAngle(deg2rad(0));
			 hero.body.SetAngularVelocity(0);
			 hero.body.SetFixedRotation(true);
			 hero.maxVelocity = maxV;
			 setTimeout(function():void { ropeAdded = false; }, 1000);
		}
		
		private function initDisplay():void
		{
			displayReady = true;
			_vecSprites = new Vector.<CitrusSprite>();
			
			for (var i:uint = 0; i < numSegments; i++)
			{
				var img:Image = new Image(segmentTexture);
				img.scaleX = img.scaleY = (heightSegment) * 2 / segmentTexture.width;
				var image:CitrusSprite = new CitrusSprite(i.toString(), { group:2, width:heightSegment * 2, height:widthSegment, view:img, registration:"center" } );
				_ce.state.add(image);
				_vecSprites.push(image);
			}
		}
		
		private function updateSegmentDisplay():void
		{
			var i:uint = 0;
			for each(var bodyRope:b2Body in _vecBodyRope)
			{
				_vecSprites[i].x = bodyRope.GetPosition().x * ws;
				_vecSprites[i].y = bodyRope.GetPosition().y * ws;
				_vecSprites[i].rotation = rad2deg(bodyRope.GetAngle()) + 90;
				i++;
			}
		}
		
		private function deg2rad(degrees:Number):Number
		{
			return (degrees * 180 / Math.PI);
		}
		
		private function rad2deg(radians:Number):Number
		{
			return (radians * Math.PI / 180);
		}
	}
}