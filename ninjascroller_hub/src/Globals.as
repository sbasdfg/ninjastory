package  
{
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Globals 
	{
		
		public static var playerHP:int = 10;
		public static var playerSTR:int = 5;
		public static var playerDEX:int = 5;
		public static var playerMAG:int = 5;
		
		public static var canDoubleJump:Boolean = true;
		public static var canWallKick:Boolean = true;
		public static var canWallClimb:Boolean = true;
		public static var canSlide:Boolean = true;
		public static var canBreakWalls:Boolean = true;
		public static var canTightRopeWalk:Boolean = true;
		public static var canGrapple:Boolean = true;
		public static var canFalcon:Boolean = true;
		public static var canShadow:Boolean = true;
		
		public static var inventory:Vector.<String> = new Vector.<String>;
		public static var invQuantity:Vector.<int> = new Vector.<int>;
		public static var invType:Vector.<String> = new Vector.<String>;
		
		public static var quickBar:Array = [ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1];
		
		public static var experience:int;
		public static var toNextLevel:int;
		public static var currentLevel:int;
		public static var yen:int;
		
		public static var nextArea:String = "null";
	}

}