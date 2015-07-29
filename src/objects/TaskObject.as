package src.objects {
    import Box2D.Dynamics.b2World;
    import Box2D.Dynamics.b2Body;
    import flash.display.DisplayObject;
    import src.costumes.ActiveObjectCostume;
    import src.costumes.DecorCostume;
    import src.events.SubmitTaskEvent;
    import src.interfaces.Updatable;
    import src.interfaces.Update;
    import src.util.Collider;
    
    public class TaskObject extends AbstractObject implements Update {
        public static const RED_TASK_COLOR_STATE:String = "_red";
        public static const GREEN_TASK_COLOR_STATE:String = "_green";
        public static const PURPLE_TASK_COLOR_STATE:String = "_purple";
        public static const INDIGO_TASK_COLOR_STATE:String = "_indigo";
        
        public static const REMOVE_STATE:String = "_remove";
        
        protected static var FLAG_POSITION_X:int = 0;
        static var FLAG_POSITION_Y:int = 0;
        
        public var id:uint = 1;
        public var task_id:uint = 0;
        
        public var is_active = true;
        public var active_area:DisplayObject;
        public var color_object:DecorCostume;
        
        public function TaskObject() {
            super();
            costume = new ActiveObjectCostume();
        }
        
        public function getActiveArea():DisplayObject {
            return ActiveObjectCostume(costume).getActiveArea();
        }
        
        public function submitAnswer():void {
            costume.dispatchEvent(new SubmitTaskEvent(task_id, this));
        }
        
        public function positiveOutcome():void {}
        
        public function negativeOutcome():void {}
        
        public function update():void {}
        
        public function isActive():Boolean {
            return is_active;
        }
        
        public function activate():void {
            is_active = true;
            if (body) body.SetActive(is_active);
        }
        
        public function deactivate():void {
            is_active = false;
            if (body) body.SetActive(is_active);
        }
        
        override public function readXMLParams(paramsXML:XML):void {
            super.readXMLParams(paramsXML);
            
            task_id = paramsXML.@task_id;
            
            if ( paramsXML.@id ) {
                id = paramsXML.@id;
            }
            
            var color:String = paramsXML.@color;
            if ( color ) createColorObject(color);
            
            if ( costume is ActiveObjectCostume ) active_area = ActiveObjectCostume(costume).getActiveArea();
        }
        
        public function createColorObject(color:String):void {
            color_object = new DecorCostume();
            color_object.setType(DecorCostume.TASK_FLAG_TYPE);
            color_object.setState("_" + color);
            color_object.x = 0;
            color_object.y = 0;
            costume.addChild(color_object);
        }
        
        public function show():void {
            costume.visible = true;
        }
        
        public function hide():void {
            costume.visible = false;
        }
        
        public function remove():void {
            costume.setAnimatedState(REMOVE_STATE);
            destroy();
        }
        
        override public function destroy():void {
            super.destroy();
            game.deleteManager.add(costume);
            game.deleteManager.add(body);
            game.cRoom.remove(this);
        }
    }

}