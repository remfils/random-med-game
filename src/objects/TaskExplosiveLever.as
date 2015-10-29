package src.objects {
    import Box2D.Collision.b2AABB;
    import Box2D.Common.Math.b2Vec2;
    import flash.events.Event;
    import src.costumes.ActiveObjectCostume;


    public class TaskExplosiveLever extends TaskLever {
        private const EXPLOSION_FRAME_COUNT:int = 18;
        private const OPEN_FAME_COUNT:int = 21;
        
        
        private var _frame_dellay:Number = 0;
        
        public function TaskExplosiveLever() {
            super();
            costume.setType(ActiveObjectCostume.EXPLOSIVE_LEVER_TYPE);
            costume.setState();
        }
        
        override public function positiveOutcome():void {
            costume.setAnimatedState(OPEN_STATE + REMOVE_STATE);
            
            _frame_dellay = OPEN_FAME_COUNT;
            
            costume.addEventListener(Event.ENTER_FRAME, destroyAfterFrameDellay);
        }
        
        override public function negativeOutcome():void {
            costume.setAnimatedState(BREAK_STATE);
            
            _frame_dellay = EXPLOSION_FRAME_COUNT;
            
            costume.addEventListener(Event.ENTER_FRAME, destroyAfterFrameDellay);
            
            var aabb:b2AABB = new b2AABB();
            var delta:b2Vec2 = new b2Vec2(2, 2);
            
            aabb.lowerBound = body.GetPosition().Copy();
            aabb.lowerBound.Subtract(delta);
            aabb.upperBound = body.GetPosition().Copy();
            aabb.upperBound.Add(delta);
            
            body.GetWorld().QueryAABB(game.createExposionQuerryAABBCallback(body.GetPosition(), 50, 1), aabb);
        }
        
        private function destroyAfterFrameDellay(e:Event):void {
            _frame_dellay --;
            
            if ( !_frame_dellay ) {
                destroy();
            }
        }
        
        override public function remove():void {
            //super.remove();
            
            startRemovingFlag();
        }
        
        override public function destroy():void {
            costume.stop();
            costume.visible = false;
            super.destroy();
        }
    }

}