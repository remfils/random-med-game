package src.util {
    import flash.display.DisplayObject;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.utils.Timer;
    import src.events.ExitLevelEvent;
    import src.Game;
    import src.levels.Room;
    import src.objects.AbstractObject;
    import src.objects.DropObject;
    import src.objects.ExitObject;
    
    public class ItemDropper extends AbstractManager {
        
        public static var minX:Number = 100;
        public static var maxX:Number = 654;
        public static var minY:Number = 100;
        public static var maxY:Number = 400;
        
        private static var delayedDropObject:DropObject
        
        public static function dropFrom(dropObjects:Array):DropObject {
            trace(dropObjects.length);
            var i:int = dropObjects.length,
                p:Number = 0,
                randomP:Number = Math.random();
            
            while ( i-- ) {
                p += DropObject(dropObjects[i]).dropProbability;
                
                if ( p > randomP ) {
                    dropObjects[i].playDrop();
                    return dropObjects[i];
                }
            }
            
            return null;
        }
        
        public static function dropAtPointFrom(dropObjects:Array, x:Number, y:Number ):void {
            var obj:DropObject = dropFrom(dropObjects);
            
            if ( obj ) {
                obj.x = x;
                obj.y = y;
                
                if ( obj.isFixed ) {
                    delayedDropObject = obj;
                    startDelayedDrop();
                }
                else {
                    while ( game.cRoom.checkOverlapGameObjects(obj) ) {
                        obj.y -= obj.height;
                    }
                    dropInCurrentRoom(obj);
                }
            }
        }
        
        private static function startDelayedDrop():void {
            var timer:Timer = new Timer(100);
            timer.addEventListener(TimerEvent.TIMER, checkZoneToDropObject);
            timer.start();
        }
        
        private static function checkZoneToDropObject(e:TimerEvent):void {
            if ( delayedDropObject is ExitObject ) {
                if ( !game.cRoom.checkOverlapGameObjects(ExitObject(delayedDropObject).collider) ) {
                    var timer:Timer = e.target as Timer;
                    timer.removeEventListener(TimerEvent.TIMER, checkZoneToDropObject);
                    timer.stop();
                    dropInCurrentRoom(delayedDropObject);
                }
            }
        }
        
        public static function dropSmallFromObject(container:DisplayObject):void {
            var drops:Array = new Array(
                DropFactory.createSmallHealthPotion(0.4),
                DropFactory.createSmallManaPotion(0.4)
            ),
                i:int = drops.length;
            
            var object:DropObject = dropFrom(drops);
            
            while (drops.length) {
                drops.pop();
            }
            
            if ( object ) {
                object.x = container.x;
                object.y = container.y;
                dropInCurrentRoom(object);
            }
        }
        
        public static function dropInCurrentRoom(dropObject:DropObject):void {
            var room:Room = game.cRoom;
            dropObject.playDrop();
            dropObject.requestBodyAt(room.world);
            room.gameObjectPanel.addChild(dropObject);
            
        }
    }

}