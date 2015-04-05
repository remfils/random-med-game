package src.events {
    import flash.events.Event;
    
    /**
     * ...
     * @author vlad
     */
    public class ExitLevelEvent extends Event {
        public static const EXIT_LEVEL_EVENT:String = "EVENT_EXIT_LEVEL";
        public var nextLevel:Boolean = true;
        
        public function ExitLevelEvent(nextLevel:Boolean=true) { 
            super("EVENT_EXIT_LEVEL", false, false);
            this.nextLevel = nextLevel;
        } 
        
        public override function clone():Event { 
            return new ExitLevelEvent(nextLevel);
        } 
        
        public override function toString():String { 
            return formatToString("ExitLevelEvent", "type", "bubbles", "cancelable", "eventPhase"); 
        }
        
    }
    
}