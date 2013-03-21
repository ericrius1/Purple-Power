package
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import ssg.StarField;
	
	//This sprite is right on top of our application level, so this is where we can do all our drawing
	//stage is on top of application
	//main is on top of stage
	[SWF(backgroundColor="0x00000")]
	public class Main extends Sprite
	{
		private static const SHIP_SPEED_PERCENT:Number = 0.75; // Screen width percent per second
		private static const ENEMY_SPEED_PERCENT:Number = .1; // Screen width percent per second
		private static const LASER_COOLDOWN : Number = 0.1;
		private static const LASER_SPEED_PERCENT:Number = 4.0; //traverse 4 screens in one second
		private var _initialWidth : int;
		
		private var _playerShip:PlayerShip;
		private var _enemyShips:Vector.<EnemyShip>;
		private var _numShips:int = 5;
		private var _explosion:Explosion;
		private var _explosionFrame:Number;
		
		private var _starField: StarField;
		private var _lasers   : Vector.<Laser>
		
		
		private var _lastTime:int
		
		private var _mouseDown:Boolean;
		private var _laserShootFuse: Number;

		public function Main()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.BEST;
			stage.frameRate = 60;
			
			_initialWidth = stage.stageWidth;
			addEventListener(Event.ENTER_FRAME, onInitialEnterFrame);
		}
		
		private function onInitialEnterFrame(event : Event): void{
			if(stage.stageWidth != _initialWidth)
			{
				removeEventListener(Event.ENTER_FRAME, onInitialEnterFrame);
				if(!init())
				{
					trace("Bad Initialization!");
				    NativeApplication.nativeApplication.exit(1);
				}
			}
		}
		
		private function init() : Boolean
		{
			_playerShip = new PlayerShip();
			if (_playerShip == null)
			{
				return false;
			}
			var targetWidth:Number = stage.stageWidth * 0.15;
			_playerShip.width = targetWidth;
			_playerShip.scaleY = _playerShip.scaleX; //match scale x and scale y to maintain aspect ratio
			_playerShip.x = stage.stageWidth * 0.5;
			_playerShip.y = stage.stageHeight * 0.9;
			
		
			
			_starField = new StarField();
			addChild(_starField);
			addChild(_playerShip);
			
			createEnemyShips();
		
			
			_explosion = new Explosion();
			_explosion.gotoAndStop(1);
			
			_lasers = new <Laser> [];
			_laserShootFuse = 0;
			mouseEnabled = true;
			stage.mouseChildren = true;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_lastTime = getTimer();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			_mouseDown = false;

			return true;
		}
		
		private function createEnemyShips():void
		{
			var targetWidth:Number = stage.stageWidth * 0.15;
			_enemyShips = new Vector.<EnemyShip>();
			for(var i:int = 0; i < _numShips; i++)
			{
				var enemyShip:EnemyShip = new EnemyShip();
				
				
				enemyShip.width = targetWidth;
				enemyShip.scaleY = enemyShip.scaleX; //match scale x and scale y to maintain aspect ratio
				enemyShip.x = stage.stageWidth * 0.2 * i;
				enemyShip.y = stage.stageHeight * 0.5;
				
				enemyShip.y = 100;
				_enemyShips.push(enemyShip);
				addChild(enemyShip);
			}
			
		}
		
		private function onMouseDown(event:MouseEvent) : void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_mouseDown = true;
		}
		

		private function onMouseMove(event:MouseEvent) : void
		{
		}
		
		private function onMouseUp(event:MouseEvent) : void
		{
			
			_mouseDown = false;
			
		}
		
		private function onEnterFrame(event:Event): void
		{
			var currentTime:int = getTimer();
			var deltaTime:Number = (currentTime - _lastTime) / 1000.0;
			_lastTime = currentTime;
			
			update(deltaTime);
			
		}
		
		private function update (deltaTime:Number): void
		{
			updateShip(deltaTime);
			_starField.update(deltaTime);
			updateEnemyShips(deltaTime);
			updateLasers(deltaTime);
		}
		
		private function updateShip(deltaTime:Number) : void
		{
			
				if(!_mouseDown)
					return;
			
				var shipTargetX:Number = stage.mouseX;
				var shipTargetY:Number = stage.mouseY;
				
				var dirX:Number = shipTargetX -_playerShip.x;
				var dirY:Number = shipTargetY -_playerShip.y;
				var dist:Number = Math.sqrt( (dirX*dirX) + (dirY*dirY));
				if(dist==0)
				{
					return;
				}
				dirX /=dist;
				dirY /=dist;
				var speed:Number = stage.stageWidth * SHIP_SPEED_PERCENT;
				var deltaX:Number = dirX * speed * deltaTime;
				var deltaY:Number = dirY * speed * deltaTime;
				if(Math.abs(shipTargetX - _playerShip.x) < Math.abs(deltaX))
					_playerShip.x = shipTargetX;
					
				else
					_playerShip.x +=deltaX;
				if(Math.abs(shipTargetY - _playerShip.y) < Math.abs(deltaY))
					_playerShip.y = shipTargetY;
				else
					_playerShip.y +=deltaY;
				
					

			
		}
		
		private function updateLasers(deltaTime:Number) : void
		{
			var laser:Laser;
			
			_laserShootFuse -= deltaTime;
			while ( _laserShootFuse <=0)
			{
				_laserShootFuse += LASER_COOLDOWN;
				
				var temp_laser:Laser = new Laser();
				temp_laser.width = stage.stageWidth * 0.01;
				temp_laser.height = stage.stageHeight * 0.05;
				temp_laser.x = _playerShip.x;
				temp_laser.y = _playerShip.y - (_playerShip.height * 0.5);
				
				addChildAt(temp_laser, getChildIndex(_playerShip));
				_lasers.push(temp_laser);
			}
			var speed:Number = stage.stageHeight * LASER_SPEED_PERCENT;
			for (var i:int = _lasers.length-1; i >=0; --i)
			{
				laser = _lasers[i];
				var laserRect:Rectangle = laser.getRect(this);
				
				laser.y -= speed * deltaTime;

				//build a swept rectangle
				
				laserRect = laserRect.union(laser.getRect(this));
				
				for (var j:int = _enemyShips.length-1; j >=0; j--)
				{
					var enemyShip:EnemyShip = _enemyShips[j];
					if(enemyShip &&laserRect.intersects(enemyShip.getRect(this)))
					{
						_explosion.x = enemyShip.x;
						_explosion.y = enemyShip.y;
						addChild(_explosion);
						_explosionFrame = 0;
						removeChild(enemyShip);
						_enemyShips.splice(j, 1);
						enemyShip = null;
					}
				}
				//remove laser from display list 
				if(laser.y< -laser.height)
				{
					removeChild(laser);
					_lasers.splice(i, 1);
					continue;
				}	
			}
		}
//		
//		protected function onExplosionEnterFrame(event:Event):void
//		{
//	
//			if(_explosion.currentFrame == _explosion.totalFrames)
//			{
//				_explosion.stop();
//				removeChild(_explosion);
//				_explosion.removeEventListener(Event.ENTER_FRAME, onExplosionEnterFrame);
//			}	
//		}
		
		private function updateEnemyShips(deltaTime:Number) : void 
		{
			for(var i:int = 0; i < _enemyShips.length; i++)
			{
				if(_enemyShips[i])
				{
				
					var speed:Number = stage.stageWidth * ENEMY_SPEED_PERCENT;
					_enemyShips[i].x +=speed * deltaTime;
				}
				
				else if(_explosion.parent)
				{
					_explosionFrame += 60 * deltaTime;
					if(int(_explosionFrame) > _explosion.totalFrames)
					{
						_explosion.stop();
						removeChild(_explosion);
						//_explosion.goToAndStop(1);
	
					}	
					else
					{
						_explosion.gotoAndStop(int(_explosionFrame));
					}
				}
			}
		}
		
	}
}