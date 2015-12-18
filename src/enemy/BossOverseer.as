package src.enemy {
    import Box2D.Collision.b2Point;
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
    import src.util.Random;


    public class BossOverseer extends Enemy implements Init {
        public static var LEFT_WALL_EYE_X:Number = 184.85;
        public static var WALL_EYE_Y:Number = 59.75;
        public static var TOP_Y:Number = 130;
        public static var LEFT_X:Number = 156.8;
        public static var RIGHT_X:Number = 592.25;
        
        public static var _movement_speed:Number = 15; // D!
        public static var MOVEMENT_START_ACCELERATION:Number = 0.7;
        public static var DENSITY:Number = 0.5;
        public static var FRICTION:Number = 0.8;
        public static var TMP_FORCE_MULTIPLIER:Number = 2;
        public static var MAX_HEALTH:int = 500;
        public static var TMP_FORCE_MAX_LENGTH:Number = 3;
        public static var LINEAR_DAMPING:Number = 0;
        
        private const HEALTH_AT_FIRST_TEST:int = MAX_HEALTH - MAX_HEALTH / 4;
        private const HEALTH_AT_SECOND_TEST:int = MAX_HEALTH - 3 * MAX_HEALTH / 4;
        
        private static const INIT_STATE:String = "_init";
        private static const SWING_STATE:String = "_charge";
        private static const STAND_STATE:String = "_stand";
        private static const HIT_ARM_STATE:String = "_armHit";
        private static const OPEN_EYES_STATE:String = "_openEyes";
        //private static const
        
        private static const FRAME_SWING_ARM_END:int = 4; // 6
        private static const FRAME_HIT_ARM_ATTACK_START:int = 3;
        private static const FRAME_HIT_ARM_END:int = 15;
        private static const FRAME_HIT_ARM_ATTACK_END:int = 5;
        private static const FRAME_OPEN_EYES_DELLAY:int = 15 + 20;
        private static const FRAME_OPEN_EYES_END:int = 14;
        private static const FRAME_FIRE_EYES_END:int = 14 + 20;
        public static var FRAME_ATTACK_DELLAY:int = 15;
        private static const FRAME_DEATH_END:int = 103;
        public static var FRAME_TMP_FORCE_ACT_END:int = 10;
        public static var FRAME_EYES_CLOSED:int = 15;
        
        private static const FRAME_INIT_END:int = 58;

        private var _end_animation_frame:int = 0;
        
        private var _state:int = 0;
        
        private const INIT_STATE_ID:int = 1;
        private const SWING_STATE_ID:int = 2;
        private const STAND_STATE_ID:int = 3;
        private const HIT_ARM_STATE_ID:int = 4;
        private const HIT_ARM_MOVING_STATE_ID:int = 7;
        private const MOVE_TO_LEFT_CORNER_ID:int = 5;
        private const MOVE_TO_RIGHT_CORNER_ID:int = 6;
        private const SPAWN_EYES_ID:int = 8;
        private const ATTACK_FINISH_STATE_ID:int = 9;
        private const DEATH_STATE_ID:int = 10;
        
        private var sub_state:int = 0;
        private const SPAWN_START_MOVING:int = 1;
        private const SPAWN_SPAWN_EYS:int = 2;
        private const SPAWN_OPEN_EYES:int = 3;
        private const WAIT_BEFORE_OPEN_EYES:int = 5;
        private const SPAWN_REMOVE_EYES:int = 4;
        private const SUBSTATE_EYES_FIRE:int = 6;
        private const SUBSTATE_EYES_FIRE_END:int = 7;
        
        private var change_state:Boolean = false;
        private var _destination:b2Vec2 = new b2Vec2();
        
        private var _attacks:Vector.<Attack>;
        
        private var _current_attack:Attack;
        
        private var _anchor:b2Body;
        private var _move_joint:b2LineJoint;
        private var _joint_def:b2LineJointDef;
        private var _movement_force:b2Vec2 = new b2Vec2();
        
        
        private var _test_attack_counter:int = 0;
        private var _wall_eyes:Vector.<WallEye>;
        
        public function BossOverseer() {
            super();
            
            _attacks = new Vector.<Attack>(20);
            _attacks[0] = null;
            _attacks[INIT_STATE_ID] = new Attack(FRAME_INIT_END, initInitAttack, null, initEndAttack);
            _attacks[STAND_STATE_ID] = new Attack(100, standInitAttack);
            _attacks[MOVE_TO_LEFT_CORNER_ID] = new Attack(0, moveLeftCornerInitAttack, moveAnyUpdateAttack, moveAnyEndAttack);
            _attacks[MOVE_TO_RIGHT_CORNER_ID] = new Attack(0, moveRightCornerInitAttack, moveAnyUpdateAttack, moveAnyEndAttack);
            _attacks[HIT_ARM_STATE_ID] = new Attack(0, hitArmInitAttack, hitArmUpdateAttack);
            _attacks[SPAWN_EYES_ID] = new Attack(0, spawnEyesInitAttack, spawnEyesUpdateAttack, spawnEyesEndAttack);
            _attacks[DEATH_STATE_ID] = new Attack(0, initDeathAttack, updateDeathAttack);
            
            this.health = MAX_HEALTH;
            this.costume_remove_delay = FRAME_DEATH_END / Game.FRAMES_PER_MILLISECOND;
            
            _wall_eyes = new Vector.<WallEye>();
        }
        
// + поведение
        
        private function initInitAttack():void {
            setState(INIT_STATE, true);
            body.SetActive(false);
            isFlip = false;
        }
        
        private function initEndAttack():void {
            body.SetActive(true);
            isFlip = true;
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
            }
        }
        
        private function moveWithTemporalForce():void {
            if ( current_frame < FRAME_TMP_FORCE_ACT_END ) {
                body.ApplyForce(_movement_force, body.GetLocalCenter());
                
                if ( _movement_force.Length() < TMP_FORCE_MAX_LENGTH )
                    _movement_force.Multiply(TMP_FORCE_MULTIPLIER);
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
            isFlip = false;
            removeJointAndStop();
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
            
            _joint_def.enableLimit = true;
            _joint_def.lowerTranslation = 0;
            _joint_def.upperTranslation = l;
            
            _move_joint = b2LineJoint(body.GetWorld().CreateJoint(_joint_def));
            body.SetAwake(true);
            
            _movement_force = p.Copy();
            _movement_force.Multiply( -MOVEMENT_START_ACCELERATION);
            
            costume.scaleX = x < this.x ? -1 : 1;
            
            isFlip = false;
        }
        
        private function hitArmInitAttack():void {
            setState(SWING_STATE, true);
            _state = SWING_STATE_ID;
            moveTo( player.x, player.y - player.collider.height / 2 - costume.getCollider().height / 2 - 10);
        }
        
        private function hitArmUpdateAttack():void {
            if ( _state == SWING_STATE_ID ) {
                if ( current_frame > FRAME_SWING_ARM_END ) {
                    current_frame = 0;
                    _state = HIT_ARM_MOVING_STATE_ID;
                    costume.stop();
                }
            }
            else if ( _state == HIT_ARM_MOVING_STATE_ID ) {
                moveWithTemporalForce();
                
                if ( hasArrivedToDestination() ) {
                    moveAnyEndAttack();
                    
                    setState(HIT_ARM_STATE, true);
                    
                    _state = HIT_ARM_STATE_ID;
                }
            }
            else if ( _state == HIT_ARM_STATE_ID ) {
                if ( current_frame >= FRAME_HIT_ARM_ATTACK_START && current_frame <= FRAME_HIT_ARM_ATTACK_END ) {
                    if ( costume.getCollider().hitTestObject(player.collider) ) {
                        game.changePlayerStat(new ChangePlayerStatObject(ChangePlayerStatObject.HEALTH_STAT, -2, 0, true));
                    }
                }
                if ( current_frame >= FRAME_HIT_ARM_END ) {
                    setState(STAND_STATE);
                    _state = ATTACK_FINISH_STATE_ID;
                }
            }
            else if ( _state == ATTACK_FINISH_STATE_ID ) {
                if ( current_frame >= FRAME_ATTACK_DELLAY ) {
                    change_state = true;
                }
            }
        }
        
        private function spawnEyesInitAttack():void {
            moveTo(37.15, 75.05);
            
            sub_state = SPAWN_START_MOVING;
            
            setState(STAND_STATE);
        }
        
        private function spawnEyesUpdateAttack():void {
            switch ( sub_state ) {
                case SPAWN_START_MOVING:
                    moveWithTemporalForce();
                    
                    if ( hasArrivedToDestination() ) {
                        moveAnyEndAttack();
                        
                        sub_state = SPAWN_SPAWN_EYS;
                        
                        setState(STAND_STATE);
                    }
                    break;
                case SPAWN_SPAWN_EYS:
                    if ( _wall_eyes.length == 0 ) {
                        var eye:WallEye;
                        for ( var i:int = 0; i < 3; i++ ) {
                            eye = new WallEye();
                            eye.x = LEFT_WALL_EYE_X + i * (5 + eye.costume.width);
                            eye.y = WALL_EYE_Y;
                            _wall_eyes.push(eye);
                            cRoom.add(eye);
                        }
                    }
                    
                    sub_state = WAIT_BEFORE_OPEN_EYES;
                    break;
                case WAIT_BEFORE_OPEN_EYES:
                    if ( currentFrame > FRAME_OPEN_EYES_DELLAY ) {
                        var closed_eye_index:int = Random.getOneFromThree() - 1;
                        var i:int = _wall_eyes.length;
                        
                        while ( i-- ) {
                            if ( i != closed_eye_index ) {
                                _wall_eyes[i].open();
                            }
                        }
                        
                        setState(OPEN_EYES_STATE, true);
                        
                        sub_state = SUBSTATE_EYES_FIRE;
                    }
                    break;
                case SUBSTATE_EYES_FIRE:
                    if ( current_frame > FRAME_OPEN_EYES_END ) {
                        setState(STAND_STATE);
                        sub_state = SUBSTATE_EYES_FIRE_END;
                    }
                    break;
                case SUBSTATE_EYES_FIRE_END:
                    if ( current_frame > FRAME_EYES_CLOSED ) {
                        change_state = true;
                    }
                    break;
            }
            
        }
        
        private function spawnEyesEndAttack():void {
            var eye:WallEye;
            
            while ( _wall_eyes.length ) {
                eye = _wall_eyes.pop();
                
                eye.die();
            }
        }
        
        private function initDeathAttack ():void {
            setState(DEATH_STATE, true);
        }
        
        private function updateDeathAttack ():void {
            if ( current_frame > FRAME_DEATH_END ) {
                costume.stop();
                cRoom.remove(this);
            }
        }
        
// - поведение
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var req:CreateBodyRequest = super.requestBodyAt(world);
            
            req.setAsDynamicSensor();
            
            req.fixture_defs[0].friction = DENSITY;
            req.fixture_defs[0].density = FRICTION;
            
            req.bodyDef.linearDamping = LINEAR_DAMPING;
            
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
        
        private function dellayedInitTimerListener(e:TimerEvent):void {
            var timer:Timer = Timer(e.target);
            timer.removeEventListener(TimerEvent.TIMER_COMPLETE, dellayedInitTimerListener);
        
            _current_attack = _attacks[INIT_STATE_ID];
            
            _current_attack.init_function();
            
            is_active = true;
        }
        
        override public function update():void {
            if ( !is_active ) return;
            
            currentFrame ++;
            
            if ( _current_attack.update_function ) {
                _current_attack.update_function();
            }
            
            if ( _current_attack.end_animation_frame != 0 ) {
                if ( current_frame > _current_attack.end_animation_frame ) {
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
            
            switch ( _test_attack_counter ) {
                case 0:
                    if ( health < HEALTH_AT_FIRST_TEST ) {
                        attack = _attacks[SPAWN_EYES_ID];
                        _test_attack_counter++;
                    }
                    break;
                case 1:
                    if ( health < HEALTH_AT_SECOND_TEST ) {
                        attack = _attacks[SPAWN_EYES_ID];
                        _test_attack_counter++;
                    }
                    break;
            }
            
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
        
        override public function die():void {
            super.die();
            
            _current_attack = _attacks[DEATH_STATE_ID];
            _current_attack.init_function();
        }
        
        override public function destroy():void {
            game.deleteManager.add(body);
        }
    }

}