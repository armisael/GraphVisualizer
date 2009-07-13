////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (c) 2008 Josh Tynjala
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to 
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package com.flextoolbox.controls
{
	import flash.display.*;
	import flash.events.*;
	
	import mx.controls.scrollClasses.ScrollThumb;
	import mx.core.EdgeMetrics;
	import mx.core.IUIComponent;
	import mx.core.ScrollControlBase;
	import mx.core.ScrollPolicy;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDetail;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	
	//----------------------------------
	//  Metadata
	//----------------------------------
	
	[DefaultProperty("content")]
	
	//----------------------------------
	//  Styles
	//----------------------------------
	
	/**
	 * Number of pixels between the left border and the left edge of the content.
	 * 
	 * @default 0
	 */
	[Style(name="paddingLeft", type="Number", format="Length")]
	
	/**
	 * Number of pixels between the right border and the right edge of the content.
	 * 
	 * @default 0
	 */
	[Style(name="paddingRight", type="Number", format="Length")]
	
	/**
	 * Number of pixels between the top border and the top edge of the content.
	 * 
	 * @default 0
	 */
	[Style(name="paddingTop", type="Number", format="Length")]
	
	/**
	 * Number of pixels between the bottom border and the bottom edge of the content.
	 * 
	 * @default 0
	 */
	[Style(name="paddingBottom", type="Number", format="Length")]
	
	/**
	 * The horizontal alignment of the ZoomFrame's content. Possible values are "left", "center", and "right".
	 * 
	 *  @default "left"
	 */
	[Style(name="horizontalAlign", type="String")]
	
	/**
	 * The vertical alignment of the ZoomFrame's content. Possible values are "top", "middle", and "bottom".
	 * 
	 *  @default "top"
	 */
	[Style(name="verticalAlign", type="String")]

	/**
	 * Holds a <code>DisplayObject</code> which may be zoomed in or out by
	 * altering the <code>scale</code> property. A border is displayed around
	 * the content if desired.
	 * 
	 * @author Josh Tynjala
	 * @see flash.display.DisplayObject
	 */
	public class ZoomFrame extends ScrollControlBase
	{
		
		public static const SCALED:String = "Scaled"
		
	//----------------------------------
	//  Static Methods
	//----------------------------------
	
		/**
		 * @private
		 * Creates the default styles and passes them to the StyleManager.
		 */
		private static function initializeStyles():void
		{
			var selector:CSSStyleDeclaration = StyleManager.getStyleDeclaration("ZoomFrame");
			
			if(!selector)
			{
				selector = new CSSStyleDeclaration();
			}
			
			selector.defaultFactory = function():void
			{
				this.backgroundColor = 0xffffff;
				this.horizontalAlign = "left";
				this.verticalAlign = "top";
			}
			
			StyleManager.setStyleDeclaration("ZoomFrame", selector, false);
		}
		
		//initialize the default styles
		initializeStyles();
		
	//----------------------------------
	//  Constructor
	//----------------------------------
	
		/**
		 * Constructor.
		 */
		public function ZoomFrame()
		{
			super();
			this.verticalScrollPolicy = ScrollPolicy.AUTO;
			this.horizontalScrollPolicy = ScrollPolicy.AUTO;
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
			
	//----------------------------------
	//  Properties
	//----------------------------------
	
		/**
		 * @private
		 * Flag that is set when the content property changes.
		 */
		private var _contentChanged:Boolean = false;
		
		/**
		 * @private
		 * Storage for the content property.
		 */
		private var _content:DisplayObject;
		
		[Bindable]
		public function get content():DisplayObject
		{
			return this._content;
		}
		
		/**
		 * @private
		 */
		public function set content(value:DisplayObject):void
		{
			if(this._content != value)
			{
				if(this._content && this.contains(this._content))
				{
					this.removeChild(this._content);
					this._content.mask = null;
				}
				
				this._content = value;
				this._contentChanged = true;
				this.invalidateProperties();
				this.invalidateSize();
				this.invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 * Storage for the scale property.
		 */
		private var _scale:Number = 1.0;
		
		[Bindable]
		public function get scale():Number
		{
			return this._scale;
		}
		
		/**
		 * @private
		 */
		public function set scale(value:Number):void
		{
			if(this._scale != value)
			{
				this._scale = value;
				this.invalidateProperties();
				this.invalidateSize();
				this.invalidateDisplayList();
				this.dispatchEvent(new Event(ZoomFrame.SCALED));
			}
		}
		
	//----------------------------------
	//  Public Methods
	//----------------------------------
	
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void
		{
			var allStyles:Boolean = styleProp == null || styleProp == "styleName";
			
			super.styleChanged(styleProp);
			
			if(allStyles || styleProp == "verticalAlign" || styleProp == "horizontalAlign")
			{
				this.invalidateDisplayList();
			}
		}
		
		public function scroll(x:Number, y:Number):void
		{
			_content.x = x;
			_content.y = y;
			this.horizontalScrollPosition = -x;
			this.verticalScrollPosition = -y;
		}
		
	//----------------------------------
	//  Protected Methods
	//----------------------------------
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(this.content)
			{
			
				if(this._contentChanged)
				{
					this._contentChanged = false;
					this.addChild(this.content);
					this.content.mask = this.maskShape;
				}
				
				this.content.scaleX = this.content.scaleY = this.scale;
			}
		}
		
		/**
		 * @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			if(this.content)
			{
				var metrics:EdgeMetrics = this.viewMetrics;
				var paddingLeft:Number = this.getStyle("paddingLeft");
				var paddingRight:Number = this.getStyle("paddingRight");
				var paddingTop:Number = this.getStyle("paddingTop");
				var paddingBottom:Number = this.getStyle("paddingBottom");
				
				var w:Number = this.content.width;
				var h:Number = this.content.height;
				if(this.content is IUIComponent)
				{
					var contentComponent:IUIComponent = this.content as IUIComponent;
					w = contentComponent.getExplicitOrMeasuredWidth();
					h = contentComponent.getExplicitOrMeasuredHeight();
				}
				
				this.measuredWidth = w + metrics.left + metrics.right + paddingLeft + paddingRight;
				this.measuredHeight = h + metrics.top + metrics.bottom + paddingTop + paddingBottom;
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var contentWidth:Number = this.content.width;
			var contentHeight:Number = this.content.height;
			if(this.content is IUIComponent)
			{
				var contentComponent:IUIComponent = this.content as IUIComponent;
				contentWidth = contentComponent.getExplicitOrMeasuredWidth();
				contentHeight = contentComponent.getExplicitOrMeasuredHeight();
				contentComponent.setActualSize(contentWidth, contentHeight);
			}
			
			var metrics:EdgeMetrics = this.viewMetrics;
			var paddingLeft:Number = this.getStyle("paddingLeft");
			var paddingRight:Number = this.getStyle("paddingRight");
			var paddingTop:Number = this.getStyle("paddingTop");
			var paddingBottom:Number = this.getStyle("paddingBottom");
			
			var visibleWidth:Number = unscaledWidth - metrics.left - metrics.right; 
			var visibleHeight:Number = unscaledHeight - metrics.top - metrics.bottom;
			var totalColumns:Number = Math.max(contentWidth + paddingLeft + paddingRight, visibleWidth);
			var totalRows:Number = Math.max(contentHeight + paddingTop + paddingBottom, visibleHeight)
			
			this.setScrollBarProperties(totalColumns, visibleWidth, totalRows, visibleHeight);
			
			var horizontalAlign:String = this.getStyle("horizontalAlign");
			if(!horizontalAlign)
			{
				horizontalAlign = "left";
			}
			switch(horizontalAlign.toLowerCase())
			{
				case "right":
				{
					this.content.x = (metrics.left + visibleWidth) - paddingRight - contentWidth;
					this.content.x += Math.max(0, contentWidth - visibleWidth);
					break;
				}
				case "center":
				{
					this.content.x = metrics.left + (visibleWidth - contentWidth) / 2;
					this.content.x += Math.max(0, contentWidth - visibleWidth) / 2;
					break;
				}
				default: //left
				{
					this.content.x = metrics.left + paddingLeft;
				}
			}
			
			var verticalAlign:String = this.getStyle("verticalAlign");
			if(!verticalAlign)
			{
				verticalAlign = "top";
			}
			switch(verticalAlign.toLowerCase())
			{
				case "bottom":
				{
					this.content.y = (metrics.top + visibleHeight) - paddingBottom - contentHeight;
					this.content.y += Math.max(0, contentHeight - visibleHeight);
					break;
				}
				case "middle":
				{
					this.content.y = metrics.top + (visibleHeight - contentHeight) / 2;
					this.content.y += Math.max(0, contentHeight - visibleHeight) / 2;
					break;
				}
				default: //top
				{
					this.content.y = metrics.top + paddingTop;
				}
			}
			
			this.content.x -= this.horizontalScrollPosition;
			this.content.y -= this.verticalScrollPosition;
		}
		
		/**
		 * @private
		 * Redraw when the scrollbar changes. Takes into account the
		 * liveScrolling property.
		 */
		override protected function scrollHandler(event:Event):void
		{
			super.scrollHandler(event);
			
			if(!this.liveScrolling && ScrollEvent(event).detail == ScrollEventDetail.THUMB_TRACK)
            {
                return;
            }
			
			this.invalidateDisplayList();
		}
		
	//----------------------------------
	//  DRAG'n'DROP
	//----------------------------------
		
		private var click_x:Number;
		private var click_y:Number;
		private var scroll_x:Number;
		private var scroll_y:Number;
		private function onMouseDown(evt:MouseEvent):void
		{
			// to let the scrollbars to work
			if (evt.target is ScrollThumb) return;
			
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			click_x = evt.stageX;
			click_y = evt.stageY;
			scroll_x = this.horizontalScrollPosition;
			scroll_y = this.verticalScrollPosition;
		}
		
		private function onMouseUp(evt:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseMove(evt:MouseEvent):void
		{
			if (this.horizontalScrollBar) {
				this.horizontalScrollPosition = scroll_x - (evt.stageX - click_x);
				if (this.horizontalScrollPosition > this.maxHorizontalScrollPosition)
					this.horizontalScrollPosition = this.maxHorizontalScrollPosition;
				else if (this.horizontalScrollPosition < 0)
					this.horizontalScrollPosition = 0;
				this.horizontalScrollBar.dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL));
			}
			if (this.verticalScrollBar) {
				this.verticalScrollPosition = scroll_y - (evt.stageY - click_y);
				if (this.verticalScrollPosition > this.maxVerticalScrollPosition)
					this.verticalScrollPosition = this.maxVerticalScrollPosition;
				else if (this.verticalScrollPosition < 0)
					this.verticalScrollPosition = 0;
				this.verticalScrollBar.dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL));
			}
		}
		
		
	}
}