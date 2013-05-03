package entities.Interface.LevelGUI 
{
	import flash.display.Bitmap;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class HUDMarque extends Sprite 
	{
		
		protected var _messageQueue:Array = [];
		protected var _currentMessageNum:int = 0;
		
		protected var _messText:TextField;
		
		private var _messageTimer:Timer = new Timer(500, 0);
		
		public function HUDMarque() 
		{
			addEventListener(Event.ADDED_TO_STAGE, initMarque);
		}
		
		protected function initMarque(e:Event):void
		{
			var marbmp:Bitmap = new Assets.HUDMARQUE();
			var martex:Texture = Texture.fromBitmap(marbmp);
			var marImage:Image = new Image(martex);
			
			marImage.x = 150;
			marImage.y = 0;
			
			addChild(marImage);
			
			_messageQueue[0] = "Welcome to Ninja Story";
			_currentMessageNum = 0;
			_messText = new TextField(400, 30, _messageQueue[0]);
			_messText.hAlign = HAlign.CENTER;
			_messText.x = 200;
			_messText.y = 10;
			_messText.fontSize = 16;
			
			addChild(_messText);
			
			_messageTimer.start()
			_messageTimer.addEventListener(TimerEvent.TIMER, scrollMessage);
			
		}
		
		public function addMessage(message:String):void
		{
			_messageQueue.push(message);
			//trace(_currentMessageNum, _messageQueue.length);
		}
		
		protected function scrollMessage(e:TimerEvent):void
		{
			//trace ("Timer Fire");
			if (_messageQueue.length > _currentMessageNum)
			{
				_messText.text = _messageQueue[_currentMessageNum];
				_currentMessageNum++;
			}
		}
		
	}

}