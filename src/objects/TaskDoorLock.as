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
        
        private var key:TaskKey;
        
        public function TaskDoorLock() {
            super();
            costume.setType(LOCK_TYPE);
            costume.setState();
            
            is_active = true;
        }
        
        override public function update():void {
            if ( !is_active ) return;
            var player:Player = game.player;
            
            if ( active_area.hitTestObject(player.collider) ) {
                var holdObject:Object = player.holdObject;
                
                if ( holdObject ) {
                    if ( holdObject is TaskKey ) {
                        eatPlayerKey();
                        key = TaskKey(holdObject);
                        id = key.id;
                        submitAnswer();
                    }
                }
            }
            
            if ( !costume.visible ) {
                destroy();
            }
        }
        
        override public function positiveOutcome():void {
            costume.setState(UNLOCK_STATE);
        }
        
        public function removeCorpse():void {
            game.deleteManager.add(this);
        }
        
        override public function negativeOutcome():void {
            costume.setState(BREAK_KEY_STATE);
        }
        
        private function eatPlayerKey():void {
            var player:Player = game.player;
            var hb:TaskObject = player.holdObject;
            player.holdObject = null;
            hb.hide();
            game.deleteManager.add(hb);
        }
        
        override public function destroy():void {
            super.destroy();
        }
        
    }

}