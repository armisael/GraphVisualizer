package org.silix.utils
{
	import flash.display.*;
	
	public class MaskCircle extends Sprite
	{
		public function MaskCircle(x:Number, y:Number, r:Number)
		{
			this.x = x;
			this.y = y;
			
			with (this.graphics) {
				beginFill(0x000000);
				drawCircle(0, 0, r);
			}
			
		}
	}
}