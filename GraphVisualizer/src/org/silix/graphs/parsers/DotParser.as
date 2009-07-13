package org.silix.graphs.parsers
{
	import com.chewtinfoil.utils.StringUtils;
	
	import flash.events.*;
	
	import org.silix.graphs.Graph;

	public class DotParser implements IParser
	{	
		private var lines: String;
		private var total: int;
		
		public function can_parse(o:Object):Boolean
		{
			var s: String = String(o);
			if (s.indexOf("strict") == 0) s = s.substr("strict".length + 1)
			return s.indexOf("digraph") == 0 || s.indexOf("graph") == 0;
		}
		
		public function parse(o:Object, g: Graph):void
		{
			var s: String = String(o).replace(/\n/g, "").replace(/\t/g, "");
			var header: String = StringUtils.trim(s.substr(0, s.indexOf("{")));
			var options: Array = parse_header(header);
			g.options = options;
			lines = StringUtils.trim(s.substring(s.indexOf("{")+1, s.lastIndexOf("}")));
			total = lines.length;
			
			var v1: String;
			var v2: String;
			var evt: ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
			while (lines.length > 0) {
				v1 = get_id(lines);
				lines = StringUtils.trimLeft(lines.substr(v1.length + ((lines.charAt(0)=='"')?2:0) ));
				if (lines.indexOf("--") != 0 && lines.indexOf("->") != 0) {
					options = parse_edge_opts(lines);
					g.addVertex(v1, options);
					lines = StringUtils.trimLeft(lines.substr(lines.indexOf(";")+1)); // maybe here we have to check something...
					continue;
				}
				lines = StringUtils.trimLeft(lines.substr(2));
				v2 = get_id(lines);
				lines = StringUtils.trimLeft(lines.substr(v2.length + ((lines.charAt(0)=='"')?2:0) ));
				options = parse_edge_opts(lines);
				g.addEdge(v1, v2, options);
				lines = StringUtils.trimLeft(lines.substr(lines.indexOf(";")+1)); // maybe here we have to check something...
			}
			
		}
		
		
		/* =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
		 * Private Methods
		 * =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~ */
		private function parse_lines(lines:String):void
		{
			
		}
		
		private function parse_header(header:String):Array
		{
			var opt: Array = new Array();
			opt["name"] = "Generic Graph";
			
			var word:String = get_id(header);
			if (word == "strict") {
				opt["type2"] = Graph.STRICT;
				header = StringUtils.trim(header.substr(word.length));
				word = get_id(header);
			} else
				opt["type2"] = Graph.NORMAL;
			
			if (word == "digraph")
				opt["type1"] = Graph.DIGRAPH;
			else opt["type1"] = Graph.GRAPH;
			
			header = StringUtils.trim(header.substr(word.length));
			if (header.length > 0)
				opt["name"] = get_id(header);
				
			return opt;
		}
		
		private function parse_edge_opts(s:String):Array
		{
			if (s.charAt(0) != '[') return null;
			
			var res:Array = new Array();
			s = s.substring(1, s.indexOf("]"));
			var v:Array = s.split(",");
			var w:Array;
			for (var i:int = 0; i < v.length; i++) {
				w = v[i].split("=");
				res[ get_id(w[0]) ] = get_id(w[1]);
			}
			
			return res;
		}
		
		private function get_id(s:String):String
		{
			s = StringUtils.trim(s);
			if (s.charAt(0) != '"')
				return s.substring(0, Math.min(myIndexOf(s, ";"),myIndexOf(s, " "), myIndexOf(s, "="), myIndexOf(s, ":"), myIndexOf(s, ",")));
			else {
				var ss: String = s.substr(1);
				var cnt: int = 0;
				do {
					var i: int = ss.indexOf('"')
					var j: int = ss.indexOf("\\\"");
					if (j < 0 || j > i) 
						return s.substr(1, cnt+i);
					else ss = ss.substr(i+1);
					cnt += i+1;
				} while (ss.length > 0); 
			}
			return "";
		}
		
		private function myIndexOf(s:String, p:String):int
		{
			var n:int = s.indexOf(p);
			return (n >= 0) ? n : int.MAX_VALUE;
		}
		
	}
}