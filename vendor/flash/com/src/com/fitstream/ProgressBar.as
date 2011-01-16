package com.fitstream{

	import flash.display.Sprite;
	import flash.display.GradientType;
	import flash.geom.Matrix;

	public class ProgressBar extends Sprite {
		private var _value:Number = 0;
		private var pbWidth:uint;
		private var pbHeight:uint;
		private var pbBG:Sprite;
		private var pbFG:Sprite;
		private var sS:Sprite;
		private var separators:Array;
		private var gm:Matrix;
		
		public function ProgressBar(width:uint, height:uint)
		{
			pbWidth = width;
			pbHeight = height;
			
			pbBG = new Sprite();
			pbFG = new Sprite();
			sS = new Sprite();
			
			gm = new Matrix();
			gm.createGradientBox(pbWidth,pbHeight,Math.PI/2,0,0);
			
			drawBG();
			drawFG();
			
			separators = new Array();
			
			addChild(pbBG);
			addChild(pbFG);
			addChild(sS);
			
		}
		
		private function drawBG():void
		{
			
			with (pbBG.graphics) {
				clear();
				beginFill(0x999999);
				drawRoundRect(0, 1, pbWidth, pbHeight,pbHeight/2,pbHeight/2);
				endFill();
				
				beginGradientFill(
					GradientType.LINEAR,
					[0x000000, 0x333333],
					[1, 1],
					[0, 255],
					gm
				);
				drawRoundRect(0, 0, pbWidth, pbHeight,pbHeight/2,pbHeight/2);
				endFill();
			}
		}
		
		private function drawFG():void
		{
			with (pbFG.graphics) {
				clear();
				beginGradientFill(
					GradientType.LINEAR,
					[0x29ABE2, 0x0071BC],
					[1,1],
					[0,255],
					gm
				);
				drawRoundRect(0,0,Math.round(pbWidth * _value),pbHeight,pbHeight/4,pbHeight/4);
				endFill;
			}
		}
		
		public function addSeparatorAt(p:Number, w:Number):void
		{
			if (p >= 1) return;
			separators.push({percent:p, width:w});
			drawSeparators();
		}
		
		private function drawSeparators():void
		{
			with (sS.graphics) {
				clear();
				beginGradientFill(
					GradientType.LINEAR,
					[0x69FFFF, 0x0045C7],
					[1,1],
					[0,255],
					gm
				);
				for each(var s:Number in separators) {
					if (s.percent == 0)
						drawRoundRectComplex(s.percent*pbWidth, 0, s.width*pbWidth, pbHeight, pbHeight/4, 0, pbHeight/4, 0);
					else
						drawRect(s.percent*pbWidth, 0, s.width*pbWidth, pbHeight);
				}
				endFill();
			}
		}
		
		public function setSize(width:uint, height:uint):void
		{
			pbWidth = width;
			pbHeight = height;
			
			drawFG();
			drawBG();
			drawSeparators();
		}
		
		public function set value(v:Number):void
		{
			_value = v;
			drawFG();
		}
		
		public function get value():Number
		{
			return _value;
		}
		
	}
	
}