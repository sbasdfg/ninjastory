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
		}
		
	}

}