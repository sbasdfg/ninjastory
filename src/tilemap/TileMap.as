package tilemap 
{
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2JointDef;
	import Box2D.Dynamics.Joints.b2WeldJoint;
	import Box2D.Dynamics.Joints.b2WeldJointDef;
	import citrus.core.CitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.core.State;
	import citrus.input.controllers.Keyboard;
	import citrus.math.MathVector;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.CitrusSprite;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.physics.box2d.Box2D;
	import citrus.utils.objectmakers.ObjectMakerStarling;
	import entities.Climbers.Rope;
	import entities.Climbers.RopeAnchor;
	import entities.Climbers.RopeVerticle;
	import entities.Enemy.Enemy;
	import entities.Enemy.TrainingDummy;
	import entities.Interface.LevelGUI.TextFlyby;
	import entities.Platforms.RopeHorizontal;
	import entities.Player2;
	import entities.Sensors.EnemyAINode;
	import entities.Sensors.Goal;
	import entities.Sensors.InfoPoint;
	import entities.Sensors.Trophy;
	import entities.Traps.SpikeTrap;
	import entities.Weapons.MeleeWeapons.Sword;
	import entities.Weapons.RangedWeapons.Shuriken;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class TileMap extends StarlingState
	{
		
		private var level:XML;
		private var box2D:Box2D;
		
		public function TileMap(zone:int = 0, quest:int = 0) 
		{
			super();
			
			switch(zone)
			{
				case 0:
					switch(quest)
					{
						case 0:
							level = XML(new Assets.LEVEL1XML());
							break;
					}
					break;
			}
			
			var objects:Array = [Hero, Platform];
			
		}
		
		override public function initialize():void
		{
			super.initialize();
			
			box2D = new Box2D("box2d");
			box2D.visible = true;
			add(box2D);
			
			var bitmap:Bitmap = new Assets.MAPTILES();
			var texture:Texture = Texture.fromBitmap(bitmap);
			var xml:XML = XML(new Assets.MAPTILEXML());
			var sTextureAtlas:TextureAtlas = new TextureAtlas(texture, xml);
			
			ObjectMakerStarling.FromTiledMap(level, sTextureAtlas);
			
			
 
			var hero:Player2 = getObjectByName("hero") as Player2;
			var rope:RopeVerticle = getObjectByName("rope") as RopeVerticle;
			var goal:Goal = getObjectByName("goal") as Goal;
			var spiketrap:SpikeTrap = getObjectByName("spiketrap") as SpikeTrap;
			var trophy:Trophy = getObjectByName("trophy") as Trophy;
			var info:InfoPoint = getObjectByName("infopoint") as InfoPoint;
			var enemyAINode:EnemyAINode = getObjectByName("enemyainode") as EnemyAINode;
			var enemy:Enemy = getObjectByName("enemy") as Enemy;
			var walkRope:RopeHorizontal = getObjectByName("ropewalk") as RopeHorizontal;
 
			view.camera.setUp(hero, new MathVector(stage.stageWidth / 2, 100), new Rectangle(0, 0, 2500, 2500), new MathVector(.25, .05));
			
			var enemy2:TrainingDummy = new TrainingDummy("enemy", { width:50, height:100 } );
			enemy2.x = hero.x + 300;
			enemy2.y = hero.y;
			
			add(enemy2);
			
			hero.onDeath.add(defeat);
			hero.onFireWeapon.add(fireWeapon);
			hero.onMeleeWeapon.add(swingWeapon);
			hero.doneSwinging.add(doneSwinging);
			hero.onTakeDamage.add(heroDamage);
			
			rope.onHang.add(heroOnRope);
			rope.onHangEnd.add(heroOffRope);
			
			goal.onContact.add(victoryTime);
			
			spiketrap.onContact.add(trapDamage);
			
			trophy.onContact.add(getTrophy);
			
			info.onContact.add(displayInfo);
			
			enemyAINode.onContact.add(enemyAICall);
			
			//addChild(new TextFlyby(750, 2350));
			var borderbmp:Bitmap = new Assets.LEVELBG();
			var borderTex:Texture = Texture.fromBitmap(borderbmp);
			
			//addChild(new Image(borderTex));
			
			var keyboard:Keyboard = CitrusEngine.getInstance().input.keyboard as Keyboard;
			keyboard.addKeyAction("left", Keyboard.LEFT, 1);
			keyboard.addKeyAction("left", Keyboard.A, 1);
			keyboard.addKeyAction("right", Keyboard.RIGHT, 1);
			keyboard.addKeyAction("right", Keyboard.D, 1);
			keyboard.addKeyAction("crouch", Keyboard.DOWN, 1);
			keyboard.addKeyAction("crouch", Keyboard.S, 1);
			keyboard.addKeyAction("lookup", Keyboard.UP, 1);
			keyboard.addKeyAction("lookup", Keyboard.W, 1);
			keyboard.addKeyAction("jump", Keyboard.SPACE, 1);
			keyboard.addKeyAction("shoot", Keyboard.X, 1);
			keyboard.addKeyAction("melee", Keyboard.Z, 1);
		}
		
		public function displayInfo():void
		{
			trace("there will be information here");
		}
		
		public function enemyAICall():void
		{
			trace("Enemy:  I think I am supposed to do something.");
		}
		
		public function getTrophy():void
		{
			trace("#include <trophy.h>");
		}
		
		public function trapDamage():void
		{
			trace("Ow!  That's a trap!");
		}
		
		public function victoryTime():void
		{
			trace("You Win Muthafucka!");
			var hero:* = getObjectByName("hero");
			hero.setVictory();
		}
		
		public function heroOnRope(thisRope:*):void
		{
			trace("Swingin'");
			var hero:* = getObjectByName("hero");
			hero.grabRope(thisRope);
		}
		
		public function heroOffRope():void
		{
			trace("Ain't Swingin'");
		}
		
		public function heroDamage(textX:int, textY:int, textString:String):void
		{
			var damageTextContainer:CitrusSprite;
			damageTextContainer = new CitrusSprite("dmgtxt", { x:textX, y:textY, view: new Sprite() } );
			var damageText:TextFlyby = new TextFlyby(0, 0);
			damageText.textColor = 0xFF0000;
			damageText.textString = textString;
			trace("Flyby Should say: " + textString);
			(damageTextContainer.view as Sprite).addChild(damageText);
			add(damageTextContainer);
		}
		
		public function doneSwinging():void
		{
			var rope:* = getObjectByName("rope");
			trace("Done Swingin'");
			rope.removeJoint();
		}
		
		public function fireWeapon(weaponType:String, direction:String, enemyWeapon:Boolean, params:Object = null):void
		{
			var firedWeapon:Shuriken = new Shuriken(weaponType, direction, enemyWeapon, params);
			add(firedWeapon);
			firedWeapon.onExplode.add(weaponDamage);
			//trace(params);
		}
		
		public function swingWeapon(WeaponType:String, thrustDirection:String, enemyWeapon:Boolean, faceRight:Boolean, target:Box2DPhysicsObject):void
		{
			var meleeWeapon:Sword;
			
			var meleeJointDef:b2WeldJointDef;
			var meleeJoint:b2WeldJoint;
			
			if (faceRight) meleeWeapon = new Sword(faceRight, thrustDirection, target.x + target.width, target.y, target, enemyWeapon);
			else meleeWeapon = new Sword(faceRight, thrustDirection, target.x - target.width, target.y, target, enemyWeapon);
			add(meleeWeapon);
			
			meleeWeapon.onDestroy.add(destroyMeleeWeapon);
			meleeWeapon.onStrike.add(weaponDamage);
			
			meleeJointDef = new b2WeldJointDef
			meleeJointDef.Initialize(target.body, meleeWeapon.body, target.body.GetWorldCenter());
			
			meleeJoint = b2WeldJoint(box2D.world.CreateJoint(meleeJointDef));
		}
		
		
		
		public function destroyMeleeWeapon(target:*):void
		{
			target._usingMeleeWeapon = false;
		}
		
		public function weaponDamage(currentWeapon:*, weaponTarget:*):void
		{
			if (weaponTarget.name == "enemy" || weaponTarget.name == "hero") weaponTarget.hurt(currentWeapon.getDamage(), currentWeapon.x);
			else if (weaponTarget.name == "breakwall" && Globals.canBreakWalls) weaponTarget.kill = true;
			else trace ("You hit a wall dumbass");
			trace(weaponTarget.name);
			//currentWeapon.kill = true;
		}
		
		public function defeat():void
		{
			trace("Defeated");
		}
		
	}

}