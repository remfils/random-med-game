package src.bullets {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import src.Game;
    import src.interfaces.*;
    import src.objects.AbstractObject;
    import src.util.CreateBodyRequest;
    import src.util.Collider;
    
    public class Bullet extends AbstractObject implements LoopClip {
        public static var bulletDef:BulletDef = new BulletDef(50, 10, 0, 500);
        
        public var colliderWidth:Number = 0;
        public var colliderHeight:Number = 0;
        
        private var active = true;
        private var bodyHidden:Boolean = false;

        public function Bullet() {
            var collider:DisplayObject = costume.getCollider();
            
            colliderWidth = collider.width;
            colliderHeight = collider.height;
        }
        
        public function getBulletDefenition():BulletDef {
            return bulletDef;
        }
        
        override public function requestBodyAt(world:b2World):void {
            /*var collider:Collider = getChildByName("collider001") as Collider;
            
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.userData = { "object": this };
            fixtureDef.density = 1;
            fixtureDef.friction = 0;
            fixtureDef.restitution = 0;
            
            var bodyCreateRequest:CreateBodyRequest = new CreateBodyRequest(world, collider, this);
            bodyCreateRequest.setAsDynamicBody(fixtureDef);
            
            bodyCreateRequest.setBodyPosition(position);
            
            speed.normalize(1);
            bodyCreateRequest.velocity = new b2Vec2 ( speed.x * bulletDef.speed, speed.y * bulletDef.speed );
            
            game.bodyCreator.add(bodyCreateRequest);*/
        }
        
        // deprecated
        public function createBodyFromCollider(world:b2World):b2Body {
            /*var collider:Collider = getChildByName("collider001") as Collider;
            
            colliderWidth = collider.width;
            colliderHeight = collider.height;
            
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.userData = { "object": this };
            fixtureDef.density = 1;
            fixtureDef.friction = 0;
            fixtureDef.restitution = 0;
            
            var bodyCreateRequest:CreateBodyRequest = new CreateBodyRequest(world, collider, this);
            bodyCreateRequest.setAsDynamicBody(fixtureDef);
            bodyCreateRequest.actor = this;
            
            game.bodyCreator.add(bodyCreateRequest);
            */
            //body = collider.replaceWithDynamicB2Body(world, fixtureDef);
            //body.SetBullet(true);
            return null;
        }
        
        public function setSpeedDirection(dir_x:Number, dir_y:Number):void {
            body.SetLinearVelocity(new b2Vec2(dir_x * getBulletDefenition().speed, dir_y * getBulletDefenition().speed));
        }
        
        public function update():void {
            if ( !body ) return;
            
            // write better
            if ( costume.currentFrame == costume.totalFrames ) {
                deactivate();
            }
            if (!active) {
                updateActiveState();
                return;
            }
            
            if ( bodyHidden ) {
                body.SetPosition(new b2Vec2(-100 / Game.WORLD_SCALE, -100 / Game.WORLD_SCALE));
                return;
            }
            
            x = body.GetPosition().x * Game.WORLD_SCALE;
            y = body.GetPosition().y * Game.WORLD_SCALE;
        }
        
        public function safeCollide():void {
            detachBody();
            //gotoAndPlay("destroy");
        }
        
        public function detachBody():void {
            bodyHidden = true;
        }
        
        public function activate():void {
            active = true;
            bodyHidden = false;
            updateActiveState();
        }
        
        public function deactivate():void {
            active = false;
            updateActiveState();
        }
        
        private function updateActiveState():void {
            body.SetAwake(active);
            costume.visible = active;
        }
        
        public function isActive():Boolean {
            return active;
        }
        
        public function moveTo(X:Number, Y:Number):void {
            this.x = X;
            this.y = Y;
            body.SetPosition(new b2Vec2(X / Game.WORLD_SCALE, Y / Game.WORLD_SCALE));
        }

    }
    
}
