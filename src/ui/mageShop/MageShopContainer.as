package src.ui.mageShop {
    import flash.display.MovieClip;
	/**
     * ...
     * @author vlad
     */
    public class MageShopContainer extends MovieClip {
        public var isSpell:Boolean = false;
        public var locked:Boolean = false;
        public var type:String = "";
        public var item:InventoryItem;
        
        private var label_mc:MovieClip;
        
        public function MageShopContainer() {
            gotoAndStop("normal");
            
            label_mc = getChildByName("label_mc") as MovieClip;
        }
        
        public function setAsItem():void {
            label_mc.gotoAndStop("item");
            isSpell = false;
        }
        
        public function setAsSpell():void {
            label_mc.gotoAndStop("spell");
            isSpell = true;
        }
        
        public function setLocked():void {
            gotoAndStop("locked");
            locked = true;
        }
        
    }

}