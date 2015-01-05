package spaceObjects
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	
	public class Asteroid extends Sprite
	{
		
		private var pos:Point;
		private var asteroidBody:b2Body;
		
		public function Asteroid(_pos:Point)
		{
			pos = _pos;
			super();
			
			graphics.beginFill(0x00FFFF);
			graphics.drawRect(-2.5,-2.5,2.5,2.5);
			graphics.endFill();
			
			init();
			initGraphics();
		}
		
		private function init():void {
			
			var bodyDef:b2BodyDef;
			// Body definition
			bodyDef = new b2BodyDef();
			bodyDef.active = true;
			bodyDef.type = b2Body.b2_dynamicBody;
			bodyDef.position.Set(pos.x, pos.y);
			bodyDef.angularDamping = 0.05;
			bodyDef.linearDamping = 0.05;
			bodyDef.userData = this;
			
			// Add user data
			asteroidBody = smo.m_world.CreateBody(bodyDef);
			
			
			// Module shape
			var newModuleShape:b2PolygonShape = new b2PolygonShape();
			newModuleShape.SetAsOrientedBox(1, 1, new b2Vec2(pos.x, pos.y), 0);
			
			// Fixture definition
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.density = 0.2;
			fixtureDef.friction = 0.5;
			fixtureDef.restitution = 0.5;
			fixtureDef.shape = newModuleShape;
			fixtureDef.userData = this;
			
			var newModule:b2Fixture = asteroidBody.CreateFixture(fixtureDef);
			
			
			
			smo.universe.addChild(this);
		}
		
		private function initGraphics():void {
			/*
			var bmd:BitmapData = new BitmapData(5,5,true,0xFFCC00);
			var mat:Matrix = new Matrix();
			graphics.beginBitmapFill(bmd, mat, false, false);
			graphics.drawRect(0, 0, 5, 5);
			*/
			
		}
	}
}