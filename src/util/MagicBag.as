package src.util {
    import flash.display.DisplayObject;
    import src.costumes.ObjectCostume;
    import src.Player;


    public class MagicBag extends AbstractManager {
        public static const SMALL_HP_STAT_OBJ:Object = { "HEALTH": 1 };
        public static const SMALL_MP_STAT_OBJ:Object = { "MANA": 2 };
        public static const COIN_STAT_OBJ:Object = { "MONEY": 1 };
        public static const EMERALD_STAT_OBJ:Object = { "MONEY": 20 };
        
        public static const DROP_STATE:String = "_drop";
        public static const PICKUP_STATE:String = "_pickup";
        
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
                not_active = true;
                costume.setAnimatedState(PICKUP_STATE);
                game.deleteManager.add(this);
                
                switch (costume.type) {
                    case ObjectCostume.SMALLHP_TYPE:
                        player.addToStats(SMALL_HP_STAT_OBJ);
                    break;
                    case ObjectCostume.SMALLMP_TYPE:
                        player.addToStats(SMALL_MP_STAT_OBJ);
                    break;
                    case ObjectCostume.EXIT_TYPE:
                        game.finishLevel();
                    break;
                    case ObjectCostume.COIN_TYPE:
                        player.addToStats(COIN_STAT_OBJ);
                    break;
                    case ObjectCostume.EMERALD_TYPE:
                        player.addToStats(EMERALD_STAT_OBJ);
                    break;
                    default:
                }
            }
        }
    }

}