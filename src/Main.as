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
	
	import ssg.BossShip;
	import ssg.EnemyShipClass;
	import ssg.StarField;
	import ssg.SuperEnemyShipClass;
	
	//This sprite is right on top of our application level, so this is where we can do all our drawing
	//stage is on top of application
	//main is on top of stage
	[SWF(backgroundColor="0x00000")]
	public class Main extends Sprite
	{
		private static const SHIP_SPEED_PERCENT:Number = 0.75; // Screen width percent per second
	
		private static const LASER_COOLDOWN : Number = .3;
		private static const LASER_SPEED_PERCENT:Number = 1.0; //traverse 4 screens in one second
		private var _initialWidth : int;
		
		private var _playerShip:PlayerShip;
		private var _playerHitSound:PlayerHitSound;
		
		private var _enemyShips:Vector.<EnemyShipClass>;
		private var _numShips:int = 10;
		private var _numShipsToSpawn:int = 2;
		private var _maxShips:int = _numShips *2;
		private var _minShips:int = _numShips * 0.3;
		private var _spawnShips:Boolean = true;
		
		private var _bossMode:Boolean = false;
		private var _bossShip:BossShip;
		
		private var _enemyKillCount:int = 0;
		private var _poweredUp:Boolean = false;
		private var _enemyKillsToPowerUp:int = 5;
		


		private var _starField: StarField;
		private var _lasers   : Vector.<Laser>
		private var _laserSound:LaserSound 
		
		
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
			
			_enemyShips = new <EnemyShipClass> [];
			for(var i:int = 0; i < _numShips; i++)
			{
				createEnemyShip(stage.stageWidth * (1/_numShips) * i, 100 + i*_playerShip.height * .2);
			}
			
			_starField = new StarField();
			addChild(_starField);
			addChild(_playerShip);
		
		
			
			_laserSound = new LaserSound();
			_playerHitSound = new PlayerHitSound();
		
			
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
		
		
		private function createEnemyShip(x:Number, y:Number):void
		{
	
				var enemyShip:EnemyShipClass = new EnemyShipClass(x,y, stage.stageWidth, stage.stageHeight);
		
				addChild(enemyShip.GetShip());
				addChild(enemyShip.GetLaser());
				_enemyShips.push(enemyShip);
				//addChild(new EnemyLaser());
			
		}
		
		private function onMouseDown(event:MouseEvent) : void
		{
	
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_mouseDown = true;
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
			if(!_bossMode)
				updateEnemyShips(deltaTime);
			else
				updateBoss(deltaTime);
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
			
				//Check if player has been hit
				for (var j:int = _enemyShips.length-1; j >=0; j--)
				{
					var enemyShip:EnemyShipClass = _enemyShips[j];
					var enemyLaserRect:Rectangle = enemyShip.GetLaser().getRect(this);
					
					//Check if player is hit by enemy
					if(_playerShip.getRect(this).intersects(enemyLaserRect))
					{
						trace("BOOOM:   "   + deltaTime);
						_playerHitSound.play();
						if(enemyShip.GetLaser().parent)
						{
							removeChild(enemyShip.GetLaser());
						}
							
					}
				}
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
				_laserSound.play();
			}
			var speed:Number = stage.stageHeight * LASER_SPEED_PERCENT;
			for (var i:int = _lasers.length-1; i >=0; --i)
			{
				laser = _lasers[i];
				var laserRect:Rectangle = laser.getRect(this);
				
				laser.y -= speed * deltaTime;

				//build a swept rectangle
				
				laserRect = laserRect.union(laser.getRect(this));
	
				if(_bossMode == true)
				{
					if(_bossShip.HitByLaser(laserRect))
					{
						// do something with laser?
					}
				
				}
				for (var j:int = _enemyShips.length-1; j >=0; j--)
				{
					var enemyShip:EnemyShipClass = _enemyShips[j];
					
					//Check if enemy is hit by laser
					if(!enemyShip.IsExploding() && enemyShip.HitByLaser(laserRect))
					{
						addChild(enemyShip.GetExplosion());
						enemyShip.GetShip().visible = false;
						enemyShip.GetLaser().visible = false;
						_enemyKillCount++;
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
		
		private function SpawnBoss():void
		{
			_bossShip = new BossShip(stage.stageWidth, stage.stageHeight);
		  	addChild(_bossShip.GetShip());
			_bossMode = true;
		}
		
		private function updateBoss(deltaTime:Number):void
		{
			if(_bossShip ==  null)
			{
				SpawnBoss();
			}
			_bossShip.Update(deltaTime);
			
		}

		private function updateEnemyShips(deltaTime:Number) : void 
		{
			//We have killed all the normal ships, now lets bring on the boss!
			if(_spawnShips == false&& _enemyShips.length == 0)
			{
				SpawnBoss();
				return;
			}
			
			for(var i:int = 0; i < _enemyShips.length; i++)
			{
				if(_enemyShips[i].IsDead())
				{
					removeChild(_enemyShips[i].GetShip());
					if(_enemyShips[i].GetLaser().parent)
						removeChild(_enemyShips[i].GetLaser());
					if(_enemyShips[i].GetExplosion().parent)
						removeChild(_enemyShips[i].GetExplosion());
					_enemyShips.splice(i, 1)
				
					if(_enemyShips.length > _maxShips)
						_spawnShips = false;
					if(_enemyShips.length <_minShips && _spawnShips == true)
					{
						var numShipsToSpawn:int = Math.random() * 5;
						if(Math.random() < 0.5)
						{
							_minShips++;
							_numShipsToSpawn++;
						}
						for(var j:int = 0; j <numShipsToSpawn * Math.random() +1; j++)
						{	
							createEnemyShip(Math.random() * stage.stageWidth ,  -_playerShip.height * .5);
						}
					}
					continue;
				}
				_enemyShips[i].Update(deltaTime);
			}

		}
		
	}
}