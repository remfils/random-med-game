package src.enemy {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2World;
    import flash.geom.Point;
    import src.Game;
    import src.util.CreateBodyRequest;
    import src.util.Output;
    
    public class ChargerEnemy extends Enemy {
        private static const RAT_DEATH_DELAY:Number = 18 / Game.FRAMES_PER_MILLISECOND;
        
        public static const ATTACK_HORIZONTAL_STATE:String = "_charge_hor";
        public static const ATTACK_VERTICAL_STATE:String = "_charge_vert";
        public static const WALK_HORIZONTAL_STATE:String = "_walk_hor";
        public static const WALK_VERTICAL_STATE:String = "_walk_vert";
        
        private static const STATE_CHARGE:String = "_charge";
        private static const STATE_WALK:String = "_walk";
        private static const SUBSTATE_VERTICAL:String = "_vert";
        private static const SUBSTATE_HORIZONTAL:String = "_hor";
        
        private static const ACTION_WALK_ID:int = 1;
        private static const ACTION_CHARGE_ID:int = 2;
        
        public var speed:b2Vec2;
        private var movement_direction:b2Vec2 = new b2Vec2(1,0);
        
        public static var SPEED:Number = 2;
        public static var CHARGE_SPEED:Number = 8;
        
        private var horizontal:Boolean = true;
        public var charge:Boolean = false;
        
        public function ChargerEnemy() {
            super();
            speed = new b2Vec2(SPEED, 0);
            agroDistance = 200;
            
            costume_remove_delay = RAT_DEATH_DELAY;
            
            _actions[ACTION_WALK_ID] = new Attack(0, walkInitAction, walkUpdateAction);
            _actions[ACTION_CHARGE_ID] = new Attack(0, chargeInitAction, chargeUpdateAction);
            _actions[ACTION_DEATH_ID].end_animation_frame = 18;
        }
        
        override protected function deathInitAction():void {
            costume.scaleY = costume.scaleX = 1;
            
            super.deathInitAction();
        }
        
        private function walkInitAction():void {
            setSpeed(SPEED);
            updateScaling();
            
            charge = false;
            setState(STATE_WALK);
            
            /*speed.Normalize();
            speed.Multiply(SPEED);*/
        }
        
        private function walkUpdateAction():void {
            if ( isPlayerInAgroRange() && !charge ) {
                var dx:Number = player.x - x;
                var dy:Number = player.y - y;
                
                if ( Math.abs(dx) < costume.width / 2 ) {
                    movement_direction.Set(0, 1);
                    if ( dy < 0 ) {
                        movement_direction.Multiply(-1);
                    }
                    
                    forceChangeAction(ACTION_CHARGE_ID);
                }
                else if ( Math.abs(player.y - y) < costume.height ) {
                    movement_direction.Set(1, 0);
                    if ( dx < 0 ) {
                        movement_direction.Multiply(-1);
                    }
                    
                    forceChangeAction(ACTION_CHARGE_ID);
                }
            }
            
            if ( stoppedAtObstacle() ) {
                smartFlip();
            }
            
            moveAcrossLine();
        }
        
        private function chargeInitAction():void {
            setSpeed(CHARGE_SPEED);
            updateScaling();
            
            charge = true;
            setState(STATE_CHARGE);
            
            /*speed.Normalize();
            speed.Multiply(CHARGE_SPEED);*/
        }
        
        private function chargeUpdateAction():void {
            if ( stoppedAtObstacle() ) {
                smartFlip();
                forceChangeAction(ACTION_WALK_ID);
            }
            
            moveAcrossLine();
        }
        
        private function stoppedAtObstacle():Boolean {
            return body.GetLinearVelocity().LengthSquared() == 0;
        }
        
        private function moveAcrossLine():void {
            body.SetLinearVelocity(speed);
        }
        
        override public function readXMLParams(paramsXML:XML):void {
            super.readXMLParams(paramsXML);
            
            var rot:Number = costume.rotation;
            costume.rotation = 0;
            
            if ( rot == 90 || rot == -90 ) {
                horizontal = true;
                movement_direction.Set(0, 1);
                
                if ( rot < 0 ) {
                    smartFlip();
                }
            }
        }
        
        override public function init():void {
            super.init();
            
            forceChangeAction(ACTION_WALK_ID);
        }
        
        override protected function setState(state:String = "", is_animated:Boolean = false):void {
            if ( state.length > 1 && state != DEATH_STATE ) {
                state += movement_direction.y == 0 ? SUBSTATE_HORIZONTAL : SUBSTATE_VERTICAL;
            }
            
            super.setState(state, is_animated);
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createReq:CreateBodyRequest = super.requestBodyAt(world);
            createReq.setAsDynamicBody();
            return createReq;
        }
        
        private function smartFlip():void {
            movement_direction.Multiply( -1);
            
            setSpeed(SPEED);
            
            updateScaling();
        }
        
        private function updateScaling():void {
            if ( movement_direction.x == 0 ) {
                costume.scaleX = 1;
                costume.scaleY = movement_direction.y;
                horizontal = false;
            }
            else {
                costume.scaleX = movement_direction.x;
                costume.scaleY = 1;
                horizontal = true;
            }
        }
        
        private function setSpeed(speed_scalar:Number) {
            speed.SetV(movement_direction);
            speed.Multiply(speed_scalar);
        }
        
        /*override public function update():void {
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
        }*/
        
        // D!
        /*override protected function activateIfPlayerIsAround():void {
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
        }*/
        
        override public function deactivate():void {
            is_active = false;
            stopCharge();
        }
        
        override protected function flip():void {
            /*if ( speed.x != 0 ) {
                costume.scaleX = speed.x / Math.abs(speed.x);
                costume.scaleY = 1;
            }
            else {
                costume.scaleX = 1;
                costume.scaleY = speed.y / Math.abs(speed.y);
            }*/
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