package src.bullets {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import src.costumes.ItemCostume;
    import src.Game;
    import src.interfaces.*;
    import src.objects.AbstractObject;
    import src.util.CreateBodyRequest;
    import src.util.Collider;
    
    public class Bullet extends AbstractObject implements LoopClip {
        private var gws:Number = Game.WORLD_SCALE;
        public static const DEF_ARRAY:Array = new Array(new BulletDef(100, 10, 0, 1000), new BulletDef(100, 10, 3, 1000), new BulletDef(50, 10, 0, 500));
        
        public static const POWER_SPELL_TYPE:int = 0;
        public static const NUKELINO_TYPE:int = 1;
        public static const SPARK_TYPE:int = 2;

        public static const DEFAULT_STATE:String = "_default";
        public static const DESTOY_STATE:String = "_destroy";
        
        public var bullet_type:int = SPARK_TYPE;
        
        //public static var bulletDef:BulletDef = DEF_ARRAY[SPARK_TYPE];
        
        public var colliderWidth:Number = 0;
        public var colliderHeight:Number = 0;
        
        private var active = true;
        public var is_bomb:Boolean = false;
        private var bodyHidden:Boolean = false;
        private var speed:Point;

        public function Bullet() {
            costume = new ItemCostume();
            
            var collider:DisplayObject = costume.getCollider();
            
            colliderWidth = collider.width;
            colliderHeight = collider.height;
        }
        
        public function setType(type_:String):void {
            costume.setType(type_);
            switch (type_) {
                case ItemCostume.NUKELINO_TYPE:
                    bullet_type = NUKELINO_TYPE;
                    is_bomb = true;
                    break;
                case ItemCostume.POWER_SPELL_TYPE:
                    bullet_type = POWER_SPELL_TYPE;
                    break;
                case ItemCostume.SPARK_TYPE:
                    bullet_type = SPARK_TYPE;
                    break;
            }
            costume.setState(DEFAULT_STATE);
        }
        
        public function setDirection(dir_x:Number, dir_y:Number):void {
            speed = new Point(dir_x, dir_y);
            speed.normalize(1);
        }
        
        public function getBulletDefenition():BulletDef {
            return DEF_ARRAY[bullet_type];
        }
        
        override public function requestBodyAt(world:b2World):void {
            var collider:DisplayObject = costume.getCollider();
            var bulletDef:BulletDef = getBulletDefenition();
            
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.userData = { "object": this };
            fixtureDef.density = 1;
            fixtureDef.friction = 0;
            fixtureDef.restitution = 0;
            
            var bodyCreateRequest:CreateBodyRequest = new CreateBodyRequest(world, collider, this);
            bodyCreateRequest.setAsDynamicBody(fixtureDef);
            
            bodyCreateRequest.setBodyPosition(new Point(x, y));
            
            bodyCreateRequest.velocity = new b2Vec2 ( speed.x * bulletDef.speed, speed.y * bulletDef.speed );
            
            game.bodyCreator.add(bodyCreateRequest);
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
                body.SetPosition(new b2Vec2(-100 / gws, -100 / gws));
                return;
            }
            
            x = body.GetPosition().x * gws;
            y = body.GetPosition().y * gws;
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
            body.SetPosition(new b2Vec2(X / gws, Y / gws));
        }

    }
    
}
