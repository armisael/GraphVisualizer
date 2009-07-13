package org.silix.graphs.edges
{
	import org.silix.graphs.vertexes.GenericVertex;
	import org.silix.graphs.Graph;

	public class LastfmEdge extends GenericEdge
	{
		public function LastfmEdge(g:Graph, idx:int, v1:GenericVertex, v2:GenericVertex, options:Array=null)
		{
			super(g, idx, v1, v2, options);
		}
		
		override public function draw(o:Object=null):void
		{
			//trace(v1, v2);
			this.alpha = 0.3 + int(_options["tasteometer"]);
			//this._tickness = _options["tasteometer"] * 3;
			super.draw(o);
		}
		
	}
}