package src {
    import src.objects.AbstractObject;
    import src.ui.mageShop.InventoryItem;
    import src.ui.playerStat.PlayerStat;
	/**
     * ...
     * @author vlad
     */
    public class User {
        public var uid:uint=0;
        public var name:String = "";
        public var surname:String = "";
        public var levelsCompleted:int = 0;
        
        public var inventory:Array = new Array();
        
        public var player:Player; // delete-me
        public var playerData:Object;
        
        public function User() {
            player = Player.getInstance();
        }
        
        public function putSpellAt ( position:int, Spell:Class ):void {
            /*if ( position >= maxSpells || spells.length == maxSpells ) {
                throw new RangeError("You can't any more spells", 1);
            }
            if ( position == -1 ) {
            }
            else {
                spells[position] = Spell;
            }*/
        }
        
        public function setPlayerInventory():void {
            trace("ran: User.setPlayerInvetory");
            /*var item:InventoryItem;
            player.spells = [];
            
            for ( var i:int = 0; i < inventory.length; i++ ) {
                item = inventory[i];
                if ( item.onPlayer ) {
                    if ( item.isSpell ) {
                        player.spells.push(item.getClassFromName());
                    }
                }
            }*/
        }
        
        public function setDataFromXML (userXML:XMLList):void {
            var item:InventoryItem;
            for each ( var data:XML in userXML.* ) {
                if ( this.hasOwnProperty(data.name()) ) {
                    this[data.name()] = data;
                }
                else {
                    playerData[data.name()] = data;
                }
            }
            
            if ( userXML.INVENTORY ) {
                for each ( var itemXML:XML in userXML.INVENTORY.* ) {
                    item = new InventoryItem();
                    item.setParams(itemXML.@iid, itemXML.@name, itemXML.@nameRus, itemXML.@dsc, itemXML.@isSpell == "true", itemXML.@onPlayer == "true");
                    inventory.push(item);
                }
            }
        }
        
        public function toXML():XML {
            var result:XML,
                item:InventoryItem;
            
            updateData();
            
            result =  <User>
                <uid>{this.uid}</uid>
                <name>{this.name}</name>
                <surname>{this.surname}</surname>
                <HEALTH>{playerData.HEALTH}</HEALTH>
                <MAX_HEALTH>{playerData.MAX_HEALTH}</MAX_HEALTH>
                <MANA>{playerData.MANA}</MANA>
                <MAX_MANA>{playerData.MAX_MANA}</MAX_MANA>
                <EXP>{playerData.EXP}</EXP>
                <MONEY>{playerData.MONEY}</MONEY>
                <levelsCompleted>{this.levelsCompleted}</levelsCompleted>
                <MAX_SPELLS>{playerData.MAX_SPELLS}</MAX_SPELLS>
                <MAX_ITEMS>{playerData.MAX_ITEMS}</MAX_ITEMS>
                <INVENTORY></INVENTORY>
            </User>;
            
            for ( var i = 0; i < inventory.length; i++ ) {
                item = inventory[i];
                result.INVENTORY.*[i] = <Item>
                    <iid>{item.iid}</iid>
                    <onPlayer>{item.onPlayer}</onPlayer>
                </Item>;
            }
            
            return result;
        }
        
        public function updateData():void {
            if ( levelsCompleted < AbstractObject.game.levelId ) {
                levelsCompleted = AbstractObject.game.levelId;
            }
        }
        
    }

}