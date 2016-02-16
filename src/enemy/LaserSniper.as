package src.enemy {


    public class LaserSniper extends Sniper {
        
        public function LaserSniper() {
            super();
            
            charge_delay = 56;
            
            TOTAL_CHARGE_FRAMES = 49;
        }
        
        override public function shoot():void {
            var laser:EnemyLaser = new EnemyLaser(EnemyLaser.SMALL_TYPE);
            
            laser.x = x - 1.25;
            laser.y = y - 32;
            laser.rotateTo(player);
            
            cRoom.add(laser);
        }
    }

}