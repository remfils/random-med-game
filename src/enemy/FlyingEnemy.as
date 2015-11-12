package src.enemy {
    import Box2D.Collision.b2Point;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2World;
    import Box2D.Dynamics.Joints.b2MouseJoint;
    import Box2D.Dynamics.Joints.b2MouseJointDef;
    import src.costumes.CostumeEnemy;
    import src.Game;
    import src.util.CreateBodyRequest;
    import src.util.SoundManager;
    
    public class FlyingEnemy extends Enemy {
        private static const GHOST_DEATH_DELAY:Number = 23 / Game.FRAMES_PER_MILLISECOND;
        
        public static const STAND_STATE:String = "_stand";
        public static const ATTACK_STATE:String = "_active";
        
        public static var SPEED:Number = 10;
        private var leashJoint:b2MouseJoint;
        private var target:b2Body;
        
        private var jointDef:b2MouseJointDef;
        
        public function FlyingEnemy() {
            super();
            agroDistance = 230;
        }
        
        override public function readXMLParams(paramsXML:XML):void {
            super.readXMLParams(paramsXML);
            
            costume_remove_delay = GHOST_DEATH_DELAY;
        }
        
        override public function update():void {
            super.update();
            
            if ( isActive() ) {
                
                var point:b2Vec2 = player.body.GetPosition().Copy();
                point.Subtract(body.GetPosition());
                
                var impulse:b2Vec2 = body.GetLinearVelocity();
                impulse.Normalize();
                impulse.Multiply(-1);
                
                impulse.Add(point);
                impulse.Normalize();
                impulse.Multiply(0.5);
                
                body.ApplyImpulse(impulse, point);
                
                /*if ( leashJoint ) {
                    leashJoint.SetTarget(target.GetPosition());
                }
                else {
                    createLeashJoint();
                }*/
            }
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createReq:CreateBodyRequest = super.requestBodyAt(world);
            
            createReq.setAsDynamicBody();
            
            return createReq;
        }
        
        /*override protected function activateIfPlayerIsAround():void {
            if ( !isActive() ){
                if ( agroDistance > playerDistance ) {
                    activate();
                }
            }
        }*/
        
        override public function activate():void {
            super.activate();
            costume.setState(ATTACK_STATE);
            SoundManager.instance.playSFX(SoundManager.SFX_ACTIVATE_GHOST);
        }
        
        override public function deactivate():void {
            super.deactivate();
            costume.setState(STAND_STATE);
        }
        
        public function setTarget(body:b2Body):void {
            target = body;
        }
        
        private function createLeashJoint():void {
            if (!jointDef) defineJoint();
            
            leashJoint = this.body.GetWorld().CreateJoint(jointDef) as b2MouseJoint;
            leashJoint.SetTarget(target.GetPosition());
        }
        
        protected function defineJoint():void {
            jointDef = new b2MouseJointDef();
            jointDef.bodyA = this.body.GetWorld().GetGroundBody();
            jointDef.bodyB = this.body;
            jointDef.target = this.body.GetPosition();
            jointDef.maxForce = SPEED * this.body.GetMass();
            jointDef.dampingRatio = 1;
            jointDef.collideConnected = true;
        }
        
        private function destroyLeashJoint():void {
            if ( leashJoint ) {
                body.GetWorld().DestroyJoint(leashJoint);
                leashJoint = null;
            }
        }
        
        override public function destroy():void {
            destroyLeashJoint();
            super.destroy();
        }
    }
    
}
