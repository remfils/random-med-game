package src {
    import src.objects.AbstractObject;
    import src.ui.mageShop.InventoryItem;
    import src.ui.playerStat.PlayerStat;
    import src.util.AbstractManager;

    public class User extends AbstractManager {
        public var uid:uint=0;
        public var name:String = "";
        public var surname:String = "";
        public var levelsCompleted:int = 0;
        
        public var inventory:Array = new Array();
        public var playerInventory:Vector.<InventoryItem>;
        
        public var playerData:Object;
        
        public function User() {
            playerData = new Object();
            playerInventory = new <InventoryItem>[];
            //player = Player.getInstance();
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
        
        public function addToPlayerInventory():void {
            
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
                    //item.setParams(itemXML.@iid, itemXML.@name, itemXML.@nameRus, itemXML.@dsc, itemXML.@isSpell == "true", itemXML.@onPlayer == "true");
                    
                    item.setParametersFromXML(itemXML);
                    inventory[inventory.length] = item;
                    
                    //if ( item.onPlayer ) playerInventory[playerInventory.length - 1] = item;
                }
            }
        }
        
        public function toXML():XML {
            var result:XML,
                item:InventoryItem;
            var player:Player = game.player;
            
            if ( levelsCompleted < AbstractObject.game.levelId ) {
                levelsCompleted = AbstractObject.game.levelId;
            }
            
            result =  <User>
                <uid>{this.uid}</uid>
                <name>{this.name}</name>
                <surname>{this.surname}</surname>
                <HEALTH>{player.HEALTH}</HEALTH>
                <MAX_HEALTH>{player.MAX_HEALTH}</MAX_HEALTH>
                <MANA>{player.MANA}</MANA>
                <MAX_MANA>{player.MAX_MANA}</MAX_MANA>
                <EXP>{player.EXP}</EXP>
                <MONEY>{player.MONEY}</MONEY>
                <levelsCompleted>{this.levelsCompleted}</levelsCompleted>
                <MAX_SPELLS>{player.MAX_SPELLS}</MAX_SPELLS>
                <MAX_ITEMS>{player.MAX_ITEMS}</MAX_ITEMS>
                <INVENTORY></INVENTORY>
            </User>;
            
            for ( var i = 0; i < playerInventory.length; i++ ) {
                item = playerInventory[i];
                result.INVENTORY.*[i] = <Item>
                    <iid>{item.iid}</iid>
                    <onPlayer>{item.onPlayer}</onPlayer>
                </Item>;
            }
            
            return result;
        }
        
        // D!
        public function updateData():void {
            if ( levelsCompleted < AbstractObject.game.levelId ) {
                levelsCompleted = AbstractObject.game.levelId;
            }
        }
        
        public function clearInventory():void {
            while (inventory.length) {
                inventory.pop();
            }
        }
    }

}