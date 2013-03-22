package ssg
{
	import flash.display.Sprite;

	public final class EnemyShipClass extends Sprite
	{
		
		private static const ENEMY_SPEED_PERCENT:Number = .1; // Screen width percent per second
		private var _explosion:Explosion;
		private var _explosionFrame:Number;
		private var  _explosionSound:ExplosionSound;
		private var _enemyShip:EnemyShip;
		
		
		public function EnemyShipClass(x:Number, y:Number)
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
			
		}
		
		public function GetShip():EnemyShip
		{
			return _enemyShip;
		}
		
	}
}