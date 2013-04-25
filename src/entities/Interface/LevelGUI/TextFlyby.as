package entities.Interface.LevelGUI
{
	import flash.events.TimerEvent;
	import starling.events.Event
	import flash.utils.Timer;
	import starling.display.Sprite;
	import starling.text.BitmapFont;
	import starling.text.TextField;
 
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class TextFlyby extends Sprite
	{
 
		public var textString:String = "";
		public var textFont:String = "Arial";
		public var textColor:uint = 0xFFFFFF;
		public var textSize:int = 12;
		public var isShadow:Boolean = true;
		public var shadowColor:uint = 0x000000;
		public var shadowOffset:int = 2;
		protected var _textDisplay:TextField;
		protected var _shadowTextDisplay:TextField;
		protected var _initialFade:Number = 0;
		protected var _fadeSpeed:Number = .05;
		protected var _solidTime:Number = 20;
		protected var _moveDelay:Number = 20;
 
		protected var updateTimer:Timer;
 
		public function TextFlyby(x:int, y:int)
		{
			this.x = x;
			this.y = y;
 
			addEventListener(Event.ADDED_TO_STAGE, initialize);
 
		}
 
		protected function initialize(e:Event):void
		{
			_textDisplay = new TextField(100, 50, textString);
			//_textDisplay.fontName = textFont;
			_textDisplay.color = textColor;
			_textDisplay.fontSize = textSize;
 
			if (isShadow)
			{
				_shadowTextDisplay = new TextField(100, 500, textString);
				//_shadowTextDisplay.fontName = textFont;
				_shadowTextDisplay.color = textColor;
				_shadowTextDisplay.fontSize = textSize;
				_shadowTextDisplay.x -= shadowOffset;
				_shadowTextDisplay.y -= shadowOffset;
				addChild(_shadowTextDisplay);
			}
 
			addChild(_textDisplay);
 
			this.alpha = _initialFade;
 
			updateTimer = new Timer(_moveDelay);
			updateTimer.addEventListener(TimerEvent.TIMER, moveUp);
			updateTimer.start();
 
			trace("Damage Flyby: " + textString);
		}
 
		protected function moveUp(e:TimerEvent):void
		{
			this.y -= 1;
			this.alpha += _fadeSpeed;
 
			//trace (this.alpha, x, y);
			if (this.alpha >= 1)
			{
				this.alpha = 1;
				_solidTime--;
				if (_solidTime <= 0)
				{
					updateTimer.stop();
					updateTimer.removeEventListener(TimerEvent.TIMER, moveUp);
					updateTimer.addEventListener(TimerEvent.TIMER, fadeout);
					updateTimer.start();
				}
			}
		}
 
		protected function fadeout(e:TimerEvent):void
		{
			this.alpha -= _fadeSpeed;
			if (this.alpha <= 0)
			{
				updateTimer.stop();
				updateTimer.removeEventListener(TimerEvent.TIMER, fadeout);
				this.removeFromParent(true);
			}
		}
 
	}
 
}