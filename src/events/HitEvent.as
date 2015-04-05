package src.events {
    import flash.events.Event;
    
    /**
     * ...
     * @author vlad
     */
    public class HitEvent extends Event {
        public static const TYPE:String = "HIT_EVENT";
        public var damage:Number = 0;
        
        public function HitEvent(damage:Number=0) { 
            super(TYPE, false, true);
            
            this.damage = damage;
        } 
        
        public override function clone():Event { 
            return new HitEvent(type, bubbles, cancelable);
        } 
        
        public override function toString():String { 
            return formatToString("HitEvent", "type", "bubbles", "cancelable", "eventPhase"); 
        }
        
    }
    
}