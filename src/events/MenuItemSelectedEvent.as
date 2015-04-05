package src.events {
    import flash.events.Event;
    
    public class MenuItemSelectedEvent extends Event {
        public var id:Number;
            
        static public const LEVEL_SELECTED:String = "MenuLevelSelectedEvent"
        
        public function MenuItemSelectedEvent(type:String, id:Number, bubbles:Boolean=true, cancelable:Boolean=false) { 
            super(type, bubbles, cancelable);
            this.id = id;
        } 
        
        public override function clone():Event { 
            return new MenuItemSelectedEvent(type, id, bubbles, cancelable);
        } 
        
        public override function toString():String { 
            return formatToString("LevelSelectedEvent", "type", "bubbles", "cancelable", "eventPhase"); 
        }
        
    }
    
}