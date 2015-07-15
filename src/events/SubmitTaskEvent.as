package src.events {
    import flash.events.Event;
    import src.objects.TaskObject;

    public class SubmitTaskEvent extends Event {
        public static const GUESS_EVENT:String = "guess_e";
        
        public static const LEVER_TYPE:int = 1;
        public static const ENEMY_TYPE:int = 2;
        public static const KEY_TYPE:int = 3;
        
        public var task_id:int;
        public var task_object:TaskObject;
        
        public function SubmitTaskEvent(task_id_:int, task_object_:TaskObject) {
            super(GUESS_EVENT, false, false);
            task_id = task_id_;
            task_object = task_object_;
        }
        
    }

}