package src.enemy {
    import Box2D.Dynamics.b2World;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import src.Game;
    import src.util.CreateBodyRequest;
    import src.util.Collider;
	/**
     * ...
     * @author vlad
     */
    public class Projectile extends Enemy {
        private var speed:b2Vec2;
        private var SPEED:Number = 1;
        
        public function setSpeed(dir:b2Vec2):void {
            dir.Normalize();
            dir.Multiply(SPEED);
            speed = dir;
        }
        
        override public function update():void {
            if ( !body ) return;
            
            this.body.ApplyImpulse(speed,body.GetWorldCenter());
            
            x = body.GetPosition().x * Game.WORLD_SCALE;
            y = body.GetPosition().y * Game.WORLD_SCALE;
        }
        
        override public function activate():void {
            active = true;
            //gotoAndStop("normal");
        }
        
        override public function deactivate():void {
            active = false;
        }
        
        override public function makeHit(damage:Number):void {
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createBodyReq:CreateBodyRequest = super.requestBodyAt(world);
            createBodyReq.setAsDynamicSensor();
            return createBodyReq;
        }
        
        /*override public function createBodyFromCollider(world:b2World):b2Body {
            var collider:Collider = getChildByName("collider001") as Collider;
            body = collider.replaceWithDynamicSensor(world, {"object":this});
            return body;
        }*/
        
        override public function destroy():void {
        }
        
    }

}