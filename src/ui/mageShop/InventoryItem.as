package src.ui.mageShop {
    import flash.display.MovieClip;
    import flash.utils.getDefinitionByName;
    
    public class InventoryItem extends MovieClip {
        public var parentContainer:MageShopContainer;
        
        public var iid:uint;
        public var item_name:String;
        public var rus_name:String;
        public var onPlayer:Boolean;
        public var isSpell:Boolean;
        public var dsc:String;
        
        public function InventoryItem() {
            super();
            item_mc.mouseEnabled = false;
        }
        
        public function setParams(iid:uint, name:String, name_rus:String, dsc:String, isSpell:Boolean, onPlayer:Boolean):void {
            this.iid = iid;
            this.item_name = name;
            this.rus_name = name_rus;
            this.dsc = dsc;
            this.isSpell = isSpell;
            this.onPlayer = onPlayer;
            
            item_mc.gotoAndStop(item_name);
        }
        
        public function setInitialPositionInContainer():void {
            x = 50;
            y = 40;
        }
        
        public function getClassFromName():Class {
            var spellClass:Class = null ;
            
            if ( isSpell ) {
                spellClass = getDefinitionByName("src.bullets." + item_name) as Class
            }
            
            return spellClass;
        }
        
    }

}