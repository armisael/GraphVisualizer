package org.silix.graphs.edges
{
	import org.silix.graphs.vertexes.GenericVertex;
	import org.silix.graphs.Graph;
	import flash.text.*;
	import flash.display.*;

	public class LabeledEdge extends GenericEdge
	{
		private static var textFormat: TextFormat;
		private var _label:TextField = new TextField();
		
		public function LabeledEdge(g:Graph, idx:int, v1:GenericVertex, v2:GenericVertex, options:Array=null)
		{
			if (textFormat == null) {
				textFormat = new TextFormat();
		    	textFormat.bold = true;
				textFormat.font = "Vera";
			}
		
			super(g, idx, v1, v2, options);
			
			if (options != null && options["label"] != undefined) {
				_label.text = options["label"];
				_label.setTextFormat(textFormat);
				_label.blendMode = BlendMode.LAYER;
				_label.selectable = false;
				_label.wordWrap = true;
				_label.embedFonts = true;
				
				//_label.width = RADIUS * 2 + 2;
				//_label.height = RADIUS * 2 + 2;
			}
				
			addChild(_label);
		}
		
		override public function draw(o:Object = null):void
		{
			super.draw(o);
			_label.x = (x2-x1)/2 + x1;
			_label.y = (y2-y1)/2 + y1;
			_label.rotation = Math.acos(Math.sqrt(Math.pow(x2-x1, 2) + Math.pow(y2-y1, 2)) / (x2-x1));
			//trace(Math.sqrt(Math.pow(x2-x1, 2) + Math.pow(y2-y1, 2)) / (x2-x1));
			
			_label.rotation = (e*180 / Math.PI);
			if (_label.rotation > 90) _label.rotation -= 180;
			if (_label.rotation < -90) _label.rotation += 180;
			//trace(_label.rotation, (_label.rotation), _label.rotation >= -180 && _label.rotation <= 180);
		}
		
		
	}
}