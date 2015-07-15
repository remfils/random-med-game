package src.task {
    import flash.events.Event;
    import src.events.SubmitTaskEvent;
    import src.Game;
    import src.levels.Room;
    import src.objects.TaskObject;
    import src.util.AbstractManager;
    import src.util.ComboManager;
    import src.util.Recorder;

    public class TaskManager extends AbstractManager {
        public static const ENEMY_TYPE:String = "enemies";
        public static const LEVER_TYPE:String = "levers";
        
        public var events:Array;// D!
        private var tasks:Vector.<Task>;
        
        public function TaskManager() {
            tasks = new Vector.<Task>();
            events = new Array();
            Task.taskManager = this;
        }
        
        public function assignTaskToRoom(task:Task, room:Room):void {
            task.room = room;
            room.assignTask(task);
            tasks.push(task);
        }
        
        // D!
        public function addLeverTaskToRoom(room:Room, id:uint, color:uint=0 ):void {
            var task:Task = new Task(id);
            task.color = color;
            task.room = room;
            room.assignTask(task);
            tasks.push(task);
        }
        
        // D!
        public function addEnemyTaskToRoom(room:Room, id:uint, enemyCount:uint, color:uint=0 ):void {
            var task:Task = new KillEnemyTask();
            task.color = color;
            task.assignToRoom(room);
            tasks.push(task);
        }
        // D!
        public function guessEventListener(e:Event):void {
            var answer:TaskObject = e.target as TaskObject;
            var i:int = tasks.length;
            
            e.stopImmediatePropagation();
            
            while(i--) {
                if ( tasks[i].id == answer.task_id ) {
                    var task:Task = tasks[i];
                    
                    if ( task.makeGuess(answer) ) {
                        tasks.splice(i, 1);
                        
                        game.player.addToStats({"EXP": task.getReward()});
                        
                        if ( task.room ) {
                            //task.room.assignTask( getNextTaskForRoom(task.room) );
                        }
                    }
                    break;
                }
            }
        }
        
        public function guessEventListener2(e:SubmitTaskEvent):void {
            var task:Task;
            var task_object:TaskObject = e.task_object;
            var task_index:int = getTaskIndexById(e.task_id);
            
            if ( task_index == -1 ) return;
            
            task = tasks[task_index];
            
            if (task) {
                if ( task.checkAnswer(task_object) ) {
                    task_object.positiveOutcome();
                    task.complete();
                    tasks.splice(task_index, 1);
                    
                    var room:Room = task.room;
                    
                    var tmpTask:Task = getTaskForRoom(room);
                    
                    if (tmpTask && !tmpTask.external) {
                        room.currentTask = tmpTask;
                    }
                    else {
                        room.currentTask = null;
                        room.unlock();
                        room.createDrop();
                    }
                }
                else {
                    task_object.negativeOutcome();
                }
                Recorder.recordTask(task);
            }
        }
        
        public function getTaskIndexById(task_id:int):int {
            var i:int = tasks.length;
            while (i--) {
                if (tasks[i].id == task_id) {
                    return i;
                }
            }
            return -1;
        }
        
        public function getTaskForRoom(room:Room):Task {
            var tmpTask:Task;
            for each (tmpTask in tasks) {
                if (tmpTask.room == room) return tmpTask;
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