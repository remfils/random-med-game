package src.enemy {
    import flash.geom.Point;


    public class LaserSniper extends Sniper {
        
        public function LaserSniper() {
            super();
            
            frame_recharge_end = 15;
            
            FRAME_TARGET_IS_LOCKED = 40;
            FRAME_SHOOT = 49;
            _actions[ACTION_SHOOT_ID].end_animation_frame = 53;
            _actions[ACTION_DEATH_ID].end_animation_frame = 50;
        }
        
        override protected function shootAtPoint(p:Point):void {
            var laser:EnemyLaser = new EnemyLaser(EnemyLaser.SMALL_TYPE);
            
            laser.x = x + 2.15;
            laser.y = y - 44.3;
            
            p.y -= player.costume.height / 2;
            
            laser.rotateTo(p);
            
            cRoom.add(laser);
        }
    }

}