package com.fitstream {
	
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	
	import flash.events.*;
	
	import flash.geom.Rectangle;
	import com.fitstream.events.ScrollBarEvent;
	
	public class ScrollBar extends Sprite {
		
		private var trackS:Sprite;
		private var upBTN:SimpleButton;
		private var downBTN:SimpleButton;
		private var nubS:Sprite;
		private var grabber:Sprite;
		private var sbHeight:Number;
		private var parentObj:Sprite;
				
		public function ScrollBar (obj:Sprite, h:Number) {
			sbHeight = h;
			parentObj = obj;
			
			trackS = new Sprite();
			with (trackS.graphics) {
				beginFill(0x999999);
				drawRect(0, 0, 10, sbHeight);
			}
			addChild(trackS);
			
			nubS = new Sprite();
			var nH:Number = Math.round(sbHeight * (sbHeight/parentObj.height)); 
			with (nubS.graphics) {
				beginFill(0xF5F5F5);
				drawRect(0, 0, 10, sbHeight);
			}
			
			nubS.buttonMode = true;
			addChild(nubS);

			grabber = new Sprite();
			with (grabber.graphics) {
				beginFill(0x3D3D3D);
				drawRect(0, 0, 6, 1);
				drawRect(0, 2, 6, 1);
				drawRect(0, 4, 6, 1);
				endFill();
				
				beginFill(0xC7C7C7);
				drawRect(0, 1, 6, 1);
				drawRect(0, 3, 6, 1);
				drawRect(0, 5, 6, 1);
				endFill();
			}
			grabber.x = (nubS.width - grabber.width)/2;
			nubS.addChild(grabber);

			
			nubS.addEventListener(MouseEvent.MOUSE_DOWN, startDragNub);
			nubS.addEventListener(MouseEvent.MOUSE_UP, endDragNub);
			addEventListener(Event.ADDED_TO_STAGE, addedHandler);

		} 
		
		private function addedHandler(e:Event):void {
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
		}
		
		public function resize(h:Number = -1):void {
			
			if (h >= 0) {
				sbHeight = h;
				trackS.height = sbHeight;
			}
			drawNub(Math.round(sbHeight * (sbHeight/parentObj.height)));
			nubS.y = 0;
		}
		
		private function drawNub(h:Number):void {
			with (nubS.graphics) {
				clear();
				beginFill(0xF5F5F5);
				drawRect(0, 0, 10, h);
			}
			
			grabber.y = Math.round((h-grabber.height)/2);
		}
		
		private function startDragNub(e:MouseEvent):void {
			nubS.startDrag(false, new Rectangle(0, 0, 0, sbHeight-nubS.height));
			stage.addEventListener(MouseEvent.MOUSE_UP, endDragNub);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, doDrag); 
		}
		
		private function endDragNub(e:MouseEvent):void {
			nubS.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, endDragNub);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, doDrag);
		}
		
		private function doDrag(e:MouseEvent):void {
			var percent:Number = nubS.y / (sbHeight-nubS.height);
			dispatchEvent(new ScrollBarEvent(ScrollBarEvent.SCROLL, percent));
		}
		
		private function wheelHandler(e:MouseEvent):void {
			
			nubS.y = nubS.y - (e.delta*6);
			if (nubS.y > sbHeight-nubS.height) nubS.y = sbHeight - nubS.height;
			if (nubS.y < 0) nubS.y = 0; 
			doDrag(null);
		}
	}
}