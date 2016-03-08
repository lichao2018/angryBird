package 
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import Box2D.Dynamics.b2World;
	/**
	 * ...
	 * @author lichao
	 */
	public class angryBird extends Sprite
	{
		private var world:b2World;
		private var _mouseJoint:b2MouseJoint;
		private var birdSp:birdSprite = new birdSprite();
		private var birdSpInitX:Number = 100;
		private var birdSpInitY:Number = 100;
		
		public function angryBird() 
		{
			init();
			
			graphics.beginFill(0x9999, .1);
			graphics.drawCircle(100, 100, 100);
			graphics.endFill();
		}
		
		public function init():void {
		    world = CreateUtils.CreateWorld();
			CreateUtils.CreateDebug(world, stage);
			CreateUtils.CreateWalls(world, stage);
			
			addChild(birdSp);
			birdSp.x = birdSpInitX;
			birdSp.y = birdSpInitY;
			birdSp.buttonMode = true;
			
			addEventListener(Event.ENTER_FRAME, update);
			birdSp.addEventListener(MouseEvent.MOUSE_DOWN, birdClicked);
		}
		
		public function update(e:Event):void {			
			world.Step(1 / 30, 10, 10);
			
			for (var currentBody:b2Body = world.GetBodyList(); currentBody; currentBody = currentBody.GetNext()) {
			    if (currentBody.GetUserData()) {
					currentBody.GetUserData().x=currentBody.GetPosition().x*30;
					currentBody.GetUserData().y=currentBody.GetPosition().y*30;
				    currentBody.GetUserData().rotation=currentBody.GetAngle()*(180/Math.PI);	
				}
			}
			
			world.ClearForces();
			world.DrawDebugData();
		}
		
		public function birdClicked(e:MouseEvent):void {
		    addEventListener(MouseEvent.MOUSE_MOVE, birdMove);
			addEventListener(MouseEvent.MOUSE_UP, birdReleased);
			birdSp.removeEventListener(MouseEvent.MOUSE_DOWN, birdClicked);
		}
			
		public function birdMove(e:MouseEvent):void {
		    birdSp.x = mouseX;
			birdSp.y = mouseY;
			var distanceX:Number = birdSp.x - birdSpInitX;
			var distanceY:Number = birdSp.y - birdSpInitY;
			if (distanceX * distanceX + distanceY * distanceY > 100 * 100) {
			    var birdAngle:Number = Math.atan2(distanceY, distanceX);
				birdSp.x = birdSpInitX + 100 * Math.cos(birdAngle);
				birdSp.y = birdSpInitY + 100 * Math.sin(birdAngle);
			}
		}
		
		public function birdReleased(e:MouseEvent):void {
			birdSp.buttonMode = false;
			removeEventListener(MouseEvent.MOUSE_MOVE, birdMove);
			removeEventListener(MouseEvent.MOUSE_UP, birdReleased);
			var bird:b2Body = createBird();
			var distanceX:Number = birdSp.x / 30 - birdSpInitX / 30;
			var distanceY:Number = birdSp.y / 30 - birdSpInitY / 30;
			var distance:Number = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
			var birdAngle:Number = Math.atan2(distanceY, distanceX);
			bird.SetLinearVelocity(new b2Vec2(-distance * Math.cos(birdAngle)/4, -distance * Math.sin(birdAngle)/4));   //为什么要-distance*Math.con(birdAngle)
		}
		
		public function createBird():b2Body {		    
			var birdDef:b2BodyDef = new b2BodyDef();
			var birdShape:b2CircleShape = new b2CircleShape(.5);
			var birdFixtureDef:b2FixtureDef = new b2FixtureDef();
			
			birdFixtureDef.shape = birdShape;
			birdFixtureDef.density = 1;
			birdFixtureDef.restitution = 0.6;
			birdDef.position.Set(birdSp.x / 30, birdSp.y / 30);
			birdDef.type = b2Body.b2_dynamicBody;
			birdDef.userData = birdSp;
			var bird:b2Body = world.CreateBody(birdDef);
			bird.CreateFixture(birdFixtureDef);
			
			return bird;
		}
		
	}

}

class birdSprite extends flash.display.Sprite {
	public function birdSprite() {
	    graphics.beginFill(0xff, .2);
		graphics.drawCircle(50, 50, 15);
		graphics.endFill();
	}
}