package src.objects {
    import flash.display.DisplayObject;
    import flash.events.Event;
    import src.Game;
    import src.Player;
    import src.util.Collider;
	/**
     * ...
     * @author vlad
     */
    public class TaskDoorLock extends TaskObject {
        public var _activeArea:Collider;
        public var _collider:Collider;
        private var playerCollider:Collider;
        
        public function TaskDoorLock() {
            super();
            //playerCollider = game.player.getColliderBad();
            
            _activeArea = costume.getChildByName("activeArea") as Collider;
            _collider = costume.getChildByName("collider001") as Collider;
            
            is_active = true;
        }
        
        override public function update():void {
            if ( !is_active ) return;
            
            if ( _collider.checkObjectCollision(playerCollider) ) {
                var holdObject:Object = Player.getInstance().holdObject;
                
                if ( holdObject ) {
                    if ( holdObject is TaskKey ) {
                        id = TaskKey(holdObject).id;
                        costume.dispatchEvent(new Event("GUESS_EVENT"));
                    }
                }
            }
        }
        
        override public function positiveOutcome():void {
            game.deleteManager.add(body);
            removePlayerKey();
            //gotoAndPlay("unlock");
            game.cRoom.changeTaskObjectsToCoins(task_id);
        }
        
        public function removeCorpse():void {
            game.deleteManager.add(this);
        }
        
        override public function negativeOutcome():void {
            removePlayerKey();
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