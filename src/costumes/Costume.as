package src.costumes {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;

    public class Costume extends MovieClip {
        protected static const COLLIDER_NAME:String = "costume_collider";
        public var costume_collider:DisplayObject;
        
        protected var type:String = "";
        
        public function Costume() {
            costume_collider = getChildByName(COLLIDER_NAME) as MovieClip;
            this.mouseEnabled = false;
            costume_collider.visible = false;
        }
        
        public function setType(type_:String):void {
            type = type_;
        }
        
        public function setState(state_:String):void {
            gotoAndStop(type + state_);
        }
        
        public function getCollider():DisplayObject {
            return costume_collider;
        }
        
    }

}