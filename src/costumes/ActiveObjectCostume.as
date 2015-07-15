package src.costumes {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;


    public class ActiveObjectCostume extends Costume {
        private static const ACTIVE_AREA_NAME:String = "active_area_mc";
        public var active_area_mc:DisplayObject;
        
        public function ActiveObjectCostume() {
            super();
            
            active_area_mc = getChildByName(ACTIVE_AREA_NAME);
            if (active_area_mc) active_area_mc.visible = false;
        }
        
        public function getActiveArea():DisplayObject {
            return active_area_mc;
        }
        
    }

}