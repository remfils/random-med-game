package src.util {
    import src.task.Record;
    import src.task.Task;


    public class Recorder extends AbstractManager {
        
        private static var _recordings:Vector.<Record> = new Vector.<Record>();
        
        public function Recorder() {
            super();
        }
        
        public static function recordTask(task:Task):void {
            newRecord(task.type, task.id, task.is_complete);
        }
        
        public static function newRecord(type_id_:int = 0, id_:int = 0, task_complete_:Boolean = false):void {
            var rec:Record = new Record();
            rec.type_id = type_id_;
            rec.id = id_;
            rec.task_complete = task_complete_;
            
            add(rec);
        }
        
        public static function add(record:Record):void {
            _recordings.push(record);
        }
        
    }

}