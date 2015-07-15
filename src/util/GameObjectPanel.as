package src.util {
    import flash.display.DisplayObject;
    import src.interfaces.ExtrudeObject;
    import src.objects.TaskKey;
    import src.ui.playerStat.PlayerStat;
    import src.Player;
    import flash.display.Sprite;
    import src.levels.Room;
    
    public class GameObjectPanel extends Sprite {

        public function GameObjectPanel() {
            
        }
        
        public function update():void {
            if ( numChildren < 2 ) return;
            
            var i:int = numChildren;
            
            while ( i-- - 1 ) {
                if ( getChildAt(i-1).y > getChildAt(i).y ) {
                    swapChildrenAt(i-1, i);
                }
            }
        }
        
        override public function addChild(child:DisplayObject):DisplayObject {
            var i:int = numChildren;
            
            while ( i-- ) {
                if ( getChildAt(i).y < child.y ) {
                    return addChildAt(child, i);
                }
            }
            
            return super.addChild(child);
        }
        
    }
    
}
