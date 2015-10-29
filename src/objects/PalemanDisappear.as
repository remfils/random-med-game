package src.objects {
    import Box2D.Dynamics.b2World;
    import flash.events.Event;
    import src.costumes.DecorCostume;
    import src.interfaces.Init;
    import src.util.CreateBodyRequest;


    public class PalemanDisappear extends AbstractObject implements Init {
        
        private var _frame_counter:int = 0;
        
        public function PalemanDisappear() {
            super();
            
            costume = new DecorCostume();
            costume.setType(DecorCostume.PALEMAN_TYPE);
            
            _frame_counter = 45;
            
            properties = IS_EXTRUDED;
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            return null;
        }
        
        public function init():void {
            costume.addEventListener(Event.ENTER_FRAME, enterFrameListener);
            costume.setAnimatedState();
        }
        
        private function enterFrameListener(e:Event):void {
            if ( ! _frame_counter-- ) {
                costume.visible = false;
                destroy();
            }
        }
        
        override public function destroy():void {
            super.destroy();
            
            costume.removeEventListener(Event.ENTER_FRAME, enterFrameListener);
        }
    }

}