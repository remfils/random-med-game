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
    public class DoorLock extends TaskObject {
        public var _activeArea:Collider;
        public var _collider:Collider;
        private var playerCollider:Collider;
        
        public function DoorLock() {
            super();
            playerCollider = game._player.getCollider();
            
            _activeArea = getChildByName("activeArea") as Collider;
            _collider = getChildByName("collider001") as Collider;
            
            active = true;
        }
        
        override public function update():void {
            if ( !active ) return;
            
            if ( _collider.checkObjectCollision(playerCollider) ) {
                var holdObject:Object = Player.getInstance().holdObject;
                
                if ( holdObject ) {
                    if ( holdObject is Key ) {
                        id = Key(holdObject).id;
                        dispatchEvent(new Event("GUESS_EVENT"));
                    }
                }
            }
        }
        
        override public function positiveOutcome():void {
            game.deleteManager.add(body);
            removePlayerKey();
            gotoAndPlay("unlock");
            Game.cRoom.changeTaskObjectsToCoins(taskId);
        }
        
        public function removeCorpse():void {
            game.deleteManager.add(this);
        }
        
        override public function negativeOutcome():void {
            removePlayerKey();
        }
        
        private function removePlayerKey():void {
            var holdObject:Object = Player.getInstance().holdObject;
            Player.getInstance().removeChild(DisplayObject(holdObject));
            //game.deleteManager.add(holdObject);
            Player.getInstance().holdObject = null;
            holdObject = null;
            gotoAndPlay("break_key");
        }
        
        override public function destroy():void {
            super.destroy();
        }
        
    }

}