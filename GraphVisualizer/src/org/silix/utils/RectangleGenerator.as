package org.silix.utils
{
	import de.polygonal.ds.*;
	
	import flash.display.*;
	
	public class RectangleGenerator
	{
		private var l:DLinkedList = new DLinkedList();
		private var _w:Number;
		private var _h:Number;
		private var _idx:int = 0;
		//private var _mapping: Array = new Array();
		
		public function RectangleGenerator(w:Number, h:Number)
		{
			_w = w;
			_h = h;
		}
		
		public function addRectangle(o:DisplayObject):Object
		{
			var w:Number = o.width;
			var h:Number = o.height;
			
			var i:DListIterator = l.getListIterator();
			var r:Object;
			while (i.node != null) {
				r = i.node.data;
				if (r.w >= w && r.h >= h) {
					split(i, r, w, h);
					//_mapping[o.name] = r;
					return {x: r.x, y: r.y};
				}
				i.next();
			}
			
			r = expand();
			return addRectangle(o);
		}
		
		private function split(i:DListIterator, r:Object, w:Number, h:Number):void
		{
			var r1: Object = {x: r.x + w, y: r.y, w: r.w - w, h: h};
			var r2: Object = {x: r.x, y: r.y + h, w: w, h: r.h - h};
			
			if (r1.w > r2.h) r1.h += r.h - h;
			else r2.w += r.w - w;
			
			if (r1.w > 0 && r1.h > 0) l.insertBefore(i, r1);
			if (r2.w > 0 && r2.h > 0) l.insertBefore(i, r2);
			i.remove();
		}
		
		private function dump():void
		{
			var i: DListIterator = l.getListIterator();
			var r: Object;
			while (i.hasNext()) {
				r = i.next();
			}
		}
		
		private function expand():Object
		{
			_idx++;
			var r:Object;
			var res:Object = null;
			var start:int = Math.pow(_idx-1, 2);
			var end:int = Math.pow(_idx, 2);
			var middle:int = (end-start-1)/2 + start;
			for (var i:int = start; i < end; i++)
			{
				r = {	x: ( (i <= middle)? (_idx-1) * _w : (end-i-1) * _w ),
						y: ( (i < middle)? (i-start) * _h : (_idx-1) * _h ), 
						w: _w, h: _h };
					
				l.append(r);
				if (res == null) res = r;
			}
			
			return res;
		}

	}
}