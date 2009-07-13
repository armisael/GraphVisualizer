package org.silix.graphs
{
	import caurina.transitions.Tweener;
	
	import flash.events.*;
	
	import mx.containers.*;
	
	import org.silix.graphs.edges.GenericEdge;
	import org.silix.graphs.vertexes.GenericVertex;
	
	
	public class GraphComponent extends Box 
	{
		public static const GRAPH: int = 0;
		public static const DIGRAPH: int = 1;
		public static const NORMAL: int = 2;
		public static const STRICT: int = 3;
		
		private static const VERTEX_PADDING: int = 2;
		
		protected var _vertexClass: Class = GenericVertex;
		protected var _edgeClass: Class = GenericEdge;
		protected var _onVertex: Function = null;
		protected var _onEdge: Function = null;
		protected var _type1: int = Graph.GRAPH;
		protected var _type2: int = Graph.NORMAL;
		protected var _options: Array;
		protected var _name: String;
		private var _V: Array = new Array();
		
		protected var _currentTime: String;
		protected var _lastTime: String;
		private var _Vcard: int = 0;
		
		private var _components: GraphComponent;
		
		public function GraphComponent(options: Array = null)
		{
			_options = options;
			setVars();
		}
		
		public function addExistingVertex(v:GenericVertex):void
		{
			if (_V[v.value] == undefined) {
				_Vcard++;
				_V[v.value] = v;
			}
		}
		
		public function moveVertexes(x:Number, y:Number):void
		{
			Tweener.addTween(this, {x: x - this._vertexClass.margin - VERTEX_PADDING,
									y: y - this._vertexClass.margin - VERTEX_PADDING,
									time: 1, transition: 'linear' } );
		}
		
		public function draw(algorithm: Function):Function
		{
			return algorithm(this);
		}
		
		public function placeAll():void
		{
			var x_max:Number = 0;
			var y_max:Number = 0;
			var x_min:Number = Number.MAX_VALUE;
			var y_min:Number = Number.MAX_VALUE;
			var s: int;
			for (var i:String in _V) {
				s = _V[i].status;
				if (s == GenericVertex.STATUS_ADDED) _V[i].appear();
				else if (s == GenericVertex.STATUS_DELETED) _V[i].disappear();
				else _V[i].draw();
				
				if (x_max < _V[i].toX) x_max = _V[i].toX + _vertexClass.margin + 2*VERTEX_PADDING;
				if (y_max < _V[i].toY) y_max = _V[i].toY + _vertexClass.margin + 2*VERTEX_PADDING;
				if (x_min > _V[i].toX) x_min = _V[i].toX - _vertexClass.margin - 2*VERTEX_PADDING;
				if (y_min > _V[i].toY) y_min = _V[i].toY - _vertexClass.margin - 2*VERTEX_PADDING;
	 		}
	 		
	 		// Move each vertex so that there is no space in the top-left edge.
	 		for (i in _V)
	 		{
	 			_V[i].toX -= x_min - this._vertexClass.margin - VERTEX_PADDING;
	 			_V[i].toY -= y_min - this._vertexClass.margin - VERTEX_PADDING;
	 			if (_V[i].x != _V[i].toX || _V[i].y != _V[i].toY)
	 				Tweener.addTween(_V[i], {x: _V[i].toX, y:_V[i].toY, time: 1, transition:'linear', rounded:true });
	 		}
	 		
	 		this.width = x_max - x_min + this._vertexClass.margin - VERTEX_PADDING;
	 		this.height = y_max - y_min + this._vertexClass.margin - VERTEX_PADDING;
		}
		
		public function containsVertex(name:String):Boolean
		{
			return _V[name] != undefined;	
		}
		
		public function complete():void
		{
			for (var i:String in _V) {
				rawChildren.addChild(_V[i]);
				
				if (directed)
					for (var j:String in _V[i].E)
						rawChildren.addChild(_V[i].E[j]);
				else
					for (j in _V[i].E)
						if (_V[i].E[j].v1.idx < _V[i].E[j].v2.idx)
							rawChildren.addChild(_V[i].E[j]);
					
			}
		}
		
		/* public function starting(s:String):void
		{
			_currentTime = s;
			for (var i:String in _V)
				_V[i].changeTo(s);
		} */
		
		public function changeTo(date:String):void
		{
			_lastTime = _currentTime;
			_currentTime = date;
			for (var i:String in _V) {
				_V[i].changeTo(date);
				for (var j:String in _V[i].E) 
					_V[i].E[j].changeTo(date);
			}
		}
		
		
		/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
		 * PRIVATE METHODS
		 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
		protected function onVertex(evt:Event):void
		{
			if (_onVertex != null)
				_onVertex(evt);
		}
		
		protected function onEdge(evt:Event):void
		{
			if (_onEdge != null)
				_onEdge(evt);
		}
		
		private function setVars():void
		{
			if (_options != null) {
				if (options["type1"]) _type1 = options["type1"];
				if (options["type1"]) _type2 = options["type1"];
				if (options["name"]) _name = options["name"];
			}
		}
		 
		/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
		 * GETTER / SETTER
		 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
		 override public function get name():String
		 {
		 	return _name;
		 }
		 
		 public function get V():Array
		 {
		 	return _V;
		 }
		 
		 public function get directed():Boolean
		 {
		 	return _type1 == Graph.DIGRAPH;
		 }
		 
		 public function get edgeClass():Class { return _edgeClass; }
		 public function set edgeClass(v:Class):void
		 {
		 	_edgeClass = v; 
		 }
		 
		 public function get vertexClass():Class { return _vertexClass; }
		 public function set vertexClass(v:Class):void
		 {
		 	_vertexClass = v;
		 }
		 
		 public function get edgeOverFunction():Function { return _onEdge; }
		 public function set edgeOverFunction(v:Function):void
		 {
		 	_onEdge = v; 
		 }
		 
		 public function get vertexOverFunction():Function { return _onVertex; }
		 public function set vertexOverFunction(v:Function):void
		 {
		 	_onVertex = v;
		 }
		 
		 public function get options():Array { return _options; }
		 public function set options(v:Array):void
		 {
		 	_options = v;
		 	setVars()
		 }
		 
		 public function get currentTime():String { return _currentTime; }
		 public function get lastTime():String { return _lastTime; }
		 public function get vertexCard():int { return _Vcard; }
		 
		 override public function toString():String
		 {
		 	var s:String = "{"+name+"}.";
		 	for (var i:String in _V)
		 		s += "(" + _V[i] + ")";
		 	return s;
		 }
		 
	}
}