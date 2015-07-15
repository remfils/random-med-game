package src.task {


    public class Record {
        
        public static const ENTER_ROOM_TYPE:int = 1;
        public static const LEAVE_ROOM_TYPE:int = 2;
        public static const LEVER_PULL_TYPE:int = 3;
        public static const KEY_USED_TYPE:int = 4;
        public static const ENEMY_KILL_TYPE:int = 5;
        
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