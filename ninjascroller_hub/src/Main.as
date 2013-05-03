package 
{
	import citrus.core.starling.StarlingCitrusEngine;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import tilemap.TileMap;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class Main extends StarlingCitrusEngine
	{
		public function Main():void 
		{
			//var loader:Loader = new Loader();
			//loader.load(new URLRequest("assets/xml/levels/maptest.tmx"));
			//loader.contentLoaderInfo.addEventListener(Event.COMPLETE, levelLoaded, false, 0, true);
		}
		
		override protected function handleAddedToStage(e:Event):void
		{
			super.handleAddedToStage(e);
			setUpStarling(true);
			state = new TileMap();

		}
		
		public function levelLoaded(e:Event):void
		{
			var levelXML:XML = e.target.loader.content;
			trace(levelXML);
			state = new TileMap();
		}

		public function get playerHP():int
		{
			return Globals.playerHP;
		}
		
		public function set playerHP(_playerHP:int):void
		{
			Globals.playerHP = _playerHP;
		}
		
		public function get playerSTR():int
		{
			return Globals.playerSTR;
		}
		
		public function set playerSTR(_playerSTR:int):void
		{
			Globals.playerSTR = _playerSTR;
		}
		
		public function get playerDEX():int
		{
			return Globals.playerDEX;
		}
		
		public function set playerDEX(_playerDEX:int):void
		{
			Globals.playerDEX = _playerDEX;
		}
		
		public function get playerMAG():int
		{
			return Globals.playerMAG;
		}
		
		public function set playerMAG(_playerMAG:int):void
		{
			Globals.playerMAG = _playerMAG;
		}
		
		public function get canDoubleJump():Boolean
		{
			return Globals.canDoubleJump;
		}
		
		public function set canDoubleJump(_canDoubleJump:Boolean):void
		{
			Globals.canDoubleJump = _canDoubleJump;
		}
		
		public function get canWallKick():Boolean
		{
			return Globals.canWallKick;
		}
		
		public function set canWallKick(_canWallKick:Boolean):void
		{
			Globals.canWallKick = _canWallKick;
		}
		
		public function get canWallClimb():Boolean
		{
			return Globals.canWallClimb;
		}
		
		public function set canWallClimb(_canWallClimb:Boolean):void
		{
			Globals.canWallClimb = _canWallClimb;
		}
		
		public function get canSlide():Boolean
		{
			return Globals.canSlide;
		}
		
		public function set canSlide(_canSlide:Boolean):void
		{
			Globals.canSlide = _canSlide;
		}
		
		public function get canBreakWalls():Boolean
		{
			return Globals.canBreakWalls;
		}
		
		public function set canBreakWalls(_canBreakWalls:Boolean):void
		{
			Globals.canBreakWalls = _canBreakWalls;
		}
		
		public function get canTightRopeWalk():Boolean
		{
			return Globals.canTightRopeWalk;
		}
		
		public function set canTightRopeWalk(_canTightRopeWalk:Boolean):void
		{
			Globals.canTightRopeWalk = _canTightRopeWalk;
		}
		
		public function get canGrapple():Boolean
		{
			return Globals.canGrapple;
		}
		
		public function set canGrapple(_canGrapple:Boolean):void
		{
			Globals.canGrapple = _canGrapple;
		}
		
		public function get canFalcon():Boolean
		{
			return Globals.canFalcon;
		}
		
		public function set canFalcon(_canFalcon:Boolean):void
		{
			Globals.canFalcon = _canFalcon;
		}
		
		public function get canShadow():Boolean
		{
			return Globals.canShadow;
		}
		
		public function set canShadow(_canShadow:Boolean):void
		{
			Globals.canShadow = _canShadow;
		}
		
		public function get inventory():Vector.<String>
		{
			return Globals.inventory;
		}
		
		public function set inventory(_inventory:Vector.<String>):void
		{
			Globals.inventory = _inventory;
		}
		
		public function get invQuantity():Vector.<int>
		{
			return Globals.invQuantity;
		}
		
		public function set invQuantity(_invQuantity:Vector.<int>):void
		{
			Globals.invQuantity = _invQuantity;
		}
		
		public function get invType():Vector.<String>
		{
			return Globals.invType;
		}
		
		public function set invType(_invType:Vector.<String>):void
		{
			Globals.invType = _invType;
		}
		
		public function get quickBar():Array
		{
			return Globals.quickBar;
		}
		
		public function set quickBar(_quickBar:Array):void
		{
			Globals.quickBar = _quickBar;
		}
		
		public function get experience():int
		{
			return Globals.experience;
		}
		
		public function set experience(_experience:int):void
		{
			Globals.experience = _experience;
		}
		
		public function get toNextLevel():int
		{
			return Globals.toNextLevel;
		}
		
		public function set toNextLevel(_toNextLevel:int):void
		{
			Globals.toNextLevel = _toNextLevel;
		}
		
		public function get currentLevel():int
		{
			return Globals.currentLevel;
		}
		
		public function set currentLevel(_currentLevel:int):void
		{
			Globals.currentLevel = _currentLevel;
		}
		
		public function get yen():int
		{
			return Globals.yen;
		}
		
		public function set yen(_yen:int):void
		{
			Globals.yen = _yen;
		}
		
		public function get nextArea():String
		{
			return Globals.nextArea;
		}
		
		public function set nextArea(_nextArea:String):void
		{
			Globals.nextArea = _nextArea;
		}
	}
	
}