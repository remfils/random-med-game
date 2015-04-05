package src.util {
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2Fixture;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
	/**
     * ...
     * @author vlad
     */
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
                    var body:b2Body = request.world.CreateBody(request.bodyDef);
                    
                    body.CreateFixture(request.fixtureDef);
                    body.SetLinearVelocity(request.velocity);
                    request.parent.body = body;
                    
                    request.parent.removeChild(request.collider);
                    request.destroy();
                    
                    bodies.splice(i, 1);
                }
            }
        }
        
    }

}