package src.util {
    import flash.geom.Point;
    import src.task.Record;
    import src.task.Task;


    public class Recorder extends AbstractManager {
        public static var server:Server;
        
        private static var _recordings:Vector.<Record> = new Vector.<Record>();
        
        public function Recorder() {
            super();
        }
        
        public static function recordTaskGuess(task:Task, task_obj_id:int = 0):void {
            add(new Record(task.type, task.id, task_obj_id, int(task.is_complete)));
            // newRecord(task.type, task.id, task.is_complete);
        }
        
        public static function recordPlayerDmg(from_id:int, dmg:int):void {
            if ( dmg ) {
                add(new Record(Record.PLAYERLOOSE_HEALTH_TYPE, from_id, dmg, game.player.HEALTH));
            }
        }
        
        public static function recordEnterRoom(room_point:Point):void {
            add(new Record(Record.ROOM_ENTER_TYPE, room_point.x, room_point.y));
        }
        
        public static function recordPickUpItem(item_id:int):void {
            add(new Record(Record.ITEM_PICKUP_TYPE, item_id));
        }
        
        public static function recordSecretRoomFound():void {
            add(new Record(Record.SECRET_ROOM_UNLOCKED));
        }
        
        public static function recordManaUse(spell_id:Number, mana_cost:Number, mana_left:Number ):void {
            add(new Record(Record.PLAYERLOOSE_MANA_TYPE, spell_id, mana_cost, mana_left));
        }
        
        /*public static function newRecord(type_id_:int = 0, id_:int = 0, result:Boolean = false):void {
            var rec:Record = new Record();
            rec.type_id = type_id_;
            rec.id = id_;
            rec.result = result;
            
            add(rec);
        }*/
        
        public static function add(record:Record):void {
            _recordings.push(record);
        }
        
        public static function send():void {
            var record:Record;
            var resultXML:XML = <events></events>;
            var i:int = 0;
            
            if ( !_recordings.length ) return;
            
            while ( _recordings.length ) {
                record = _recordings.pop();
                resultXML.*[i++] = record.toXML();
            }
            trace(resultXML);
            
            server.sendRecordedData(resultXML);
        }
    }

}