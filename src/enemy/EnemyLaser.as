package src.enemy {
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import src.costumes.CostumeEnemy;
    import src.objects.AbstractObject;
    import src.util.ChangePlayerStatObject;
    import src.util.CreateBodyRequest;


    public class EnemyLaser extends Enemy {
        private var collider:DisplayObject;
        private const DAMAGE:ChangePlayerStatObject = new ChangePlayerStatObject(ChangePlayerStatObject.HEALTH_STAT, -1, 3, true);
        
        private const FRAME_LASER_HIT_START:int = 3;
        private const FRAME_LASER_HIT_END:int = 7;
        private const FRAME_LASER_END:int = 9;
        
        private var dy:Number;
        
        public static const SMALL_TYPE:int = 1;
        public static const BOSS_TYPE:int = 2;
        
        
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
            
            dy = player.costume.height / 4;
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var req:CreateBodyRequest = super.requestBodyAt(world);
            
            req.setAsStaticSensor();
            
            return req;
        }
        
        override public function update():void {
            currentFrame ++;
            
            if ( current_frame > FRAME_LASER_HIT_END ) {
                //body.SetActive(false);
            }
            else if ( current_frame > FRAME_LASER_HIT_START ) {
                var pl_x:Number = player.x;
                var pl_y:Number = player.y + dy;
                var max_y:Number = player.y + player.costume.height - dy;
                
                while ( pl_y < max_y ) {
                    if ( costume.hitTestPoint(pl_x, pl_y, true) ) {
                        game.changePlayerStat(DAMAGE);
                        break;
                    }
                    
                    pl_y += dy;
                }
                
                //body.SetActive(true);
            }
            
            if ( current_frame > FRAME_LASER_END ) {
                die();
            }
        }
        
        public function rotateTo(target:AbstractObject):void {
            var rad_angle:Number = 0;
            
            if ( target.x != x ) {
                rad_angle = Math.atan(( y - target.y + target.costume.height / 2 ) / ( x - target.x ));
                
                if ( x > target.x ) {
                    rad_angle += Math.PI;
                }
            }
            else {
                rad_angle = Math.PI / 2;
                if ( target.y > y ) {
                    rad_angle *= -1;
                }
            }
            
            costume.rotation = rad_angle * 180 / Math.PI;
        }
        
        override public function die():void {
            cRoom.remove(this);
            costume.stop();
            destroy();
        }
    }

}