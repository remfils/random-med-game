package src.objects {
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2World;
    import flash.geom.Point;
    import src.Game;
    import src.interfaces.ExtrudeObject;
    import src.interfaces.SolidBody;
    import flash.display.MovieClip;
    import src.Player;
    import src.util.Collider;
    import src.util.CreateBodyRequest;
    public class DropObject extends AbstractObject implements SolidBody, ExtrudeObject {
        public var dropProbability:Number = 0;
        public var isFixed:Boolean = false;
        public var statObject:Object;
        
        public function DropObject() {
            super();
        }
        
        public function playDrop():void {
            gotoAndPlay("drop");
        }
        
        public function requestBodyAt(world:b2World, position:Point=null, speed:Point=null):void {
            var collider:Collider = getChildByName("collider001") as Collider;
            
            var createBodyRequest:CreateBodyRequest = new CreateBodyRequest(world, collider);
            createBodyRequest.setAsDynamicSensor();
            
            game.bodyCreator.add(createBodyRequest);
        }
        
        public function createBodyFromCollider(world:b2World):b2Body {
            var collider:Collider = getChildByName("collider001") as Collider;
            body = collider.replaceWithDynamicSensor(world, { "object": this } );
            return body;
        }
        
        public function pickUp():void {
            if ( game.player.addToStats(statObject) ) {
                game.deleteManager.add(body);
                body = null;
                gotoAndPlay("pickup");
            }
        }
    }

}