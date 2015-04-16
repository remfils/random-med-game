package src.objects {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import Box2D.Dynamics.b2Body;
    import flash.geom.Point;
    import src.Game;
    import src.interfaces.Updatable;
    import src.util.Collider;
    import src.util.CreateBodyRequest;
    public class DynamicObstacle extends Obstacle implements Updatable {
        private var fixtureDef:b2FixtureDef;
        public var world:b2World;
        public var colliderName:String = "collider_001";
        
        public function DynamicObstacle() {
            super();
            fixtureDef = new b2FixtureDef();
            fixtureDef.density = 6;
            fixtureDef.friction = 0.6;
        }
        
        override public function requestBodyAt(world:b2World, position:Point=null, speed:Point=null):void {
            this.world = world;
            
            var collider:Collider = getChildByName(colliderName) as Collider;
            
            var createBodyRequest:CreateBodyRequest = new CreateBodyRequest(world, collider, this);
            createBodyRequest.setAsDynamicBody(fixtureDef);
            createBodyRequest.bodyDef.linearDamping = 5;
            createBodyRequest.setBodyPosition( new Point(x + collider.x, y + collider.y) );
            
            game.bodyCreator.add(createBodyRequest);
        }
        
        override public function createBodyFromCollider(world:b2World):b2Body {
            this.world = world;
            var collider:Collider = getChildByName(colliderName) as Collider;
            
            this.body = collider.replaceWithDynamicB2Body(world, fixtureDef);
            this.body.SetPosition(new b2Vec2( (x + collider.x) / Game.WORLD_SCALE, (y + collider.y) / Game.WORLD_SCALE));
            this.body.SetLinearDamping(5);
            return this.body;
        }
        
        public function update():void {
            if ( !body ) return;
            
            x = body.GetPosition().x * Game.WORLD_SCALE;
            y = body.GetPosition().y * Game.WORLD_SCALE;
        }
        
        public function isActive():Boolean {
            return true;
        }
        
    }

}