package src.objects {
    import Box2D.Dynamics.b2World;
    import fl.motion.Color;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import src.costumes.ActiveObjectCostume;
    import src.costumes.DecorCostume;
    import src.events.SubmitTaskEvent;
    import src.Game;
    import src.interfaces.ExtrudeObject;
    import src.interfaces.Updatable;
    import src.Main;
    import flash.events.Event;
    import src.task.TaskEvent;
    import src.util.Collider;
    import Box2D.Dynamics.b2Body;
    import src.util.ComboManager;

    public class TaskLever extends TaskObject {
        public static const LEVER_TYPE:String = "Lever";
        public static const OPEN_STATE:String = "_open";
        public static const BREAK_STATE:String = "_break";
        
        private static const COLOR_OBJ_DISSAPEAR_FRAME:int = 8;
        
        private var state:String = "";
        
        private var testFun:Function; // D!
        private var frame_counter:int = 0;
        
        public function TaskLever ():void {
            super();
            costume.setType(LEVER_TYPE);
            costume.setState();
        }
        
        override public function positiveOutcome():void {
            costume.setState(OPEN_STATE);
            state = OPEN_STATE;
        }
        
        override public function negativeOutcome():void {
            costume.setState(BREAK_STATE);
            state = BREAK_STATE;
        }
        
        // D!
        override public function setTint(color:uint):void {
            var col:Color = new Color();
            col.setTint(color, 0.5);
            var tintObject:DisplayObject = costume.getChildByName("tintObject_mc");
            tintObject.transform.colorTransform = col;
        }
        
        override public function createColorObject(color:String):void {
            super.createColorObject(color);
            color_object.x = -16;
            color_object.y = 9;
        }
        
        // change to better collider support
        override public function update():void {
            if ( game.ACTION_PRESSED && is_active ) {
                if ( active_area.hitTestObject(game.player.collider) ) {
                    submitAnswer();
                    is_active = false;
                }
                /*if ( _activeArea.checkObjectCollision( game.player.getColliderBad()) && game.player.ACTION_PRESSED ) {
                    dispatchEvent(new Event(Game.GUESS_EVENT));
                }*/
            }
        }
        
        override public function remove():void {
            costume.setAnimatedState(state + REMOVE_STATE);
            
            if ( ! color_object ) return;
            
            var flag_smoke:DecorCostume = new DecorCostume();
            flag_smoke.x = color_object.x;
            flag_smoke.y = color_object.y;
            costume.addChild(flag_smoke);
            flag_smoke.setAnimatedState(DecorCostume.TASK_FLAG_SMOKE_TYPE);
            
            frame_counter = 0;
            flag_smoke.addEventListener(Event.ENTER_FRAME, smokeFrameListener);
            
            destroy();
        }
        
        private function smokeFrameListener(e:Event):void {
            trace(frame_counter);
            if ( frame_counter++ >= COLOR_OBJ_DISSAPEAR_FRAME ) {
                costume.removeChild(color_object);
                var target:DecorCostume = DecorCostume(e.target);
                target.removeEventListener(Event.ENTER_FRAME, smokeFrameListener);
                
                game.deleteManager.add(target);
            }
        }
    }

}