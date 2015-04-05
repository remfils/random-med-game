package src.task {
    
    import src.levels.Room;
    import src.objects.TaskObject;
    import src.util.ComboManager;
    import src.util.Random;
    
    public class Task {
        public static var taskManager:TaskManager;
        
        public var guessCount:Number = 0;
        public var room:Room;
        public var id:uint;
        public var color:uint = 0;
        var answer:uint;

        public function Task(id:uint) {
            answer = Random.getOneFromThree();
            this.id = id;
        }
        
        public function assignToRoom(room:Room):void {
            this.room = room;
            if ( room && !room.hasTask() ) room.assignTask(this);
        }
        
        public function getAnswer():int {
            return answer;
        }
        
        public function makeGuess(taskObject:TaskObject):Boolean {
            guessCount ++;
            
            if ( taskObject ) {
                if ( taskObject.id == answer ) {
                    taskObject.positiveOutcome();
                    return saveTaskResult(true);
                }
                else {
                    taskObject.negativeOutcome();
                    
                }
            }
            
            return saveTaskResult(false);
        }
        
        protected function saveTaskResult(result:Boolean):Boolean {
            var taskResultObject:TaskResultObject = new TaskResultObject();
            
            taskResultObject.task_id = id;
            
            taskResultObject.is_task_complete = result;
            taskManager.addResult(taskResultObject);
            
            return result;
        }
        
        public function getExperience():Number {
            var total:Number = 0;
            switch ( guessCount ) {
                case 1:
                    total += 5;
                    ComboManager.addCombo(ComboManager.LEVER_COMBO);
                break;
                case 2:
                    total += 1;
                default:
                    ComboManager.clearCombo(ComboManager.LEVER_COMBO);
            }
            
            total *= ComboManager.getCombo(ComboManager.LEVER_COMBO);
            
            return total;
        }

    }
    
}
