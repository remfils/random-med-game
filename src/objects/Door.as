package src.objects {
    
    import Box2D.Collision.b2WorldManifold;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2World;
    import fl.motion.Color;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import src.costumes.Costume;
    import src.costumes.DecorCostume;
    import src.costumes.ObjectCostume;
    import src.interfaces.Updatable;
    import src.Player;
    import src.util.Collider;
    import src.util.CreateBodyRequest;
    
    public class Door extends TaskObject {
        public static const LOCKED_STATE:String = "_lock";
        public static const UNLOCKED_STATE:String = "_unlock";
        
        public static const DOOR_SECRET_TYPE:String = "secret";
        public static const DOOR_START_TYPE:String = "start";
        
        private var locked:Boolean = true;
        public var specialLock:Boolean = false;
        public var isSecret:Boolean = false;
        
        public var goto:int;
        
        public var level:int;

        public function Door() {
            costume = new ObjectCostume();
            costume.setType(ObjectCostume.DOOR_TYPE);
            costume.setState(LOCKED_STATE);
            show();
        }
        
        // delete
        public function setDestination ( LEVEL:int ) {
            level = LEVEL;
        }
        
        //delete
        public function setWall ( body:b2Body ):void {
            //this.wall = body;
        }
        
        public function setExit( exitBody:b2Body ):void {
            
        }
        
        // delete
        public function getDirection ():String {
            var doorRotation = costume.rotation;
            
            switch ( doorRotation ) {
                case 90:
                    doorRotation = -90;
                    break;
                case 180:
                case -180:
                    doorRotation = 0;
                    break;
                default:
                    doorRotation += 180;
            }
            
            switch ( doorRotation ) {
                case   0: return "down";
                case  90: return "left";
                case -90: return "right";
                case 180: return "up";
                default: return "left";
            }
        }
        
        // gameobjct methods
        override public function isActive ():Boolean {
            return locked;
        }
        
        // DELeTE
        public function getExit ():Collider {
            return new Collider();
        }
        
        //delete
        public function checkExitCollision ( P:Player ): Boolean {
            return !locked;
        }
        
        
        public function assignTask( taskId:int ):void {
            this.task_id = taskId;
            specialLock = true;
        }
        
        
        public function setType(type:String):void {
            isSecret = type == DOOR_SECRET_TYPE;
            if ( isSecret ) {
                costume.setType(ObjectCostume.DOOR_SECRET_TYPE);
                specialLock = true;
                instantLock();
            }
            
            if ( type == DOOR_START_TYPE ) {
                costume.setType(ObjectCostume.DOOR_START_TYPE);
                costume.setState();
                specialLock = true;
            }
        }
        
        public function lock ():void {
            if ( locked || specialLock ) return;
            
            instantLock();
        }
        
        public function instantLock():void {
            locked = true;
            
            costume.setState(LOCKED_STATE);
            
            if (body) body.SetActive(locked);
        }

        public function unlock () {
            if ( costume.visible && locked && !specialLock) {
                costume.setState(UNLOCKED_STATE);
                
                locked = false;
                body.SetActive(locked);
            }
        }
        
        override public function readXMLParams(paramsXML:XML):void {
            var color:String = paramsXML.@color;
            if (color) createColorObject(color);
            
            task_id = paramsXML.@task_id;
        }
        
        override public function createColorObject(color:String):DecorCostume {
            var costume:DecorCostume = super.createColorObject(color);
            costume.x = -42;
            costume.y = 1;
            return costume;
        }
        
        override public function setTint(color:uint):void {
            var col:Color = new Color();
            col.setTint(color, 1);
            //tintObject_mc.transform.colorTransform = col;
        }

    }
    
}
