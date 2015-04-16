package src.costumes {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;

    public class Costume extends MovieClip {
        protected static const COLLIDER_NAME:String = "costume_collider";
        
        protected var type:String = "";
        
        public function Costume() {
            
        }
        
        public function setType(type_:String):void {
            type = type_;
        }
        
        public function setState(state_:String):void {
            gotoAndStop(type + state_);
        }
        
        public function getCollider():DisplayObject {
            return getChildByName(COLLIDER_NAME);
        }
        
    }

}