package ships
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	
	import modules.BaseModule;
	import modules.Engine;
	
	public class ShipBase extends MovieClip
	{
		public var shipBody:b2Body;
		private var positions:Array = [];
		private var currentPosition:Number = 0
		private var pos:Point;
		private var moduleArr:Array;
		
		public var lastAngle:Number = 0;
		
		public function ShipBase(_pos:Point)
		{
			super();
			pos = _pos;
			setModulePositions();
			initShip();
			initModules();
		}
		
		private function setModulePositions():void {
			
			addPt(0, 0);
			addPt(-1, -1);
			addPt(-1, 0);
			addPt(-1, 1);
			addPt(-2, -1);
			addPt(-2, 0);
			addPt(-2, 1);
			addPt(-3, 1);
		}
		
		private function addPt(x:Number, y:Number):void {
			positions.push(new Point(pos.x + (x * 2), pos.y + (y * 2)));
		}
		
		public function activateEngines():void {
			var module:BaseModule;
			for each(module in moduleArr){
				if(module is Engine){
					if( ! Engine(module).isActive){
						Engine(module).activate();
					}
				}
			}
		}
		
		public function deactivateEngines():void {
			var module:BaseModule;
			for each(module in moduleArr){
				if(module is Engine){
					if(Engine(module).isActive){
						Engine(module).deactivate();
					}
				}
			}
		}
		
		
		private function initShip():void {

			var bodyDef:b2BodyDef;
			// Body definition
			bodyDef = new b2BodyDef();
			bodyDef.active = true;
			bodyDef.type = b2Body.b2_dynamicBody;
			bodyDef.position.Set(pos.x, pos.y);
			bodyDef.angularDamping = 0.1;
			bodyDef.linearDamping = 0.1;
			bodyDef.userData = this;
			
			// Add user data
			shipBody = smo.m_world.CreateBody(bodyDef);
			
			smo.universe.addChild(this);
			
		}
		
		private function initModules():void {
			
			moduleArr = [];
			
			addModule(new BaseModule());
			addModule(new BaseModule());
			addModule(new BaseModule());
			addModule(new BaseModule());
			addModule(new Engine());
			addModule(new BaseModule());
			addModule(new Engine());
		}
		
		
		private function addModule(module:BaseModule):void {
			
			var pos:Point = positions[currentPosition];
			if(!pos){
				throw new Error("No more modules allowed on this ship!");
			}
			
			// Module shape
			var newModuleShape:b2PolygonShape = new b2PolygonShape();
			newModuleShape.SetAsOrientedBox(1, 1, new b2Vec2(pos.x, pos.y), 0);
			
			// Fixture definition
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.density = 0.2;
			fixtureDef.friction = 0.5;
			fixtureDef.restitution = 0.5;
			fixtureDef.shape = newModuleShape;
			fixtureDef.userData = module;
			
			
			var newModule:b2Fixture = shipBody.CreateFixture(fixtureDef);
			
			module.x = pos.x * (module.width)/2;
			module.y = pos.y * (module.height)/2;
			addChild(fixtureDef.userData);
			
			currentPosition++;
			
			moduleArr.push(module);
		}
	}
}