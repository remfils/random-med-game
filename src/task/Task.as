package src.task {
    
    import src.levels.Room;
    import src.objects.TaskObject;
    import src.util.AbstractManager;
    import src.util.ChangePlayerStatObject;
    import src.util.ComboManager;
    import src.util.Random;
    import src.util.Recorder;
    
    public class Task extends AbstractManager{
        public var reward:ChangePlayerStatObject = new ChangePlayerStatObject(ChangePlayerStatObject.EXP_STAT, 10);
        
        public static var taskManager:TaskManager; // D!
        
        public var id:int;
        public var type:int;
        public var is_complete:Boolean = false;
        public var external:Boolean = false;
        public var guessCount:Number = 0;
        public var room:Room;
        public var color:uint = 0;
        var answer:uint;
        
        static private var combo:Number = 1;
        
        public var end_time:Date;// D!

        public function Task(id_:uint=0, type_id_:int=0) {
            answer = Random.getOneFromThree();
            id = id_;
            type = type_id_;
        }
        
        public function get MULT():Number {
            return ( combo + 1 ) / 2 * combo; 
        }
        
        // D!
        public function assignToRoom(room:Room):void {
            this.room = room;
            if ( room && !room.hasTask() ) room.assignTask(this);
        }
        
        public function getAnswer():int {
            return answer;
        }
        
        public function checkAnswer(task_object:TaskObject):Boolean {
            var res:Boolean = answer == task_object.id;
            
            if ( !res && combo > 1 )
                game.player.displayMessage("комбо сбито");
            
            guessCount ++;
            return res;
        }
        
        // D!
        public function makeGuess(taskObject:TaskObject):Boolean {
            if ( taskObject ) {
                guessCount ++;
                
                if ( taskObject.id == answer ) {
                    taskObject.positiveOutcome();
                    is_complete = true;
                }
                else {
                    taskObject.negativeOutcome();
                    is_complete = false;
                }
                // Recorder.recordTaskGuess(this);
            }
            return is_complete;
        }
        
        // D!
        protected function saveTaskResult(result:Boolean):Boolean {
            var taskResultObject:TaskResultObject = new TaskResultObject();
            
            taskResultObject.task_id = id;
            
            taskResultObject.is_task_complete = result;
            taskManager.addResult(taskResultObject);
            
            return result;
        }
        
        public function readXML(taskXML:XML):void {
            type = taskXML.@type;
            id = taskXML.@id;
            external = taskXML.hasOwnProperty("@external");
        }
        
        public function complete():void {
            is_complete = true;
            if (external) room.unlockDoorsWithTaskID(id);
            
            TaskManager.failed_guess_count += guessCount - 1;
            TaskManager.total_guess_count += 3;
            
            generateReward();
        }
        
        protected function generateReward():void {
            var total:Number = 0;
            var prev_combo:int = combo;
            
            switch ( guessCount ) {
                case 1:
                    total += 5;
                    incMultiplier();
                    break;
                case 2:
                    total += 1;
                default:
                    resetMultiplier();
            }
            
            total *= prev_combo;
            reward.delta = total;
        }
        
        public function incMultiplier():void {
            if ( combo != 1 )
                game.player.displayMessage( "комбо x" + combo );
            
            combo ++;
            
            if ( combo > 4 )
                combo = 4;
        }
        
        public function resetMultiplier():void {
            combo = 1;
        }

    }
    
}
