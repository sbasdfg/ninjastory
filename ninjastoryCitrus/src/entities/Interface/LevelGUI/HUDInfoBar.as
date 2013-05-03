package entities.Interface.LevelGUI 
{
	import flash.display.Bitmap;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.BitmapFont;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	
	/**
	 * ...
	 * @author Megan Morgan Games
	 */
	public class HUDInfoBar extends Sprite 
	{
		
		protected var _enemy:Boolean;
		protected var _posX:Number;
		protected var _posY:Number;
		
		protected var _nameText:TextField;
		protected var _hpText:TextField;
		
		public var charName:String = "null";
		public var hitpoints:int = 0;
		public var maxHitpoints:int = 0;
		
		protected var _displaying:Boolean = false;
		
		private var _fadeTimer:Timer = new Timer(2000, 1);
		
		public function HUDInfoBar(enemy:Boolean) 
		{
			_enemy = enemy;
			addEventListener(Event.ADDED_TO_STAGE, infoBarInit);
		}
		
		protected function infoBarInit(e:Event):void
		{
			var barbmp:Bitmap = new Assets.HUDINFOBAR();
			var bartex:Texture = Texture.fromBitmap(barbmp);
			var barImage:Image = new Image(bartex);
			
			if (!_enemy) maxHitpoints = Globals.playerHP;
			
			_hpText = new TextField(50,50,"init");
			_hpText.text = "" + hitpoints + " / " + maxHitpoints;
			_hpText.width = barImage.width - 20;
			_hpText.hAlign = HAlign.CENTER;
			_nameText = new TextField(50,50,"init");
			_nameText.text = charName;
			_nameText.width = barImage.width - 20;
			_nameText.hAlign = HAlign.CENTER;
			
			if (_enemy)
			{
				barImage.scaleX = -1;
				barImage.x = stage.stageWidth;
			}
			else barImage.x = 0;
			barImage.y = 0;
			_hpText.y = 5;
			_nameText.y = -15;
			if (_enemy) _hpText.x = _nameText.x = barImage.x - 200;
			else _hpText.x = _nameText.x = barImage.x + 20;
			
			addChild(barImage);
			if (_enemy)
			{
				_hpText.alpha = 0;
				_nameText.alpha = 0;
				addChild(_nameText);
			}
			else _hpText.y = -8;
			addChild(_hpText);
			
			
		}
		
		public function updateText(hp:int = 0, maxHP:int = 0, thisName:String = ""):void
		{
			if (_enemy) 
			{
				_nameText.text = thisName;
				_hpText.text = "" + hp + " / " + maxHP;
				_nameText.alpha = 1;
				_hpText.alpha = 1;
				if (!_displaying)
				{
					_fadeTimer.addEventListener(TimerEvent.TIMER, timeToFade);
					_fadeTimer.start()
				}
				else
				{
					_fadeTimer.reset();
					_fadeTimer.start();
				}
				
				_displaying = true;
			}
			else
			{
				hitpoints = hp;
				_hpText.text = "" + hitpoints + " / " + maxHitpoints;
			}
		}
		
		public function timeToFade(e:TimerEvent):void
		{
			removeEventListener(TimerEvent.TIMER, timeToFade);
			addEventListener(Event.ENTER_FRAME, fadeOut);
			_displaying = false;
		}
		
		public function fadeOut(e:Event):void
		{
			_nameText.alpha -= .25;
			_hpText.alpha -= .25;
			if (_nameText.alpha <= 0) removeEventListener(Event.ENTER_FRAME, fadeOut);
		}
		
	}

}