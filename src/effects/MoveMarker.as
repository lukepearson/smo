package effects
{
	import com.greensock.TweenLite;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class MoveMarker extends Sprite
	{
		public function MoveMarker()
		{
			super();
			var innerRing = createRing(2, 0xB8F741);
			var midRing = createRing(4, 0x00C90D);
			var outerRing = createRing(6, 0x3DE548);
			
			addChild(innerRing);
			addChild(midRing);
			addChild(outerRing);
			
			TweenLite.to(innerRing, 1, {width:10, height:10, onComplete:tweenBack, onCompleteParams:[innerRing,true]});
			TweenLite.to(midRing, 0.8, {width:20, height:20,  onComplete:tweenBack, onCompleteParams:[midRing,false]});
			TweenLite.to(outerRing, 0.4, {width:30, height:30, onComplete:tweenBack, onCompleteParams:[outerRing,false]});
		}
		
		private function tweenBack(ring:Sprite, destroyOnComplete:Boolean):void {
			if(destroyOnComplete) {
				TweenLite.to(ring,1.6, {width:1, height:1, onComplete:destroy, onCompleteParams:[ring]});
			}else{
				TweenLite.to(ring, 1.6, {width:1, height:1});
			}
		}
		
		private function destroy(ring:Sprite):void {
			MovieClip(this.parent).removeChild(this);
		}
		
		private function createRing(radius:Number, color:Number):Sprite {
			
			var ring:Sprite = new Sprite();
			
			ring.graphics.lineStyle(0.8, color);
			ring.graphics.drawCircle(0,0, radius);
			
			return ring;
		}
	}
}