package src.costumes {
    import flash.display.MovieClip;
    import flash.text.TextField;


    public class MenuButtonCostume extends Costume {
        
        public static const LEVEL_BTN:String = "level_btn";
        public static const INVENTORY_BTN:String = "inventory_btn";
        public static const ACHIVEMENTS_BTN:String = "achivements_btn";
        public static const GOTO_TITLE_BTN:String = "goto_title_btn";
        public static const MOVE_LEVELS_LEFT:String = "move_levels_left";
        public static const MOVE_LEVELS_RIGHT:String = "move_levels_right";
        public static const LEVEL_SELECT_BTN:String = "level_select_btn";
        
        public var level_name:TextField;
        
        public function MenuButtonCostume() {
            super();
        }
        
        override public function setState(state_:String):void {
            super.setState(state_);
            if ( state_ == LEVEL_SELECT_BTN ) {
                level_name = TextField(getChildByName("level_name"));
            }
        }
    }

}