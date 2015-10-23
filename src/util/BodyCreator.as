package src.util {
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2Fixture;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import src.objects.AbstractObject;

    public class BodyCreator extends AbstractManager {
        private var bodies:Array;
        
        public function BodyCreator() {
            super();
            bodies = new Array();
        }
        
        public function add(request:CreateBodyRequest):void {
            bodies.push(request);
        }
        
        public function createBodies():void {
            if ( bodies.length ) {
                var i:int = bodies.length;
                while ( i-- ) {
                    var request:CreateBodyRequest = bodies[i];
                    
                    request.create();
                    
                    //request.actor.removeChild(request.collider);
                    request.destroy();
                    request = null;
                    
                    bodies.splice(i, 1);
                }
            }
        }
        
    }

}