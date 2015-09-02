package src.util {


    public class ChangePlayerStatObject {
        
        public static const MAX_HEALTH_STAT:String = "MAX_HEALTH";
        public static const MAX_MANA_STAT:String = "MAX_MANA";
        public static const HEALTH_STAT:String = "HEALTH";
        public static const MANA_STAT:String = "MANA";
        public static const EXP_STAT:String = "EXP";
        public static const MONEY_STAT:String = "MONEY";
        public static const MAX_SPELLS_STAT:String = "MAX_SPELLS";
        public static const MAX_ITEMS_STAT:String = "MAX_ITEMS";
        
        public var stat_name:String;
        public var delta:int;
        public var id:int;
        public var is_enemy:Boolean;
        
        public function ChangePlayerStatObject(stat_name_:String, delta_:int=0, id_:int=1, is_enemy_:Boolean=false) {
            stat_name = stat_name_;
            delta = delta_;
            id = id_;
            is_enemy = is_enemy_;
        }
        
        public function destroy():void {
            stat_name = null;
            delta = null;
            id = null;
            is_enemy = null;
        }
    }

}