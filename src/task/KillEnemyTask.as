package src.task {
    import src.enemy.Enemy;
    import src.objects.TaskObject;
    import src.util.ComboManager;
    public class KillEnemyTask extends Task {
        private var enemyCount:int = 0;
        private var enemiesTotal:int = 0;
        
        public function KillEnemyTask(id:uint, enemyCount:int) {
            super(id);
            this.enemyCount = enemyCount;
            this.enemiesTotal = enemyCount;
        }
        
        override public function makeGuess(taskObject:TaskObject):Boolean {
            enemyCount --;
            
            ComboManager.addCombo(ComboManager.ENEMY_COMBO);
            
            if ( enemyCount == 0 ) return saveTaskResult(true);
            else return saveTaskResult(false);
        }
        
        override public function getExperience():Number {
            return 2 * enemiesTotal;
        }
        
    }

}