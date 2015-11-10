package src.enemy {
    import Box2D.Dynamics.b2World;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import src.costumes.CostumeEnemy;
    import src.Game;
    import src.util.CreateBodyRequest;
    import src.util.Collider;
    import src.util.SoundManager;

    public class Projectile extends Enemy {
        private var speed:b2Vec2;
        private var SPEED:Number = 4;
        
        public function Projectile() {
            super();
            costume.setType(CostumeEnemy.GREEN_BULLET_TYPE);
            activate();
            
            death_sound_id = SoundManager.SFX_HIT_ENEMY_BULLET;
        }
        
        public function setSpeed(dir:b2Vec2):void {
            dir.Normalize();
            dir.Multiply(SPEED / Game.WORLD_SCALE);
            speed = dir;
        }
        
        override public function update():void {
            if ( !body ) return;
            
            body.ApplyImpulse(speed, body.GetWorldCenter());
            
            x = body.GetPosition().x * Game.WORLD_SCALE;
            y = body.GetPosition().y * Game.WORLD_SCALE;
        }
        
        override public function activate():void {
            is_active = true;
            costume.setState();
        }
        
        override public function deactivate():void {
            is_active = false;
        }
        
        override public function makeHit(damage:Number):void {}
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createBodyReq:CreateBodyRequest = super.requestBodyAt(world);
            createBodyReq.setAsDynamicSensor();
            createBodyReq.setAsBullet();
            return createBodyReq;
        }
    }

}