package modules
{
	import flash.display.Sprite;

	public class BaseModule extends Sprite
	{
		
		public var w:uint = 5;
		public var isActive:Boolean = false;
		
		public function BaseModule()
		{
			super();
			drawOutline();
		}
		
		protected function drawOutline():void {
			graphics.lineStyle(1, 0);
			graphics.beginFill(0xCCCCCC);
			graphics.drawRect(-w, -w, (w*2)-1, (w*2)-1);
			
		}
	}
}