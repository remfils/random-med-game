package src.costumes {
    import flash.display.MovieClip;


    public class MenuSprites extends MovieClip {
        
        public static const STAR_EMPTY:String = "star_empty";
        public static const STAR_FULL:String = "star_full";
        public static const BG:String = "BG";
        public static const MAGE_SHOP:String = "mage_shop";
        public static const ITEM_ICO_SPELL:String = "item_ico_spell";
        public static const ITEM_ICO_ITEM:String = "item_ico_item";
        
        public static const ITEM_HOLDER:String = "item_holder";
        public static const ITEM_HOLDER_LOCKED:String = "item_holder_locked";
        public static const SPELL_HOLDER:String = "spell_holder";
        public static const SPELL_HOLDER_LOCKED:String = "spell_holder_locked";
        
        public static const LOADING_CIRCLE:String = "loading_circle";
        
        public static const CLOSE_BUTTON:String = "close_btn";
        
        public static const COIN_GRAPHIC:String = "coin";
        public static const EXP_GRAPHIC:String = "exp_gr";
        
        public function MenuSprites() {
            super();
        }
        
        public function setSprite(type:String):void {
            gotoAndStop(type);
        }
        
    }

}