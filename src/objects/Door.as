package src.objects {
    
    import Box2D.Collision.b2WorldManifold;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2World;
    import fl.motion.Color;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import src.costumes.ObjectCostume;
    import src.interfaces.Updatable;
    import src.Player;
    import src.util.Collider;
    
    public class Door extends AbstractObject implements Updatable {
        public static const LOCKED_STATE:String = "_locked";
        public static const UNLOCKED_STATE:String = "_unlocked";
        
        private var locked:Boolean = true;
        public var specialLock:Boolean = false;
        public var isSecret:Boolean = false;
        
        public var goto:int;
        
        public var level:int;
        
        public var taskId:int = 0;

        public function Door() {
            show();
            
            costume = new ObjectCostume();
            costume.setType(ObjectCostume.DOOR_TYPE);
            costume.setState(LOCKED_STATE);
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
            var doorRotation = rotation;
            
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
        public function isActive ():Boolean {
            return locked;
        }
        
        // delete me maybe
        public function update ():void {
            
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
            this.taskId = taskId;
            specialLock = true;
        }
        
        
        public function setType(type:String):void {
            isSecret = type == "secret";
            if ( isSecret ) {
                costume.setType(ObjectCostume.SECRET_DOOR_TYPE);
            }
        }
        
        public function lock ():void {
            if ( locked || specialLock ) return;
            
            instantLock();
        }
        
        public function instantLock():void {
            locked = true;
            
            costume.setState(LOCKED_STATE);
            
            body.SetActive(true);
        }

        public function unlock () {
            if ( visible && locked && !specialLock) {
                costume.setState(UNLOCKED_STATE);
                
                locked = false;
                wall.SetActive(false);
            }
        }
        
        public function hide () {
            visible = false;
        }
        
        public function show () {
            visible = true;
        }
        
        override public function setTint(color:uint):void {
            var col:Color = new Color();
            col.setTint(color, 1);
            tintObject_mc.transform.colorTransform = col;
        }

    }
    
}
