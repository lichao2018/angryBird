package {
        import flash.display.Sprite;
        import flash.events.Event;
        import flash.events.MouseEvent;
        import Box2D.Dynamics.*;
        import Box2D.Collision.*;
        import Box2D.Collision.Shapes.*;
        import Box2D.Common.Math.*;
        import Box2D.Dynamics.Joints.*;
        public class ball extends Sprite {
                private var world:b2World=new b2World(new b2Vec2(0,10),true);
                private var worldScale:int=30;
                private var bird:birdMc=new birdMc();
                private var rock:birdMc;
                private var birdSphere:b2Body;
                private var following:Boolean=false;
                public function ball() {
                        addChild(bird);
                        debugDraw();
                        bird.x=170;
                        bird.y=270;
                        bird.buttonMode=true;
                        addWall(640,10,640,395);
                        addWall(640,10,640,-5);
                        addWall(10,240,-5,240);
                        addWall(10,240,1275,240);
                        for (var i:int=0; i<=4; i++) {
                                addBlock(20,20,1050,365-i*40);
                                addBlock(20,20,1150,365-i*40);
                        }
                        addBlock(80,20,1100,165);
                        addPig(20,1100,125);
                        addEventListener(Event.ENTER_FRAME,updateWorld);
                        bird.addEventListener(MouseEvent.MOUSE_DOWN, birdClicked);
						
						graphics.beginFill(0x999900, .5);
			graphics.drawRect(0, 0, stage.stageWidth * 2, stage.stageHeight);
			graphics.endFill();
                }
                private function addWall(w,h,px,py):void {
                        var floorShape:b2PolygonShape = new b2PolygonShape();
                        floorShape.SetAsBox(w/worldScale,h/worldScale);
                        var floorFixture:b2FixtureDef = new b2FixtureDef();
                        floorFixture.density=0;
                        floorFixture.friction=10;
                        floorFixture.restitution=0.5;
                        floorFixture.shape=floorShape;
                        var floorBodyDef:b2BodyDef = new b2BodyDef();
                        floorBodyDef.position.Set(px/worldScale,py/worldScale);
                        floorBodyDef.userData={assetName:"wall",assetSprite:null,remove:false};
                        var floor:b2Body=world.CreateBody(floorBodyDef);
                        floor.CreateFixture(floorFixture);
                }
                private function addPig(r,px,py):void {
                        var pigShape:b2CircleShape=new b2CircleShape(r/worldScale);
                        var pigFixture:b2FixtureDef = new b2FixtureDef();
                        pigFixture.density=1;
                        pigFixture.friction=3;
                        pigFixture.restitution=0.1;
                        pigFixture.shape=pigShape;
                        var pigBodyDef:b2BodyDef = new b2BodyDef();
                        pigBodyDef.position.Set(px/worldScale,py/worldScale);
                        pigBodyDef.type=b2Body.b2_dynamicBody;
                        pigBodyDef.userData={assetName:"pig",assetSprite:null,remove:false};
                        var pigSphere:b2Body=world.CreateBody(pigBodyDef);
                        pigSphere.CreateFixture(pigFixture);
                }
                private function addBlock(w,h,px,py):void {
                        var blockShape:b2PolygonShape = new b2PolygonShape();
                        blockShape.SetAsBox(w/worldScale,h/worldScale);
                        var blockFixture:b2FixtureDef = new b2FixtureDef();
                        blockFixture.density=0.5;
                        blockFixture.friction=10;
                        blockFixture.restitution=0.1;
                        blockFixture.shape=blockShape;
                        var blockBodyDef:b2BodyDef = new b2BodyDef();
                        blockBodyDef.position.Set(px/worldScale,py/worldScale);
                        rock=new birdMc();
                        rock.width=w*2;
                        rock.height=h*2;
                        addChild(rock);
                        blockBodyDef.userData={assetName:"block",assetSprite:rock,remove:false};
                        blockBodyDef.type=b2Body.b2_dynamicBody;
                        var block:b2Body=world.CreateBody(blockBodyDef);
                        block.CreateFixture(blockFixture);
                }
                private function birdClicked(e:MouseEvent):void {
                        addEventListener(MouseEvent.MOUSE_MOVE,birdMoved);
                        addEventListener(MouseEvent.MOUSE_UP,birdReleased);
                        bird.removeEventListener(MouseEvent.MOUSE_DOWN,birdClicked);
                }
                private function debugDraw():void {
                        var worldDebugDraw:b2DebugDraw=new b2DebugDraw();
                        var debugSprite:Sprite = new Sprite();
                        addChild(debugSprite);
                        worldDebugDraw.SetSprite(debugSprite);
                        worldDebugDraw.SetDrawScale(worldScale);
                        worldDebugDraw.SetFlags(b2DebugDraw.e_shapeBit|b2DebugDraw.e_jointBit);
                        worldDebugDraw.SetFillAlpha(0.8);
                        world.SetDebugDraw(worldDebugDraw);
                }
                private function birdMoved(e:MouseEvent):void {
                        bird.x=mouseX;
                        bird.y=mouseY;
                        var distanceX:Number=bird.x-170;
                        var distanceY:Number=bird.y-270;
                        if (distanceX*distanceX+distanceY*distanceY>10000) {
                                var birdAngle:Number=Math.atan2(distanceY,distanceX);
                                bird.x=170+100*Math.cos(birdAngle);
                                bird.y=270+100*Math.sin(birdAngle);
                        }
                }
                private function birdReleased(e:MouseEvent):void {
                        following=true;
                        bird.buttonMode=false;
                        removeEventListener(MouseEvent.MOUSE_MOVE,birdMoved);
                        removeEventListener(MouseEvent.MOUSE_UP,birdReleased);
                        var sphereShape:b2CircleShape=new b2CircleShape(15/worldScale);
                        var sphereFixture:b2FixtureDef = new b2FixtureDef();
                        sphereFixture.density=1;
                        sphereFixture.friction=3;
                        sphereFixture.restitution=0.1;
                        sphereFixture.shape=sphereShape;
                        var sphereBodyDef:b2BodyDef = new b2BodyDef();
                        sphereBodyDef.type=b2Body.b2_dynamicBody;
                        sphereBodyDef.userData={assetName:"bird",assetSprite:bird,remove:false};
                        sphereBodyDef.position.Set(bird.x/worldScale,bird.y/worldScale);
                        birdSphere=world.CreateBody(sphereBodyDef);
                        birdSphere.CreateFixture(sphereFixture);
                        var distanceX:Number=bird.x-170;
                        var distanceY:Number=bird.y-270;
                        var distance:Number=Math.sqrt(distanceX*distanceX+distanceY*distanceY);
                        var birdAngle:Number=Math.atan2(distanceY,distanceX);
                        birdSphere.SetLinearVelocity(new b2Vec2(-distance*Math.cos(birdAngle)/4,-distance*Math.sin(birdAngle)/4));
                }
                private function updateWorld(e:Event):void {
                        world.Step(1/30,10,10);
                        for (var currentBody:b2Body=world.GetBodyList(); currentBody; currentBody=currentBody.GetNext()) {
                                if (currentBody.GetUserData()) {
                                        if (currentBody.GetUserData().assetSprite!=null) {
                                                currentBody.GetUserData().assetSprite.x=currentBody.GetPosition().x*worldScale;
                                                currentBody.GetUserData().assetSprite.y=currentBody.GetPosition().y*worldScale;
                                                currentBody.GetUserData().assetSprite.rotation=currentBody.GetAngle()*(180/Math.PI);
                                        }
                                        if (currentBody.GetUserData().remove) {
                                                if (currentBody.GetUserData().assetSprite!=null) {
                                                        removeChild(currentBody.GetUserData().assetSprite);
                                                }
                                                world.DestroyBody(currentBody);
                                        }
                                }
                        }
                        if (following) {
                                var posX:Number=bird.x;
                                posX=stage.stageWidth/2-posX;
                                if (posX>0) {
                                        posX=0;
                                }
                                if (posX<-640) {
                                        posX=-640;
                                }
                                x=posX;
                        }
                        world.ClearForces();
                        world.DrawDebugData();
                }
        }
} 

class birdMc extends flash.display.Sprite {
	public function birdMc() {
	    graphics.beginFill(0xff, 1);
		graphics.drawCircle(0, 0, 15);
		graphics.endFill();
	}
}