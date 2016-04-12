package 
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.*;
	/**
	 * ...
	 * @author lichao
	 */
	public class Car extends Sprite
	{
		private var world:b2World;
		private var screenWidth:Number = stage.stageWidth / 30;
		private var screenHeight:Number = stage.stageHeight / 30;
		private var joint:b2RevoluteJoint;
		private var isLeft:Boolean = false;
		private var isRight:Boolean = false;
		private var car:b2Body;
		
		public function Car() 
		{
			world = CreateUtils.CreateWorld();
			addChild(CreateUtils.CreateDebug(world, stage));
			
			init();
		}
		
		private function init():void 
		{
			addEventListener(Event.ENTER_FRAME, update);
			createGround();
			car = createCar();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function update(e:Event):void 
		{
			world.Step(1 / 30, 10, 10);
			world.ClearForces();
			world.DrawDebugData();
			
			joint.EnableMotor(true);
			if (isLeft) {
				joint.SetMotorSpeed(8);
			}else if (isRight) {
				joint.SetMotorSpeed(-8);
			}else {
				joint.EnableMotor(false);
			}
			
			x = stage.stageWidth / 2 - car.GetDefinition().position.x * 30;
		}
		
		private function onKeyDown(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.LEFT) {
				isLeft = true;
				isRight = false;
			}else if (e.keyCode == Keyboard.RIGHT) {
				isLeft = false;
				isRight = true;
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.LEFT) {
				isLeft = false;
			}else if (e.keyCode == Keyboard.RIGHT) {
				isRight = false;
			}
		}
		
		private function createGround():b2Body {
			var bodyDef:b2BodyDef = new b2BodyDef();
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			var shape:b2PolygonShape = new b2PolygonShape();
			
			shape.SetAsBox(30, 0.0005);
			fixtureDef.shape = shape;
			bodyDef.type = b2Body.b2_staticBody;
			bodyDef.position.Set(screenWidth / 2, screenHeight - 2);
			var ground:b2Body = world.CreateBody(bodyDef);
			ground.CreateFixture(fixtureDef);
			
			return ground;
		}
		
		private function createCar():b2Body {
			var bodyDef:b2BodyDef = new b2BodyDef();
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			var carShape:b2PolygonShape = new b2PolygonShape();
			var wheelShape:b2CircleShape = new b2CircleShape(.5);
			fixtureDef.density = 1.0;
			fixtureDef.friction = 1.0;
			fixtureDef.restitution = 0.2;
			
			carShape.SetAsBox(2, .5);
			fixtureDef.shape = carShape;
			bodyDef.type = b2Body.b2_dynamicBody;
			bodyDef.position.Set(screenWidth / 4, screenHeight - 3.5);
			var car:b2Body = world.CreateBody(bodyDef);
			car.CreateFixture(fixtureDef);
			
			bodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_dynamicBody;
			fixtureDef.shape = wheelShape;
			bodyDef.position.Set(screenWidth / 4 - 1, screenHeight - 2.5);
			var leftWheel:b2Body = world.CreateBody(bodyDef);
			leftWheel.CreateFixture(fixtureDef);
			
			bodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_dynamicBody;
			bodyDef.position.Set(screenWidth / 4 + 1, screenHeight - 2.5);
			wheelShape = new b2CircleShape(.5);
			fixtureDef.shape = wheelShape;
			var rightWheel:b2Body = world.CreateBody(bodyDef);
			rightWheel.CreateFixture(fixtureDef);
			
			var jointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			jointDef.Initialize(leftWheel, car, leftWheel.GetWorldCenter());
			jointDef.motorSpeed = 0;
			jointDef.enableMotor = true;
			jointDef.collideConnected = false;
			jointDef.maxMotorTorque = 400;
			joint = world.CreateJoint(jointDef) as b2RevoluteJoint;
			
			jointDef = new b2RevoluteJointDef();
			jointDef.Initialize(rightWheel, car, rightWheel.GetWorldCenter());
			jointDef.collideConnected = false;
			world.CreateJoint(jointDef);
			
			return car;
		}
	}

}