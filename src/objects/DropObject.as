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
    
    // ADD COSTUME SUPPORT
    
    public class DropObject extends AbstractObject implements ExtrudeObject {
        public var dropProbability:Number = 0;
        public var isFixed:Boolean = false;
        public var statObject:Object;
        
        public function DropObject() {
            super();
        }
        
        public function playDrop():void {
            //gotoAndPlay("drop");
        }
        
        override public function requestBodyAt(world:b2World):void {
            /*var collider:Collider = getChildByName("collider001") as Collider;
            
            var createBodyRequest:CreateBodyRequest = new CreateBodyRequest(world, collider, this);
            createBodyRequest.setAsDynamicSensor();
            
            game.bodyCreator.add(createBodyRequest);*/
        }
        
        // delete me
        /*public function createBodyFromCollider(world:b2World):b2Body {
            var collider:Collider = getChildByName("collider001") as Collider;
            body = collider.replaceWithDynamicSensor(world, { "object": this } );
            return body;
            return new b2Body(
        }*/
        
        public function pickUp():void {
            if ( game.player.addToStats(statObject) ) {
                game.deleteManager.add(body);
                body = null;
                //gotoAndPlay("pickup");
            }
        }
    }

}