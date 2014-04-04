package
{
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.StageScaleMode;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.events.UncaughtErrorEvent;
	import flash.events.ErrorEvent;
	
	[SWF(width = "756", height = "650", frameRate = "60", backgroundColor = "#5dc7cf")]
	
	public class FlappyPreloader extends MovieClip
	{
		private var barSpriteBottom:Sprite;
		private var loader:Loader
		
		private static const PROGRESS_BAR_HEIGHT:Number = 20;
		
		public function FlappyPreloader()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stop();
		}
		
		private function onAddedToStage(event:Event):void 
		{
			stage.showDefaultContextMenu = false;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.align = StageAlign.TOP_LEFT;
			
			barSpriteBottom = new Sprite();
			this.addChild(barSpriteBottom);
			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			/////LOADER/////
			loader = new Loader();
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.securityDomain = SecurityDomain.currentDomain;
			loaderContext.allowCodeImport = true;
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
			
			var flashVars:Object = stage.loaderInfo.parameters;
			var url:String;
			if(flashVars['swfVersion'] != undefined) {
				url = "//raiderbear-6a1.kxcdn.com/flappy/FlappyFlight_" + String(flashVars['swfVersion']) + ".swf";
			}
			else url = "//freeman.youjumpijump.com/swf/FlappyFlight.swf";
			loader.load(new URLRequest(url), loaderContext);
//			if (ExternalInterface.available) ExternalInterface.call("mixpanelTrack", "loading swf", JSON.stringify({ 
//				"url": url
//			}));
		}
		
		private function onProgress(event:ProgressEvent):void 
		{
			var percentage:Number = event.bytesLoaded / event.bytesTotal;
			barSpriteBottom.graphics.clear();
			barSpriteBottom.graphics.beginFill(0xcccccc);
			barSpriteBottom.graphics.drawRect(0, this.stage.stageHeight - PROGRESS_BAR_HEIGHT, this.stage.stageWidth * event.bytesLoaded / event.bytesTotal, PROGRESS_BAR_HEIGHT);
			barSpriteBottom.graphics.endFill();
		}
		
		private function onComplete(e:Event):void {
			loader.contentLoaderInfo.removeEventListener(flash.events.ProgressEvent.PROGRESS, onProgress);
			loader.contentLoaderInfo.removeEventListener(flash.events.Event.COMPLETE, onComplete);
			this.start();
		}
		
		private function start():void {
			// get rid of the progress bar
			barSpriteBottom.graphics.clear();
			this.removeChild(barSpriteBottom);
			barSpriteBottom = null;
			addChild(loader);
		}
		
		private function errorHandler(errorEvent:IOErrorEvent):void {
			if(ExternalInterface.available) ExternalInterface.call("mixpanelTrack", "preloader ioerror: " + errorEvent.toString());
		}
		
		private function uncaughtErrorHandler(event:UncaughtErrorEvent):void {
			if (event.error is Error) {
				var error:Error = event.error as Error;
				var errorString:String = error.getStackTrace();
				if (!errorString) errorString = error.toString();
				if(ExternalInterface.available) ExternalInterface.call("mixpanelTrack", "preloader: " + errorString);
			}
			else if (event.error is ErrorEvent) {
				var errorEvent:ErrorEvent = event.error as ErrorEvent;
				if(ExternalInterface.available) ExternalInterface.call("mixpanelTrack", "preloader event: " + errorEvent.toString());
			}
			else
			{
				// a non-Error, non-ErrorEvent type was thrown and uncaught
				if(ExternalInterface.available) ExternalInterface.call("mixpanelTrack", "preloader nonerror thrown");
			}
		}
	}
}