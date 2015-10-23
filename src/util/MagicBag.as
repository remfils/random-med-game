package src.util {
    import flash.display.DisplayObject;
    import src.costumes.ObjectCostume;
    import src.Ids;
    import src.interfaces.Update;
    import src.Player;


    public class MagicBag extends AbstractManager implements Update {
        public static const SMALL_HP_STAT_OBJ:ChangePlayerStatObject = new ChangePlayerStatObject(ChangePlayerStatObject.HEALTH_STAT, 2, Ids.ITEM_POTION_HEALTH_ID);
        public static const SMALL_MP_STAT_OBJ:ChangePlayerStatObject = new ChangePlayerStatObject(ChangePlayerStatObject.MANA_STAT, 2, Ids.ITEM_POTION_MANA_ID);
        public static const COIN_STAT_OBJ:ChangePlayerStatObject = new ChangePlayerStatObject(ChangePlayerStatObject.MONEY_STAT, 1, Ids.ITEM_COIN_ID);
        public static const EMERALD_STAT_OBJ:ChangePlayerStatObject = new ChangePlayerStatObject(ChangePlayerStatObject.MONEY_STAT, 10, Ids.ITEM_EMERALD_ID);
        
        public static const DROP_STATE:String = "_drop";
        public static const PICKUP_STATE:String = "_pickup";
        
        public static const MAP_PICKUP_DELLAY:Number = 700;
        
        public var is_empty:Boolean = true;
        public var not_active:Boolean = true;
        
        public var costume:ObjectCostume;
        public var collider:DisplayObject;
        private var player:Player;
        
        public function MagicBag() {
            super();
            costume = new ObjectCostume();
            player = game.player;
        }
        
        public function setType(str:String):void {
            costume.setType(str);
            is_empty = false;
        }
        
        public function readXML(objectsXML:XMLList):void {
            var randomP:Number = Math.random();
            var p:Number = 0;
            
            for each (var item:XML in objectsXML.*) {
                p += Number(item.@p) || 1;
                if ( p > randomP ) {
                    costume.setType(item.name());
                    is_empty = false;
                    break;
                }
            }
        }
        
        public function open():ObjectCostume {
            if (is_empty) return null;
            
            costume.setAnimatedState(DROP_STATE);
            collider = costume.getCollider(); 
            
            not_active = false;
            return costume;
        }
        
        public function update():void {
            if ( not_active ) return;
            
            if ( collider.hitTestObject(player.collider) ) {
                var change:ChangePlayerStatObject;
                
                switch (costume.type) {
                    case ObjectCostume.SMALLHP_TYPE:
                        change = SMALL_HP_STAT_OBJ;
                    break;
                    case ObjectCostume.SMALLMP_TYPE:
                        change = SMALL_MP_STAT_OBJ;
                    break;
                    case ObjectCostume.EXIT_TYPE:
                        costume.setState(PICKUP_STATE);
                        game.finishLevel(MAP_PICKUP_DELLAY);
                    break;
                    case ObjectCostume.COIN_TYPE:
                        change = COIN_STAT_OBJ;
                    break;
                    case ObjectCostume.EMERALD_TYPE:
                        change = EMERALD_STAT_OBJ;
                    break;
                }
                
                if ( change ) {
                    if ( game.changePlayerStat(change) ) {
                        Recorder.recordPickUpItem(change.id);
                        not_active = true;
                        costume.setAnimatedState(PICKUP_STATE);
                        game.deleteManager.add(this);
                    }
                }
            }
        }
    }

}