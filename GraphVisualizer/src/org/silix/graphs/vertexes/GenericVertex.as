package org.silix.graphs.vertexes
{
	import caurina.transitions.Tweener;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import mx.core.FlexSprite;
	
	import org.silix.graphs.Graph;
	import org.silix.graphs.edges.GenericEdge;
	
	public class GenericVertex extends FlexSprite
	{
		public static const RADIUS: Number = 6;
		public static const THICKNESS: Number = 4;
		public static const MOVED: String = "Vertex.moved";
		
		public static const STATE_NORMAL: int = 0;
		public static const STATE_HIGHLIGHTED: int = 1;
		
		public static const STATUS_NORMAL: int = 0;
		public static const STATUS_ADDED: int = 1;
		public static const STATUS_DELETED: int = 2;
		
		public var toX: Number;
		public var toY: Number;
		
		protected var _name: String;
		protected var _idx: int;
		protected var _E: Array = new Array();
		protected var _Ecard: int = 0;
		protected var _g: Graph;
		protected var _options: Array;
		
		protected var _exists: Array = new Array();
		
		protected var _bg_color: Number = 0xFFFFFF;
		protected var _fg_color: Number = 0x133C72;
		protected var _h_bg_color: Number = 0xFFFFFF;
		protected var _h_fg_color: Number = 0xF48500;
		protected var _added_bg_color: Number = 0xFFFFFF;
		protected var _added_fg_color: Number = 0xFF0000;
		
		protected var _state: int = GenericVertex.STATE_NORMAL;
		
		public function GenericVertex(g:Graph, idx: int, name: String, options: Array = null)
		{
			_name = name;
			_idx = idx;
			_g = g;
			_options = options;
			_exists[g.currentTime] = true;
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			
			draw();	
		}
		
		public function addNeighbour(v:GenericVertex, options: Array = null):GenericEdge
		{
			if(_E[v.name] == undefined) {
				_E[v.name] = new _g.edgeClass(_g, _Ecard++, this, v, options);
				return _E[v.name];
				/*if (_g.directed) 
					_E[v.name].draw(graphics);
				else if (_E[v.name].v1.idx < _E[v.name].v2.idx)
					_E[v.name].draw(graphics);*/
			} else _E[v.name].exists = true;
			return null
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
		
		public function isNeighbourOf(v:GenericVertex):Boolean
		{
			return _E[v.name] != undefined;
		}
		
		public function changeTo(date:String):void
		{
			if (_exists[date] == undefined)
				_exists[date] = false;
		}
		
		/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
		 * PRIVATE METHODS
		 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
		public function draw():void
		{
			graphics.clear();
			if (_state == GenericVertex.STATE_HIGHLIGHTED) {
				graphics.beginFill(_h_bg_color);
				graphics.lineStyle(THICKNESS, _h_fg_color);
			/*} else if (status == GenericVertex.STATUS_ADDED) {
				graphics.beginFill(_added_bg_color);
				graphics.lineStyle(THICKNESS, _added_fg_color);
			*/} else {
				graphics.beginFill(_bg_color);
				graphics.lineStyle(THICKNESS, _fg_color);
			}
			graphics.drawCircle(0, 0, RADIUS);
		}
		
		protected function mouseOverHandler(evt:Event):void
		{
			_state = GenericVertex.STATE_HIGHLIGHTED;
			draw();
		}
		
		protected function mouseOutHandler(evt:Event):void
		{
			_state = GenericVertex.STATE_NORMAL;
			draw();
		}
		
		/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
		 * GETTER / SETTER
		 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
		public function get value():String
		{
			return _name;
		}
		
		public function get E():Array
		{
			return _E;
		}
		
		//public function get x():Number { return _x; }
		override public function set x(v:Number):void
		{
			if (super.x == v) return;
			//trace("setto x");
			super.x = v;
			// we dispose the event only for the y coord.... sorry
			dispatchEvent(new Event(GenericVertex.MOVED));
		}
		
		//public function get y():Number { return _y; }
		override public function set y(v:Number):void
		{
			//if (super.y == v) return;  // va tolto altrimenti non solleva l'evento!
			//trace("setto y");
			super.y = v;
			dispatchEvent(new Event(GenericVertex.MOVED));
		}
		
		override public function toString():String
		{
			return "["+_idx+"]."+_name;
		}
		
		public static function get margin():Number
		{
			return RADIUS + THICKNESS/2;
		}
		
		public function get info():String
		{
			if (_g.directed)
				return "Outgoing edges: " + this._Ecard;
			return "Edges: " + this._Ecard;
		}
		
		public function get idx():int
		{
			return _idx;
		}
		
		public function get exists():Boolean { return _exists[_g.currentTime]; }
		public function set exists(v:Boolean):void {
			_exists[_g.currentTime] = v;
		}
		
		public function getClass():Class {
       		return Class(getDefinitionByName(getQualifiedClassName(this)));
		}
		
		public function get status():int {
			//if (_g.lastTime == null) return GenericVertex.STATUS_NORMAL;
			
			var b1: Boolean = (_exists[_g.currentTime] != undefined) ? _exists[_g.currentTime] : false;
			var b2: Boolean = (_exists[_g.lastTime] != undefined) ? _exists[_g.lastTime] : false;
			
			if (b1 == b2) return GenericVertex.STATUS_NORMAL;
			if (b1) return GenericVertex.STATUS_ADDED;
			return GenericVertex.STATUS_DELETED;
		}

	}
}