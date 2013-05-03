package entities.Weapons.RangedWeapons 
{
	import entities.Enemy.Enemy;
	import entities.Player2;
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Shuriken extends RangedWeapon 
	{

		protected var weaponParams:Object = null;
		
		public function Shuriken(name:String, direction:String, enemyWeapon:Boolean, params:Object = null)
		{	
			setProperties(name, params);
			super("rangedweapon", direction, enemyWeapon, weaponParams);
		}
		
		public function setProperties(weaponName:String, params:Object):void
		{
			switch(weaponName)
			{
				case "shuriken":
					_damage = int(Math.random() * 4) + 2;
					rotateSpeed = 30;
					weaponParams = { x:params.x, y:params.y, width:25, height:25, speed:params.speed, angle:params.angle, explodeDuration:20, fuseDuration:params.fuseDuration };
					break;
			}
		}
		
	}

}