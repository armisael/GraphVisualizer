package org.silix.graphs
{
	import flash.events.*;
	
	import mx.containers.*;
	
	import org.silix.graphs.edges.GenericEdge;
	import org.silix.graphs.vertexes.GenericVertex;
	import org.silix.utils.CallLater;
	import org.silix.utils.RectangleGenerator;
	
	public class Graph extends GraphComponent
	{
		public static const GRAPH: int = 0;
		public static const DIGRAPH: int = 1;
		public static const NORMAL: int = 2;
		public static const STRICT: int = 3;
		
		private var _components: Array = new Array();
		private var _Vcard: Array = new Array();
		private var _Ecard: Array = new Array();
		
		public function Graph(options: Array = null)
		{
			super(options);
		}
		
		/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
		 * PUBLIC METHODS
		 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
		public function addVertex(name:String, options: Array = null): Object
		{
			if (_Vcard[_currentTime] == undefined) _Vcard[_currentTime] = 0
			
			var c:GraphComponent = getComponentFor(name);
			if(! c.containsVertex(name)) {
				var v:GenericVertex = new _vertexClass(this, _Vcard[_currentTime]++, name, options);
				v.addEventListener(MouseEvent.MOUSE_OVER, onVertex);
				c.addExistingVertex(v);
				//rawChildren.addChild(v);
				return {component: c, vertex: v};
			} else {
				if (!c.V[name].exists) {
					c.V[name].exists = true;
					_Vcard[_currentTime]++;
				}
			}
			return {component: c, vertex: c.V[name]};
		}
		
		public function addEdge(v1name:String, v2name:String, options: Array = null):void
		{
			if (_Ecard[_currentTime] == undefined) _Ecard[_currentTime] = 0
			var e:GenericEdge;
			
			var r1: Object = addVertex(v1name);
			var r2: Object = addVertex(v2name);
			
			e = r1.vertex.addNeighbour(r2.vertex, options);
			//if (e != null) rawChildren.addChild(e);
			if (_type1 == Graph.GRAPH) {
				e = r2.vertex.addNeighbour(r1.vertex, options);
				//if (e != null) rawChildren.addChild(e);
			}
			
			mergeComponents(r1.component, r2.component);
			
			_Ecard[_currentTime]++;
		}
		
		override public function draw(algorithm:Function):Function
		{
			var f: Function;
			for (var i:int = 0; i < _components.length; i++)
				f = _components[i].draw(algorithm);
			
			placeAll();
			
			if (f != null)
				CallLater.call(function():void { draw(f); }, 1000);
			
			return null;
		}
		
		override public function placeAll():void
		{
			var w:Number = 0;
			var h:Number = 0;
			
			for (var i:int = 0; i < _components.length; i++) {
				_components[i].placeAll();
				if (_components[i].width > w) w = _components[i].width;
				if (_components[i].height > h) h = _components[i].height;
			}
			
			var rg:RectangleGenerator = new RectangleGenerator(w, h);
			
			var r:Object;
			for (i = 0; i < _components.length; i++) {
				r = rg.addRectangle(_components[i]);
				_components[i].moveVertexes(r.x, r.y);
				
				if (_components[i].width + r.x > w)
					w = _components[i].width + r.x;
					
				if (_components[i].height + r.y > h)
					h = _components[i].height + r.y;
					
				/* this.graphics.beginFill(0xFFFFFF * Math.random());
				this.graphics.drawRect(r.x, r.y, _components[i].width, _components[i].height);    */
			} 
			
			this.width = w+10;
			this.height = h+10;
			/* this.graphics.beginFill(0xFF0000);
			this.graphics.drawRect(0, 0, this.width, this.height); */
		}
		
		/*
			When finished to parse the graph, call this method to add the vertices
			and edges to their component!
		*/
		override public function complete():void
		{
			for (var i:String in _components) {
				rawChildren.addChild(_components[i]);
				_components[i].complete();
			}
		}
		
		/* override public function starting(s:String):void
		{
			_currentTime = s;
			for (var i:String in _components) {
				_components[i].starting(s);
			}
		} */
		
		override public function changeTo(date:String):void
		{
			super.changeTo(date);
			// I don't know why, but it works also without this...
			/*for (var i:String in _components) {
				_components[i].changeTo(date);
			}*/
		}
		
		
		/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
		 * PRIVATE METHODS
		 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
		private function getComponentFor(name:String): GraphComponent
		{
			var i:int;
			for (i = 0; i < _components.length; i++)
				if (_components[i].containsVertex(name))
					return _components[i];
			_components[i] = new GraphComponent(_options);
			return _components[i];
		}
		
		private function mergeComponents(c1:GraphComponent, c2:GraphComponent):void
		{
			if (c1 == c2) return;
			
			for (var j:String in c2.V)
				//c1.V[j] = c2.V[j];
				c1.addExistingVertex(c2.V[j]);
			
			for (var i: int = _components.indexOf(c2); i < _components.length-1; i++) {
				_components[i] = _components[i+1];
			}
			_components.length = _components.length - 1; 
		}
		
		
		/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
		 * GETTER / SETTER
		 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
		 public function get nComponents():int { return _components.length; }
		 override public function get vertexCard():int { return _Vcard[_currentTime]; }
		 public function get edgeCard():int { return _Ecard[_currentTime]; }
	}
}