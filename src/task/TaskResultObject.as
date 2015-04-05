package src.task {
    import src.levels.Room;
	/**
     * ...
     * @author vlad
     */
    public class TaskResultObject {
        public var creation_date:Date;
        public var is_task_complete:Boolean;
        public var task_id:int;
        
        public function TaskResultObject() {
            creation_date = new Date();
        }
        
    }

}