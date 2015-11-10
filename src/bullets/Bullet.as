package src.bullets {
    import Box2D.Collision.b2AABB;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2Fixture;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.media.SoundMixer;
    import flash.utils.Timer;
    import src.costumes.BulletCostume;
    import src.enemy.Enemy;
    import src.Game;
    import src.Ids;
    import src.interfaces.*;
    import src.objects.AbstractObject;
    import src.objects.Door;
    import src.objects.Obstacle;
    import src.Player;
    import src.task.Record;
    import src.util.ChangePlayerStatObject;
    import src.util.CreateBodyRequest;
    import src.util.Collider;
    import src.util.ObjectPool;
    import src.util.Recorder;
    import src.util.SoundManager;
    
    public class Bullet extends AbstractObject implements LoopClip {
        private var gws:Number = Game.WORLD_SCALE;

        public static const DEFAULT_STATE:String = "_default";
        public static const DESTOY_STATE:String = "_destroy";
        
        public var colliderWidth:Number = 0;
        public var colliderHeight:Number = 0;
        
        private var active = true;
        private var bodyHidden:Boolean = false;
        
        public var explode:Boolean = false;
        private var powder_power:Number = 2;
        private var explosion_rad:Number = 2;
        
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
            
            createBodyReq.setAsDynamicSensor();
            
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
            if ( explode ) {
                var aabb:b2AABB = new b2AABB();
                aabb.lowerBound = body.GetPosition().Copy();
                aabb.lowerBound.Subtract(new b2Vec2(explosion_rad, explosion_rad));
                aabb.upperBound = body.GetPosition().Copy();
                aabb.upperBound.Add(new b2Vec2(explosion_rad, explosion_rad));
                
                game.cRoom.world.QueryAABB(game.createExposionQuerryAABBCallback(body.GetPosition(), bulletDef.damage, 2), aabb);
                
                explode = false;
                
                SoundManager.instance.playSFX(SoundManager.SFX_EXPLOSION);
            }
            x = body.GetPosition().x * gws;
            y = body.GetPosition().y * gws;
        }
        
        private function queryAABBCallback(fixture:b2Fixture):Boolean {
            var userData:Object = fixture.GetUserData();
            var object_name:String = "object";
            
            if ( userData && userData.hasOwnProperty(object_name) ) {
                if ( userData[object_name] is AbstractObject ) {
                    var obj:AbstractObject = AbstractObject(userData[object_name]);
                    var obj_impulse:b2Vec2 = obj.body.GetPosition().Copy();
                    obj_impulse.Subtract(body.GetPosition());
                    obj_impulse.Multiply(10);
                    
                    if ( obj is Door && Door(obj).isSecret ) {
                        Door(obj).specialLock = false;
                        Door(obj).unlock();
                        Recorder.recordSecretRoomFound();
                        
                        SoundManager.instance.playSFX(SoundManager.SFX_OPEN_SECRET_ROOM);
                    }
                    
                    if ( obj is Obstacle ) {
                        Obstacle(obj).breakObject();
                    }
                    
                    if ( obj is Enemy ) {
                        Enemy(obj).makeHit(bulletDef.damage);
                    }
                    
                    if ( obj is Player ) {
                        game.changePlayerStat(new ChangePlayerStatObject(ChangePlayerStatObject.HEALTH_STAT, -2, 0, true));
                    }
                    
                    if ( obj is Bullet ) {
                        return true;
                    }
                    
                    obj.body.ApplyImpulse( obj_impulse, obj.body.GetWorldCenter());
                }
            }
            return true;
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
        
        public function breakBullet():void {
            costume.setAnimatedState(DESTOY_STATE);
            
            if ( bulletDef.is_boom ) {
                explode = true;
            }
            
            var timer:Timer = ObjectPool.getTimer(bulletDef.end_animation_delay);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, bulletIsFinishedPlaying);
            
            game.bulletController.safeDeactivateBullet(this);
            
            SoundManager.instance.playSFX(bulletDef.sfx_hit);
        }
        
        private function bulletIsFinishedPlaying(e:TimerEvent):void {
            var t:Timer = Timer(e.target);
            t.removeEventListener(TimerEvent.TIMER_COMPLETE, bulletIsFinishedPlaying);
            
            active = false;
            costume.visible = false;
            costume.stop();
        }

    }
    
}
