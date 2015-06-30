package src.bullets {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import src.costumes.BulletCostume;
    import src.Game;
    import src.interfaces.*;
    import src.objects.AbstractObject;
    import src.util.CreateBodyRequest;
    import src.util.Collider;
    
    public class Bullet extends AbstractObject implements LoopClip {
        private var gws:Number = Game.WORLD_SCALE;

        public static const DEFAULT_STATE:String = "_default";
        public static const DESTOY_STATE:String = "_destroy";
        
        public var colliderWidth:Number = 0;
        public var colliderHeight:Number = 0;
        
        private var active = true;
        private var bodyHidden:Boolean = false;
        private var speed:Point;
        
        public var bulletDef:BulletDef;

        public function Bullet(bulletDef_:BulletDef) {
            bulletDef = bulletDef_;
            
            costume = new BulletCostume();
            
            var collider:DisplayObject = costume.getCollider();
            
            colliderWidth = collider.width;
            colliderHeight = collider.height;
        }
        
        public function setType(type_:String):void {
            costume.setType(type_);
            costume.setState(DEFAULT_STATE);
        }
        
        public function setDirection(dir_x:Number, dir_y:Number):void {
            speed = new Point(dir_x, dir_y);
            speed.normalize(1);
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createBodyReq:CreateBodyRequest = super.requestBodyAt(world);
            
            var fixtureDef:b2FixtureDef = createBodyReq.fixtureDef;
            fixtureDef.density = 1;
            fixtureDef.friction = 0;
            fixtureDef.restitution = 0;
            
            createBodyReq.setAsDynamicBody();
            
            createBodyReq.velocity = new b2Vec2 ( speed.x * bulletDef.speed, speed.y * bulletDef.speed );
            
            return createBodyReq;
        }
        
        public function setSpeedDirection(dir_x:Number, dir_y:Number):void {
            var speed:Number = bulletDef.speed;
            body.SetLinearVelocity(new b2Vec2(dir_x * speed, dir_y * speed));
        }
        
        public function update():void {
            if ( !body || !active ) return;
            
            if ( bodyHidden ) {
                if (active && !costume.visible) deactivate();
                return;
            }
            
            x = body.GetPosition().x * gws;
            y = body.GetPosition().y * gws;
        }
        
        public function setState(state:String):void {
            costume.setState(DESTOY_STATE);
        }
        
        // D!
        public function safeCollide():void {
            costume.setState(DESTOY_STATE);
            detachBody();
        }
        
        public function detachBody():void {
            bodyHidden = true;
            body.SetActive(!bodyHidden);
            //body.SetPosition(new b2Vec2( -100 / gws, -100 / gws));
        }
        
        public function activate():void {
            active = true;
            bodyHidden = false;
            updateActiveState();
        }
        
        public function deactivate():void {
            active = false;
            costume.stop();
            updateActiveState();
        }
        
        private function updateActiveState():void {
            costume.visible = active;
            body.SetActive(active);
        }
        
        public function isActive():Boolean {
            return active;
        }
        
        public function moveTo(X:Number, Y:Number):void {
            this.x = X;
            this.y = Y;
            body.SetPosition(new b2Vec2(X / gws, Y / gws));
        }

    }
    
}
