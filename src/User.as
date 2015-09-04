package src {
    import src.costumes.PlayerCostume;
    import src.objects.AbstractObject;
    import src.ui.mageShop.InventoryItem;
    import src.ui.playerStat.PlayerStat;
    import src.util.AbstractManager;

    public class User extends AbstractManager {
        public var uid:uint = 0;
        public var sid:uint = 0;
        public var name:String = "";
        public var surname:String = "";
        public var levelsCompleted:int = 0;
        
        private const backup_var_names:Array = [
            "HEALTH",
            "MAX_HEALTH",
            "MANA",
            "MAX_MANA",
            "MONEY",
            "EXP"
        ];
        
        public var inventory:Array = new Array(); // D!
        public var playerInventory:Vector.<InventoryItem>;
        
        public var player:Player;
        public var playerData:Object;
        public var backup_player:Object;
        
        public function User() {
            playerData = new Object();
            playerInventory = new <InventoryItem>[];
            player = new Player();
            
        }
        
        // D!
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
        // D!
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
            var dname:String;
            
            for each ( var data:XML in userXML.* ) {
                dname = data.name();
                if ( this.hasOwnProperty(dname) ) {
                    this[dname] = data;
                }
                else if ( player.hasOwnProperty(dname)){
                    player[dname] = data;
                }
                else {
                    playerData[dname] = data;
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
            
            trace(player.MONEY);
        }
        
        public function getEXPToNextLevel():int {
            var _EXP:int = playerData.EXP;
            var next_level_xp:Number = 0;
            var level = 0;
            
            while ( (next_level_xp = getXPToLevel(level) ) < _EXP) {
                level ++;
            }
            
            return next_level_xp - _EXP;
        }
        
        private function getXPToLevel(lvl:Number):Number{
            if ( lvl > 0 ) return 25 * lvl * lvl + getXPToLevel(lvl - 1);
            else return 25;
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
        
        public function backupPlayer():void {
            if ( backup_player ) {
                // remove object
            }
            backup_player = new Object();
            
            for each ( var p in backup_var_names ) {
                backup_player[p] = player[p];
            }
        }
        
        public function resetPlayer():void {
            for each ( var prop in backup_var_names ) {
                player[prop] = backup_player[prop];
            }
            
            player.costume.setType(PlayerCostume.STAND_TYPE);
        }
    }

}