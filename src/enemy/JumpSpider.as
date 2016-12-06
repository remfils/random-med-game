package src.enemy {


    public class JumpSpider extends Enemy {
        
        public function JumpSpider() {
            super();
            
            this._actions[ACTION_DEATH_ID].end_animation_frame = 37;
        }
        
    }

}