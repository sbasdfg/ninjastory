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
		
		public function Shuriken(name:String, direction:String, enemyWeapon:Boolean, params:Object = null)
		{	
			super("rangedweapon", direction, enemyWeapon, params);
			_damage = int(Math.random() * 4) + 2;
			rotateSpeed = 30;
		}
		
	}

}