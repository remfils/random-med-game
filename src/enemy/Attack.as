package src.enemy {


    public class Attack {
        
        public var end_animation_frame:int = 0;
        public var init_function:Function = null;
        public var update_function:Function = null;
        public var end_function:Function = null;
        
        public function Attack(end_animation_frame:int, init_function:Function, update_function:Function=null, end_function:Function=null) {
            this.end_animation_frame = end_animation_frame;
            this.init_function = init_function;
            this.update_function = update_function;
            this.end_function = end_function;
        }
        
    }

}