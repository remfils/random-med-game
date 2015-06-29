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
        
        public static var fixtureDef:b2FixtureDef = new b2FixtureDef();
        fixtureDef.density = 6;
        fixtureDef.friction = 0.6;
        
        public var state:int;
        
        public var is_static:Boolean = false;
        public var extruded:Boolean = false;
        public var has_drop:Boolean = false;
        public var active:Boolean = false;
        
        public function Obstacle() {
            
        }
        
        public function readXMLParams(paramsXML:XML):void {
            costume.readXMLParams(paramsXML);
            var type:String = paramsXML.name();
            
            switch (type) {
                case ObjectCostume.VASE_TYPE:
                    extruded = true;
                break;
                case ObjectCostume.BARELL_TYPE:
                    extruded = true;
                case ObjectCostume.BOX_TYPE:
                    is_static = false;
                    active = true;
                    has_drop = true;
                default:
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
            setState(NORMAL_STATE);
        }
        
        private function setState(state_:int):void {
            state = state_;
            //gotoAndStop(name + STATE_LABELS[state]);
        }
        
        override public function requestBodyAt(world:b2World):void {
            var collider:DisplayObject = costume.getCollider();
            
            var bodyCreateRequest:CreateBodyRequest = new CreateBodyRequest(world, collider, this);
            
            if ( is_static ) bodyCreateRequest.setAsStaticBody();
            else bodyCreateRequest.setAsDynamicBody(fixtureDef);
            
            bodyCreateRequest.setBodyPosition( new Point(x + collider.x, y + collider.y) );
            
            game.bodyCreator.add(bodyCreateRequest);
        }
        
        public function update():void {
            if (!active) return;
            
            x = body.GetPosition().x * Game.WORLD_SCALE;
            y = body.GetPosition().y * Game.WORLD_SCALE;
        }
        
        public function breakObject():void {
            // code to break obj
        }
        
        override public function destroy():void {
            super.destroy();
            //if ( has_drop ) ItemDropper.dropSmallFromObject(this);
            setState(DESTROY_STATE);
        }
        
        public function isActive():Boolean {
            return active;
        }
        
    }

}