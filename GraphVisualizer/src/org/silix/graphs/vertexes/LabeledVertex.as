package org.silix.graphs.vertexes
{
	import org.silix.graphs.Graph;
	import flash.text.*;
	import flash.display.*;

	public class LabeledVertex extends GenericVertex
	{
		private static var textFormat: TextFormat;
		private var _label:TextField = new TextField();
			
		public function LabeledVertex(g:Graph, idx:int, name:String, options:Array=null)
		{
			if (textFormat == null) {
				textFormat = new TextFormat();
		    	textFormat.bold = true;
			}
		
			super(g, idx, name, options);
			
			_bg_color = _fg_color;
			_added_bg_color = _added_fg_color;
			_h_bg_color = _h_fg_color;
			
			this.draw();
			
			_label.text = name;
			_label.setTextFormat(textFormat);
			_label.blendMode = BlendMode.LAYER;
			_label.selectable = false;
			_label.wordWrap = true;
			
			_label.x = -RADIUS;
			_label.y = -RADIUS;
			_label.width = RADIUS * 2 + 2;
			_label.height = RADIUS * 2 + 2;
				
			addChild(_label);
		}
		
		override public function draw():void
		{
			super.draw();
			if (_state == GenericVertex.STATE_HIGHLIGHTED) {
				_label.textColor = 0xFFFFFF - _h_fg_color;
			} else if (status == GenericVertex.STATUS_ADDED) {
				_label.textColor = 0xFFFFFF - _added_fg_color;
			} else {
				_label.textColor = 0xFFFFFF - _fg_color;
			}
		}
		
		static public function get margin():Number
		{
			return RADIUS + THICKNESS/2;
		}
		
	}
}