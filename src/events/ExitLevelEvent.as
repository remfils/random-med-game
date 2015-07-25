package src.events {
    import flash.events.Event;
    
    public class ExitLevelEvent extends Event {
        public static const EXIT_TO_MENU_CMD:int = 1;
        public static const NEXT_LEVEL_CMD:int = 2;
        public static const RESTART_LEVEL_CMD:int = 3;
        
        public static const EXIT_LEVEL_EVENT:String = "EVENT_EXIT_LEVEL";
        public var nextLevel:Boolean = true; // D!
        public var level_completed:Boolean;
        
        public var cmd:int;
        
        public function ExitLevelEvent(cmd_:int = EXIT_TO_MENU_CMD, level_completed_:Boolean=true) { 
            super(EXIT_LEVEL_EVENT, false, false);
            cmd = cmd_;
            level_completed = level_completed_;
        } 
        
        public override function clone():Event { 
            return new ExitLevelEvent(cmd,level_completed);
        } 
        
        public override function toString():String { 
            return formatToString(EXIT_LEVEL_EVENT, "type", "bubbles", "cancelable", "eventPhase"); 
        }
        
    }
    
}