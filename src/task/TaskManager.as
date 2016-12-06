package src.task {
    import fl.motion.Keyframe;
    import flash.events.Event;
    import src.costumes.Costume;
    import src.costumes.ObjectCostume;
    import src.events.SubmitTaskEvent;
    import src.Game;
    import src.levels.Room;
    import src.objects.TaskDoorLock;
    import src.objects.TaskExplosiveLever;
    import src.objects.TaskKey;
    import src.objects.TaskLever;
    import src.objects.TaskObject;
    import src.util.AbstractManager;
    import src.util.ComboManager;
    import src.util.MagicBag;
    import src.util.Output;
    import src.util.Recorder;

    public class TaskManager extends AbstractManager {
        public static const ENEMY_TYPE:String = "enemies";
        public static const LEVER_TYPE:String = "levers";
        
        public static const THREE_STARS_THRESHOLD:Number = 0.52;
        public static const TWO_STARS_THRESHOLD:Number = 0.8;
        
        public static var failed_guess_count:int = 0;
        public static var total_guess_count:int = 0;
        
        public var events:Array;// D!
        private var tasks:Vector.<Task>;
        private var task_objects:Vector.<TaskObject>
        
        public function TaskManager() {
            tasks = new Vector.<Task>();
            task_objects = new Vector.<TaskObject>();
            events = new Array();
            Task.taskManager = this;
        }
        
        public function assignTaskToRoom(task:Task, room:Room):void {
            task.room = room;
            if ( !task.external ) room.assignTask(task);
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
                        
                        //game.player.addToStats({"EXP": task.getReward()});
                        
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
                    game.player.changeStat(task.reward);
                    
                    replaceTaskObjectsWithGoods(task.id, task.guessCount);
                    
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
                Recorder.recordTaskGuess(task, task_object.getID());
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
        
        // D!
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
        
        public function addTaskObject(obj:TaskObject):void {
            if ( obj is TaskDoorLock) return;
            task_objects.push(obj);
        }
        
        public function removeTaskObject(obj:TaskObject):void {
            var i:int = task_objects.length;
            while ( i-- ) {
                if ( task_objects[i] == obj ) {
                    task_objects.splice(i, 1);
                    break;
                }
            }
        }
        
        public function replaceTaskObjectsWithGoods(task_id:int, guess_count:int):void {
            var i:int = task_objects.length;
            var task_object:TaskObject, obj:ObjectCostume;
            var magic_bag:MagicBag;
            var bag_costume:Costume;
            
            while ( i-- ) {
                if ( task_objects[i].task_id == task_id ) {
                    task_object = task_objects[i];
                    task_object.remove();
                    
                    if ( guess_count <= 2 ) {
                        magic_bag = new MagicBag();
                        magic_bag.setType(ObjectCostume.COIN_TYPE);
                    }
                    
                    if ( guess_count == 1 ) {
                        if ( (task_object is TaskLever) && TaskLever(task_object).state == TaskLever.OPEN_STATE ) {
                            magic_bag.setType(ObjectCostume.EMERALD_TYPE);
                        }
                    }
                    
                    if ( magic_bag ) {
                        bag_costume = magic_bag.open();
                        bag_costume.x = task_object.x;
                        bag_costume.y = task_object.y;
                        game.cRoom.gameObjectPanel.addChild(bag_costume);
                        game.cRoom.add(magic_bag);
                    }
                    
                    task_objects.splice(i, 1);
                    magic_bag = null;
                }
            }
        }
        
        public function gradeLevel():Number {
            var res:int = 1;
            
            if ( game.secret_room_found ) res ++;
            
            if ( total_guess_count ) {
                if ( Number(failed_guess_count) / total_guess_count < 0.6 ) res ++;
            }
            else {
                res ++;
            }
            
            return res;
        }
    }

}