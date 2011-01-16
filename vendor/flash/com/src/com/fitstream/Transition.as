package com.fitstream {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.filters.DropShadowFilter;
	import flash.display.Bitmap;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class Transition extends Sprite {
		[Embed(source='big_logo_bg.png')] private var logoIMG:Class;
		[Embed(	
			source="IT018___.TTF", 
			fontWeight="bold", 
			fontFamily="ITC Avant Garde Gothic"
		)]
		public var embedfont:String;
		private var tWidth:uint;
		private var tHeight:uint;
		private var bgS:Sprite;
		private var eTXT:TextField;
		private var rTXT:TextField;
		private var wTXT:TextField;
		private var tTXT:TextField;
		private var gm:Matrix;
		private var logo:Bitmap;
		private var logoRatio:Number;
		private var eTF:TextFormat;
		private var oTF:TextFormat;
		private var t:Timer;
		
		public function Transition (width:uint, height:uint) 
		{
			tWidth = width;
			tHeight = height;
			bgS = new Sprite();
			addChild(bgS);
			
			logo = new logoIMG();
			logo.smoothing = true;
			//logoRatio = logo.width/logo.height;
			//logo.width = tWidth/2;
			//logo.height = logo.width * logoRatio;
			logo.x = tWidth - logo.width;
			//logo.y = tHeight - logo.height;
			//logo.alpha = .15;
			addChild(logo);
			
			eTF = new TextFormat();
			eTF.color = 0xFFFFFF;
			eTF.font = "ITC Avant Garde Gothic";
			//eTF.size = 60;
			eTF.bold = true;
			
			oTF = new TextFormat();
		 	oTF.color = 0xFFFFFF;
			oTF.font = "ITC Avant Garde Gothic";
			//oTF.size = 30;
			oTF.bold = true;
			
			var ds:DropShadowFilter = new DropShadowFilter(1, 45, 0x00, 1, 3, 3, 1, 3);
			
			eTXT = new TextField();
			eTXT.multiline = true;
			eTXT.width = tWidth;
			eTXT.defaultTextFormat = eTF;
			eTXT.autoSize = 'left';
			eTXT.selectable = false;
			eTXT.embedFonts = true;
			eTXT.x = 10;
			eTXT.y = 10;
			eTXT.filters = [ds];
			addChild(eTXT);
			
			rTXT = new TextField();
			rTXT.width = tWidth;
			rTXT.defaultTextFormat = oTF;
			rTXT.autoSize = 'left';
			rTXT.selectable = false;
			rTXT.embedFonts = true;
			rTXT.filters = [ds];
			rTXT.x = 10;
			rTXT.y = 80;
			addChild(rTXT);
			
			wTXT = new TextField();
			wTXT.width = tWidth;
			wTXT.defaultTextFormat = oTF;
			wTXT.autoSize = 'left';
			wTXT.selectable = false;
			wTXT.embedFonts = true;
			wTXT.filters = [ds];
			wTXT.x = 10;
			wTXT.y = 130;
			addChild(wTXT);
			
			tTXT = new TextField();
			tTXT.width = tWidth;
			tTXT.defaultTextFormat = oTF;
			tTXT.autoSize = 'left';
			tTXT.selectable = false;
			tTXT.embedFonts = true;
			tTXT.filters = [ds];
			tTXT.x = 10;
			tTXT.y = tHeight - 30;
			addChild(tTXT);
			
			t = new Timer(1000);
			t.addEventListener(TimerEvent.TIMER, timerHandler);
			
			gm = new Matrix();
			
			drawBG();
		}
		
		public function setInfo (eName:String, reps:String, weight:String, time:uint):void {
			eTXT.text = eName;
			if (String(reps).length > 0) {
				if (String(reps).indexOf('s') > 0) {
					rTXT.text = reps;
				} else {
					rTXT.text = 'Reps: ' + reps;
				}
			}
			else
				rTXT.text = '';
			if (String(weight).length > 0)
				wTXT.text = 'Weight: ' + weight;
			else 
				wTXT.text = '';
			
			tTXT.text = 'Starts in: ' + time;

			t.reset();
			t.repeatCount = time;
			t.start();

			setSize(tWidth, tHeight);
		}
		
		private function timerHandler (e:TimerEvent):void {
			tTXT.text = 'Starts in: ' + (t.repeatCount - t.currentCount);
			tTXT.setTextFormat(eTF);
		}
		
		public function pause (p:Boolean):void {
			if (p) t.stop();
			else t.start();
		}
		
		public function setSize (width:uint, height:uint):void {
			tWidth = width;
			tHeight = height;
			
			eTXT.width = tWidth;
			
			eTF.size = 1;	
			eTXT.setTextFormat(eTF);
		
			while (eTXT.textWidth + 240 < tWidth && eTF.size <= 200) {
				eTF.size = Number(eTF.size) + 1;
				eTXT.setTextFormat(eTF);
			}
			
			
			rTXT.y = eTXT.y + eTXT.height + 10;
			rTXT.width = tWidth;
			oTF.size = eTF.size;
			rTXT.setTextFormat(oTF);						
			
			wTXT.y = rTXT.y + rTXT.height + 10;
			wTXT.width = tWidth;
			wTXT.setTextFormat(oTF);
			
			
			logo.x = tWidth - logo.width;
			
			tTXT.setTextFormat(eTF);
			tTXT.y = tHeight - tTXT.height;
			
			
			drawBG();
		}
		
		private function drawBG():void {
			gm.createGradientBox(tWidth,tHeight,Math.PI/2,0,0);
			with (bgS.graphics) {
				clear();
				beginGradientFill(
					GradientType.LINEAR,
					[0x333333, 0x000000],
					[1, 1],
					[0, 255],
					gm
				);
				drawRect(0, 0, tWidth, tHeight);
				endFill();
			}
		}
	}
	
}