package org.silix.utils
{
	import flash.display.*;
	
	public class MaskRectangle extends Sprite
	{
		public function MaskRectangle(x:Number, y:Number, w:Number, h:Number, r:Number)
		{
			this.x = x;
			this.y = y;
			
			with (this.graphics) {
				beginFill(0x000000);
				drawRoundRect(0, 0, w, h, r);
			}
			
		}


	}
}