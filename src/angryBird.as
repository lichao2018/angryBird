package 
{
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Joints.*;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import mx.core.FlexSimpleButton;
	
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
		private var birdSpInitX:Number = 150;
		private var birdSpInitY:Number = 400; 
		private var bird:b2Body;
		private var screenDraging:Boolean;
		private var screenX:Number;
		private var btn:buttonSprite;
		private var tf:TextField;
		private var reset:Boolean;
		
		public function angryBird() 
		{
			world = CreateUtils.CreateWorld();
			addChild(CreateUtils.CreateDebug(world, stage));
			setUI();
			init();
			
			graphics.beginFill(0x9999, .1);
			graphics.drawCircle(birdSpInitX, birdSpInitY, 100);
			graphics.endFill();
		}
		
		private function init():void {
			CreateUtils.CreateWalls(world, stage);
			
			birdSp.x = birdSpInitX;
			birdSp.y = birdSpInitY;
			addChild(birdSp);
			birdSp.buttonMode = true;
			
			for (var i:int = 0; i < 4; i ++) {
				addBlock(stage.stageWidth / 30 / 2 * 3, stage.stageHeight / 30 - i -1);
				addBlock(stage.stageWidth / 30 / 2 * 3 + 2, stage.stageHeight / 30 - i - 1);
			}
			//addPig(stage.stageWidth / 30 / 2 * 3 + 1, stage.stageHeight / 30 -1);
			addPig(15, 20);
						
			addEventListener(Event.ENTER_FRAME, update);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			birdSp.addEventListener(MouseEvent.MOUSE_DOWN, birdClicked);
		}
		
		private function onMouseDown(e:MouseEvent):void {
			screenDraging = true;
		}
		
		private function onMouseMove(e:MouseEvent):void {
			if (screenDraging) {
				screenX = stage.stageWidth / 2 - mouseX;
				if (screenX > 0) {
					screenX = 0;
				}
				if (screenX < -800) {
					screenX = -800;
				}
			}
		}
		
		private function onMouseUp(e:MouseEvent):void {
			screenDraging = false;
		}
		
		private function update(e:Event):void {			
			world.Step(1 / 30, 10, 10);
			
			if (reset) {
				reset = false;
				removeChild(tf);
			}
			
			for (var currentBody:b2Body = world.GetBodyList(); currentBody; currentBody = currentBody.GetNext()) {
			    if (currentBody.GetUserData()) {
					if (currentBody.GetUserData().name == "bird") {
						var sprite:Sprite = currentBody.GetUserData() as Sprite;
						sprite.x=currentBody.GetPosition().x*30;
						sprite.y=currentBody.GetPosition().y*30;
						sprite.rotation=currentBody.GetAngle()*(180/Math.PI);
					}
				}
			}
			
			if (screenDraging) {
				x = screenX;
			}
			else {
				var posX:Number = stage.stageWidth / 2 - birdSp.x;
				if (posX > 0) {
					posX = 0;	
				}
				if (posX < -800) {
					posX = -800;
			    }
			    x = posX;
			}		
			
			var contactList:b2Contact = world.GetContactList();
			if (contactList != null) {
				var bodyA:b2Body = contactList.GetFixtureA().GetBody();
				var bodyB:b2Body = contactList.GetFixtureB().GetBody();
				if (bodyA.GetUserData() && bodyB.GetUserData()) {
					if (bodyA.GetUserData().name == "bird" && bodyB.GetUserData().name == "pig") {
						world.DestroyBody(bodyB);
						showResult();
					}else if (bodyA.GetUserData().name == "pig" && bodyB.GetUserData().name == "bird") {
						world.DestroyBody(bodyA);
						showResult();
					}
				}
			}
			
			btn.x = -x + 50;
			
			world.ClearForces();
			world.DrawDebugData();
		}
		
		private function birdClicked(e:MouseEvent):void {
		    stage.addEventListener(MouseEvent.MOUSE_MOVE, birdMoved);
			stage.addEventListener(MouseEvent.MOUSE_UP, birdReleased);
			birdSp.removeEventListener(MouseEvent.MOUSE_DOWN, birdClicked);
		}
			
		private function birdMoved(e:MouseEvent):void {
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
			birdSp.name = "bird";
			var bird:b2Body = world.CreateBody(birdDef);
			bird.CreateFixture(birdFixtureDef);
			
			return bird;
		}

		private function addBlock(x:Number, y:Number):void {
		    var blockDef:b2BodyDef = new b2BodyDef();
			var blockShape:b2PolygonShape = new b2PolygonShape();
			var blockFixtureDef:b2FixtureDef = new b2FixtureDef();
			
			blockShape.SetAsBox(.5, .5);
			blockFixtureDef.shape = blockShape;
			blockFixtureDef.density = 1;
			blockFixtureDef.restitution = 0.4;
			blockDef.position.Set(x, y);
			blockDef.type = b2Body.b2_dynamicBody;
			blockDef.userData = { name:"block" };
			var block:b2Body = world.CreateBody(blockDef);
			block.CreateFixture(blockFixtureDef);
		}
		
		private function addPig(x:Number, y:Number):void {
			var pigDef:b2BodyDef = new b2BodyDef();
			var pigShape:b2CircleShape = new b2CircleShape(.5);
			var pigFixtureDef:b2FixtureDef = new b2FixtureDef();
			
			pigFixtureDef.shape = pigShape;
			pigFixtureDef.density = 1;
			pigFixtureDef.restitution = 0.4;
			pigDef.position.Set(x, y);
			pigDef.type = b2Body.b2_dynamicBody;
			pigDef.userData = { name:"pig" };
			var pig:b2Body = world.CreateBody(pigDef);
			pig.CreateFixture(pigFixtureDef);
		}
		
		private function showResult():void {
			tf = new TextField();
			tf.text = "YOU WIN.";
			var posX:Number = stage.stageWidth / 2 - birdSp.x;
			if (posX >= 0) {
				tf.x = stage.stageWidth / 2;
			}else if (posX < 0 && posX > -800) {
				tf.x = birdSp.x;
			}else {
			 	tf.x = stage.stageWidth / 2 * 3;
			}
			tf.y = stage.stageHeight / 2;
			addChild(tf);
		}
			
		private function setUI():void {
			btn = new buttonSprite();
			btn.y = 40;
			addChild(btn);
			btn.buttonMode = true;
			btn.addEventListener(MouseEvent.MOUSE_DOWN, btnClicked);
		}
		
		private function btnClicked(e:MouseEvent):void 
		{
			addEventListener(MouseEvent.MOUSE_UP, btnReleased);
			removeEventListener(MouseEvent.MOUSE_DOWN, btnClicked);
		}
		
		private function btnReleased(e:MouseEvent):void 
		{
			removeEventListener(MouseEvent.MOUSE_UP, btnReleased);
			reset = true;
			var body:b2Body;
			for (body = world.GetBodyList(); body; body = body.GetNext()) {
				world.DestroyBody(body);
			}
			init();
		}
	}

}

class birdSprite extends flash.display.Sprite {
	
	public function birdSprite() {
	    graphics.beginFill(0xff, 1);
		graphics.drawCircle(0, 0, 15);
		graphics.endFill();
	}
}

class buttonSprite extends flash.display.Sprite {
	public function buttonSprite() {
		graphics.beginFill(0x999999, .5);
		graphics.drawRect(0, 0, 40, 20);
		graphics.endFill();
	}
}