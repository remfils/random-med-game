package src.enemy {
    import Box2D.Dynamics.b2World;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import flash.geom.Point;
    import src.util.Collider;
    import src.util.CreateBodyRequest;
	/**
     * ...
     * @author vlad
     */
    public class Sniper extends Enemy {
        public var charge:Boolean = false;
        public var chargeTime:Number = 0;
        public var chargeDelay:Number = 100;
        
        public function Sniper() {
            super();
        }
        
        override public function activate():void {
            active = true;
            gotoAndStop("active");
        }
        
        override public function deactivate():void {
            active = false;
            gotoAndStop("normal");
        }
        
        override protected function flip():void {
            
        }
        
        override public function update():void {
            if ( !body ) return;
            
            calculateDistanceToPlayer();
            
            if ( isActive() ) {
                if ( chargeTime == 0 ) {
                    startShoot();
                    chargeTime = chargeDelay;
                }
                else {
                    chargeTime --;
                }
            }
            
            if ( chargeTime == 0 ) {
                activateIfPlayerIsAround();
            }
            
            playHitAnimationIfNeeded();
            
            updatePosition();
        }
        
        public function startShoot():void {
            active = false;
            gotoAndPlay("shoot");
        }
        
        override public function requestBodyAt(world:b2World, position:Point=null, speed:Point=null):void {
            var collider:Collider = getChildByName("collider001") as Collider;
            
            var createBodyRequest:CreateBodyRequest = new CreateBodyRequest(world, collider);
            createBodyRequest.setAsStaticBody();
            
            game.bodyCreator.add(createBodyRequest);
        }
        
        override public function createBodyFromCollider(world:b2World):b2Body {
            var collider:Collider = getChildByName("collider001") as Collider;
            body = collider.replaceWithStaticB2Body(world, {"object": this});
            return body;
        }
        
        public function shoot():void {
            var direction:b2Vec2 = new b2Vec2(player.x - x, player.y - y);
            
            var bullet:Projectile = new EnemyBullet();
            bullet.setSpeed(direction);
            bullet.activate();
            bullet.setPosition(x, y);
            
            this.cRoom.addEnenemy(bullet);
        }
        
    }

}