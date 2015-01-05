package modules
{
	import flash.display.Sprite;
	import flash.filters.GlowFilter;

	public class Engine extends BaseModule
	{
		
		public var thrust:uint = 5;
		private var engineTrail:Sprite;
		
		public function Engine()
		{
			drawOutline();
		}
		
		override protected function drawOutline():void {
			graphics.clear();
			graphics.lineStyle(1, 0);
			graphics.beginFill(0xAABBCC);
			graphics.drawRect(-w, -w, (w*2)-1, (w*2)-1);
			
		}
		
		public function activate():void {
			isActive = true;
			this.filters = [new GlowFilter];
			
		}
		
		public function deactivate():void {
			isActive = false;
			this.filters = [];
		}
	}
}