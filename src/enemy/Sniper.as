package src.enemy {
    import Box2D.Dynamics.b2World;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import src.Game;
    import src.util.Collider;
    import src.util.CreateBodyRequest;

    public class Sniper extends Enemy {
        public static const MONK_DEATH_DELAY:Number = 43 / Game.FRAMES_PER_MILLISECOND;
        
        public static const ACTIVE_STATE:String = "_active";
        public static const STAND_STATE:String = "_stand";
        public static const SHOOT_STATE:String = "_shoot";
        
        public var charge:Boolean = false;
        public var chargeTime:Number = 0;
        public var chargeDelay:Number = 100;
        
        protected var framesToShoot:int = 0;
        protected var bulletFired:Boolean = false;
        protected var TOTAL_CHARGE_FRAMES:int = 47;
        
        public function Sniper() {
            super();
            agroDistance = 400;
            exp = 10;
        }
        
        override public function readXMLParams(paramsXML:XML):void {
            super.readXMLParams(paramsXML);
            
            costume_remove_delay = MONK_DEATH_DELAY;
        }
        
        override public function activate():void {
            is_active = true;
            costume.setState(ACTIVE_STATE);
        }
        
        override public function deactivate():void {
            charge = bulletFired = is_active = false;
            chargeTime = framesToShoot = 0;
            costume.setState(STAND_STATE);
        }
        
        override protected function flip():void {}
        
        override public function update():void {
            super.update();
            
            if ( is_active ) {
                if ( !chargeTime ) {
                    startShoot();
                    chargeTime = chargeDelay;
                }
                else {
                    chargeTime --;
                }
                if ( bulletFired ) {
                    if ( !framesToShoot-- ) {
                        bulletFired = false;
                        costume.setState(ACTIVE_STATE);
                        shoot();
                        framesToShoot = 0;
                    }
                }
            }
        }
        
        public function startShoot():void {
            bulletFired = true;
            framesToShoot = TOTAL_CHARGE_FRAMES;
            costume.setAnimatedState(SHOOT_STATE);
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createBodyReq:CreateBodyRequest = super.requestBodyAt(world);
            createBodyReq.setAsStaticBody();
            return createBodyReq;
        }
        
        /*override public function createBodyFromCollider(world:b2World):b2Body {
            var collider:Collider = getChildByName("collider001") as Collider;
            body = collider.replaceWithStaticB2Body(world, {"object": this});
            return body;
        }*/
        
        public function shoot():void {
            var direction:b2Vec2 = new b2Vec2(player.x - x, player.y - y);
            
            var bullet:Projectile = new Projectile();
            
            bullet.setSpeed(direction);
            bullet.setPosition(new Point(x, y));
            
            cRoom.addEnemy(bullet);
            //this.cRoom.addEnenemy(bullet);
        }
        
    }

}