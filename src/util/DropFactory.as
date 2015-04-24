package src.util {
    import flash.geom.Point;
    import src.Game;
    import src.objects.DropObject;
    import src.objects.ExitObject;
	
    // THIS IS REALY BAD
    
    public class DropFactory extends AbstractManager {
        
        public function DropFactory() {
            
        }
        
        public static function createSmallManaPotion(probability:Number = 1):DropObject {
            /*var dropObject:DropObject = new DropMana();
            dropObject.statObject = { "MANA": 4 };
            dropObject.dropProbability = probability;
            return dropObject;*/
            return new DropObject();
        }
        
        public static function createSmallHealthPotion(probability:Number = 1):DropObject {
            /*var dropObject:DropObject = new DropHP();
            dropObject.statObject = { "HEALTH": 4 };
            dropObject.dropProbability = probability;
            return dropObject;*/
            return new DropObject();
        }
        
        public static function createCoin(probability:Number = 1):DropObject {
            /*var dropObject:DropObject = new DropHP();
            dropObject.statObject = { "MONEY": 5 };
            dropObject.dropProbability = probability;
            return dropObject;*/
            return new DropObject();
        }
        
        public static function createExitObject():DropObject {
            /*var dropObject:DropObject = new ExitObject();
            dropObject.x = 384;
            dropObject.y = 251;
            return dropObject;*/
            return new DropObject();
        }
        
    }

}