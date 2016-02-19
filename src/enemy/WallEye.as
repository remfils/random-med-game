package src.enemy {
    import flash.display.DisplayObject;
    import src.costumes.CostumeEnemy;
    import src.interfaces.Init;


    public class WallEye extends Enemy {
        
        private static const INIT_STATE:String = "_init";
        private static const OPEN_STATE:String = "_open";
        private static const REMOVE_STATE:String = "_remove";
        private static const REMOVE_INIT_STATE:String = "_removeInit";
        
        private static const FRAME_INIT_END:int = 15;
        private static const FRAME_OPEN_HITFRAME_START:int = 11;
        private static const FRAME_OPEN_HITFRAME_END:int = 17;
        private static const FRAME_OPEN_END:int = 34;
        private static const FRAME_REMOVE_END:int = 17;
        
        protected var collider:DisplayObject;
        
        public function WallEye() {
            super();
            
            costume.setType(CostumeEnemy.WALL_EYE);
            
            setState(INIT_STATE, true);
            
            collider = costume.getCollider();
            
            health = 10000;
        }
        
        override public function update():void {
            current_frame ++;
            
            switch ( current_state ) {
                case INIT_STATE:
                    if ( current_frame > FRAME_INIT_END ) {
                        costume.stop();
                    }
                    break;
                case OPEN_STATE:
                    if (current_frame > FRAME_OPEN_HITFRAME_START && current_frame < FRAME_OPEN_HITFRAME_END ) {
                        if ( collider.hitTestObject(player.collider) ) {
                            game.hitPlayer(1);
                        }
                    }
                    else if ( current_frame > FRAME_OPEN_END ) {
                        costume.stop();
                    }
                    break;
                case REMOVE_STATE:
                case REMOVE_INIT_STATE:
                    if ( current_frame > FRAME_REMOVE_END ) {
                        destroy();
                    }
            }
        }
        
        public function open():void {
            setState(OPEN_STATE, true);
        }
        
        /*override public function die():void {
            switch ( current_state ) {
                case INIT_STATE:
                    setState(REMOVE_INIT_STATE, true);
                    break;
                case OPEN_STATE:
                    setState(REMOVE_STATE, true);
                    break;
            }
            
            cRoom.removeEnemy(this);
        }*/
    }

}