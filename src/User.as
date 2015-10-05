package src {
    import src.bullets.BulletController;
    import src.costumes.PlayerCostume;
    import src.objects.AbstractObject;
    import src.ui.mageShop.InventoryItem;
    import src.ui.playerStat.PlayerStat;
    import src.util.AbstractManager;

    public class User extends AbstractManager {
        public var game:Game;
        
        public var uid:uint = 0;
        public var sid:uint = 0;
        public var name:String = "";
        public var surname:String = "";
        public var levels_completed:int = 0;
        
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
                clearInventory();
                
                for each ( var itemXML:XML in userXML.INVENTORY.* ) {
                    item = new InventoryItem();
                    //item.setParams(itemXML.@iid, itemXML.@name, itemXML.@nameRus, itemXML.@dsc, itemXML.@isSpell == "true", itemXML.@onPlayer == "true");
                    
                    item.setParametersFromXML(itemXML);
                    inventory[inventory.length] = item;
                    
                    //if ( item.onPlayer ) playerInventory[playerInventory.length - 1] = item;
                }
            }
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
                <levelsCompleted>{this.levels_completed}</levelsCompleted>
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
        
        public function clearInventory():void {
            while (inventory.length) {
                inventory.pop();
            }
        }
        
        public function preparePlayerForGame():void {
            var i:int, inv_length:int = inventory.length;
            var item:InventoryItem;
            
            var spells:Array = player.spells;
            while ( spells.length ) {
                spells.pop();
            }
            
            for (i = 0; i < inv_length; i++) {
                item = InventoryItem(inventory[i]);
                if (item.onPlayer) {
                    if (item.isSpell ){
                        player.spells.push(BulletController.getIndexOfBulletByName(item.item_name));
                    }
                }
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