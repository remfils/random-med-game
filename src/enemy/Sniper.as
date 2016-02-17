package src.enemy {
    import Box2D.Dynamics.b2World;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import src.Game;
    import src.util.Collider;
    import src.util.CreateBodyRequest;
    import src.util.SoundManager;

    public class Sniper extends Enemy {
        public static const MONK_DEATH_DELAY:Number = 43 / Game.FRAMES_PER_MILLISECOND;
        
        public static const ACTIVE_STATE:String = "_active";
        public static const STAND_STATE:String = "_stand";
        public static const SHOOT_STATE:String = "_shoot";
        
        public var charge:Boolean = false;
        public var charge_time:Number = 0;
        public var charge_delay:Number = 50;
        
        protected var frames_to_shoot:int = 0;
        protected var bullet_fired:Boolean = false;
        protected var TOTAL_CHARGE_FRAMES:int = 30;
        
        protected const WAIT_ATTACK:Attack = null;
        protected const SHOOT_BULLET_ATTACK:Attack = null;
        protected var current_attack:Attack;
        
        //protected var current_frame:int = 0;
        
        public function Sniper() {
            super();
            agroDistance = 400;
            exp = 10;
            
            death_sound_id = SoundManager.SFX_DESTROY_MONK;
        }
        
        override public function readXMLParams(paramsXML:XML):void {
            super.readXMLParams(paramsXML);
            
            costume_remove_delay = MONK_DEATH_DELAY;
            
            setState(Sniper.STAND_STATE);
        }
        
        override public function activate():void {
            is_active = true;
            costume.setState(ACTIVE_STATE);
        }
        
        override public function deactivate():void {
            charge = bullet_fired = is_active = false;
            charge_time = frames_to_shoot = 0;
            costume.setState(STAND_STATE);
        }
        
        override protected function flip():void {}
        
        override public function update():void {
            if ( !is_active) return;
            
            super.update();
            
            if ( !charge_time ) {
                startShoot();
                charge_time = charge_delay;
            }
            else {
                charge_time --;
            }
            if ( bullet_fired ) {
                if ( !frames_to_shoot-- ) {
                    bullet_fired = false;
                    costume.setState(ACTIVE_STATE);
                    shoot();
                    frames_to_shoot = 0;
                }
            }
        }
        
        public function startShoot():void {
            bullet_fired = true;
            frames_to_shoot = TOTAL_CHARGE_FRAMES;
            costume.setAnimatedState(SHOOT_STATE);
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createBodyReq:CreateBodyRequest = super.requestBodyAt(world);
            createBodyReq.setAsStaticBody();
            return createBodyReq;
        }
        
        /*override public function createBodyFromCollider(world:b2World):b2Body {
            var collider:Collider = getChildByName("collider001") as Collider;
            body = collider.replaceWithStaticB2Body(world, {"object": this});
            return body;
        }*/
        
        public function shoot():void {
            var direction:b2Vec2 = new b2Vec2(player.x - x, player.y - y);
            
            var bullet:Projectile = new Projectile();
            
            bullet.setSpeed(direction);
            bullet.setPosition(new Point(x, y));
            
            cRoom.add(bullet);
            
            SoundManager.instance.playSFX(SoundManager.SFX_SHOOT_MONK);
            //this.cRoom.addEnenemy(bullet);
        }
        
    }

}