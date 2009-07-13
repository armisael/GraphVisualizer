package org.silix.graphs.edges
{
	import org.silix.graphs.vertexes.GenericVertex;
	import org.silix.graphs.Graph;

	public class HistoryEdge extends GenericEdge
	{
		public function HistoryEdge(g:Graph, idx:int, v1:GenericVertex, v2:GenericVertex, options:Array=null)
		{
			super(g, idx, v1, v2, options);
		}
		
		override public function draw(o:Object=null):void
		{
			super.draw(o);
			this.alpha = int(_options["value"]) / 20 + 0.3;
		}
		
	}
}