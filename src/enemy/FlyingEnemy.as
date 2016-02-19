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
        
        public static const STAND_STATE:String = "";
        public static const ATTACK_STATE:String = "_active";
        
        public static var SPEED:Number = 10;
        private var leashJoint:b2MouseJoint;
        private var target:b2Body;
        
        private const ACTION_STAND_ID:int = 1;
        private const ACTION_FOLLOW_ID:int = 2;
        
        private var jointDef:b2MouseJointDef;
        
        public function FlyingEnemy() {
            super();
            agroDistance = 230;
            
            _actions[ACTION_DEATH_ID].end_animation_frame = 23;
            
            _actions[ACTION_STAND_ID] = new Attack( 0, standInitAction, standUpdateAction);
            _actions[ACTION_FOLLOW_ID] = new Attack( 0, followInitAction, followUpdateAction);
        }
        
        private function standInitAction():void {
            setState(STAND_STATE, false);
        }
        
        private function standUpdateAction():void {
            if ( isPlayerInAgroRange() ) {
                activate();
                forceChangeAction(ACTION_FOLLOW_ID);
            }
        }
        
        private function followInitAction():void {
            SoundManager.instance.playSFX(SoundManager.SFX_ACTIVATE_GHOST);
            setState(ATTACK_STATE);
        }
        
        private function followUpdateAction():void {
            var point:b2Vec2 = player.body.GetPosition().Copy();
            point.Subtract(body.GetPosition());
            
            var impulse:b2Vec2 = body.GetLinearVelocity();
            impulse.Normalize();
            impulse.Multiply(-1);
            
            impulse.Add(point);
            impulse.Normalize();
            impulse.Multiply(0.5);
            
            body.ApplyImpulse(impulse, point);
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createReq:CreateBodyRequest = super.requestBodyAt(world);
            
            createReq.setAsDynamicBody();
            
            return createReq;
        }
        
        override public function init():void {
            super.init();
            
            forceChangeAction(ACTION_STAND_ID);
        }
    }
    
}
