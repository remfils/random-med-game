package src.task {


    public class Record {
        public static const LEVEL_START_TYPE:int = 1; // икрок начал уровень. dataA = level_id
        public static const LEVEL_END_TYPE:int = 2; // игрок закончил уровень. dataA = level_id
        public static const ROOM_ENTER_TYPE:int = 3; // игрок вышел из комнаты. dataA = x, dataB = y
        public static const LEVER_PULL_TYPE:int = 4; // игрок потянул за рычаг. dataA = task_id, dataB = object_id, result
        public static const ENEMY_KILL_TYPE:int = 5; // игрок убил врага. dataA = task_id, dataB = enemy_id, result
        public static const ITEM_PICKUP_TYPE:int = 6; // игрок подобрал предмет. dataA = object_id
        public static const PLAYERLOOSE_HEALTH_TYPE:int = 7; // игрок получил урон. dataA = enemy_id??, dataB = dmg, result = cur_health
        public static const PLAYERLOOSE_MANA_TYPE:int = 8; // игрок потратил ману. dataA = spell_id, dataB = cost, result = cur_mana
        public static const PLAYERGET_TITUL_TYPE:int = 9; // игрок получил титул. dataA = titul_id
        public static const PLAYERGET_LEVEL_TYPE:int = 10; // игрок получил новый уровень. dataA = level_num
        public static const PLAYER_DEAD_TYPE:int = 11; // игрк умер.
        public static const GAMEMENU_ENTER_TYPE:int = 12; // игрок поставил игру на паузу.
        public static const GAMEMENU_LEAVE_TYPE:int = 13; // игрок возобнил игру после паузы.
        public static const KEY_USED_TYPE:int = 14; // использовал ключ. dataA = task_id, dataB = object_id, result
        
        public var date:Date;
        public var type_id:int;
        public var dataA:int = 0;
        public var dataB:int = 0;
        public var result:Boolean = false;
        
        public function Record(type_id_:int = ROOM_ENTER_TYPE, dataA_:int = 0, dataB_:int = 0, result_:Boolean = false ) {
            type_id = type_id_;
            dataA = dataA_;
            dataB = dataB_;
            result = result_;
            date = new Date();
        }
        
        public function toXML():XML {
            return <event type_id={type_id} result={result?1:0} date={Math.round(date.valueOf()/1000)} dataA={dataA} dataB={dataB} />;
        }
    }

}