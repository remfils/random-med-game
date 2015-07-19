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
        
        private var testFun:Function; // D!
        
        public function TaskLever ():void {
            super();
            costume.setType(LEVER_TYPE);
            costume.setState();
        }
        
        override public function positiveOutcome():void {
            costume.setState(OPEN_STATE);
        }
        
        override public function negativeOutcome():void {
            costume.setState(BREAK_STATE);
        }
        
        override public function setTint(color:uint):void {
            var col:Color = new Color();
            col.setTint(color, 0.5);
            var tintObject:DisplayObject = costume.getChildByName("tintObject_mc");
            tintObject.transform.colorTransform = col;
        }
        
        override public function createColorObject(color:String):DecorCostume {
            var costume:DecorCostume = super.createColorObject(color);
            costume.x = -16;
            costume.y = 9;
            return costume;
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
    }

}