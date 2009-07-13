package org.silix.graphs.edges
{
	import org.silix.graphs.Graph;
	import org.silix.graphs.vertexes.GenericVertex;

	public class TrustletEdge extends GenericEdge
	{
		public function TrustletEdge(g:Graph, idx:int, v1:GenericVertex, v2:GenericVertex, options:Array=null)
		{
			super(g, idx, v1, v2, options);
		}
		
		override public function draw(o:Object=null):void
		{
			super.draw(o);
			this.alpha = level2alpha(_options["level"]);
		}
		
		private function level2alpha(l:String):Number
		{
			if (l == "Master") return 1;
			if (l == "Journeyer") return 0.8;
			if (l == "Apprentice") return 0.6;
			if (l == "Observer") return 0.4;
			return 0;
		}
	}
}