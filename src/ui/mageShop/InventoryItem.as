package src.ui.mageShop {
    import flash.display.MovieClip;
    import flash.utils.getDefinitionByName;
    import src.costumes.MenuItemCostume;
    
    public class InventoryItem {
        public var parentContainer:MageShopContainer;
        
        public var iid:uint;
        public var item_name:String;
        public var rus_name:String;
        public var onPlayer:Boolean;
        public var isSpell:Boolean;
        public var dsc:String;
        
        public var item_index:int;
        
        public var itemMenu:MenuItemCostume;
        
        public function InventoryItem() {
            super();
        }
        
        public function setParams(iid:uint, name:String, name_rus:String, dsc:String, isSpell:Boolean, onPlayer:Boolean):void {
            this.iid = iid;
            this.item_name = name;
            this.rus_name = name_rus;
            this.dsc = dsc;
            this.isSpell = isSpell;
            this.onPlayer = onPlayer;
        }
        
        public function setParametersFromXML(params:XML):void {
            this.iid = params.@iid;
            this.item_name = params.@name;
            this.rus_name = params.@nameRus;
            this.dsc = params.@dsc;
            this.isSpell = params.@isSpell == "true";
            this.onPlayer = params.@onPlayer == "true";
        }
    }

}