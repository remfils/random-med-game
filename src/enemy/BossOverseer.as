package src.enemy {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2Fixture;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import Box2D.Dynamics.Joints.b2Joint;
    import Box2D.Dynamics.Joints.b2LineJoint;
    import Box2D.Dynamics.Joints.b2LineJointDef;
    import Box2D.Dynamics.Joints.b2MouseJoint;
    import Box2D.Dynamics.Joints.b2MouseJointDef;
    import Box2D.Dynamics.Joints.b2PrismaticJoint;
    import Box2D.Dynamics.Joints.b2PrismaticJointDef;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.utils.Timer;
    import src.costumes.CostumeEnemy;
    import src.Game;
    import src.interfaces.Init;
    import src.util.ChangePlayerStatObject;
    import src.util.CreateBodyRequest;
    import src.util.ObjectPool;


    public class BossOverseer extends Enemy implements Init {
        
        private const TOP_Y:Number = 130;
        private const LEFT_X:Number = 156.8;
        private const RIGHT_X:Number = 592.25;
        
        private var movement_speed:Number = 15;
        
        private static const INIT_STATE:String = "_init";
        private static const SWING_STATE:String = "_charge";
        private static const STAND_STATE:String = "_stand";
        private static const HIT_ARM_STATE:String = "_armHit";
        //private static const
        
        private static const FRAME_SWING_ARM_END:int = 6; // 6
        private static const FRAME_HIT_ARM_ATTACK_START:int = 3;
        private static const FRAME_HIT_ARM_END:int = 15;
        private static const FRAME_HIT_ARM_ATTACK_END:int = 5;
        private static const FRAME_DEATH_END:int = 101;
        
        private static const FRAME_INIT_END:int = 58;
        
        private var frame_counter:int = 0;
        private var _end_animation_frame:int = 0;
        
        private var _state:int = 0;
        
        private const INIT_STATE_ID:int = 1;
        private const SWING_STATE_ID:int = 2;
        private const STAND_STATE_ID:int = 3;
        private const HIT_ARM_STATE_ID:int = 4;
        private const HIT_ARM_MOVING_STATE_ID:int = 7;
        private const MOVE_TO_LEFT_CORNER_ID:int = 5;
        private const MOVE_TO_RIGHT_CORNER_ID:int = 6;
        
        private var change_state:Boolean = false;
        private var _destination:b2Vec2 = new b2Vec2();
        
        private var _attacks:Vector.<Attack>;
        
        private var _current_attack:Attack;
        
        private var _anchor:b2Body;
        private var _move_joint:b2LineJoint;
        private var _joint_def:b2LineJointDef;
        private var _movement_force:b2Vec2 = new b2Vec2();
        
        public function BossOverseer() {
            super();
            
            _attacks = new Vector.<Attack>(20);
            _attacks[0] = null;
            _attacks[INIT_STATE_ID] = new Attack(FRAME_INIT_END, initInitAttack, null, initEndAttack);
            _attacks[STAND_STATE_ID] = new Attack(100, standInitAttack);
            _attacks[MOVE_TO_LEFT_CORNER_ID] = new Attack(0, moveLeftCornerInitAttack, moveAnyUpdateAttack, moveAnyEndAttack);
            _attacks[MOVE_TO_RIGHT_CORNER_ID] = new Attack(0, moveRightCornerInitAttack, moveAnyUpdateAttack, moveAnyEndAttack);
            _attacks[HIT_ARM_STATE_ID] = new Attack(0, hitArmInitAttack, hitArmUpdateAttack);
            
            this.health = 300;
            this.costume_remove_delay = FRAME_DEATH_END;
        }
        
// + поведение
        
        private function initInitAttack():void {
            setState(INIT_STATE, true);
        }
        
        private function initEndAttack():void {
            body.SetActive(true);
        }
        
        private function standInitAttack():void {
            setState(STAND_STATE);
            _attacks[STAND_STATE_ID].end_animation_frame = 30;//100 + 400 * Math.random();
        }
        
        private function moveLeftCornerInitAttack():void {
            setState(STAND_STATE);
            moveTo(LEFT_X, TOP_Y);
        }
        
        private function moveRightCornerInitAttack():void {
            setState(STAND_STATE);
            moveTo(RIGHT_X, TOP_Y);
        }
        
        private function moveAnyUpdateAttack():void {
            moveWithTemporalForce();
            
            if ( hasArrivedToDestination() ) {
                change_state = true;
                
                removeJointAndStop();
            }
        }
        
        private function moveWithTemporalForce():void {
            if ( frame_counter < 10 ) {
                body.ApplyForce(_movement_force, body.GetLocalCenter());
                
                _movement_force.Multiply(2);
            }
        }
        
        private function hasArrivedToDestination():Boolean {
            var p:b2Vec2 = _destination.Copy();
            p.Subtract(body.GetPosition());
            return p.Length() < 0.1;
        }
        
        private function removeJointAndStop():void {
            body.GetWorld().DestroyJoint(_move_joint);
            body.SetLinearVelocity(new b2Vec2(0, 0));
        }
        
        private function moveAnyEndAttack():void {
            
        }
        
        private function moveTo(x:Number, y:Number):void {
            var p:b2Vec2;
            
            _destination.Set( x / Game.WORLD_SCALE, y / Game.WORLD_SCALE);
            p = _destination.Copy();
            
            _anchor.SetPosition(p);
            
            p.Subtract(body.GetPosition());
            var l:Number = p.Normalize();
            p.Multiply(-1);
            
            _joint_def.Initialize(body, _anchor.GetWorld().GetGroundBody(), _anchor.GetPosition().Copy(), p);
            /*_joint_def.enableMotor = true;
            _joint_def.motorSpeed = movement_speed;
            _joint_def.maxMotorForce = body.GetMass() * movement_speed * 0.4 / Game.TIME_STEP;*/
            
            _joint_def.enableLimit = true;
            _joint_def.lowerTranslation = 0;
            _joint_def.upperTranslation = l;
            
            _move_joint = b2LineJoint(body.GetWorld().CreateJoint(_joint_def));
            body.SetAwake(true);
            
            _movement_force = p.Copy();
            _movement_force.Multiply( -0.7);
        }
        
        private function hitArmInitAttack():void {
            setState(SWING_STATE, true);
            _state = SWING_STATE_ID;
        }
        
        private function hitArmUpdateAttack():void {
            if ( _state == SWING_STATE_ID ) {
                if ( frame_counter > FRAME_SWING_ARM_END ) {
                    _state = HIT_ARM_MOVING_STATE_ID;
                    setState(HIT_ARM_STATE);
                    moveTo( player.x, player.y - player.collider.height / 2 - costume.getCollider().height / 2 - 10);
                }
            }
            else if ( _state == HIT_ARM_MOVING_STATE_ID ) {
                moveWithTemporalForce();
                
                if ( hasArrivedToDestination() ) {
                    removeJointAndStop();
                    
                    setState(HIT_ARM_STATE, true);
                    
                    _state = HIT_ARM_STATE_ID;
                }
            }
            else if ( _state == HIT_ARM_STATE_ID ) {
                if ( frame_counter >= FRAME_HIT_ARM_ATTACK_START && frame_counter <= FRAME_HIT_ARM_ATTACK_END ) {
                    if ( costume.getCollider().hitTestObject(player.collider) ) {
                        game.changePlayerStat(new ChangePlayerStatObject(ChangePlayerStatObject.HEALTH_STAT, -2, 0, true));
                    }
                }
                if ( frame_counter >= FRAME_HIT_ARM_END ) {
                    change_state = true;
                }
            }
        }
        
// - поведение
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var req:CreateBodyRequest = super.requestBodyAt(world);
            
            req.setAsDynamicBody();
            
            req.fixture_defs[0].friction = 0.8;
            req.fixture_defs[0].density = 0.5;
            
            var fix:b2FixtureDef = new b2FixtureDef();
            fix.shape = req.fixtureDef.shape;
            fix.isSensor = true;
            
            var b_d:b2BodyDef = new b2BodyDef();
            b_d.active = true;
            b_d.position.x = 0;
            b_d.position.y = 0;
            
            _anchor = world.CreateBody(b_d)
            _anchor.CreateFixture(fix);
            
            return req;
        }

        override public function readXMLParams(paramsXML:XML):void {
            super.readXMLParams(paramsXML);
            
            costume.setType(CostumeEnemy.OVERSEER_TYPE);
            setState(INIT_STATE);
        }
        
        public function init():void {
            var timer:Timer = ObjectPool.getTimer(300);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, dellayedInitTimerListener);
            
            setState(INIT_STATE);
            
            is_active = false;
            
            _joint_def = new b2LineJointDef();
        }
        
        override public function activate():void {
            //super.activate();
        }
        
        override public function deactivate():void {
            //super.deactivate();
        }
        
        private function setAttack(attack_id):void {
            _current_attack = _attacks[attack_id];
        }
        
        private function setState(state:String, is_animated:Boolean = false):void {
            trace("setState(): to ", state);
            
            frame_counter = 0;
            
            if ( is_animated ) costume.setAnimatedState(state);
            else costume.setState(state);
        }
        
        private function dellayedInitTimerListener(e:TimerEvent):void {
            var timer:Timer = Timer(e.target);
            timer.removeEventListener(TimerEvent.TIMER_COMPLETE, dellayedInitTimerListener);
        
            _current_attack = _attacks[INIT_STATE_ID];
            
            _current_attack.init_function();
            
            is_active = true;
        }
        
        override public function update():void {
            if ( !is_active ) return;
            
            frame_counter ++;
            
            if ( _current_attack.update_function ) {
                _current_attack.update_function();
            }
            
            if ( _current_attack.end_animation_frame != 0 ) {
                if ( frame_counter > _current_attack.end_animation_frame ) {
                    change_state = true;
                }
            }
            
            if ( change_state ) {
                change_state = false;
                
                if ( _current_attack.end_function ) {
                    _current_attack.end_function();
                }
                
                decideWhatToDo();
            }
            
            super.update();
        }
        
        private function decideWhatToDo():void {
            var attack:Attack;
            var num:Number;
            
            attack = _current_attack;
            
            while ( attack == _current_attack ) {
                num = Math.random();
                
                if ( num < 0.1 ) { // stand
                    attack = _attacks[STAND_STATE_ID];
                }
                else if ( num < 0.4 ) { // move right corner
                    attack = _attacks[MOVE_TO_RIGHT_CORNER_ID];
                }
                else if ( num < 0.8 ) { // hit arm
                    if ( player.y > y + costume.getCollider().height / 2 ) {
                        attack = _attacks[HIT_ARM_STATE_ID];
                    }
                }
                else { // move left corner
                    attack = _attacks[MOVE_TO_LEFT_CORNER_ID];
                }
            }
            
            _current_attack = attack;
            
            _current_attack.init_function();
        }
    }

}