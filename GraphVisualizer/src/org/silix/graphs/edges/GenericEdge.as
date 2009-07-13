package org.silix.graphs.edges
{
	import caurina.transitions.Tweener;
	
	import flash.display.*;
	import flash.events.*;
	
	import mx.core.FlexSprite;
	
	import org.silix.graphs.Graph;
	import org.silix.graphs.vertexes.GenericVertex;
	
	public class GenericEdge extends FlexSprite
	{
		public static const ARROW:Number = 5;
		
		protected var _idx: int;
		protected var _g: Graph;
		protected var _v1: GenericVertex;
		protected var _v2: GenericVertex;
		protected var _options: Array;
		
		public static const STATE_NORMAL: int = 0;
		public static const STATE_HIGHLIGHTED: int = 1;
		
		public static const STATUS_NORMAL: int = 0;
		public static const STATUS_ADDED: int = 1;
		public static const STATUS_DELETED: int = 2;
		
		protected var _exists: Array = new Array();
		protected var _state: int = GenericEdge.STATE_NORMAL;
		
		protected var _tickness: int = 1;
		protected var _color: int = 0x000000;
		protected var _h_color: Number = 0xF48500;
		protected var _added_color: Number = 0xFF0000;
		protected var x1: Number;
		protected var y1: Number;
		protected var x2: Number;
		protected var y2: Number;
		protected var e: Number;
			
		
		public function GenericEdge(g:Graph, idx:int, v1:GenericVertex, v2:GenericVertex, options: Array = null)
		{
			_idx = idx;
			_g = g;
			_v1 = v1;
			_v2 = v2;
			_options = options;
			_exists[g.currentTime] = true;
			alpha = 0;
			
			_v1.addEventListener(GenericVertex.MOVED, draw);
			_v2.addEventListener(GenericVertex.MOVED, draw);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			draw();
		}
		
		public function appear():void
		{
			Tweener.addTween(this, {alpha: 1, transition: 'linear', time: 0.5});
			draw();
		}
		
		public function disappear():void
		{
			Tweener.addTween(this, {alpha: 0, transition: 'linear', time: 0.5});
		}
		
		public function changeTo(date:String):void
		{
			if (_exists[date] == undefined)
				_exists[date] = false;
		}
		
		// o:Object is the event for the GenericVertex.MOVED event
		public function draw(o:Object = null):void
		{
			var c:int = _color;
			var s:int = status;
			if (_state == GenericEdge.STATE_HIGHLIGHTED) c = _h_color;
			//else if (s == GenericEdge.STATUS_ADDED) c = _added_color;
			
			//if (s == GenericEdge.STATUS_DELETED)
			//	trace("A");
			// The edge has been deleted, if it is the first time we call this function, tween it to 0
			if (s == GenericEdge.STATUS_DELETED) {
				if (alpha == 1) Tweener.addTween(this, {alpha: 0, transition: 'linear', time: 0.5});
				return;
			// The edge has been added, if it is the first time we call this function, tween it to 1
			} else if (s == GenericEdge.STATUS_ADDED) {
				if (alpha == 0) Tweener.addTween(this, {alpha: 1, transition: 'linear', time: 0.5});
			// The edge is unchanged, if it is not shown, return.
			} else if (alpha != 1) return; 
			
			graphics.clear();
			
			//if (s == GenericEdge.STATUS_ADDED && alpha < 1) Tweener.addTween(this, {alpha: 1, transition: 'linear', time: 0.5});
			
			e = ((v2.y>v1.y)?1:-1) * Math.acos( (v2.x-v1.x) / Math.sqrt(Math.pow(v2.x-v1.x,2) + Math.pow(v2.y-v1.y,2)) );
			x1 = v1.x + v1.getClass().margin * Math.cos(e);
			y1 = v1.y + v1.getClass().margin * Math.sin(e);
			x2 = v2.x + v2.getClass().margin * Math.cos(Math.PI + e);
			y2 = v2.y + v2.getClass().margin * Math.sin(Math.PI + e);
			graphics.lineStyle(_tickness, c);
			graphics.moveTo(x1, y1);
			graphics.lineTo(x2, y2);
			
			if (_g.directed) {
				graphics.beginFill(c);
				graphics.moveTo(x2, y2);
				graphics.lineTo(x2 + ARROW * Math.cos(e - Math.PI*3/4),
						 y2 + ARROW * Math.sin(e - Math.PI*3/4)	);
				graphics.lineTo(x2 + ARROW * Math.cos(e - Math.PI*5/4),
						 y2 + ARROW * Math.sin(e - Math.PI*5/4)	);
			}
		}
		
		
		
		
		/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
		 * PROTECTED METHODS
		 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
		protected function mouseOverHandler(evt:Event):void
		{
			_state = GenericEdge.STATE_HIGHLIGHTED;
			draw();
		}
		
		protected function mouseOutHandler(evt:Event):void
		{
			_state = GenericEdge.STATE_NORMAL;
			draw();
		}



		/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
		 * GETTER / SETTER
		 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
		public function get status():int {
			//if (_g.lastTime == null) return GenericVertex.STATUS_NORMAL;
			
			var b1: Boolean = (_exists[_g.currentTime] != undefined) ? _exists[_g.currentTime] : false;
			var b2: Boolean = (_exists[_g.lastTime] != undefined) ? _exists[_g.lastTime] : false;
			
			if (b1 == b2) return GenericEdge.STATUS_NORMAL;
			if (b1) return GenericEdge.STATUS_ADDED;
			return GenericEdge.STATUS_DELETED;
		}
		
		public function get exists():Boolean { return _exists[_g.currentTime]; }
		public function set exists(v:Boolean):void {
			_exists[_g.currentTime] = v;
		}
		
		public function get idx():int
		{
			return _idx;
		}
		
		public function get v1():GenericVertex
		{
			return _v1;
		}
		
		public function get v2():GenericVertex
		{
			return _v2;
		}

	}
}