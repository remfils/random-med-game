package src.objects {
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import src.Game;
    import src.Player;
    import src.util.Collider;
    import src.util.SoundManager;
    
    public class TaskDoorLock extends TaskObject {
        public var _activeArea:Collider;
        public var _collider:Collider;
        private var playerCollider:Collider;
        
        public static const LOCK_TYPE:String = "DoorLock";
        public static const BREAK_KEY_STATE:String = "_break";
        public static const UNLOCK_STATE:String = "_unlock";
        
        private static const KEY_UNLOCK_DELAY:int = 1533;
        
        private var key:TaskKey;
        
        public function TaskDoorLock() {
            super();
            costume.setType(LOCK_TYPE);
            costume.setState();
            
            is_active = true;
            
            properties = 0;
        }
        
        override public function update():void {
            if ( !is_active ) return;
            var player:Player = game.player;
            
            if ( active_area.hitTestObject(player.collider) ) {
                var holdObject:Object = player.holdObject;
                if ( holdObject ) {
                    if ( holdObject is TaskKey ) {
                        key = TaskKey(holdObject);
                        id = key.id;
                        eatPlayerKey();
                        submitAnswer();
                    }
                }
            }
        }
        
        override public function positiveOutcome():void {
            costume.setState(UNLOCK_STATE);
            deactivate();
            var timer:Timer = new Timer(KEY_UNLOCK_DELAY);
            timer.addEventListener(TimerEvent.TIMER, destroyAfterTimePasses);
            timer.start();
            SoundManager.instance.playSFX(SoundManager.SFX_OPEN_LOCK1);
        }
        
        private function destroyAfterTimePasses(e:TimerEvent):void {
            var a:Timer = e.target as Timer;
            a.removeEventListener(TimerEvent.TIMER, destroyAfterTimePasses);
            
            destroy();
        }
        
        // D!
        public function removeCorpse():void {
            game.deleteManager.add(this);
        }
        
        override public function negativeOutcome():void {
            costume.setState(BREAK_KEY_STATE);
            SoundManager.instance.playSFX(SoundManager.SFX_BREAK_KEY);
        }
        
        private function eatPlayerKey():void {
            var player:Player = game.player;
            var hb:TaskObject = player.holdObject;
            hb.hide();
            hb.destroy();
            game.taskManager.removeTaskObject(hb);
            player.holdObject = null;
        }
        
        override public function deactivate():void {
            is_active = false;
        }
        
        override public function destroy():void {
            super.destroy();
        }
        
    }

}