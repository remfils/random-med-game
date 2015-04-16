package src.util {
    import Box2D.Dynamics.b2Body;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import src.enemy.Enemy;
    import src.Game;
    import src.interfaces.SolidBody;
    import src.objects.AbstractObject;
    import src.ui.AbstractMenu;
	/**
     * ...
     * @author vlad
     */
    public class DeleteManager extends AbstractManager {
        private var sleep:Boolean = true;
        
        private var objectsToRemove:Array;
        
        public function DeleteManager() {
            objectsToRemove = new Array();
        }
        
        public function add(object:Object):void {
            sleep = false;
            objectsToRemove.push(object);
        }
        
        public function clear():void {
            if ( sleep ) return;
            
            clearWorld();
            
            if ( objectsToRemove.length == 0 ) sleep = true;
        }
        
        public function clearWorld():void {
            var i:int = objectsToRemove.length;
            while ( i-- ) {
                if ( objectsToRemove[i] is b2Body ) {
                   game.cRoom.world.DestroyBody(objectsToRemove[i]);
                }
                
                if ( objectsToRemove[i] is AbstractObject
                    || objectsToRemove[i] is AbstractMenu
                    || objectsToRemove[i] is AbstractManager
                ) {
                    objectsToRemove[i].destroy();
                }
                
                if ( objectsToRemove[i] is DisplayObject ) {
                    var dispObj:DisplayObject = objectsToRemove[i] as DisplayObject;
                    if ( dispObj.parent ) dispObj.parent.removeChild(dispObj);
                }
                
                if ( objectsToRemove[i] is Enemy ) {
                    //Game.cRoom.killEnemy(objectsToRemove[i] as Enemy);
                }
                
                objectsToRemove.splice(i, 1);
            }
        }
        
        override public function destroy():void {
            super.destroy();
            
            clearWorld();
            
            sleep = null;
            
            objectsToRemove = null;
        }
    }

}