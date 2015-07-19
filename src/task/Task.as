﻿package src.task {
    
    import src.levels.Room;
    import src.objects.TaskObject;
    import src.util.ComboManager;
    import src.util.Random;
    import src.util.Recorder;
    
    public class Task {
        
        public static var taskManager:TaskManager; // D!
        
        public var id:int;
        public var type:int;
        public var is_complete:Boolean = false;
        public var external:Boolean = false;
        public var guessCount:Number = 0;
        public var room:Room;
        public var color:uint = 0;
        var answer:uint;
        
        public var end_time:Date;// D!

        public function Task(id_:uint=0, type_id_:int=0) {
            answer = Random.getOneFromThree();
            id = id_;
            type = type_id_;
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
            trace(answer, task_object.id);
            return answer == task_object.id;
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
                Recorder.recordTask(this);
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
        
        public function getReward():Number {
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
        
        public function readXML(taskXML:XML):void {
            type = taskXML.@type;
            id = taskXML.@id;
            external = taskXML.hasOwnProperty("@external");
        }
        
        public function complete():void {
            is_complete = true;
            if (external) room.unlockDoorsWithTaskID(id);
        }

    }
    
}
