package ssg
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	public final class EnemyShipClass extends Sprite
	{
		
		private static const ENEMY_SPEED_PERCENT:Number = .5; // Screen width percent per second
		private var _explosion:Explosion;
		private var _explosionFrame:Number = 0;
		private var  _explosionSound:ExplosionSound;
		private var _enemyShip:EnemyShip;
		private var _stageWidth:Number;
		private var _speed:Number;
		private var _direction:int = 1;
	    private var _isExploding:Boolean = false;
		private var _isDead:Boolean = false;
		
		public function EnemyShipClass(x:Number, y:Number, stageWidth:Number)
		{
			//var targetWidth:Number = stage.stageWidth * 0.15;
			_explosion = new Explosion();
			_explosion.gotoAndStop(1);
			_explosionSound = new ExplosionSound();
			_enemyShip = new EnemyShip();
			_enemyShip.width = 100;
			_enemyShip.scaleY = _enemyShip.scaleX; //match scale x and scale y to maintain aspect ratio
			_enemyShip.x =x
			_enemyShip.y = y
			
			_enemyShip.y = 100;
			
			_stageWidth = stageWidth;
			_speed = _stageWidth * ENEMY_SPEED_PERCENT;
			
		}
		public function Update(deltaTime:Number):void
		{
			if(_isExploding)
			{
				_explosionFrame += 60 * deltaTime;
				
				if(int(_explosionFrame) > _explosion.totalFrames)
				{
					_explosion.stop();
					_isExploding = false;
					_isDead = true;
						
				}	
				else
				{
					_explosion.gotoAndStop(int(_explosionFrame));
				}
				return;
			}
			
			_enemyShip.x+= _speed * deltaTime * _direction;
			if(_enemyShip.x > _stageWidth || _enemyShip.x < 0){
				_direction *= -1;
			}
		}
		
		public function HitByLaser(laserRect:Rectangle):Boolean
		{
			if(laserRect.intersects(_enemyShip.getRect(this)))
			{
				_explosion.x = _enemyShip.x;
				_explosion.y = _enemyShip.y;
				_explosionSound.play();
				_explosionFrame = 0;
				_isExploding = true;
				return true;
			}
			else
				return false;
			
		}
		
		public function GetShip():EnemyShip
		{
			return _enemyShip;
		}
		
		public function GetExplosion():Explosion
		{
			return _explosion;
		}
		
		public function IsDead():Boolean
		{
			return _isDead;
		}
		
		public function IsExploding():Boolean
		{
			return _isExploding;
		}
		
	}
}