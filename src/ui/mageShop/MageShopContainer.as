package src.ui.mageShop {
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import src.costumes.MenuSprites;

    public class MageShopContainer extends Sprite {
        public var isSpell:Boolean = false;
        public var locked:Boolean = false;
        public var type:String = "";
        
        public var costume:MenuSprites;
        
        public var item:InventoryItem;
        
        private var label_mc:MovieClip;
        
        public function MageShopContainer() {
            costume = new MenuSprites();
            setAsSpell();
            addChild(costume);
        }
        
        public function setAsItem():void {
            costume.setSprite(MenuSprites.ITEM_HOLDER);
            isSpell = false;
        }
        
        public function setAsSpell():void {
            costume.setSprite(MenuSprites.SPELL_HOLDER);
            isSpell = true;
        }
        
        public function setLocked():void {
            if ( isSpell ) costume.setSprite(MenuSprites.SPELL_HOLDER_LOCKED);
            else costume.setSprite(MenuSprites.ITEM_HOLDER_LOCKED);
            
            locked = true;
        }
        
    }

}