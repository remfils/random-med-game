package src.enemy {
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import src.costumes.CostumeEnemy;
    import src.util.ChangePlayerStatObject;
    import src.util.CreateBodyRequest;


    public class EnemyLaser extends Enemy {
        private var collider:DisplayObject;
        private const DAMAGE:ChangePlayerStatObject = new ChangePlayerStatObject(ChangePlayerStatObject.HEALTH_STAT, -1, 3, true);
        
        private const FRAME_LASER_HIT_START:int = 3;
        private const FRAME_LASER_HIT_END:int = 7;
        private const FRAME_LASER_END:int = 9;
        
        private var dy:Number;
        
        public function EnemyLaser() {
            costume.setType(CostumeEnemy.ENEMY_LASER);
            costume.setAnimatedState();
            
            collider = costume.getCollider();
            
            dy = player.costume.height / 7;
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
        
        override public function die():void {
            cRoom.remove(this);
            costume.stop();
            destroy();
        }
    }

}