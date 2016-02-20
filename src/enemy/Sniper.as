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
        public static const ACTIVE_STATE:String = "_active";
        public static const STAND_STATE:String = "";
        public static const SHOOT_STATE:String = "_shoot";
        
        public static const ACTION_STAND_ID:int = 1;
        public static const ACTION_WAIT_ID:int = 2;
        public static const ACTION_SHOOT_ID:int = 3;
        
        protected var FRAME_TARGET_IS_LOCKED:int = 18;
        protected var FRAME_SHOOT:int = 23;
        
        protected var frame_recharge_end:int = 0;
        
        protected var current_attack:Attack;
        
        protected var saved_target_position:Point;
        
        public function Sniper() {
            super();
            agroDistance = 400;
            exp = 10;
            
            _actions[ACTION_STAND_ID] = new Attack(0, standInitAction, standUpdateAction);
            _actions[ACTION_WAIT_ID] = new Attack(0, waitInitAction, waitUpdateAction);
            _actions[ACTION_SHOOT_ID] = new Attack(37, shootInitAction, shootUpdateAction, shootEndAction);
        }
        
        private function standInitAction():void {
            setState(STAND_STATE);
            activate();
        }
        
        private function standUpdateAction():void {
            if ( isPlayerInAgroRange() ) {
                forceChangeAction(ACTION_WAIT_ID);
            }
        }
        
        private function waitInitAction():void {
            setState(ACTIVE_STATE);
        }
        
        private function waitUpdateAction():void {
            if ( current_frame > frame_recharge_end ) {
                forceChangeAction(ACTION_SHOOT_ID);
            }
        }
        
        private function shootInitAction():void {
            setState(SHOOT_STATE, true);
        }
        
        private function shootUpdateAction():void {
            if ( current_frame == FRAME_TARGET_IS_LOCKED ) {
                saved_target_position = new Point(player.x, player.y);
            }
            
            if ( current_frame == FRAME_SHOOT ) {
                shootAtSavedTargetPosition();
            }
        }
        
        private function shootEndAction():void {
            forceChangeAction(ACTION_STAND_ID);
        }
        
        override public function init():void {
            super.init();
            
            forceChangeAction(ACTION_STAND_ID);
        }
        
        override protected function flip():void {}
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createBodyReq:CreateBodyRequest = super.requestBodyAt(world);
            createBodyReq.setAsStaticBody();
            return createBodyReq;
        }
        
        protected function shootAtSavedTargetPosition():void {
            shootAtPoint(saved_target_position);
        }
        
        public function shoot():void {
            var p:Point = new Point(player.x, player.y);
            
            shootAtPoint(p);
            //this.cRoom.addEnenemy(bullet);
        }
        
        protected function shootAtPoint(p:Point):void {
            var direction:b2Vec2 = new b2Vec2(p.x - x, p.y - y);
            
            var bullet:Projectile = new Projectile();
            
            bullet.setSpeed(direction);
            bullet.setPosition(new Point(x, y));
            
            cRoom.add(bullet);
            
            SoundManager.instance.playSFX(SoundManager.SFX_SHOOT_MONK);
        }
        
    }

}