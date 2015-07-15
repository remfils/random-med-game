package src.task {
    import src.enemy.Enemy;
    import src.objects.TaskObject;
    import src.util.ComboManager;
    public class KillEnemyTask extends Task {
        
        public function KillEnemyTask() {
            super();
        }
        
        override public function checkAnswer(task_object:TaskObject):Boolean {
            if ( task_object.task_id == id ) answer ++;
            trace("answer checked!");
            return !room.checkEnemiesForTask(id);
        }
        
        override public function getReward():Number {
            return 2 * answer;
        }
        
    }

}