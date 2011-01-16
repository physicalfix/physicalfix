package com.fitstream{
	
	import flash.display.Sprite;
	import com.fitstream.WorkoutPlaylistItem;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	public class WorkoutPlaylist extends Sprite {
		private var items:Array;
		private var container:Sprite;
		 		
		public function WorkoutPlaylist () {
			items = new Array();
			container = new Sprite();
			addChild(container);
		}
		
		public function loadPlaylist (exercises:Array):void {
			for each(var exercise:Object in exercises) {
				var plItem:WorkoutPlaylistItem = new WorkoutPlaylistItem(exercise);
				plItem.x = 400 - WorkoutPlaylistItem.ITEM_WIDTH - 10;
				plItem.y = (items.length * (WorkoutPlaylistItem.ITEM_HEIGHT + 2)) + 2;
				items.push(plItem);
				container.addChild(plItem);
			}
		}
		
		public function setCurrItem (idx:uint):void {
			var i:uint;
			for (i =0; i < items.length; i++) {
				items[i].active = (i == idx) ? 1 : (i == idx+1) ?  2 : 0;
				
				if (i == (idx+1)) 
						items[i].y = (i * (WorkoutPlaylistItem.ITEM_HEIGHT+2)) + 2 + WorkoutPlaylistItem.ITEM_HEIGHT;
				else if (i > (idx + 1))
					items[i].y = (i * (WorkoutPlaylistItem.ITEM_HEIGHT+2)) + 2 + (WorkoutPlaylistItem.ITEM_HEIGHT*1.5);
				else
					items[i].y = (i * (WorkoutPlaylistItem.ITEM_HEIGHT+2)) + 2;
			}
			TweenLite.to(container, 1 , {ease:Linear.easeOut, y: 2 - (idx * (WorkoutPlaylistItem.ITEM_HEIGHT + 2))});
		}
		
	}
	
}