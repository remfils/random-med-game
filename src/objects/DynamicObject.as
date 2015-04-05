package src.objects {
    import src.Game;
    import src.interfaces.Breakable;
    import src.util.ItemDropper;
    public class DynamicObject extends DynamicObstacle implements Breakable {
        private var DESTROYED:Boolean = false;
        private var STOP_UPDATE:Boolean = false;
        
        public function DynamicObject() {
            super();
        }
        
        override public function update():void {
            if ( STOP_UPDATE ) return;
            if ( DESTROYED ) {
                STOP_UPDATE = true;
                
                ItemDropper.dropSmallFromObject(this);
                
                world.DestroyBody(body);
                Game.cRoom.addChild(this);
                gotoAndPlay("break");
            }
            super.update();
        }
        
        public function breakObject():void {
            DESTROYED = true;
        }
        
        public function clearObject():void {
            
        }
        
    }

}