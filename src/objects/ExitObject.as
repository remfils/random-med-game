package src.objects {
    import Box2D.Collision.b2Pair;
    import Box2D.Dynamics.b2World;
    import Box2D.Dynamics.b2Body;
    import flash.geom.Point;
    import src.util.Collider;
    import src.util.CreateBodyRequest;
    public class ExitObject extends DropObject {
        
        public var collider:Collider;
        
        public function ExitObject() {
            super();
            // collider = getChildByName("collider002") as Collider;
            dropProbability = 1;
            isFixed = true;
        }
        
        override public function pickUp():void {
            //gotoAndPlay("pickup");
            game.finishLevel();
        }
        
        override public function requestBodyAt(world:b2World):void {
            var createBodyRequest:CreateBodyRequest = new CreateBodyRequest(world, collider, this);
            createBodyRequest.setAsStaticSensor();
            
            game.bodyCreator.add(createBodyRequest);
        }
        
        /*override public function createBodyFromCollider(world:b2World):b2Body {
            var col:Collider = collider.copy();
            body = col.replaceWithSensor(world, { "object": this } );
            return body;
        }*/
        
    }

}