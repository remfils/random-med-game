package src.enemy {
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import src.costumes.CostumeEnemy;
    import src.objects.AbstractObject;
    import src.util.ChangePlayerStatObject;
    import src.util.CreateBodyRequest;
    import src.util.Output;


    public class EnemyLaser extends Enemy {
        private var collider:DisplayObject;
        private const DAMAGE:ChangePlayerStatObject = new ChangePlayerStatObject(ChangePlayerStatObject.HEALTH_STAT, -1, 3, true);
        
        private const FRAME_LASER_HIT_START:int = 3;
        private const FRAME_LASER_HIT_END:int = 7;
        private const FRAME_LASER_END:int = 9;
        
        private var dy:Number;
        
        public static const SMALL_TYPE:int = 1;
        public static const BOSS_TYPE:int = 2;
        
        private static const ACTION_SHOOT_ID:int = 0;
        
        
        public function EnemyLaser( type:int = BOSS_TYPE) {
            switch ( type ) {
                case SMALL_TYPE:
                    costume.setType(CostumeEnemy.ENEMY_LASER_SMALL);
                    break;
                case BOSS_TYPE:
                    costume.setType(CostumeEnemy.ENEMY_LASER);
                    break;
            }
            
            costume.setAnimatedState();
            
            collider = costume.getCollider();
            
            dy = player.costume.height / 8;
            
            _actions[ACTION_SHOOT_ID] = new Attack(FRAME_LASER_END, shootInitAction, shootUpdateAction, shootEndAction);
            
            forceChangeAction(ACTION_SHOOT_ID);
        }
        
        private function shootInitAction():void {
            
        }
        
        private function shootUpdateAction():void {
            if ( current_frame > FRAME_LASER_HIT_START && current_frame < FRAME_LASER_HIT_END ) {
                var pl_x:Number = player.x;
                var pl_y:Number = player.y + player.costume.height / 4;
                var max_y:Number = player.y + player.costume.height * 3 / 4;
                
                while ( pl_y < max_y ) {
                    if ( costume.hitTestPoint(pl_x, pl_y, true) ) {
                        game.changePlayerStat(DAMAGE);
                        break;
                    }
                    
                    pl_y += dy;
                }
            }
        }
        
        private function shootEndAction():void {
            costume.stop();
            destroy();
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var req:CreateBodyRequest = super.requestBodyAt(world);
            
            req.setAsStaticSensor();
            
            return req;
        }
        
        public function rotateTo(target:Point):void {
            costume.rotation = Math.atan2(target.y - y, target.x - x) * 180 / Math.PI;
        }
        
        override protected function updatePosition():void { }
        override protected function playHitAnimationIfNeeded():void { }
        override protected function flip():void { }
    }

}