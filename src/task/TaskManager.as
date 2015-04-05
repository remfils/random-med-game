package src.task {
    import flash.events.Event;
    import src.Game;
    import src.levels.Room;
    import src.objects.TaskObject;
    import src.util.AbstractManager;
    import src.util.ComboManager;
	/**
     * ...
     * @author vlad
     */
    public class TaskManager extends AbstractManager {
        public static const ENEMY_TYPE:String = "enemies";
        public static const LEVER_TYPE:String = "levers";
        
        public var events:Array;
        private var tasks:Array;
        
        public function TaskManager() {
            tasks = new Array();
            events = new Array();
            Task.taskManager = this;
        }
        
        public function addLeverTaskToRoom(room:Room, id:uint, color:uint=0 ):void {
            var task:Task = new Task(id);
            task.color = color;
            task.assignToRoom(room);
            tasks.push(task);
        }
        
        public function addEnemyTaskToRoom(room:Room, id:uint, enemyCount:uint, color:uint=0 ):void {
            var task:Task = new KillEnemyTask(id, enemyCount);
            task.color = color;
            task.assignToRoom(room);
            tasks.push(task);
        }
        
        public function guessEventListener(e:Event):void {
            var answer:TaskObject = e.target as TaskObject;
            var i:int = tasks.length;
            
            e.stopImmediatePropagation();
            
            while(i--) {
                if ( tasks[i].id == answer.taskId ) {
                    var task:Task = tasks[i];
                    
                    if ( task.makeGuess(answer) ) {
                        tasks.splice(i, 1);
                        
                        game._player.addToStats({"EXP": task.getExperience()});
                        
                        if ( task.room ) {
                            task.room.assignTask( getNextTaskForRoom(task.room) );
                        }
                    }
                    break;
                }
            }
        }
        
        private function getNextTaskForRoom(room:Room):Task {
            for each (var task:Task in tasks ) {
                if ( task.room == room ) return task;
            }
            return null;
        }
        
        public function findTaskById(id:int):Boolean {
            var i:int = tasks.length;
            while ( i-- ) {
                if ( tasks[i].id == id ) {
                    return true;
                }
            }
            return false;
        }
        
        public function getTaskColor(id:int):uint {
            var i:int = tasks.length;
            while ( i-- ) {
                if ( tasks[i].id == id ) return tasks[i].color;
            }
            return 0;
        }
        
        public function addResult(taskResultObj:TaskResultObject):void {
            events.push(taskResultObj);
        }
        
        public function eventsToXML():XML {
            var resultXML:XML = <EventData></EventData>;
            var i:int = events.length;
            var taskObj:TaskResultObject;
            
            for ( i = 0; i < events.length; i++ ) {
                taskObj = TaskResultObject(events[i]);
                resultXML.*[i] =
                    <event>
                        <task_id>{taskObj.task_id}</task_id>
                        <result>{taskObj.is_task_complete?1:0}</result>
                        <creation_date>{Math.round(taskObj.creation_date.valueOf()/1000)}</creation_date>
                    </event>
            }
            
            return resultXML;
        }
        
    }

}