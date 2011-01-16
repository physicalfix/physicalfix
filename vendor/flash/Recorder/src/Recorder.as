package {        
	import flash.display.Sprite;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.system.SecurityPanel;
	import flash.system.Security;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.external.ExternalInterface;
	import flash.display.LoaderInfo;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	
	[SWF( backgroundColor='0xFFFFFF', frameRate='30', width='320', height='240')]
	public class Recorder extends Sprite {
		private var cam:Camera;
		private var mic:Microphone;
		private var vid:Video;
		private var ns:NetStream;
		private var nc:NetConnection;
		private var mode:String;
		private var host:String = "rtmp://u1.physicalfix.com";
		private var fileName:String;

		public function Recorder() {	
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			flash.net.NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF0;

			cam = Camera.getCamera();
			if (cam.muted) {
				Security.showSettings(SecurityPanel.PRIVACY);
				cam.addEventListener(StatusEvent.STATUS, statusHandler);
			} else { 
				connectCamera();
			}
			
			addChild(vid);

			mic = Microphone.getMicrophone();
			fileName = Base64.encode("workout_note_" + this.loaderInfo.parameters['workout_id']);
		}
		
		private function connectCamera():void {
			cam.setQuality(0, 95);
			cam.setMode(320, 240, 25);
			vid = new Video(cam.width, cam.height);
			vid.attachCamera(cam);
			addChild(vid);
			ExternalInterface.addCallback('recordVid', recordVid);
			ExternalInterface.addCallback('stopVid', stopVid);
			ExternalInterface.addCallback('reviewVid', reviewVid);
		}

		private function recordVid():void {
			if (mode == 'review') {
				removeChild(vid);
				vid = new Video(cam.width, cam.height);
				vid.attachCamera(cam);
				addChild(vid);
			}

			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
			mode = 'record';
			nc.connect(host);
			ExternalInterface.call('setRecording', true);
		}

		private function onNetStatus(e:NetStatusEvent):void {
			
			trace(e.info.code);
			
			if( e.info.code == "NetConnection.Connect.Success" ) {
				ns = new NetStream(nc);
				ns.bufferTime = 3;
				ns.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
				if (mode == 'record') {
					ns.attachCamera(cam);
					ns.attachAudio(mic);
					ns.publish(fileName, "record");
				} else {
					trace('attaching net stream.');
					vid.attachNetStream(ns);
					ns.play("https://s3.amazonaws.com/myfitstream/webcam/" + escape(fileName) + ".flv");
				}
			}
		}

		private function stopVid():void {
			ExternalInterface.call('setRecording', false);
			if( ns != null ) {
				ns.close();
			}
			nc.close();
			ExternalInterface.call('processing', true);
			//make get to sinatra to process file
			var url:String = "http://u1.physicalfix.com/process?id=" + escape(fileName);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onProcess);
			loader.load(new URLRequest(url));
		}
		
		private function onProcess(event:Event):void {
			ExternalInterface.call('processing', false);
			if (event.target.data != 'ok') {
				ExternalInterface.call('error');
			}
		}

		private function reviewVid():void {
			if (ns != null) {
				ns.close();
			}

			if (nc != null) {
				nc.close();
			}
			
			removeChild(vid);
			vid = new Video(cam.width, cam.height);
			addChild(vid);

			mode = 'review';

			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);

			nc.connect(null);
		}
		
		private function statusHandler(event:StatusEvent):void {
			if (event.code == "Camera.Unmuted") {
				connectCamera(); 
				cam.removeEventListener(StatusEvent.STATUS, statusHandler);
			}
		}
	}
}