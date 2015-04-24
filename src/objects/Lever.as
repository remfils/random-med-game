package src.objects {
    import Box2D.Dynamics.b2World;
    import fl.motion.Color;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import src.interfaces.ExtrudeObject;
    import src.interfaces.Updatable;
    import src.Main;
    import flash.events.Event;
    import src.util.Collider;
    import Box2D.Dynamics.b2Body;
    import src.util.ComboManager;

    public class Lever extends TaskObject implements ExtrudeObject {
        private var _activeArea:Collider;
        
        private var testFun:Function;

        public function Lever ():void {
            super();
            _activeArea = costume.getChildByName( "activeArea" ) as Collider;
        }
        
        public function getActiveArea ():Collider {
            return _activeArea;
        }
        
        override public function positiveOutcome():void {
            //gotoAndPlay("open");
            _activeArea.lock();
        }
        
        override public function negativeOutcome():void {
            //gotoAndPlay("break");
            _activeArea.lock();
        }
        
        override public function setTint(color:uint):void {
            var col:Color = new Color();
            col.setTint(color, 0.5);
            var tintObject:DisplayObject = costume.getChildByName("tintObject_mc");
            tintObject.transform.colorTransform = col;
        }
        
        // change to better collider support
        override public function update():void {
            if ( active ) {
                /*if ( _activeArea.checkObjectCollision( game.player.getColliderBad()) && game.player.ACTION_PRESSED ) {
                    dispatchEvent(new Event("GUESS_EVENT"));
                }*/
            }
        }
        
        override public function isActive():Boolean {
            return this.active;
        }
    }

}