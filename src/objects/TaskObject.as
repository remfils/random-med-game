package src.objects {
    import Box2D.Dynamics.b2World;
    import Box2D.Dynamics.b2Body;
    import src.interfaces.Updatable;
    import src.util.Collider;
	/**
     * ...
     * @author vlad
     */
    public class TaskObject extends AbstractObject {
        public var id:uint = 0;
        public var taskId:uint = 0;
        
        protected var active = true;
        
        public function TaskObject() {
        }
        
        public function positiveOutcome():void {
            
        }
        
        public function negativeOutcome():void {
            
        }
        
        public function update():void {}
        
        public function isActive():Boolean {
            return active;
        }
        
    }

}