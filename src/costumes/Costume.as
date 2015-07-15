package src.costumes {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;

    public class Costume extends MovieClip {
        protected static const COLLIDER_NAME:String = "costume_collider";
        public var costume_collider:DisplayObject;
        
        public var type:String = "";
        
        public function Costume() {
            costume_collider = getChildByName(COLLIDER_NAME) as MovieClip;
            this.mouseEnabled = false;
            if (costume_collider) costume_collider.visible = false;
            stop();
        }
        
        public function setType(type_:String):void {
            type = type_;
        }
        
        public function setState(state_:String=null):void {
            if (state_) gotoAndStop(type + state_);
            else gotoAndStop(type);
        }
        
        public function getCollider():DisplayObject {
            return costume_collider;
        }
        
        public function destroy():void {
            while ( numChildren ) {
                removeChild(getChildAt(numChildren-1));
            }
        }
        
        public function readXMLParams(paramsXML:XML):void {
            setType(paramsXML.name());
            
            x = paramsXML.@x;
            y = paramsXML.@y;
            
            if ( paramsXML.@flip == "true" ) {
                scaleX *= -1;
            }
            
            if ( paramsXML.@rotation ) {
                rotation = paramsXML.@rotation;
            }
        }
    }

}