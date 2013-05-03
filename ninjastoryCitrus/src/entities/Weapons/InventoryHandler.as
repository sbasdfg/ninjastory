package entities.Weapons 
{
	
	import entities.Weapons.MeleeWeapons.*;
	import entities.Weapons.RangedWeapons.*;
	import entities.Weapons.Items.*;

	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class InventoryHandler 
	{
		
		public function InventoryHandler() 
		{
			
		}
		
		public function meleeWeapon(weaponName:String):Class
		{
			switch(weaponName)
			{
				case "sword":
					return Sword;
					break;
			}
			return null;
		}
		
		public function rangedWeapon(weaponName:String):Class
		{
			switch(weaponName)
			{
				case "shuriken":
					return Shuriken;
					break;
			}
			return null;
		}
		
		public function item(itemName:String):Class
		{
			switch(itemName)
			{
				
			}
			return null;
		}
		
	}

}