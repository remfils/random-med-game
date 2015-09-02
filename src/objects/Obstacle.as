package src.objects {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import src.costumes.ObjectCostume;
    import src.Game;
    import src.interfaces.SolidBody;
    import src.interfaces.Updatable;
    import src.util.CreateBodyRequest;
    import src.util.Collider;

    public class Obstacle extends AbstractObject {
        
        public static const NORMAL_STATE:String = "_stand";
        public static const DESTROY_STATE:String = "_destroy";
        
        public var state:int;
        
        public var is_static:Boolean = false;
        public var extruded:Boolean = false;
        public var has_drop:Boolean = false;
        public var active:Boolean = false;
        public var is_break:Boolean = true;
        
        public function Obstacle() {
            costume = new ObjectCostume();
        }
        
        override public function readXMLParams(paramsXML:XML):void {
            super.readXMLParams(paramsXML);
            costume.setState(NORMAL_STATE);
            
            var type:String = paramsXML.name();
            switch (type) {
                case ObjectCostume.VASE_TYPE:
                    extruded = true;
                    is_break = false;
                    is_static = true;
                break;
                case ObjectCostume.STONE_TYPE:
                    is_static = true;
                break;
                case ObjectCostume.BARELL_TYPE:
                    extruded = true;
                    active = true;
                    has_drop = true;
                    break;
                case ObjectCostume.BOX_TYPE:
                    extruded = true;
                    active = true;
                    has_drop = true;
            }
        }
        
        // D!
        public function setType(name_:String):void {
            costume.name = name_;
            
            switch (name_) {
                case "Vase":
                    extruded = true;
                break;
                case "Barell":
                    extruded = true;
                case "Box":
                    is_static = false;
                    active = true;
                    has_drop = true;
                default:
            }
            costume.setType(name_);
            //setState(NORMAL_STATE);
        }
        
        private function setState(state_:int):void {
            state = state_;
            //gotoAndStop(name + STATE_LABELS[state]);
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createBodyReq:CreateBodyRequest = super.requestBodyAt(world);
            
            createBodyReq.fixtureDef.density = 4;
            createBodyReq.fixtureDef.friction = 1;
            
            createBodyReq.bodyDef.linearDamping = 3;
            
            if ( is_static ) createBodyReq.setAsStaticBody();
            else createBodyReq.setAsDynamicBody();
            
            return createBodyReq;
        }
        
        public function update():void {
            if (!active) return;
            
            x = body.GetPosition().x * Game.WORLD_SCALE;
            y = body.GetPosition().y * Game.WORLD_SCALE;
        }
        
        public function breakObject():void {
            if ( !is_break ) return;
            
            active = false;
            body.SetActive(active);
            costume.setState(DESTROY_STATE);
            game.cRoom.addChild(costume);
        }
        
        override public function destroy():void {
            super.destroy();
            //if ( has_drop ) ItemDropper.dropSmallFromObject(this);
            //setState(DESTROY_STATE);
        }
        
        public function isActive():Boolean {
            return active;
        }
        
    }

}