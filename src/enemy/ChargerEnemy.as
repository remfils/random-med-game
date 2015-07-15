package src.enemy {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2World;
    import flash.geom.Point;
    import src.util.CreateBodyRequest;
    
    public class ChargerEnemy extends Enemy {
        public static const ATTACK_HORIZONTAL_STATE:String = "_charge_hor";
        public static const ATTACK_VERTICAL_STATE:String = "_charge_vert";
        public static const WALK_HORIZONTAL_STATE:String = "_walk_hor";
        public static const WALK_VERTICAL_STATE:String = "_walk_vert";
        
        public var speed:b2Vec2;
        
        public static var SPEED:Number = 2;
        public static var CHARGE_SPEED:Number = 8;
        
        private var horizontal:Boolean = true;
        public var charge:Boolean = false;
        
        public function ChargerEnemy() {
            super();
            speed = new b2Vec2(SPEED, 0);
            agroDistance = 200;
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createReq:CreateBodyRequest = super.requestBodyAt(world);
            createReq.setAsDynamicBody();
            return createReq;
        }
        
        override public function update():void {
            super.update();
            
            if ( body.GetLinearVelocity().LengthSquared() == 0 ) {
                speed.Multiply(-1);
                changeSpeed(null, SPEED);
                stopCharge();
            }
            
            if ( charge ) {
                body.SetLinearVelocity(speed);
            }
            else {
                body.SetLinearVelocity(speed);
            }
        }
        
        override protected function activateIfPlayerIsAround():void {
            if ( !charge && playerDistance < agroDistance ) {
                if ( Math.abs(y - player.y) < costume.height / 4 ) {
                    horizontal = true;
                    startCharge();
                    changeSpeed(new b2Vec2(player.x - x, 0), CHARGE_SPEED);
                }
                else if ( Math.abs( x - player.x ) < costume.width / 4 ) {
                    horizontal = false;
                    startCharge();
                    changeSpeed(new b2Vec2(0, player.y - y), CHARGE_SPEED);
                }
            }
        }
        
        override public function deactivate():void {
            is_active = false;
            stopCharge();
        }
        
        override protected function flip():void {
            if ( speed.x != 0 ) {
                costume.scaleX = speed.x / Math.abs(speed.x);
                costume.scaleY = 1;
            }
            else {
                costume.scaleX = 1;
                costume.scaleY = speed.y / Math.abs(speed.y);
            }
        }
        
        private function startCharge():void {
            charge = true;
            
            if ( horizontal ) {
                costume.setState(ATTACK_HORIZONTAL_STATE);
            }
            else {
                costume.setState(ATTACK_VERTICAL_STATE);
            }
        }
        
        private function stopCharge():void {
            charge = false;
            
            if ( horizontal ) costume.setState(WALK_HORIZONTAL_STATE);
            else costume.setState(WALK_VERTICAL_STATE);
        }
        
        private function changeSpeed(direction:b2Vec2, speedVal:Number):void {
            if ( direction ) {
                speed = direction;
            }
            speed.Normalize();
            speed.Multiply(speedVal);
            
            body.ApplyImpulse( speed, body.GetWorldCenter() );
        }
        
    }

}