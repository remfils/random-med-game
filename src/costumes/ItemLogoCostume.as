package src.costumes {
    import flash.display.DisplayObject;

    public class ItemLogoCostume extends Costume {
        
        public static const SPELL_SPARK:String = "Spark";
        public static const SPELL_NUKELINO:String = "Nukelino";
        public static const SPELL_POWER_SPELL:String = "PowerSpell";
        
        public function ItemLogoCostume() {
            super();
        }
        
        override public function getCollider():DisplayObject {
            return null;
        }
    }

}