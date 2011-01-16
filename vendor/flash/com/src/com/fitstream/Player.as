package com.fitstream{

	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.sendToURL;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;

	
	[SWF( backgroundColor='0x333333', frameRate='30', width='800', height='600')]
	
	public class Player extends Sprite {
		[Embed(source='logo.png')] private var logoIMG:Class;
		[Embed(source='big_play.png')] private var BigPlayIMG:Class;
		[Embed(source='play.png')] private var playIMG:Class;
		[Embed(source='play-hover.png')] private var playHoverIMG:Class;
		[Embed(source='play-on.png')] private var playOnIMG:Class;
		[Embed(	
			source="IT018___.TTF", 
			fontWeight="bold", 
			fontFamily="ITC Avant Garde Gothic"
		)]
		public var embedfont:String;
		
		public static const PBS_HEIGHT:uint = 40;
		public static const PBL_WIDTH:uint = 0;
		public static const VID_WIDTH:int = 640;
		public static const VID_HEIGHT:int = 360;
		
		private var pb:ProgressBar;
		private var pbS:Sprite;
		private var plS:Sprite;
		private var t:Timer;
		private var transTimer:Timer;
		private var vid:Video;
		private var connection:NetConnection;
		private var stream:NetStream;
		private var playlist:Array;
		private var xLoader:URLLoader;
		private var totalTime:Number = 0;
		private var clipTime:Number = 0;
		private var elapsedTime:Number = 0;
		private var currExercise:uint = 0;
		private var rtTXT:TextField;
		private var trans:Transition;
		private var f_stop:Boolean = true;
		private var checkTime:Date = null;
		private var logo:Bitmap;
		private var playBTN:FadeButton;
		private var pl:WorkoutPlaylist;
		private var plMask:Sprite;
		private var pauseS:Sprite;
		private var pPlayBTN:Sprite;
		private var workoutSession:uint;
		private var currPlaylistItem:WorkoutPlaylistItem;
		private var nextPlaylistItem:WorkoutPlaylistItem;
		private var currLBL:TextField;
		private var nextLBL:TextField;
		
		public function Player () {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, resizeHandler);
			stage.addEventListener(Event.DEACTIVATE, inactiveHandler);
			
			t = new Timer(100);
			t.addEventListener(TimerEvent.TIMER, timerHandler);
			
			transTimer = new Timer(0,1);
			transTimer.addEventListener(TimerEvent.TIMER, transHandler);
			
			pbS = new Sprite();
			plS = new Sprite();
			
			drawPBS();
			
			playBTN = new FadeButton(new playIMG(), new playHoverIMG(), new playOnIMG(), true);
			pbS.addChild(playBTN);
			
			playBTN.y = (PBS_HEIGHT - playBTN.height)/2;
			playBTN.x = 5;
			playBTN.toggle();
			playBTN.addEventListener(MouseEvent.CLICK, playBTNHandler);
			
			pb = new ProgressBar(stage.stageWidth - 200, PBS_HEIGHT-8);
			pb.x = playBTN.x + playBTN.width + 5;
			pb.y = 4;
			pbS.y = stage.stageHeight - PBS_HEIGHT;
			pbS.addChild(pb);
			
			var rtTF:TextFormat = new TextFormat();
			rtTF.color = 0xFFFFFF;
			rtTF.font = "ITC Avant Garde Gothic";
			rtTF.size = 25;
			rtTF.bold = true;
	
			rtTXT = new TextField();
			rtTXT.defaultTextFormat = rtTF;
			rtTXT.embedFonts = true;
			rtTXT.autoSize = 'left';
			rtTXT.selectable = false;
			rtTXT.x = pb.x + pb.width + 10;
			rtTXT.y = Math.round((PBS_HEIGHT - rtTXT.textHeight)/2);
			rtTXT.filters = [new DropShadowFilter(1, 45, 0x00, 1, 3 ,3, 1, 3)];
			pbS.addChild(rtTXT);
			addChild(pbS);
			
			plS.x = stage.stageWidth - plS.width;
			addChild(plS);
			
			vid = new Video();
			vid.smoothing = true;
			vid.deblocking = 3;
			addChild(vid);
			
			trans = new Transition(stage.stageWidth, stage.stageHeight - PBS_HEIGHT);
			addChild(trans);
			trans.visible = false;
			
			playlist = new Array();
			
			logo = new logoIMG();
			logo.smoothing = true;
			//logo.width = 100;
			//logo.height = 100;
			logo.x = 10;
			logo.y = 10;
			logo.filters = [new DropShadowFilter(1,45,0x000000,1,1,1,1,3)];
			addChild(logo);
			
			/*plMask = new Sprite();
			plMask.cacheAsBitmap = true;
			addChild(plMask);
			drawPLMask();
			
			pl = new WorkoutPlaylist();
			pl.mask = plMask;
			pl.cacheAsBitmap = true;
			addChild(pl);*/
			
			pauseS = new Sprite();
			pauseS.alpha = 0;
			pauseS.buttonMode = true;
			
			pPlayBTN = new Sprite();
			pPlayBTN.addChild(new BigPlayIMG());
			pauseS.addChild(pPlayBTN);
			addChild(pauseS);
			
			
			pauseS.addEventListener(MouseEvent.CLICK, clickHandler);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			
			var params:Object = LoaderInfo(this.root.loaderInfo).parameters;
			
			if (params['lastPlayed']) currExercise = params['lastPlayed'];
			
			workoutSession = params['workoutSession'];
			
			var fileToLoad:String = params['file'] || 'playlist.xml';
			
			resizeHandler(null);
			xLoader = new URLLoader();
			xLoader.addEventListener(Event.COMPLETE, onLoadXML);
			xLoader.load(new URLRequest(fileToLoad));
			
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			var ds:DropShadowFilter = new DropShadowFilter(1, 45, 0x000000, 1, 3, 3, 1, 3);
			var gf:GlowFilter = new GlowFilter(0x000000, 1, 3, 3, 5, 3);
			var nTF:TextFormat = new TextFormat();
			nTF = new TextFormat();
			nTF.color = 0xFFFFFF;
			nTF.font = "ITC Avant Garde Gothic";
			nTF.size = 14;
			nTF.bold = true;
			
			currLBL = new TextField();
			currLBL.embedFonts = true;
			currLBL.defaultTextFormat = nTF;
			currLBL.text = 'Current Exercise';
			currLBL.filters = [ds,gf];
			currLBL.autoSize = 'left';
			addChild(currLBL);
			currLBL.x = currLBL.y = 10;
			currLBL.alpha = 0.75;
			
			nextLBL = new TextField();
			nextLBL.embedFonts = true;
			nextLBL.defaultTextFormat = nTF;
			nextLBL.text = 'Next Exercise';
			nextLBL.filters = [ds,gf];
			nextLBL.autoSize = 'left';
			addChild(nextLBL);
			nextLBL.x = stage.stageWidth - nextLBL.textWidth - 10;
			nextLBL.y = 10;
			nextLBL.alpha = 0.75;
			logo.visible = false;	
		}
		
		private function onLoadXML(event:Event):void {
			var mainXML:XML = new XML(xLoader.data);
			totalTime = Number(mainXML.totaltime.text());
			for each(var exercise:XML in mainXML..exercise) {
				var obj:Object = {
					src: exercise.src.text(),
					name: exercise.name.text(),
					weight: exercise.weight.text(),
					reps: exercise.reps.text(),
					time: Number(exercise.time.text()),
					delay: Number(exercise.delay.text()),
					musclegroup: exercise.musclegroup.text()
				};
				playlist.push(obj);
			}
			//pl.loadPlaylist(playlist);
			drawPBLines();
			connection.connect(null);
			displayTime();
			resizeHandler(null);
		}
		
		private function drawPBLines():void {
			var total:Number = 0;
			for each(var exercise:Object in playlist) {
				pb.addSeparatorAt(total/totalTime, exercise.delay/totalTime);
				total += (exercise.time + exercise.delay);
			}
		}
		
		private function resizeHandler (event:Event):void {
			drawPBS();
			//drawPLMask();
			drawPS();
			
			//pb.y = stage.stageHeight - PBS_HEIGHT-3;
			//trace(stage.stageHeight, pb.y);
			trans.setSize(stage.stageWidth, stage.stageHeight - PBS_HEIGHT);
			rtTXT.x = stage.stageWidth - rtTXT.textWidth - 10;
			rtTXT.y = Math.round((PBS_HEIGHT - rtTXT.textHeight)/2) - 2;
			
			pb.setSize(rtTXT.x - pb.x - 5, (PBS_HEIGHT-8));
			
			pbS.y = stage.stageHeight - PBS_HEIGHT;
			//pl.x = stage.stageWidth - 400;
			//plMask.x = pl.x;
			
			var workingWidth:Number = stage.stageWidth;
			var workingHeight:Number = stage.stageHeight - PBS_HEIGHT;
			var scaleFactor:Number = Math.min(stage.stageWidth / VID_WIDTH, (stage.stageHeight - PBS_HEIGHT) / VID_HEIGHT);			
			
			vid.width = VID_WIDTH * scaleFactor;
			vid.height = VID_HEIGHT * scaleFactor;
			
			vid.x = Math.round((stage.stageWidth - vid.width)/2);
			vid.y = Math.round((stage.stageHeight - PBS_HEIGHT - vid.height)/2);
			logo.x = 10;
			logo.y = vid.y + 10;
			if (logo.y < 75) {
				logo.y = 75;
			}
			pPlayBTN.x = Math.round((pauseS.width - pPlayBTN.width)/2);
			pPlayBTN.y = Math.round((pauseS.height - pPlayBTN.height)/2);
			//stage.invalidate();
			
			if (currPlaylistItem) {
				currPlaylistItem.x = 10;
				currPlaylistItem.y = currLBL.y + currLBL.textHeight + 5;
			}
			
			if (nextPlaylistItem) {
				nextPlaylistItem.x = stage.stageWidth - nextPlaylistItem.width - 10;
				nextPlaylistItem.y = currPlaylistItem.y;
			}
			
			if (nextLBL) {
				nextLBL.x = stage.stageWidth - nextLBL.textWidth - 10;
			}
			
		}
		
		private function drawPBS ():void {
			var m:Matrix = new Matrix();
			m.createGradientBox(stage.stageWidth, PBS_HEIGHT-3/2, Math.PI/2, 0, 0);
			
			with (pbS.graphics) {
				clear();
				beginGradientFill(
					GradientType.LINEAR,
					[0x9a9b9e, 0x2b2f33],
					[1, 1],
					[0, 128],
					m
				);
				drawRect(0, 2, stage.stageWidth, PBS_HEIGHT-3);
				endFill();
				
				beginFill(0xFFFFFF);
				drawRect(0,1,stage.stageWidth,1);
				endFill();
				
				beginFill(0x000000);
				drawRect(0,0,stage.stageWidth,1);
				endFill();
			}
		}
		
		private function drawPS ():void {
			with (pauseS.graphics) {
				clear();
				beginFill(0x000000);
				drawRect(0, 0, stage.stageWidth, stage.stageHeight - PBS_HEIGHT);
				endFill();
			}
		}
		
		/*private function drawPLMask ():void {
			var m:Matrix = new Matrix();
			m.createGradientBox(400, stage.stageHeight - PBS_HEIGHT, Math.PI/2, 0, 0);
			
			with (plMask.graphics) {
				clear();
				beginGradientFill(
					GradientType.LINEAR,
					[0x000000, 0x000000],
					[1, 0],
					[200, 255],
					m
				);
				drawRect(0, 0, 400, stage.stageHeight - PBS_HEIGHT);
				endFill();
			}
		}*/
		
		private function netStatusHandler (event:NetStatusEvent):void {
			trace(event.info.code);
			switch (event.info.code) {
				case 'NetConnection.Connect.Success':
					connectStream();
					break;
				case 'NetStream.Play.StreamNotFound':
					trace('Unable to locate video');
					break;
				case 'NetStream.Buffer.Full':
				case 'NetStream.Unpause.Notify':
				case 'NetStream.Play.Start':
					t.start();
					f_stop = false;
					break;
				case 'NetStream.Play.Stop':
					f_stop = true;
					currExercise++;
					//clipTime = 0;
					if (currExercise < playlist.length) {
						displayTransition(currExercise);
					} else {
						t.stop();
						checkTime = null;
						ExternalInterface.call('workoutComplete');
					}
					break;
				case 'NetStream.Buffer.Empty':
				case 'NetStream.Pause.Notify':
					if (!f_stop){
						t.stop();	
						checkTime = null;
					} 
					break;
				}
		}
		
		private function displayTransition (idx:uint):void {
			sendToURL(new URLRequest('/workouts/status/' + workoutSession + '?lastPlayed=' + idx));
			vid.visible = false;
			trans.visible = true;
			logo.visible = false;
			var item:Object = playlist[idx];
			
			if (currPlaylistItem) {
				removeChild(currPlaylistItem);
			}
			currPlaylistItem = new WorkoutPlaylistItem(playlist[idx]);
			currPlaylistItem.scaleX = currPlaylistItem.scaleY = 1.4;
			addChild(currPlaylistItem);
			
			if (nextPlaylistItem) {
				removeChild(nextPlaylistItem);	
			}
			
			if (idx + 1 < playlist.length) { 
				nextPlaylistItem = new WorkoutPlaylistItem(playlist[idx+1]);
				addChild(nextPlaylistItem);
				nextPlaylistItem.scaleX = nextPlaylistItem.scaleY = 1.4;
			} else {
				nextPlaylistItem = null;
			}
			currPlaylistItem.visible = false;
			currLBL.visible = false;
			if (nextPlaylistItem) {
				nextPlaylistItem.visible = false;
			}
			nextLBL.visible = false;
			resizeHandler(null);
			trans.setInfo(item.name, item.reps, item.weight, item.delay);
			transTimer.delay = item.delay * 1000;
			transTimer.start();
			//pl.setCurrItem(idx);
			playItem(idx);
			stream.pause();
		}
		
		private function playItem (idx:uint):void {
			var src:String = playlist[idx].src;
			//t.stop();
			stream.play(src);
			resizeHandler(null);
		}
		
		private function transHandler (event:TimerEvent):void {
			trans.visible = false;
			vid.visible = true;
			//logo.visible = true;
			stream.resume();
			currPlaylistItem.visible = true;
			currLBL.visible = true;
			
			if (nextPlaylistItem) {
				nextPlaylistItem.visible = true;
				nextLBL.visible = true;
			}
			//playItem(currExercise);
		}
		
		private function playBTNHandler(e:MouseEvent):void {
			pause(!playBTN.on);
		}
		
		private function keyHandler(e:KeyboardEvent):void {
			playBTN.toggle();
			pause(!playBTN.on);
		}
		
		private function inactiveHandler (e:Event):void {
			pause(true);
		}
		
		private function clickHandler(e:MouseEvent):void {
			playBTN.toggle();
			pause(!playBTN.on);
		}
		
		private function pause (p:Boolean):void {
			if (p) {
				if (transTimer.running){
					transTimer.stop();
					trans.pause(true);
				} 
				
				if (t.running) t.stop();
				stream.pause();
				checkTime = null;
				pauseS.alpha = .8;
			} else {
				if (trans.visible) {
					transTimer.start();
					trans.pause(false);
				}
				else stream.resume();
				t.start();
				pauseS.alpha = 0;
			}
			
		}
		
		private function timerHandler (event:TimerEvent):void {
			if (!checkTime) checkTime = new Date();
			var now:Date = new Date();
			elapsedTime += (now.time - checkTime.time)/1000;
			displayTime();
			pb.value = elapsedTime/totalTime; 
			checkTime = now;
		}

        private function displayTime():void {
            var timeLeft:Number = totalTime - elapsedTime;
			if (timeLeft < 0) {
				timeLeft = 0;
			}
			rtTXT.text = (playlist.length - currExercise) + " Exercises Left | - " +  formatTime(totalTime - elapsedTime);
        }

		private function formatTime(s:Number):String {
			var minutes:uint = Math.floor(s/60);
			var seconds:uint = s%60;
			var str:String = '';
			str += (minutes < 10) ? '0' + minutes : minutes;
			str += ':';
			str += (seconds < 10) ? '0' + seconds : seconds; 
			
			return str;
		}
		private function connectStream ():void {
			stream = new NetStream(connection);
			stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			stream.client = {onMetaData: function(data:Object):void{}};
			moveProgressBar(currExercise);
			vid.attachNetStream(stream);
			
			//t.start();
			displayTransition(currExercise);
		}
		
		private function moveProgressBar(item:uint):void {
			if (item > playlist.length) return;
			
			var rt:uint = 0;
			for (var i:uint = 0; i < item; i++)
				rt += (playlist[i].delay + playlist[i].time + 0.5);
			elapsedTime = rt;
			pb.value = elapsedTime/totalTime;
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			trace("securityErrorHandler: " + event);
		}
		private function asyncErrorHandler(event:AsyncErrorEvent):void {}
	}
	
}