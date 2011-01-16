package com.fitstream{

	import com.greensock.TweenLite;
	import com.greensock.easing.Linear; 
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class FadeButton extends Sprite {
		
		private var rState:DisplayObject;
		private var hState:DisplayObject;
		private var oState:DisplayObject;
		private var f_toggle:Boolean;
		private var f_on:Boolean = false;
		private var f_enabled:Boolean = true;
			
		public function FadeButton (r:DisplayObject, h:DisplayObject, o:DisplayObject = null, toggle:Boolean = false) {
			rState = r;
			hState = h;
			oState = o;
			f_toggle = toggle;
			
			hState.alpha = 0;
			if (oState) oState.alpha = 0;
			
			addChild(rState);
			addChild(hState);
			if (oState) addChild(oState);
			
			buttonMode = true;
			
			addEventListener(MouseEvent.ROLL_OVER, mouseHandler);
			addEventListener(MouseEvent.ROLL_OUT, mouseHandler);
			addEventListener(MouseEvent.CLICK, mouseHandler);		
		}
		
		public function toggle ():void {
			if (!f_toggle) return;
			
			if (f_on) {
				rState.alpha = 1;
				hState.alpha = 0;
				oState.alpha = 0;
			} else {
				rState.alpha = 0;
				hState.alpha = 0;
				oState.alpha = 1;
			}
			
			f_on = !f_on;
		}
		
		public function set depressed (d:Boolean):void {
			if (!f_toggle || f_on == d) return;
			toggle();
		}
		
		private function mouseHandler(e:MouseEvent):void {
			if (!f_enabled) return;
			switch(e.type) {
				case MouseEvent.ROLL_OVER:
				if (f_on) return;
				TweenLite.to(rState, .25, {ease:Linear.easeOut, alpha:0});
				TweenLite.to(hState, .25, {ease:Linear.easeOut, alpha:1});
				break;
				
				case MouseEvent.ROLL_OUT:
				
				TweenLite.to(rState, .25, {ease:Linear.easeOut, alpha:1});
				TweenLite.to(hState, .25, {ease:Linear.easeOut, alpha:0});
				
				break;
				
				case MouseEvent.CLICK:
				if (f_toggle) f_on = !f_on;
				else return;
				oState.alpha = (f_on) ? 1 : 0;
				rState.alpha = (f_on) ? 0 : 1;
				hState.alpha = 0;
				break;
			}
		}
		
		public function set enabled(e:Boolean):void {
			f_enabled = mouseEnabled = buttonMode = e;
			if(!e) alpha = .5;
			else alpha = 1;
		}
		
		public function get enabled():Boolean {
			return f_enabled;
		}
		
		public function get on():Boolean {
			return f_on;
		}

	}
}