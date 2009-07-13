package org.silix.graphs.vertexes
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	import org.silix.graphs.Graph;
	import org.silix.utils.*;

	public class LastfmVertex extends GenericVertex
	{
		public static const RADIUS: Number = 6;
		public static const THICKNESS: Number = 4;
		
		private var image: Loader;
		private var bmp: Bitmap;
		
		public function LastfmVertex(g:Graph, idx:int, name:String, options:Array=null)
		{
			super(g, idx, name, options);
			
			if (_options != null && _options["image"] != undefined && _options["image"] != "") {
				image = new Loader();
				image.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
				try {
					image.load(new URLRequest(_options["image"]));
				} catch (e:Error) { }
			}
		}
		
		override public function get info():String
		{
			var s:String = super.info;
			if (_options != null && _options["realname"] != undefined && _options["realname"] != "")
				s += "\nReal name: "+ _options["realname"];
			return s;	
		}
		
		override public function draw():void
		{
			if (_state == GenericVertex.STATE_HIGHLIGHTED) {
				graphics.beginFill(_h_bg_color);
				graphics.lineStyle(THICKNESS, _h_fg_color);
			} else {
				graphics.beginFill(_bg_color);
				graphics.lineStyle(THICKNESS, _fg_color);
			}
			graphics.drawCircle(0, 0, RADIUS);	
		}
		
		private function onImageLoaded(evt:Event):void
		{
			//bmp = ResizeImage.fillIt(image, LastfmVertex.RADIUS*2, LastfmVertex.RADIUS*2);
			bmp = ResizeImage.zoomFillingIt(image, LastfmVertex.RADIUS*2, LastfmVertex.RADIUS*2);
			bmp.x = -LastfmVertex.RADIUS;
			bmp.y = -LastfmVertex.RADIUS;
			this.addChild(bmp);
			
			var rec:MaskCircle = new MaskCircle(0, 0, LastfmVertex.RADIUS);
			this.addChild(rec);
			this.mask = rec;
		}
		
		static public function get margin():Number
		{
			return RADIUS + THICKNESS/2;
		}
	}
}