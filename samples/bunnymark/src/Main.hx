package;

import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.display3D.Context3DProfile;
import openfl.display3D.Context3DRenderMode;
import openfl.events.Event;
import openfl.Lib;
import starling.core.Starling;
import starling.textures.RenderTexture;

/**
 * ...
 * @author P.J.Shand
 */
class Main extends Sprite 
{
	private var mStarling:Starling;
	
	public function new() 
	{
		super();
		
		if (stage != null) start();
		else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	private function onAddedToStage(event:Dynamic):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		start();
	}

	private function start():Void
	{
		var fps = new FPS(10, 10, 0x000000);
		addChild(fps);
		
		Starling.multitouchEnabled = true; // for Multitouch Scene
		Starling.handleLostContext = true; // recommended everywhere when using AssetManager
		RenderTexture.optimizePersistentBuffers = true; // should be safe on Desktop
		
		mStarling = new Starling(BunnyMark, stage, null, null, Context3DRenderMode.AUTO, Context3DProfile.BASELINE_EXTENDED);
		mStarling.antiAliasing = 0;
		mStarling.simulateMultitouch = false;
		//mStarling.enableErrorChecking = Capabilities.isDebugger;
		mStarling.addEventListener(starling.events.Event.ROOT_CREATED, function():Void
		{
			BunnyMark.instance.init();
		});
		
		mStarling.start();
	}

}
