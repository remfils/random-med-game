package src.enemy {
    import flash.automation.ActionGenerator;
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
        
        private static const ACTION_INIT_ID:int = 1;
        private static const ACTION_OPEN_ID:int = 2;
        
        protected var collider:DisplayObject;
        
        public function WallEye() {
            super();
            
            health = 10000;
            isFlip = false;
            
            costume.setType(CostumeEnemy.WALL_EYE);
            
            _actions[ACTION_DEATH_ID].end_animation_frame = FRAME_REMOVE_END;
            _actions[ACTION_INIT_ID] = new Attack(FRAME_INIT_END, initInitAction, null, initEndAction);
            _actions[ACTION_OPEN_ID] = new Attack(FRAME_OPEN_END, openInitAction, openUpdateAction);
            
            collider = costume.getCollider();
            
            forceChangeAction(ACTION_INIT_ID);
        }
        
        private function initInitAction():void {
            setState(INIT_STATE, true);
        }
        
        private function initEndAction():void {
            costume.stop();
        }
        
        private function openInitAction():void {
            setState(OPEN_STATE, true);
        }
        
        private function openUpdateAction():void {
            if (current_frame > FRAME_OPEN_HITFRAME_START ) {
                if ( collider.hitTestObject(player.collider) ) {
                    game.hitPlayer(1);
                }
            }
        }
        
        override protected function deathInitAction():void {
            switch ( current_state ) {
                case INIT_STATE:
                    setState(REMOVE_INIT_STATE, true);
                    break;
                case OPEN_STATE:
                    setState(REMOVE_STATE, true);
                    break;
            }
            
            // cRoom.removeEnemy(this);
        }
        
        /*override public function update():void {
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
        }*/
        
        public function open():void {
            forceChangeAction(ACTION_OPEN_ID);
        }
        
        override public function remove():void {
            forceChangeAction(ACTION_DEATH_ID);
        }
    }

}