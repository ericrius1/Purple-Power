package ssg
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.DisplayObject;
	
	public final class StarField extends Sprite
	{
		private static const STAR_SPEED_MIN : Number = 0.01; //Percent of screen heigh object will move per second
		private static const STAR_SPEED_MAX : Number = 0.5;
		
		public function StarField()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			
			for (var i:int=0; i < 100; ++i)
			{
				var star:Star = new Star();
				star.x = Math.random() * stage.stageWidth;
				star.y = Math.random() * stage.stageHeight;
				addChild(star);
			}
		}
		
		public function update(deltaTime:Number) : void
		{
			for (var i:int=0; i < numChildren; ++i)
			{
				var star:Star = Star(getChildAt(i));
				
				var speed:Number = lerp(star.dist, STAR_SPEED_MIN, STAR_SPEED_MAX);
				speed *= stage.stageHeight * deltaTime;
				star.y+=speed;
				if(star.y >= stage.stageHeight)
				{
					
					star.x = Math.random() * stage.stageWidth;
					star.y = 10
				}
				
			}
		}
	}
}

internal function lerp(t:Number, min:Number, max:Number):Number
{
	return(min + (t * (max-min)));
}


import flash.display.Shape;



internal final class Star extends Shape
{
	private var _dist:Number;
	public function Star()
	{
		_dist = Math.random();
		var color:int = lerp(_dist, 63, 204);
		
		//red green blue
		graphics.beginFill( color <<Math.random()*16 | color <<8 | color);
		var radius:Number = lerp(_dist, 0.5, 3);
		graphics.drawCircle(0, 0 , radius);
		graphics.endFill();
	}
	
	public function get dist():Number
	{
		return _dist;
	}
}
	

