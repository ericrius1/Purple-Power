package ssg
{
	import flash.geom.Rectangle;
	import flash.display.Sprite;

	public class BossShip extends Sprite
	{
		private static const ENEMY_SPEED_PERCENT:Number = .02; // Screen width percent per second
		private var _sunCrusher:EnemyShip2;
		private var _speed:Number;
		private var  _deflectionSound:DeflectionSound;
		private var _bossSound:BossSound;
		public function BossShip(stageWidth:Number, stageHeight:Number)
		{
			_sunCrusher = new EnemyShip2();
			_sunCrusher.x = 300;
			_sunCrusher.y = -_sunCrusher.height;
			_speed = stageHeight * ENEMY_SPEED_PERCENT;
			_deflectionSound = new DeflectionSound();
			_bossSound = new BossSound();
			_bossSound.play();
		
		}
		
		public function Update(deltaTime:Number):void
		{
			_sunCrusher.y += deltaTime * _speed;
		}
		
		public function HitByLaser(laserRect:Rectangle):Boolean
		{
			if(laserRect.intersects(_sunCrusher.getRect(this)))
			{
				//_deflectionSound.play();
				return true;
			}
			else
				return false;
			
		}
		
		public function GetShip():EnemyShip2
		{
			return _sunCrusher;
		}
		
		
	}
}