package org.silix.utils
{
	import flash.events.*;
	import flash.utils.*;
	
	public class CallLater
	{
		public static function call(f:Function, delay:Number = 1000, iterations:int = 1):void
		{
			var t:Timer = new Timer(delay, iterations);
			t.start(); 
		    t.addEventListener(TimerEvent.TIMER, function(evt:Event):void{ f() });
		}

	}
}