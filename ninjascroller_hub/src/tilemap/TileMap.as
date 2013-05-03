package tilemap 
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Joints.b2Joint;
	import Box2D.Dynamics.Joints.b2JointDef;
	import Box2D.Dynamics.Joints.b2WeldJoint;
	import Box2D.Dynamics.Joints.b2WeldJointDef;
	import citrus.core.CitrusEngine;
	import citrus.core.CitrusObject;
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
	import entities.Interface.LevelGUI.HUD;
	import entities.Interface.LevelGUI.TextFlyby;
	import entities.Platforms.RopeHorizontal;
	import entities.Player2;
	import entities.Sensors.EnemyAINode;
	import entities.Sensors.Goal;
	import entities.Sensors.InfoPoint;
	import entities.Sensors.Trophy;
	import entities.Traps.SpikeTrap;
	import entities.Traps.Trap;
	import entities.Weapons.InventoryHandler;
	import entities.Weapons.Items.AttackItem;
	import entities.Weapons.Items.LootDrop;
	import entities.Weapons.MeleeWeapons.*;
	import entities.Weapons.RangedWeapons.*;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.MovieClip;
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
		private var hud:HUD = new HUD();
		private var invHandler:InventoryHandler = new InventoryHandler();
		
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
			var spiketrap:SpikeTrap = getObjectByName("spiketrap") as SpikeTrap;
			var trainingDummy:TrainingDummy = getObjectByName("trainingdummy") as TrainingDummy;

			var rope:Vector.<CitrusObject> = getObjectsByType(RopeVerticle);
			for each (var thisRope:RopeVerticle in rope)
			{
				thisRope.onHang.add(heroOnRope);
				thisRope.onHangEnd.add(heroOffRope);
				
			}
			
			//var goal:Goal = getObjectByName("goal") as Goal;
			var goal:Vector.<CitrusObject> = getObjectsByType(Goal);
			for each(var gol:Goal in goal)
			{
				gol.onContact.add(victoryTime);
			}
			
			var trap:Vector.<CitrusObject> = getObjectsByType(Trap);
			for each (var spike:Trap in trap)
			{
				spike.onContact.add(trapDamage);
			}
			
			var tropy:Vector.<CitrusObject> = getObjectsByType(Trophy);
			for each (var trop:Trophy in tropy)
			{
				trop.onContact.add(getTrophy);
			}

			var info:Vector.<CitrusObject> = getObjectsByType(InfoPoint);
			for each (var inf:InfoPoint in info)
			{
				inf.onContact.add(displayInfo);
			}

			var enemyAINode:Vector.<CitrusObject> = getObjectsByType(EnemyAINode);
			for each (var enemyAI:EnemyAINode in enemyAINode)
			{
				enemyAI.onContact.add(enemyAICall);
			}

			var enemy:Vector.<CitrusObject> = getObjectsByType(Enemy);
			for each (var enem:Enemy in enemy)
			{
				enem.onTakeDamage.add(enemyDamage);	
				enem.onMeleeWeapon.add(swingWeapon);
				enem.onRangedWeapon.add(fireWeapon);
				enem.onDeath.add(deadEnemy);
				enem.onLoot.add(enemyLoot);
				enem.target = hero;
			}
			
			//trainingDummy.onMeleeWeapon(swingWeapon);
			
			var walkrope:Vector.<CitrusObject> = getObjectsByType(RopeHorizontal);
			for each (var walkrop:RopeHorizontal in walkrope)
			{
				
			}
 
			view.camera.setUp(hero, new MathVector(stage.stageWidth / 2, 100), new Rectangle(0, 0, 2500, 2500), new MathVector(.25, .05));
			
			//var enemy2:TrainingDummy = new TrainingDummy("enemy", { width:50, height:100 } );
			//enemy2.x = hero.x + 300;
			//enemy2.y = hero.y;
			
			//add(enemy2);
			
			hero.onDeath.add(defeat);
			hero.onFireWeapon.add(fireWeapon);
			hero.onMeleeWeapon.add(swingWeapon);
			hero.doneSwinging.add(doneSwinging);
			hero.onTakeDamage.add(heroDamage);
			hero.onAttackItem.add(attackItem);
			hero.onEnterGoalArea.add(newArea);
			
			
			
			hud.playerHP = hero.playerHP;
			
			addChild(hud);
			
			//var borderbmp:Bitmap = new Assets.LEVELBG();
			//var borderTex:Texture = Texture.fromBitmap(borderbmp);

			//addChild(new Image(borderTex));
			
			//testFunc();
			
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
			keyboard.addKeyAction("1", Keyboard.NUMBER_1, 1);
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
		
		public function victoryTime(portal:String):void
		{
			var hero:* = getObjectByName("hero");
			switch(portal)
			{
				case "exit":
					trace("You Win Muthafucka!");
					hero.setVictory();
					break;
				case "shop":
					//trace("shop");
					hero.goalType = "shop";
					break;
				case "mainmenu":
					hero.goalType = "mainmenu";
					//trace("mainmenu");
					break;
				case "levelselect":
					hero.goalType = "levelselect";
					//trace("levelselect");
					break;
			}
		}
		
		public function newArea(area:String):void
		{
			Globals.nextArea = area;
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
		
		public function heroDamage(target:*, damage:int):void
		{
			hud.playerHP = target.playerHP;
			hud.marqueUpdate("You have taken " + damage + " points of damage");
			//trace("Hero Damage Fired");
		}
		
		public function enemyDamage(target:*, damage:int):void
		{
			hud.enemyMaxHP = target.maxHitpoints;
			hud.enemyHP = target.hitpoints;
			hud.enemyName = target.enemyName;
			hud.marqueUpdate(target.enemyName + " has taken " + damage + " points of damage");
		}
		
		public function deadEnemy(target:*):void
		{
			target.kill = true;
		}
		
		public function enemyLoot(loot:String, params:Object = null):void
		{
			var lootDrop:* = new LootDrop(loot, params);
			lootDrop.onPickup.add(pickupLoot);
			add(lootDrop);
		}
		
		public function pickupLoot(loot:*, target:*):void
		{
			var i:int = 0;
			var thisLoot:int = 0;
			var haveAlready:Boolean = false;
			
			for each (var invStep:String in Globals.inventory)
			{
				if (loot.name == invStep)
				{
					Globals.invQuantity[i]++;
					haveAlready = true;
					thisLoot = i;
					hud.marqueUpdate("You collected a " + loot.name + " [" + loot.lootType + "]");
				}
				i++
			}
			if (!haveAlready && i < 100)
			{
				Globals.inventory.push(loot.name);
				Globals.invQuantity.push(1);
				Globals.invType.push(loot.lootType);
				hud.marqueUpdate("You collected a " + loot.name + " [" + loot.lootType + "]");
			}
			else if (i >= 100)
			{
				hud.marqueUpdate("Your Inventory is full");
			}
			//trace(Globals.inventory[thisLoot], Globals.invQuantity[thisLoot], loot.lootType);
			loot.kill = true;
		}
		
		public function doneSwinging(rope:*):void
		{
			trace("Done Swingin'");
			trace(rope);
			rope.removeJoint();
		}
		
		public function attackItem(weaponType:String, direction:String, enemyWeapon:Boolean, params:Object = null):void
		{
			var itemFired:* = new AttackItem(weaponType, direction, enemyWeapon, params);
			add(itemFired);
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
			//var weaponClass:* = invHandler.meleeWeapon(WeaponType);
			var meleeWeapon:Sword;
			
			var meleeJointDef:b2WeldJointDef;
			var meleeJoint:b2WeldJoint;
			
			if (faceRight) meleeWeapon = new Sword(WeaponType, faceRight, thrustDirection, target.x + target.width, target.y, target, enemyWeapon);
			else meleeWeapon = new Sword(WeaponType, faceRight, thrustDirection, target.x - target.width, target.y, target, enemyWeapon);
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
		
		override public function update(timeDelta:Number):void
		{

			super.update(timeDelta);

		}
		
	}

}