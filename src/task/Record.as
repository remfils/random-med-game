package src.task {


    public class Record {
        public static const LEVEL_START_TYPE:int = 1;
        public static const LEVEL_END_TYPE:int = 2;
        public static const ROOM_ENTER_TYPE:int = 3;
        public static const LEVER_PULL_TYPE:int = 4;
        public static const ENEMY_KILL_TYPE:int = 5;
        public static const ITEM_PICKUP_TYPE:int = 6;
        public static const PLAYERLOOSE_HEALTH_TYPE:int = 7;
        public static const PLAYERLOOSE_MANA_TYPE:int = 8;
        public static const PLAYERGET_TITUL_TYPE:int = 9;
        public static const PLAYERGET_LEVEL_TYPE:int = 10;
        public static const PLAYER_DEAD_TYPE:int = 11;
        public static const GAMEMENU_ENTER_TYPE:int = 12;
        public static const GAMEMENU_LEAVE_TYPE:int = 13;
        public static const KEY_USED_TYPE:int = 14;
        
        public var date:Date;
        public var type_id:int;
        public var id:int = 0;
        public var task_complete:Boolean = false;
        
        public function Record() {
            date = new Date();
        }
        
        public function toXML():XML {
            return <event type_id={type_id} id={id} result={task_complete?1:0} date={Math.round(date.valueOf()/1000)} />;
        }
    }

}