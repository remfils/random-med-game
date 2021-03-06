package src.enemy {
    import Box2D.Common.Math.b2Vec2;
    import flash.geom.Point;
    
    public class ChargerEnemy extends Enemy {
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
                if ( Math.abs(y - player.y) < height / 4 ) {
                    horizontal = true;
                    startCharge();
                    changeSpeed(new b2Vec2(player.x - x, 0), CHARGE_SPEED);
                }
                else if ( Math.abs( x - player.x ) < width / 4 ) {
                    horizontal = false;
                    startCharge();
                    changeSpeed(new b2Vec2(0, player.y - y), CHARGE_SPEED);
                }
            }
        }
        
        override public function deactivate():void {
            active = false;
            stopCharge();
        }
        
        override protected function flip():void {
            if ( speed.x != 0 ) {
                scaleX = speed.x / Math.abs(speed.x);
                scaleY = 1;
            }
            else {
                scaleX = 1;
                scaleY = speed.y / Math.abs(speed.y);
            }
        }
        
        private function startCharge():void {
            charge = true;
            
            if ( horizontal ) {
                gotoAndStop("attack_hor");
            }
            else {
                gotoAndStop("attack_vert");
            }
        }
        
        private function stopCharge():void {
            charge = false;
            
            var animState:String = horizontal ? "walk_hor" : "walk_vert";
            gotoAndStop(animState);
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