package src.events {
    import flash.events.Event;
    
    /**
     * ...
     * @author vlad
     */
    public class GameEvent extends Event {
        
        public static const RESUME_EVENT:String = "RESUME_GAME_EVENT";
        
        public function GameEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) { 
            super(type, bubbles, cancelable);
            
        } 
        
        public override function clone():Event { 
            return new GameEvent(type, bubbles, cancelable);
        } 
        
        public override function toString():String { 
            return formatToString("GameEvent", "type", "bubbles", "cancelable", "eventPhase"); 
        }
        
    }
    
}