package entities.Weapons.MeleeWeapons 
{
	import citrus.objects.Box2DPhysicsObject;
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Sword extends MeleeWeapon 
	{
		
		protected var _sweepHeight:Number;
		
		public function Sword(name:String, faceRight:Boolean, thrustDirection:String, weaponX:int, weaponY:int, target:Box2DPhysicsObject, enemyWeapon:Boolean = false) 
		{
			
			var params:Object;
			if (thrustDirection == "sweep") _sweepHeight = target.height - 10;
			else _sweepHeight = 10;
			
			if (faceRight) 
			{
				params = { x:weaponX, y:weaponY, width:50, height:_sweepHeight };
				_angle = 0;
			}
			else 
			{
				params = { x:weaponX, y:weaponY, width:50, height:_sweepHeight };
				_angle = 180;
			}

			_damage = int(Math.random() * 4) + 2;
			
			super(thrustDirection, weaponX, weaponY, target, enemyWeapon, params, faceRight);
			//trace(faceRight);
		}
		
		public function setProperties(weaponType:String, params:Object):void
		{
			switch(weaponType)
			{
				case "sword":
					break;
			}
		}
		
	}

}