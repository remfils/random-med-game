package src.util {
    import Box2D.Collision.Shapes.b2PolygonShape;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import src.Game;
    import src.objects.AbstractObject;

    public class CreateBodyRequest {
        public var collider:DisplayObject;
        public var world:b2World;
        
        public var actor:AbstractObject;
        
        public var bodyDef:b2BodyDef;
        public var fixtureDef:b2FixtureDef;
        public var velocity:b2Vec2;
        
        public var userData:Object = null;
        //public var 
        
        public function CreateBodyRequest(world:b2World, collider:DisplayObject, actor_:AbstractObject) {
            this.world = world;
            this.collider = collider;
            this.actor = actor_;
            this.userData = { "object": actor_ };
            
            bodyDef = new b2BodyDef();
            bodyDef.angle = actor.costume.rotation * Game.TO_RAD;
            
            var globalPosition:Point = collider.localToGlobal(new Point(0,0));
            bodyDef.position.Set( globalPosition.x / Game.WORLD_SCALE, globalPosition.y / Game.WORLD_SCALE);
            
            var shape:b2PolygonShape = new b2PolygonShape();
            shape.SetAsBox(collider.width / 2 / Game.WORLD_SCALE, collider.height / 2 / Game.WORLD_SCALE);
            
            fixtureDef = new b2FixtureDef();
            fixtureDef.shape = shape;
            fixtureDef.userData = this.userData;
            
            velocity = new b2Vec2(0, 0);
        }
        
        public function setAsStaticBody():void {
            bodyDef.type = b2Body.b2_staticBody;
        }
        
        public function setAsDynamicBody():void {
            bodyDef.type = b2Body.b2_dynamicBody;
            bodyDef.fixedRotation = true;
        }
        
        public function setAsStaticSensor():void {
            setAsStaticBody();
            fixtureDef.isSensor = true;
        }
        
        public function setAsDynamicSensor():void {
            setAsStaticSensor();
            bodyDef.type = b2Body.b2_dynamicBody;
        }
        
        public function setAsBullet():void {
            bodyDef.bullet = true;
        }
        
        public function setBodyPosition(position:Point):void {
            bodyDef.position.Set(position.x / Game.WORLD_SCALE, position.y / Game.WORLD_SCALE);
        }
        
        public function destroy():void {
            collider = null;
            world = null;
            actor = null;
            bodyDef = null;
            fixtureDef = null;
            userData = null;
        }
        
    }

}