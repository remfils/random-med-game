package src.util {
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import src.costumes.Costume;
    import src.costumes.ObjectCostume;
    import src.Game;
    import src.Ids;
    import src.interfaces.Update;
    import src.objects.AbstractObject;
    import src.Player;


    public class MagicBag extends AbstractObject implements Update {
        public static const MAGIC_BAG_TYPE:String = "MagicBag";
        
        public static const SMALL_HP_STAT_OBJ:ChangePlayerStatObject = new ChangePlayerStatObject(ChangePlayerStatObject.HEALTH_STAT, 2, Ids.ITEM_POTION_HEALTH_ID);
        public static const SMALL_MP_STAT_OBJ:ChangePlayerStatObject = new ChangePlayerStatObject(ChangePlayerStatObject.MANA_STAT, 2, Ids.ITEM_POTION_MANA_ID);
        public static const COIN_STAT_OBJ:ChangePlayerStatObject = new ChangePlayerStatObject(ChangePlayerStatObject.MONEY_STAT, 1, Ids.ITEM_COIN_ID);
        public static const EMERALD_STAT_OBJ:ChangePlayerStatObject = new ChangePlayerStatObject(ChangePlayerStatObject.MONEY_STAT, 10, Ids.ITEM_EMERALD_ID);
        
        public static const DROP_STATE:String = "_drop";
        public static const PICKUP_STATE:String = "_pickup";
        
        public static const MAP_PICKUP_DELLAY:Number = 700;
        
        public var is_empty:Boolean = true;
        public var not_active:Boolean = true;
        
        //public var costume:ObjectCostume;
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
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            /*var req:CreateBodyRequest = super.requestBodyAt(world);
            
            if ( costume ) {
                if ( costume.type != ObjectCostume.EXIT_TYPE ) {
                    req.setAsDynamicBody();
                }
                else {
                    req.setAsStaticSensor();
                }
            }
            
            return req;*/
            return null;
        }
        
        public function readDropXML(objectsXML:XMLList):void {
            var randomP:Number = Math.random();
            var p:Number = 0;
            
            for each (var item:XML in objectsXML.*) {
                p += Number(item.@p) || 1;
                if ( p > randomP ) {
                    setType(item.name());
                    break;
                }
            }
        }
        
        override public function readXMLParams(paramsXML:XML):void {
            super.readXMLParams(paramsXML);
            
            setType(paramsXML.@type);
            
            costume.setState(DROP_STATE);
            collider = costume.getCollider();
            
            not_active = false;
        }
        
        public function open():Costume {
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
                var pickup_dellay:Number = 7 / Game.FRAMES_PER_MILLISECOND;;
                
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
                        
                        var timer:Timer = ObjectPool.getTimer(pickup_dellay);
                        timer.addEventListener(TimerEvent.TIMER_COMPLETE, dellayedDestoyListener);
                    }
                }
            }
        }
        
        private function dellayedDestoyListener(e:TimerEvent):void {
            var timer:Timer = Timer(e.target);
            timer.removeEventListener(TimerEvent.TIMER_COMPLETE, dellayedDestoyListener);
            destroy();
        }
    }

}