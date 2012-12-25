package com.profusiongames.states 
{
	import com.profusiongames.beings.Player;
	import com.profusiongames.containers.ScrollingContainer;
	import com.profusiongames.events.WindowEvent;
	import com.profusiongames.platforms.Ground;
	import com.profusiongames.platforms.GroundPlatform;
	import com.profusiongames.platforms.Platform;
	import com.profusiongames.scenery.Cloud;
	import com.profusiongames.scenery.Scenery;
	import com.profusiongames.windows.DeathWindow;
	import com.profusiongames.windows.Window;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flashdevelop.utils.FlashConnect;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * ...
	 * @author UnknownGuardian
	 */
	public class Game extends State
	{
		private var _player:Player = new Player();
		private var _scrollingContainer:ScrollingContainer = new ScrollingContainer();
		private var _platformList:Vector.<Platform> = new Vector.<Platform>();
		private var _sceneryList:Vector.<Scenery> = new Vector.<Scenery>();
		
		private var _minPlatformDensity:int = 40;
		private var _platformDensity:int = 80;
		private var _minHeightToGeneratePlatforms:int = -150; //what height to stop generating platforms at.
		
		private var _minSceneryDensity:int = 60;
		private var _sceneryDensity:int = 160;
		private var _minHeightToGenerateScenery:int = -150; //what height to stop generating clouds at
		
		private var _mouseX:Number = 0;
		private var _mouseY:Number = 0;
		
		private var _isPaused:Boolean = true;
		public function Game() 
		{
			addChild(_scrollingContainer);
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener(TouchEvent.TOUCH, onTouch);
			//generateInitialPlatforms();
			//generateInitialGround();
			//generateInitialClouds();
			//_scrollingContainer.addActive(_player);
			resetGame();
			
			isPaused = false;
		}
		
		private function generateInitialClouds():void 
		{
			var h:int = Main.HEIGHT - 5;
			
			//start from the bottom and generate up, ending 150 px above the player
			while (h > _minHeightToGenerateScenery)
			{
				h -= Math.random() * _sceneryDensity + _minSceneryDensity;
				var s:Scenery = generateSceneryAt(h);
				_scrollingContainer.addScenery(s);
				s.yRelativeToScreen = h;
				_sceneryList.push(s);
			}
		}
		
		private function generateInitialGround():void 
		{
			var groundPlatform:Ground = new Ground();
			groundPlatform.x = 0;
			groundPlatform.y = Main.HEIGHT - groundPlatform.height;
			_scrollingContainer.addActive(groundPlatform);
			_platformList.push(groundPlatform);
		}
		
		private function generateInitialPlatforms():void 
		{
			var h:int = Main.HEIGHT - 5;
			
			//start from the bottom and generate up, ending 150 px above the player
			while (h > _minHeightToGeneratePlatforms)
			{
				h -= Math.random() * _platformDensity + _minPlatformDensity;
				var p:Platform = generatePlatformAt(h);
				_scrollingContainer.addActive(p);
				_platformList.push(p);
			}
		}
		
		
		
		private function generatePlatformAt(h:int):Platform 
		{
			//FlashConnect.atrace("Generating platform @", h);
			var p:Platform = new GroundPlatform();//Math.random() > 0.5 ? new CloudPlatform() :
			p.x = int(Math.random() * 400) + 50;
			p.y = h;
			return p;
		}
		
		private function generateSceneryAt(h:int):Scenery
		{
			var s:Scenery = new Cloud();
			s.x = int(Math.random() * 400) + 50;
			//s.y = h;
			return s;
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			var touch:Touch = e.getTouch(stage);
			var mp:Point = touch.getLocation(_scrollingContainer);
			if (touch)
			{
				_mouseX = mp.x;
				_mouseY = mp.y;
				if(touch.phase == TouchPhase.BEGAN) {
				}
				else if(touch.phase == TouchPhase.ENDED) {
					_player.bounce(15);
				}
				else if(touch.phase == TouchPhase.MOVED) {
				}
			}
		}
		
		private function frame(e:Event):void 
		{
			//FlashConnect.atrace(_scrollingContainer.getScreenAltitude());
			checkForPlatformsToBeRemoved();
			checkForSceneryToBeRemoved();
			addPlatforms();
			addScenery();
			handlePlayer();
			checkForPlatformCollision();
			handleScrollingBackground();
			checkForGameOver();
		}
		
		private function checkForPlatformsToBeRemoved():void 
		{
			//var xClipMin:int = -500 + _player.x;
			//var xClipMax:int = 500 +  _player.x;
			//var yClipMin:int = -400 + -_scrollingContainer.getScreenAltitude();
			var yClipMax:int = 600;
			var platform:Platform;
			for (var i:int = 0; i < _platformList.length; i++)
			{
				platform = _platformList[i];
				//var xPos:int = platform.x;
				var yPos:int = platform.y + _scrollingContainer.getScreenAltitude();
				//FlashConnect.atrace(xPos, yPos, yClipMin, yClipMax);
				if (/*xPos > xClipMax || xPos < xClipMin || yPos < yClipMin ||*/ yPos > yClipMax)
				{
					_scrollingContainer.removeActive(platform);
					platform.dispose();
					_platformList.splice(i, 1);
					i--;
				}
			}
		}
		
		private function checkForSceneryToBeRemoved():void 
		{
			//var xClipMin:int = -500 + _player.x;
			//var xClipMax:int = 500 +  _player.x;
			//var yClipMin:int = -400 +  -_scrollingContainer.getScreenAltitude();
			var yClipMax:int = 600;
			//_scrollingContainer.setMinMax(-99999, yClipMax);
			var scenery:Scenery;
			for (var i:int = 0; i < _sceneryList.length; i++)
			{
				scenery = _sceneryList[i];
				//var xPos:int = scenery.x + scenery.layer.x * scenery.layer.scrollScale;
				var yPos:int = scenery.yRelativeToScreen;
				if (i == 0) _scrollingContainer.setMid(yPos);
				//FlashConnect.atrace("Scenery @",yPos, "Clip Min @", yClipMin, "Clip Max @", yClipMax, "Player @", _player.y);
				if (/*xPos > xClipMax || xPos < xClipMin || yPos < yClipMin ||*/ yPos > yClipMax)
				{
					_scrollingContainer.removeScenery(scenery);
					scenery.dispose();
					_sceneryList.splice(i, 1);
					i--;
				}
			}
		}
		
		private function addPlatforms():void
		{
			if (_platformList.length == 0)
				return;
			
			var highest:int = _platformList[_platformList.length - 1].y;
			//FlashConnect.atrace("highest:", highest, "minHeight:", _minHeightToGeneratePlatforms, "altitude:", _scrollingContainer.getScreenAltitude());
			while (highest > -_scrollingContainer.getScreenAltitude() + _minHeightToGeneratePlatforms)
			{
				highest -= Math.random() * _platformDensity  + _minPlatformDensity;
				var p:Platform  = generatePlatformAt(highest);
				_scrollingContainer.addActive(p);
				_platformList.push(p);
			}
		}
		private function addScenery():void
		{
			//return;
			
			if (_sceneryList.length == 0)
				return;
			
			var highestScenery:Scenery = _sceneryList[_sceneryList.length - 1];
			var highest:int = highestScenery.yRelativeToScreen;
			//FlashConnect.atrace("Highest Platform @" + _platformList[_platformList.length - 1].y + "Highest Scenery @" + _sceneryList[_sceneryList.length - 1].yRelativeToScreen);
			//var relativeMinHeightToGenerateScenery:int = -highestScenery.layer.y + _minHeightToGenerateScenery ;
			//FlashConnect.atrace("Makin scenery with highest:", highest, " relative:",relativeMinHeightToGenerateScenery,"and min height:", _minHeightToGenerateScenery);
			//while (highest > -_scrollingContainer.getScreenAltitude() + relativeMinHeightToGenerateScenery)
			while (highest > _minHeightToGenerateScenery)
			{
				highest -= Math.random() * _sceneryDensity + _minSceneryDensity;
				var s:Scenery  = generateSceneryAt(highest);
				_scrollingContainer.addScenery(s);
				s.yRelativeToScreen = highest;
				//s.yRelativeToScreen = highest;
				//s.layer.changeScreenToRelativeCoordinates(s);
				_sceneryList.push(s);
			}
		}
		
		private function handlePlayer():void 
		{
			_player.moveHorizontallyTowards(_mouseX);
			_player.frame();
		}
		
		private function checkForPlatformCollision():void 
		{
			if (_player.isFalling)
			{
				var playerBounds:Rectangle = _player.getBounds(_scrollingContainer);
				var platform:Platform;
				for (var i:int = 0; i < _platformList.length; i++)
				{
					platform = _platformList[i];
					var platformBounds:Rectangle = platform.getBounds(_scrollingContainer);
					if (playerBounds.intersects(platformBounds))
					{
						_player.bounce(platform.bouncePower);
						//FlashConnect.atrace("collision");
					}
				}
			}
		}
		
		private function handleScrollingBackground():void 
		{
			_scrollingContainer.centerVerticallyOnUsingMax(_player);
		}
		
				
		private function checkForGameOver():void 
		{
			if (_player.y + _scrollingContainer.getScreenAltitude() > 600)
			{
				//end game
				isPaused = true;
				showDeathPopUpMenu();
			}
		}
		
		private function showDeathPopUpMenu():void 
		{
			var deathWindow:DeathWindow = new DeathWindow();
			addChild(deathWindow);
			deathWindow.addEventListener(WindowEvent.NAVIGATION, onDeathWindowNavigation);
		}
		
		private function onDeathWindowNavigation(e:WindowEvent):void 
		{
			(e.currentTarget as Window).close();
			if (e.windowData == "upgrades")
			{
			}
			else if (e.windowData == "menu")
			{
			}
			else if (e.windowData == "play")
			{
				resetGame(true);
			}
		}
		
		private function resetGame(playOnComplete:Boolean = false ):void 
		{
			if (!_isPaused)
				_isPaused = true;
			
			//clean up everything
			var i:int = 0;
			for (i = 0; i < _sceneryList.length; i++)
				_sceneryList[i].dispose();
			for (i = 0; i < _platformList.length; i++)
				_platformList[i].dispose();
			
			_sceneryList.length = 0;
			_platformList.length = 0;
			_player.reset();
			_scrollingContainer.reset();
			
			
			//set up everything
			generateInitialGround();
			generateInitialClouds();
			_scrollingContainer.addActive(_player);
			
			if (playOnComplete)
				isPaused = false;
		}
		
		public function get isPaused():Boolean 
		{
			return _isPaused;
		}
		
		public function set isPaused(value:Boolean):void 
		{
			if (value == _isPaused) return;//same value return.
			
			_isPaused = value;
			if (_isPaused)
			{
				removeEventListener(Event.ENTER_FRAME, frame);
			}
			else
			{
				addEventListener(Event.ENTER_FRAME, frame);
			}
		}
	}

}