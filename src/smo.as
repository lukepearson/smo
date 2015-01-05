package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import Box2D.Collision.b2AABB;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Joints.b2RopeJoint;
	import Box2D.Dynamics.Joints.b2RopeJointDef;
	
	import effects.MoveMarker;
	
	import ships.ShipBase;
	
	import spaceObjects.Asteroid;

	[SWF(width='1920', height='1080', backgroundColor='#292C2C', frameRate='60')]
	public class smo extends MovieClip
	{
		
		public static var universe:Sprite;
		public static var m_world:b2World;
		public static var m_velocityIterations:int = 10;
		public static var m_positionIterations:int = 10;
		public static var m_physScale:Number = 5;
		public static var m_timeStep:Number = 1 / m_physScale;
		public static var keys:Dictionary;
		
		private var txt:TextField;
		private var navTarget:b2Vec2;
		private var ship:ShipBase;
		private var m_mouseJoint:b2RopeJoint;
		private var tractorTimer:Timer;
		
		public function smo(){
			
			keys = new Dictionary();
			universe = this;
			
			txt = new TextField();
			txt.height = 800;
			txt.width = 800;
			addChild(txt);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
				
			
			// Add event for main loop
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
			stage.addEventListener(MouseEvent.CLICK, onLeftClick);
			
			
			stage.color = 0;
			
			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0, 0);
			
			// Allow bodies to sleep
			var doSleep:Boolean = true;
			
			// Construct a world object
			m_world = new b2World( gravity, doSleep);
			
			var xMid:Number = (stage.stageWidth /2) / m_physScale;
			var yMid:Number = (stage.stageHeight / 2) / m_physScale;
			
			var top_mid:Point = new Point(xMid, 0); 
			var bot_mid:Point = new Point(xMid, stage.stageHeight / m_physScale);
			var left_mid:Point = new Point(0, yMid);
			var right_mid:Point = new Point(stage.stageWidth / m_physScale, yMid);
			
			// border
			createLineBody(top_mid,0);
			createLineBody(bot_mid,0);
			createLineBody(left_mid,-1.5707);
			createLineBody(right_mid,1.5707);
			//---
			
			// Asteroid
			for(var i:uint = 0; i<100; i++){
				var asteroidPos:Point = new Point(Math.random()*xMid, Math.random()*yMid);
				var asteroid:Asteroid = new Asteroid(asteroidPos);
			}
			
			
			// Space ship
			var startingPos:Point = new Point(xMid/3, yMid/2);
			ship = new ShipBase(startingPos);
			
			
			// set debug draw
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			debugDraw.SetSprite(this);
			debugDraw.SetDrawScale(m_physScale);
			debugDraw.SetFillAlpha(0.3);
			debugDraw.SetLineThickness(1.0);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			m_world.SetDebugDraw(debugDraw);
			m_world.DrawDebugData();
			
		}
		
		private function onRightClick(e:MouseEvent):void {
			
			var mx:Number = e.stageX / m_physScale;
			var my:Number = e.stageY / m_physScale;
			navTarget = new b2Vec2(mx, my);
				
			var mm:MoveMarker = new MoveMarker();
			mm.x = e.stageX;
			mm.y = e.stageY;
			addChild(mm);
			
		}
		
		private function onLeftClick(e:MouseEvent):void {
			
		
			var bb:b2Body = getBodyAtMouse(false);
			if(bb){
				
				if(!tractorTimer){
					tractorTimer = new Timer(100, 0);
					tractorTimer.addEventListener(TimerEvent.TIMER, onTractorTick);
					tractorTimer.start();
				}
				
				var pt_bb:b2Vec2 = bb.GetWorldCenter();
				var pt_ship:b2Vec2 = ship.shipBody.GetWorldCenter();
				
				var dist:Number = getDistance(pt_bb, pt_ship);
				
				var tractorDef:b2RopeJointDef = new b2RopeJointDef();
				tractorDef.Initialize(bb, ship.shipBody, pt_bb, pt_ship, dist);
				tractorDef.collideConnected;
				
				m_mouseJoint = m_world.CreateJoint(tractorDef) as b2RopeJoint;
				bb.SetActive(true);
			}
			
			
		}
		
		private function getDistance(pt1:b2Vec2, pt2:b2Vec2):Number {
			
			var dx:Number = pt1.x - pt2.x;
			var dy:Number = pt1.y - pt2.y;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		private function onTractorTick(e:TimerEvent):void {
			
			var len:Number = m_mouseJoint.GetMaxLength()-1;
			m_mouseJoint.SetMaxLength(len);
			
			if(len <= 5){
				tractorTimer.stop();
			}
				
			
		}
		
		private function createNavTarget(pt:b2Vec2):void {
			//navtag
			var groundBodyDef:b2BodyDef= new b2BodyDef();
			groundBodyDef.position.Set(pt.x, pt.y);
			groundBodyDef.angle = rotation;
			var groundBody:b2Body = m_world.CreateBody(groundBodyDef);
			var groundBox:b2PolygonShape = new b2PolygonShape();
			groundBox.SetAsBox(1,1);
			
			var groundFixtureDef:b2FixtureDef = new b2FixtureDef();
			groundFixtureDef.shape = groundBox;
			groundFixtureDef.friction = 1;
			groundBody.CreateFixture(groundFixtureDef);
		}
		
		private function createLineBody(pt:Point, rotation):void {
			
			var x = pt.x;
			var y = pt.y;
			
			var groundBodyDef:b2BodyDef= new b2BodyDef();
			groundBodyDef.position.Set(x, y);
			groundBodyDef.angle = rotation;
			var groundBody:b2Body = m_world.CreateBody(groundBodyDef);
			var groundBox:b2PolygonShape = new b2PolygonShape();
			groundBox.SetAsBox(220,0.2);
			
			var groundFixtureDef:b2FixtureDef = new b2FixtureDef();
			groundFixtureDef.shape = groundBox;
			groundFixtureDef.friction = 1;
			groundBody.CreateFixture(groundFixtureDef);
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			keys[String.fromCharCode(e.keyCode)] = true;
			
			if(stage.displayState != StageDisplayState.FULL_SCREEN && keys["F"]){
				stage.displayState = StageDisplayState.FULL_SCREEN;	
			}else if(stage.displayState == StageDisplayState.FULL_SCREEN && keys["F"]){
				stage.displayState = StageDisplayState.NORMAL;	
			}
			
		}
		
		private function onKeyUp(e:KeyboardEvent):void {
			keys[String.fromCharCode(e.keyCode)] = false;
		}
		
		private function doAutoPilot(bb:b2Body):Dictionary {
			
			var autopilot:Dictionary = new Dictionary();
			
			var bX = bb.GetWorldCenter().x;
			var bY = bb.GetWorldCenter().y;

			var tX = navTarget.x;
			var tY = navTarget.y;
			
			var targetAngle:Number = Math.atan2(tY-bY, tX-bX);
			var angle:Number = bb.GetAngle();
			
			ship.lastAngle = angle;
			
			txt.appendText("\n Target angle: " + targetAngle);
			
			var nearTargetAngle = Math.round(targetAngle * 10) / 10;
			var nearAngle = Math.round(angle * 10) / 10;
			
			if(nearAngle > 2.5){
				nearAngle
			}
			
			var diff:Number = targetAngle - angle;
			
			var TAU = Math.PI * 2;
			var PI = Math.PI;
			
			if(diff > PI){
				diff -= TAU;
			}
			if(diff < - PI){
				diff += TAU;
			}
			
			
			txt.appendText("\n Diff: " + diff);
			
			if(diff > 3) {
				autopilot["LEFT"] = true;
			}else if(diff < 3) {
				autopilot["RIGHT"] = true;
			}
			
			var dx:Number = bX-tX;
			var dy:Number = bY-tY;
			var distance:Number = Math.sqrt(dx * dx + dy * dy);
			
			txt.appendText("\n Distance: " + distance);
			
			if( distance > 10){
				autopilot["FORWARD"] = true;
			}else{
				// Arrived
				navTarget = null;
			}
			
			
			return autopilot;
		}
		
		public function Update(e:Event):void{
			
			m_world.Step(m_timeStep, m_velocityIterations, m_positionIterations);
			
			// Go through body list and update sprite positions/rotations
			var bb:b2Body = m_world.GetBodyList();
			while(bb) {
				if (bb.GetUserData() is ShipBase) {
					
					
					var bAngle:Number = bb.GetAngle();
					const rad180deg:Number = Math.PI;
					
					
					if(bAngle < 0 -rad180deg){
						bb.SetAngle(rad180deg);
						bAngle = bb.GetAngle();
					}else if(bAngle > rad180deg){
						bb.SetAngle(-rad180deg);
						bAngle = bb.GetAngle();
					}
					
					
					var xx = Math.cos(bAngle) / 10 ;
					var yy = Math.sin(bAngle) / 10 ;
					var frontOfShip = new b2Vec2(bb.GetWorldCenter().x, bb.GetWorldCenter().y -1);
					var backOfShip = new b2Vec2(bb.GetWorldCenter().x, bb.GetWorldCenter().y +1);
					var ff:b2Fixture = bb.GetFixtureList();
					
					var str:String = "Active: " + bb.IsActive() +
						"\n Mass: " + bb.GetMass() + 
						"\n Inertia: " + bb.GetInertia() +
						"\n Inertial Dampening: " + bb.GetLinearDamping() +
						"\n\n Angle: " + bb.GetAngle()  + 
						"\n x: " + bb.GetWorldCenter().x + 
						"\n y: " + bb.GetWorldCenter().y;
					
					txt.text = str;
					
					var autopilot:Dictionary = new Dictionary();
					var sprite:Sprite = bb.GetUserData() as Sprite;
						
					if(navTarget) {
						autopilot = doAutoPilot(bb);
					}
					
					if(keys["N"]){
						keys["N"] = null;
						if(bb.GetLinearDamping() == 0){
							bb.SetLinearDamping(0.1);
						}else{
							bb.SetLinearDamping(0);
						}
					}
					
					if(keys["A"] || autopilot["LEFT"]){
						bb.ApplyImpulse(new b2Vec2(-0.03,0), frontOfShip);
						bb.ApplyImpulse(new b2Vec2(0.03,0), backOfShip);
					}
					if(keys["D"] || autopilot["RIGHT"]){
						bb.ApplyImpulse(new b2Vec2(-0.03,0), backOfShip);
						bb.ApplyImpulse(new b2Vec2(0.03,0), frontOfShip);
					}
					
					if(keys["W"] || autopilot["FORWARD"]) {
						bb.ApplyImpulse(new b2Vec2(xx,yy), bb.GetWorldCenter());
						bb.GetUserData().activateEngines();
					}else{
						bb.GetUserData().deactivateEngines();
					}
					
					if(keys["S"] || autopilot["BACK"]) {
						bb.ApplyImpulse(new b2Vec2(0-xx, 0-yy), bb.GetWorldCenter());
					}
					
					
					sprite.x = bb.GetPosition().x * m_physScale;
					sprite.y = bb.GetPosition().y * m_physScale;
					sprite.rotation = bb.GetAngle() * (180/Math.PI);
				}else if(bb.GetUserData() is Sprite){
					if(keys["J"]){
						bb.ApplyImpulse(new b2Vec2(10, 10), bb.GetWorldCenter());
					}
					
					var sprite:Sprite = bb.GetUserData() as Sprite;
					sprite.x = bb.GetPosition().x * m_physScale * 2;
					sprite.y = bb.GetPosition().y * m_physScale * 2;
					sprite.rotation = bb.GetAngle() * (180/Math.PI);
					
				}
				bb = bb.GetNext();
			}
			
			m_world.ClearForces();
			m_world.DrawDebugData();
			txt.setTextFormat(new TextFormat("Arial",10,0xFFFFFF));
		}
		
		//======================
		// GetBodyAtMouse
		//======================
		private var mousePVec:b2Vec2 = new b2Vec2();
		
		public function getBodyAtMouse(includeStatic:Boolean = false):b2Body {
			// Make a small box.
			var mouseXWorldPhys:Number = mouseX/m_physScale;
			var mouseYWorldPhys:Number = mouseY/m_physScale;
			mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);
			aabb.upperBound.Set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);
			var body:b2Body = null;
			var fixture:b2Fixture;
			
			// Query the world for overlapping shapes.
			function GetBodyCallback(fixture:b2Fixture):Boolean
			{
				var shape:b2Shape = fixture.GetShape();
				if (fixture.GetBody().GetType() != b2Body.b2_staticBody || includeStatic)
				{
					var inside:Boolean = shape.TestPoint(fixture.GetBody().GetTransform(), mousePVec);
					if (inside)
					{
						body = fixture.GetBody();
						return false;
					}
				}
				return true;
			}
			m_world.QueryAABB(GetBodyCallback, aabb);
			return body;
		}
	}
}