package com.fitstream.events {
	import flash.events.Event;
	
	public class ScrollBarEvent extends Event {
		public static const SCROLL:String = "scroll";

		private var percent:Number;
		
		function ScrollBarEvent (type:String, percent:Number) {
			super(type, true, true);
			this.percent = percent;
		}
		
		override public function clone():Event {
			return new ScrollBarEvent(this.type, this.percent);
		}
		
		public function get scrollPercent():Number {
			return this.percent;
		}
	}
	
	
}