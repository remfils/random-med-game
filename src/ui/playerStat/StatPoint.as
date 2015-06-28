package src.ui.playerStat {
    
    import flash.display.MovieClip;
    
    // D!
    
    
    public class StatPoint extends MovieClip {
        public static const FULL_STATE:String = "full";
        public static const HALF_STATE:String = "half";
        public static const EMPTY_STATE:String = "empty";
        public static const BLINK_STATE:String = "blink";
        
        public var currentState:String = FULL_STATE;
        
        private var active:Boolean = true;
        
        public function StatPoint():void {
            super();
            refresh();
        }
        
        public function setState(State:String):void {
            currentState = State;
            refresh();
        }
        
        public function refresh():void {
            gotoAndStop(currentState);
        }
        
        public function isActive():Boolean {
            return active;
        }
    }
    
}
