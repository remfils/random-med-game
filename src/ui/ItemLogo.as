package src.ui {
    import flash.display.MovieClip;


    public class ItemLogo extends MovieClip {
        
        public static const SPELL_SPARK:String = "Spark";
        public static const SPELL_NUKELINO:String = "Nukelino";
        public static const SPELL_POWER_SPELL:String = "PowerSpell";
        
        public function ItemLogo() {
            super();
        }
        
        public function setType(type_:String):void {
            gotoAndStop(type_);
        }
    }

}