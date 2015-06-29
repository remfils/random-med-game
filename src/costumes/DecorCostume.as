package src.costumes {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import src.interfaces.LoopClip;
    
    public class DecorCostume extends Costume implements LoopClip {
        
        public static const TORCH_TYPE:String = "Torch";
        public static const WEB_TYPE:String = "Web";
        public static const SHIELD_TYPE:String = "Shield";
        
        public function DecorCostume() {
            
        }
        
        override public function setType(TYPE:String):void {
            super.setType(TYPE);
            setState("");
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