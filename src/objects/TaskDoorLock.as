package src.objects {
    import flash.display.DisplayObject;
    import flash.events.Event;
    import src.Game;
    import src.Player;
    import src.util.Collider;
    
    public class TaskDoorLock extends TaskObject {
        public var _activeArea:Collider;
        public var _collider:Collider;
        private var playerCollider:Collider;
        
        public static const LOCK_TYPE:String = "DoorLock";
        public static const BREAK_KEY_STATE:String = "_break";
        public static const UNLOCK_STATE:String = "_unlock";
        
        public function TaskDoorLock() {
            super();
            costume.setType(LOCK_TYPE);
            costume.setState();
            
            is_active = true;
        }
        
        override public function update():void {
            if ( !is_active ) return;
            
            /*if ( _collider.checkObjectCollision(playerCollider) ) {
                var holdObject:Object = Player.getInstance().holdObject;
                
                if ( holdObject ) {
                    if ( holdObject is TaskKey ) {
                        id = TaskKey(holdObject).id;
                        costume.dispatchEvent(new Event("GUESS_EVENT"));
                    }
                }
            }*/
        }
        
        override public function positiveOutcome():void {
            //game.deleteManager.add(body);
            //removePlayerKey();
            //gotoAndPlay("unlock");
            //game.cRoom.changeTaskObjectsToCoins(task_id);
        }
        
        public function removeCorpse():void {
            game.deleteManager.add(this);
        }
        
        override public function negativeOutcome():void {
            //removePlayerKey();
        }
        
        private function removePlayerKey():void {
            var holdObject:Object = game.player.holdObject;
            game.player.costume.removeChild(DisplayObject(holdObject));
            //game.deleteManager.add(holdObject);
            game.player.holdObject = null;
            holdObject = null;
            //gotoAndPlay("break_key");
        }
        
        override public function destroy():void {
            super.destroy();
        }
        
    }

}