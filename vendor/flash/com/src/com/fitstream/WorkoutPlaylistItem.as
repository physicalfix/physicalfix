package com.fitstream {
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	
	public class WorkoutPlaylistItem extends Sprite {
		[Embed(	
			source="IT018___.TTF", 
			fontWeight="bold", 
			fontFamily="ITC Avant Garde Gothic"
		)]
		public var embedfont:String;
		
		public static const ITEM_WIDTH:uint = 190;
		public static const ITEM_HEIGHT:uint = 32;
		public static const ITEM_WIDTH_LARGE:uint = 380;
		public static const ITEM_HEIGHT_LARGE:uint = 64; 
		private var nameTXT:TextField;
		private var otherTXT:TextField;
		
		private var bgS:Sprite;
		
		private var mgColors:Object = {
			chest:		0xD1E6EC,
			back:		0xD8D4E2,
			shoulders:	0xCCFFCC,
			legs:		0xFFF8C6,
			biceps:		0xE77471,
			triceps:	0xFFFFFF,
			abs:		0xFFDA6D,
			core:		0xB6FF91,
			power:		0xE7D6A1,
			cardio:		0xC0B9F0
		};
		
		public function WorkoutPlaylistItem (e:Object) {
			
			bgS = new Sprite();
			with (bgS.graphics) {
				beginFill(mgColors[e.musclegroup]);
				drawRoundRect(0, 0, ITEM_WIDTH, ITEM_HEIGHT, 5, 5);
				endFill();
			}
			addChild(bgS);
			
			var ds:DropShadowFilter = new DropShadowFilter(1, 45, 0x000000, 1, 3, 3, 1, 3);
			var gf:GlowFilter = new GlowFilter(0x000000, 1, 3, 3, 5, 3);
			var nTF:TextFormat = new TextFormat();
			nTF = new TextFormat();
			nTF.color = 0xFFFFFF;
			nTF.font = "ITC Avant Garde Gothic";
			nTF.size = 14;
			nTF.bold = true;
			
			nameTXT = new TextField();
			nameTXT.width = ITEM_WIDTH;
			nameTXT.defaultTextFormat = nTF;
			nameTXT.embedFonts = true;
			nameTXT.filters = [gf, ds];
			nameTXT.selectable = false;
			nameTXT.text = e.name;
			addChild(nameTXT);
			
			while (nameTXT.textWidth > ITEM_WIDTH) {
				nTF.size = Number(nTF.size) - 1;
				nameTXT.setTextFormat(nTF);
			}
			
			nTF.size = 11;
			otherTXT = new TextField();
			otherTXT.width = ITEM_WIDTH;
			otherTXT.defaultTextFormat = nTF;
			otherTXT.embedFonts = true;
			otherTXT.filters = [gf, ds];
			otherTXT.selectable = false;
			
			if (String(e.reps).length > 0  && String(e.weight).length > 0) {
				otherTXT.text =  e.reps;
				if (e.reps.indexOf('s') < 0) {
					otherTXT.appendText(' reps');
				}
				otherTXT.appendText(" | " + e.weight + " lbs");
			}
			else if (String(e.reps).length > 0) {
				otherTXT.text = e.reps;
				if (e.reps.indexOf('s') < 0) {
					otherTXT.appendText(" reps");
				}
			}
			else if (String(e.weight).length > 0)
				otherTXT.text = e.weight + " lbs";
			otherTXT.y = 15;
			addChild(otherTXT);
			
			alpha = .75;
		}
		
		public function set active (a:uint):void {
			switch (a) {
				case 0:
				alpha = .5;
				TweenLite.to(this, 1, {ease:Linear.easeOut, scaleX: 1, scaleY: 1, x: 400 - ITEM_WIDTH - 10});
				break
				case 1:
				alpha = 1;
				TweenLite.to(this, 1, {ease:Linear.easeOut, scaleX: 2, scaleY: 2, x: 400 - (ITEM_WIDTH*2)- 10});
				break;
				case 2:
				alpha = .75;
				TweenLite.to(this, 1, {ease:Linear.easeOut, scaleX: 1.5, scaleY: 1.5, x: 400 - (ITEM_WIDTH*1.5)- 10});
				break;
			}
			
		}
	}
	
}