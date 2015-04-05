package src.objects {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import src.Game;
    import src.interfaces.SolidBody;
    import src.interfaces.Updatable;
    import src.util.CreateBodyRequest;
    import src.util.Collider;
	/**
     * ...
     * @author vlad
     */
    public class Obstacle extends AbstractObject implements Updatable {
        
        public static const STAND_STATE:int = 1;
        public static const DESTROY_STATE:int = 2;
        private static const STATE_LABELS:Array = new Array("", "_stand", "_destroy");
        
        public static const COLLIDER_NAME:String = "obst_collider";
        
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
        
        public function setType(name_:String):void {
            name = name_;
            
            switch (name) {
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
            
            setState(STAND_STATE);
        }
        
        private function setState(state_:int):void {
            state = state_;
            gotoAndStop(name + STATE_LABELS[state]);
        }
        
        override public function requestBodyAt(world:b2World):void {
            var collider:MovieClip = getChildByName(COLLIDER_NAME) as MovieClip;
            
            var bodyCreateRequest:CreateBodyRequest = new CreateBodyRequest(world, collider);
            
            if ( isStatic ) bodyCreateRequest.setAsStaticBody();
            else bodyCreateRequest.setAsDynamicBody(fixtureDef);
            
            bodyCreateRequest.setBodyPosition( new Point(x + collider.x, y + collider.y) );
            
            game.bodyCreator.add(bodyCreateRequest);
        }
        
        public function update():void {
            if (!active) return;
            
            x = body.GetPosition().x * Game.WORLD_SCALE;
            y = body.GetPosition().y * Game.WORLD_SCALE;
        }
        
        override public function destroy():void {
            super.destroy();
            if ( has_drop ) ItemDropper.dropSmallFromObject(this);
            setState(DESTROY_STATE);
        }
        
        public function isActive():Boolean {
            return active;
        }
        
    }

}