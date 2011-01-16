package
{        
    import flash.display.Sprite;
 	import flash.net.NetConnection;
   	import flash.net.NetStream;
   	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.events.StatusEvent;
	import flash.display.StageAlign;
    import flash.display.StageScaleMode;
	import flash.display.LoaderInfo;
	import flash.events.MouseEvent;
    import flash.external.ExternalInterface;
    import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
    [SWF( backgroundColor='0x000000', frameRate='30', width='320', height='240')]

    public class NotePlayer extends Sprite
    {
		private var vid:Video;
		private var ns:NetStream;
		private var nc:NetConnection;
		private var fileName:String;
		private var playBTN:Sprite;
        private var loader:Loader;

        public function NotePlayer()
        {	
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			fileName = Base64.encode("workout_note_" + this.loaderInfo.parameters['workout_id']);
			vid = new Video(320,240);
			addChild(vid);

            ExternalInterface.addCallback('playMovie', startMovie);

            loader = new Loader();
            addChild(loader);
            loader.load(new URLRequest('https://s3.amazonaws.com/physicalfix/webcam/' + escape(fileName) + '.jpg'));

        }

        private function startMovie():void {
            if (loader) {
                removeChild(loader);
                loader.unload();
            }

            nc = new NetConnection();
			nc.connect(null);

            ns = new NetStream(nc);
		    ns.bufferTime = 3;
			vid.attachNetStream(ns);
            ns.play("https://s3.amazonaws.com/physicalfix/webcam/" + 
escape(fileName) + ".flv");
        }

    }

}
