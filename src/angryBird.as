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
		private var birdSpInitX:Number = 120;
		private var birdSpInitY:Number = 400; 
		private var bird:b2Body;
		
		public function angryBird() 
		{
			init();
			
			graphics.beginFill(0x9999, .1);
			graphics.drawCircle(birdSpInitX, birdSpInitY, 100);
			graphics.endFill();
		}
		
		private function init():void {
		    world = CreateUtils.CreateWorld();
			CreateUtils.CreateDebug(world, stage);
			CreateUtils.CreateWalls(world, stage);
			
			birdSp.x = birdSpInitX;
			birdSp.y = birdSpInitY;
			addChild(birdSp);
			birdSp.buttonMode = true;
			
			for (var i:int = 4; i > 0; i --) {
			    for (var j:int = 0; j < i; j ++) {
					addPig(stage.stageWidth/30/4*3 + j + (4-i)*.5, stage.stageHeight/30 - 1 - (4-i));
				}
			}
			
			addEventListener(Event.ENTER_FRAME, update);
			birdSp.addEventListener(MouseEvent.MOUSE_DOWN, birdClicked);
		}
		
		private function update(e:Event):void {			
			world.Step(1 / 30, 10, 10);
			
			for (var currentBody:b2Body = world.GetBodyList(); currentBody; currentBody = currentBody.GetNext()) {
			    if (currentBody.GetUserData()) {
					var sprite:Sprite = currentBody.GetUserData() as Sprite;
					sprite.x=currentBody.GetPosition().x*30;
					sprite.y=currentBody.GetPosition().y*30;
				    sprite.rotation=currentBody.GetAngle()*(180/Math.PI);	
				}
			}
			
			world.ClearForces();
			world.DrawDebugData();
		}
		
		private function birdClicked(e:MouseEvent):void {
			trace("click");
		    stage.addEventListener(MouseEvent.MOUSE_MOVE, birdMoved);
			stage.addEventListener(MouseEvent.MOUSE_UP, birdReleased);
			birdSp.removeEventListener(MouseEvent.MOUSE_DOWN, birdClicked);
		}
			
		private function birdMoved(e:MouseEvent):void {
			trace("move");
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
		
		private function birdReleased(e:MouseEvent):void {
			trace("up");
			birdSp.buttonMode = false;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, birdMoved);
			stage.removeEventListener(MouseEvent.MOUSE_UP, birdReleased);
			bird = addBird();
			var distanceX:Number = birdSp.x - birdSpInitX;
			var distanceY:Number = birdSp.y - birdSpInitY;
			var distance:Number = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
			var birdAngle:Number = Math.atan2(distanceY, distanceX);
			bird.SetLinearVelocity(new b2Vec2(-distance * Math.cos(birdAngle)/4, -distance * Math.sin(birdAngle)/4));   //为什么要-distance*Math.con(birdAngle)
		}
		
		private function addBird():b2Body {		    
			var birdDef:b2BodyDef = new b2BodyDef();
			var birdShape:b2CircleShape = new b2CircleShape(.5);
			var birdFixtureDef:b2FixtureDef = new b2FixtureDef();
			
			birdFixtureDef.shape = birdShape;
			birdFixtureDef.density = 2;
			birdFixtureDef.restitution = 0.6;
			birdDef.position.Set(birdSp.x / 30, birdSp.y / 30);
			birdDef.type = b2Body.b2_dynamicBody;
			birdDef.userData = birdSp;
			var bird:b2Body = world.CreateBody(birdDef);
			bird.CreateFixture(birdFixtureDef);
			
			return bird;
		}
		
		private function addPig(x:Number, y:Number):void {
		    var pigDef:b2BodyDef = new b2BodyDef();
			var pigShape:b2PolygonShape = new b2PolygonShape();
			var pigFixtureDef:b2FixtureDef = new b2FixtureDef();
			
			pigShape.SetAsBox(.5, .5);
			pigFixtureDef.shape = pigShape;
			pigFixtureDef.density = 1;
			pigFixtureDef.restitution = 0.4;
			pigDef.position.Set(x, y);
			pigDef.type = b2Body.b2_dynamicBody;
			var pig:b2Body = world.CreateBody(pigDef);
			pig.CreateFixture(pigFixtureDef);
		}
		
	}

}

class birdSprite extends flash.display.Sprite {
	public function birdSprite() {
	    graphics.beginFill(0xff, .2);
		graphics.drawCircle(0, 0, 15);
		graphics.endFill();
	}
}