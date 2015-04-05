package src.objects {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import src.interfaces.LoopClip;
    
    public class DecorObject extends MovieClip implements LoopClip {
        
        public static const TORCH_TYPE:String = "Torch";
        public static const WEB_TYPE:String = "Web";
        public static const SHIELD_TYPE:String = "Shield";
        
        public var type:int = 0;
        
        public function DecorObject() {
            
        }
        
        public function setType(TYPE:String) {
            switch(TYPE) {
                case TORCH_TYPE: gotoAndStop(TORCH_TYPE); break;
                case WEB_TYPE: gotoAndStop(WEB_TYPE); break;
                case SHIELD_TYPE: gotoAndStop(SHIELD_TYPE); break;
            }
        }
        
        override public function stop():void {
            super.stop();
            
            var i:int = this.numChildren;
            var decorObj:DisplayObject;
            while (i--) {
                decorObj = getChildAt(i);
                if ( decorObj is MovieClip)
                    MovieClip(decorObj).stop();
            }
        }
        
        override public function play():void {
            var i:int = this.numChildren;
            var decorObj:DisplayObject;
            while (i--) {
                decorObj = getChildAt(i);
                if ( decorObj is MovieClip)
                    MovieClip(decorObj).play();
            }
        }
        
    }

}