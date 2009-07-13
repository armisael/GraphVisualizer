package org.silix.graphs.parsers
{
	import org.silix.graphs.Graph;
	
	public interface IParser
	{
		function can_parse(o:Object):Boolean;
		function parse(o:Object, g:Graph):void;
	}
}