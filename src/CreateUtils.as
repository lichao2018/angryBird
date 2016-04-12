package 
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
	import flash.display.Sprite;
	import flash.display.Stage;
	/**
	 * ...
	 * @author lichao
	 */
	public class CreateUtils 
	{
		
		public function CreateUtils() 
		{
		}
		
		public static function CreateWorld():b2World {
			var world:b2World = new b2World(new b2Vec2(0, 10), true);
			return world;
		}
		
		public static function CreateWalls(world:b2World, stage:Stage):void {
			var bodyDef:b2BodyDef = new b2BodyDef();
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			var polygonShape:b2PolygonShape = new b2PolygonShape();
			
			//up
			bodyDef.position.Set(stage.stageWidth / 30, 0);
			bodyDef.type = b2Body.b2_staticBody;
			polygonShape.SetAsBox(stage.stageWidth / 30, .5);
			fixtureDef.shape = polygonShape;
			var upWall:b2Body = world.CreateBody(bodyDef);
			upWall.CreateFixture(fixtureDef);
			//down
			bodyDef.position.Set(stage.stageWidth / 30, stage.stageHeight / 30);
			bodyDef.type = b2Body.b2_staticBody;
			polygonShape.SetAsBox(stage.stageWidth / 30, .5);
			fixtureDef.shape = polygonShape;
			var downWall:b2Body = world.CreateBody(bodyDef);
			downWall.CreateFixture(fixtureDef);
			//left
			bodyDef.position.Set(0, stage.stageHeight / 30 / 2);
			bodyDef.type = b2Body.b2_staticBody;
			polygonShape.SetAsBox(.5, stage.stageHeight / 30 / 2);
			fixtureDef.shape = polygonShape;
			var leftWall:b2Body = world.CreateBody(bodyDef);
			leftWall.CreateFixture(fixtureDef);
			//right
			bodyDef.position.Set(stage.stageWidth / 30 * 2, stage.stageHeight / 30 / 2);
			bodyDef.type = b2Body.b2_staticBody;
			polygonShape.SetAsBox(.5, stage.stageHeight / 30 / 2);
			fixtureDef.shape = polygonShape;
			var rightWall:b2Body = world.CreateBody(bodyDef);
			rightWall.CreateFixture(fixtureDef);
		}
		
		public static function CreateBox(world:b2World, posX:Number, posY:Number, width:Number, height:Number, boxData:*):b2Body {
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.userData = boxData;
			bodyDef.position.Set(posX, posY);
			bodyDef.type = b2Body.b2_dynamicBody;
			var polygonShape:b2PolygonShape = new b2PolygonShape();
			polygonShape.SetAsBox(width / 2, height / 2);
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			//fixtureDef.isSensor = true;
			
			var boxFilter:b2FilterData = new b2FilterData();
			boxFilter.categoryBits = 2;
			boxFilter.maskBits = 4;
			fixtureDef.filter = boxFilter;
			
			fixtureDef.shape = polygonShape;
			fixtureDef.density = 1;
			var body:b2Body = world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			return body;
		}
		
		public static function CreateBall(world:b2World, posX:Number, posY:Number, radius:Number, ballData:*):b2Body {
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.userData = ballData;
			bodyDef.position.Set(posX, posY);
			bodyDef.type = b2Body.b2_dynamicBody;
			var circleShape:b2CircleShape = new b2CircleShape(radius);
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			
			var ballFilter:b2FilterData = new b2FilterData();
			ballFilter.categoryBits = 4;
			fixtureDef.filter = ballFilter;
			
			fixtureDef.shape = circleShape;
			fixtureDef.density = 1;
			fixtureDef.restitution = 0.6;
			var body:b2Body = world.CreateBody(bodyDef);
			body.CreateFixture(fixtureDef);
			return body;
		}
		
		public static function CreateDebug(world:b2World, stage:Stage):Sprite {
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			var debugSprite:Sprite = new Sprite();
			debugDraw.SetDrawScale(30);
			//stage.addChild(debugSprite);
			debugDraw.SetSprite(debugSprite);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit | b2DebugDraw.e_centerOfMassBit);
			debugDraw.SetAlpha(0.5);
			world.SetDebugDraw(debugDraw);
			return debugSprite;
		}
	}

}