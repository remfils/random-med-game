package src.task {
    import src.enemy.Enemy;
    import src.objects.TaskObject;
    import src.util.ComboManager;
    public class KillEnemyTask extends Task {
        
        public function KillEnemyTask() {
            super();
            answer = 0;
        }
        
        override public function checkAnswer(task_object:TaskObject):Boolean {
            if ( task_object.task_id == id ) {
                answer += Enemy(task_object).exp;
            }
            return !room.checkEnemiesForTask(id);
        }
        
        override protected function generateReward():void {
            reward.delta = answer;
        }
        
    }

}