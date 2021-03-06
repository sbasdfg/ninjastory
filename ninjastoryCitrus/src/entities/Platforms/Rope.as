package entities.Platforms 
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Joints.b2JointDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import Box2D.Dynamics.Joints.b2WeldJointDef;
	import citrus.math.MathUtils;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	import flash.sampler.NewObjectSample;
	import starling.display.Image;
	import starling.extensions.textureAtlas.TextureItem;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Rope extends Box2DPhysicsObject 
	{
		public var leftAnchor:Box2DPhysicsObject;
		public var rightAnchor:Box2DPhysicsObject;

		public var bridgeLength:uint;
		public var numSegments:uint = 9;
		public var heightSegment:uint = 15;
		public var useTexture:Boolean = false;
		public var density:Number = 10;
		public var friction:Number = 1;
		public var restitution:Number = 0;
		public var segmentTexture:Texture;

		private var widthSegment:uint;
		private var ws:Number;// worldscale
		private var display:Boolean = false;

		private var _vecBodyDefBridge:Vector.<b2BodyDef>
		private var _vecBodyBridge:Vector.<b2Body>;
		private var _vecFixtureDefBridge:Vector.<b2FixtureDef>;
		private var _vecRevoluteJointDef:Vector.<b2RevoluteJointDef>;
		private var _vecWeldJointDef:Vector.<b2WeldJointDef>;
		private var _shapeSegment:b2Shape;
		private var _vecSprites:Vector.<CitrusSprite>;
		
		public function Rope(name:String, params:Object = null, newLength:Number = 200, newSegments:Number = 9) 
		{
			updateCallEnabled = true;
			
			super(name, params);
			
			bridgeLength = newLength;
			numSegments = newSegments;
		}
		
		override public function destroy():void
		{
			var i:uint = 0;
			for each (var bodyChain:b2Body in _vecBodyBridge) {
				_box2D.world.DestroyBody(bodyChain);
				_ce.state.remove(_vecSprites[i]);
				++i;
			}
			super.destroy();
		}

		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);

			if (display)
				updateSegmentDisplay();
		}	
		
		override protected function defineBody():void 
		{
			super.defineBody();

			ws = _box2D.scale;

			if (!bridgeLength) {
				var distance:Number = MathUtils.DistanceBetweenTwoPoints(rightAnchor.x - int(rightAnchor.width / 2), leftAnchor.x + int(leftAnchor.width / 2), rightAnchor.y, leftAnchor.y) / 2;
				bridgeLength = distance;
			}

			widthSegment = bridgeLength / numSegments
			if (useTexture) {
				initDisplay();
			}
			_vecBodyDefBridge = new Vector.<b2BodyDef>();
			var bodyDefChain:b2BodyDef;
			for (var i:uint = 0; i < numSegments; ++i) {
				bodyDefChain = new b2BodyDef();
				bodyDefChain.type = b2Body.b2_dynamicBody;
				bodyDefChain.linearDamping = 10;
				bodyDefChain.position.Set(leftAnchor.x / ws + leftAnchor.width / 2 / ws + i * widthSegment / ws - 10 / ws, leftAnchor.y / ws);
				_vecBodyDefBridge.push(bodyDefChain);
			}
		}	
		
		override protected function createBody():void 
		{
			super.createBody();

			_vecBodyBridge = new Vector.<b2Body>();
			var bodyChain:b2Body;
			for each (var bodyDefChain:b2BodyDef in _vecBodyDefBridge) {
				bodyChain = _box2D.world.CreateBody(bodyDefChain);
				bodyChain.SetUserData(this);
				_vecBodyBridge.push(bodyChain);
			}
		}

		override protected function createShape():void 
		{
			super.createShape();

			_shapeSegment = new b2PolygonShape();
			b2PolygonShape(_shapeSegment).SetAsBox(widthSegment / ws, 5 / ws);
		}		
		
		override protected function defineFixture():void 
		{
			super.defineFixture();

			_vecFixtureDefBridge = new Vector.<b2FixtureDef>();
			var fixtureDefChain:b2FixtureDef;
			for (var i:uint = 0; i < numSegments; ++i) {
				fixtureDefChain = new b2FixtureDef();
				fixtureDefChain.shape = _shapeSegment;
				fixtureDefChain.density = density;
				fixtureDefChain.friction = friction;
				fixtureDefChain.restitution = restitution;
				fixtureDefChain.filter.maskBits = PhysicsCollisionCategories.Get("GoodGuys");
				_vecFixtureDefBridge.push(fixtureDefChain);
			}
		}

		override protected function createFixture():void 
		{
			super.createFixture();

			var i:uint = 0;
			for each (var fixtureDefChain:b2FixtureDef in _vecFixtureDefBridge) {
				_vecBodyBridge[i].CreateFixture(fixtureDefChain);
				++i;
			}
		}
		
		override protected function defineJoint():void 
		{
			_vecRevoluteJointDef = new Vector.<b2RevoluteJointDef>();
			_vecWeldJointDef = new Vector.<b2WeldJointDef>();

			for (var i:uint = 0; i < numSegments; ++i) {

				if (i == 0)
					revoluteJoint(leftAnchor.body, _vecBodyBridge[i], new b2Vec2(leftAnchor.width / 2 / ws, (-leftAnchor.height / 2 + heightSegment) / ws), new b2Vec2(-widthSegment / ws, 0));
				else
					revoluteJoint(_vecBodyBridge[i - 1], _vecBodyBridge[i], new b2Vec2(widthSegment / ws, 0), new b2Vec2(-widthSegment / ws, 0));
			}
			revoluteJoint(_vecBodyBridge[numSegments - 1], rightAnchor.body, new b2Vec2(widthSegment / ws, 0), new b2Vec2(-(rightAnchor.width / 2 / ws), (-rightAnchor.height / 2 + heightSegment) / ws));
			_body.SetActive(false);
		}
		
		private function weldJoint(bodyA:b2Body, bodyB:b2Body, anchorA:b2Vec2, anchorB:b2Vec2):void
		{
			var weldJointDef:b2WeldJointDef = new b2WeldJointDef();
			weldJointDef.localAnchorA.Set(anchorA.x, anchorA.y);
			weldJointDef.localAnchorB.Set(anchorB.x, anchorB.y);
			weldJointDef.bodyA = bodyA;
			weldJointDef.bodyB = bodyB;
			weldJointDef.collideConnected = false;
			_vecWeldJointDef.push(weldJointDef);
		}

		private function revoluteJoint(bodyA:b2Body, bodyB:b2Body, anchorA:b2Vec2, anchorB:b2Vec2):void 
		{

			var revoluteJointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			revoluteJointDef.localAnchorA.Set(anchorA.x, anchorA.y);
			revoluteJointDef.localAnchorB.Set(anchorB.x, anchorB.y);
			revoluteJointDef.bodyA = bodyA;
			revoluteJointDef.bodyB = bodyB;
			revoluteJointDef.enableMotor = true;
			revoluteJointDef.motorSpeed = 10;
			revoluteJointDef.maxMotorTorque = 200;
			revoluteJointDef.collideConnected = false;
			revoluteJointDef.enableLimit = true;
			revoluteJointDef.upperAngle = deg2rad( 0);
			revoluteJointDef.lowerAngle = deg2rad( 0);
			_vecRevoluteJointDef.push(revoluteJointDef);
		}
		
		override protected function createJoint():void 
		{
			for each (var revoluteJointDef:b2RevoluteJointDef in _vecRevoluteJointDef) {
				_box2D.world.CreateJoint(revoluteJointDef);
			}
			for each (var weldJointDef:b2WeldJointDef in _vecWeldJointDef)
			{
				_box2D.world.CreateJoint(weldJointDef);
			}
		}

		public function initDisplay():void 
		{

			display = true;
			_vecSprites = new Vector.<CitrusSprite>();

			for (var i:uint = 0; i < numSegments; ++i) {
				var img:Image = new Image(segmentTexture);
				img.scaleX = img.scaleY =  (widthSegment) * 2 / segmentTexture.width;
				var image:CitrusSprite = new CitrusSprite(i.toString(), {group:2, width:_width * 2, height:_height * 2, view:img, registration:"center"});
				_ce.state.add(image);
				_vecSprites.push(image);
			}
		}

		public function updateSegmentDisplay():void 
		{

			var i:uint = 0;
			for each (var body:b2Body in _vecBodyBridge) {
				_vecSprites[i].x = body.GetPosition().x * ws;
				_vecSprites[i].y = body.GetPosition().y * ws;
				_vecSprites[i].rotation = rad2deg(body.GetAngle());
				++i;
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