package entities.Enemy 
{
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class TrainingDummy extends Enemy 
	{
		
		public function TrainingDummy(name:String, params:Object = null) 
		{
			super("enemy", params);
			_hitpoints = 10;
			_maxHitpoints = 10;
			_enemyName = "Training Dummy";
			_visionHorizontal = 500;
			_visionVertical = 75;
			_chasingTime = 5;
			_looksForPlayer = true;
			//_canMove = true;
			_canMelee = true;
			//_canRanged = true;
			//_rangedDelay = 5000;
			_loot.push("Wood Sliver");
			_loot.push("Wood Sliver");
			_lootType.push("Junk");
			_lootType.push("Junk");
		}
		
	}

}