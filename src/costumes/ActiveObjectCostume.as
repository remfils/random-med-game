package src.costumes {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;


    public class ActiveObjectCostume extends Costume {
        public static const LEVER_TYPE:String = "Lever";
        public static const KEY_TYPE:String = "TaskKey";
        public static const LETTER_TYPE:String = "Letter";
        public static const STAIRWAY_TYPE:String = "Stairway";
        public static const EXPLOSIVE_LEVER_TYPE:String = "ExplosiveLever";
        
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