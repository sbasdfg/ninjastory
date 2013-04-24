package entities.Platforms 
{
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import starling.extensions.textureAtlas.TextureItem;
	import starling.textures.Texture;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Rope extends Box2DPhysicsObject 
	{
		
		public var _leftAnchor:Box2DPhysicsObject;
		public var _rightAnchor:Box2DPhysicsObject;
		public var ropelength:Number = 200;
		public var numSegments:Number = 9;
		public var widthSegment:Number = 5;
		public var useTexture:Boolean = false;
		
		public var segmentTexture:Texture;
		
		private var ws:Number = 30;
		private var heightSegment:Number;
		
		private var _vecBodyDefRope:Vector.<b2Body>
		private var _vecBodyRope:Vector.<b2Body>;
		private var _vecFixtureDefRope:Vector.<b2FixtureDef>;
		private var _vecRevoluteJointDef:Vector.<b2RevoluteJoint>;
		private var _vecSprites:Vector.<CitrusSprite>;
		private var _shapeRope:b2Shape;
		
		private var displayReady:Boolean = false;
		private var ropeAdded:Boolean = false;
		
		public function Rope(name:String, params:Object = null, newLength:Number = 200, newSegments:Number = 9) 
		{
			
			super(name, params);
		}
		
	}

}