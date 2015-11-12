package src  {
    
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    import src.bullets.*;
    import src.costumes.*;
    import src.interfaces.*;
    import src.objects.*;
    import src.ui.mageShop.*;
    import src.ui.StatChangeMessage;
    import src.util.*;
    
    
    public class Player extends AbstractObject implements ExtrudeObject {
//states
        /*public static const WALK_UP_STATE:String = "walk_up_state";
        public static const WALK_DOWN_STATE:String = "walk_down_state";
        public static const WALK_RIGHT_STATE:String = "walk_right_state";
        public static const WALK_LEFT_STATE:String = "walk_left_state";
        
        public static const STAND_UP_STATE:String = "stand_up_state";
        public static const STAND_DOWN_STATE:String = "stand_down_state";
        public static const STAND_RIGHT_STATE:String = "stand_right_state";
        public static const STAND_LEFT_STATE:String = "stand_left_state";
        
        public static const _STATE:String = "";*/
        
        public static const MAP_PICKUP_DURATION:Number = 700;
        
//stats
        public var MAX_HEALTH:uint = 6;
        public var MAX_MANA:uint = 14;
        private var _HEALTH:int = MAX_HEALTH;
        private var _MANA:int = MAX_MANA;
        private var _EXP:int = 0;
        public var EXP_TO_NEXT:int = 0;
        public var MONEY:int = 0;
        public var MAX_SPELLS:int = 2;
        public var MAX_ITEMS:int = 1;
        public var guess_combo:int = 0;
        
        public var spells:Array = [];
        
        public static var fixtureDef:b2FixtureDef;
//invincibility
        public var immune:Boolean = false;
        public static var invincibility_delay:Number = 140;
        var invincibilityTimer:Timer;
        
        static public var instance:Player = null; // D!
        
// переменные движения
        private var inputForce:b2Vec2 = new b2Vec2();
        private var DIRECTION_CHANGED:Boolean = false;
        public static var SPEED:uint = 40;
        public var MOVE_RIGHT:Boolean = false;
        public var MOVE_LEFT:Boolean = false;
        public var MOVE_UP:Boolean = false;
        public var MOVE_DOWN:Boolean = false;
        
// направление персонажа
        public static const END_STATE:String = "end";
        public static const STAND_STATE:String = "stand_";
        public static const DIR_LEFT_STATE:String = "_left";
        public static const DIR_RIGHT_STATE:String = "_right";
        public static const DIR_UP_STATE:String = "_up";
        public static const DIR_DOWN_STATE:String = "_down";
        
        private var state_label:String = DIR_UP_STATE;
        
        public var dir_x:Number;
        public var dir_y:Number;
        public var collider:DisplayObject; // delete me or not?
        
        public var is_picking:Boolean = false;
        public var holdObject:TaskObject = null;
        public static const HOLD_OBJECT_X:Number = -15;
        public static const HOLD_OBJECT_Y:Number = -30;
        
        private var messager:StatChangeMessage;
        
        public var currentRoom:Point = new Point(0,0);
        
        public function Player():void {
            // задаём стандартное направление
            costume = new PlayerCostume();
            costume.setType(PlayerCostume.STAND_TYPE);
            costume.setState(DIR_DOWN_STATE);
            dir_x = 0;
            dir_y = -1;

            // delete me
            collider = costume.getCollider();
            
            invincibilityTimer = new Timer(invincibility_delay,6);
            
            definePlayerFixture();
            
            messager = new StatChangeMessage();
        }
        
        private function definePlayerFixture():void {
            fixtureDef = new b2FixtureDef();
            fixtureDef.density = 1;
            fixtureDef.friction = 0.3;
            fixtureDef.userData = {"object": this}
            
            var collider:DisplayObject = costume.getCollider();
            
            var shape:b2PolygonShape = new b2PolygonShape();
            shape.SetAsBox(collider.width / 2 / Game.WORLD_SCALE, collider.height / 2 / Game.WORLD_SCALE);
            
            fixtureDef.shape = shape;
        }
        
        public function set HEALTH (hp:Number):void {
            if ( hp > MAX_HEALTH ) _HEALTH = MAX_HEALTH;
            else _HEALTH = hp;
            
            if ( hp <= 0 ) {
                hp = 0;
            }
        }
        
        public function get HEALTH ():Number {
            return _HEALTH;
        }
        
        public function set MANA (mp:Number):void {
            if ( mp > MAX_MANA ) _MANA = MAX_MANA;
            else _MANA = mp;
        }
        
        public function get MANA ():Number {
            return _MANA;
        }
        
        public function set EXP(exp:Number):void {
            _EXP = exp;
            if ( _EXP > EXP_TO_NEXT ) {
                
                EXP_TO_NEXT = getXPToLevel(LEVEL);
                
                if ( game && game.playerStat ) {
                    game.playerStat.update();
                }
            }
        }
        
        public function get EXP ():Number {
            return _EXP;
        }
        
        public function get LEVEL():int {
            var next_level_xp:Number = 0;
            var level = 0;
            
            while ( (next_level_xp = getXPToLevel(level) ) < _EXP ) {
                level ++;
            }
            
            return level;
        }
        
        public function init():void {
            messager.init();
            
            costume.scaleX = costume.scaleY = 1;
        }
        
        static public function getInstance():Player {
            if ( instance == null ) instance = new Player();
            return instance;
        }
        
        public function setActorBody(body:b2Body):void {
            this.body = body;
        }
        
        private function getXPToLevel(lvl:Number):Number{
            if ( lvl > 0 ) return 25 * lvl * lvl + getXPToLevel(lvl - 1);
            else return 25;
        }
        
        public function addSpell(str:String):void {
            spells[spells.length] = str;
        }
        
        // deprecated
        public function setInventory(inventory:Array):void {
            /*for ( var i:int = inventory.length - 1; i >= 0; i-- ) {
                if ( InventoryItem(inventory[i]).isSpell ) {
                    //inventory[i]
                    spells[spells.length - 1] = InventoryItem().item_name;
                }
            }*/
        }
        
        public function displayMessage(str:String):void {
            messager.requestDisplayMessage(str);
        }
        
        public function startPickingUp():void {
            SoundManager.instance.playSFX(SoundManager.SFX_PICKUP_OBJECT);
            
            is_picking = true;
            if (holdObject) holdObject.hide();
        }
        
        public function replaceHoldObject(obj:TaskObject):TaskObject {
            var tmpHLD:TaskObject = holdObject;
            
            holdObject = obj;
            obj.deactivate();
            obj.x = HOLD_OBJECT_X;
            obj.y = HOLD_OBJECT_Y;
            costume.addChild(obj.costume);
            obj.show();
            is_picking = false;
            
            if ( tmpHLD ) {
                game.cRoom.addActiveObject(tmpHLD);
                tmpHLD.activate();
                tmpHLD.show();
            }
            
            return tmpHLD;
        }
        
        public function handleInput(keyCode:uint, keyDown:Boolean = true):void {
            switch (keyCode) {
                case 37 :
                case 65 :
                    DIRECTION_CHANGED = true;
                    MOVE_LEFT = keyDown;
                    updateDirection();
                    break;
                case 38 :
                case 87 :
                    DIRECTION_CHANGED = true;
                    MOVE_UP = keyDown;
                    updateDirection();
                    break;
                case 39 :
                case 68 :
                    DIRECTION_CHANGED = true;
                    MOVE_RIGHT = keyDown;
                    updateDirection();
                    break;
                case 40 :
                case 83 :
                    DIRECTION_CHANGED = true;
                    MOVE_DOWN = keyDown;
                    updateDirection();
                    break;
            }
        }
        
        private function updateDirection():void {
            if ( MOVE_LEFT ) dir_x = -1;
            else if ( MOVE_RIGHT ) dir_x = 1;
            else if ( dir_y != 0 ) dir_x = 0;
            
            if ( MOVE_UP ) dir_y = -1;
            else if ( MOVE_DOWN ) dir_y = 1;
            else if ( dir_x != 0 ) dir_y = 0;
        }
        
        public function clearInput():void {
            MOVE_LEFT = false;
            MOVE_RIGHT = false;
            MOVE_DOWN = false;
            MOVE_UP = false;
            DIRECTION_CHANGED = false;
        }
        
        /** проверяет стоит ли персонаж */
        public function isStopped () :Boolean {
            return body.GetLinearVelocity().LengthSquared() < 0.3;
            //return false;
        }
        
        /** обновляет положение персонажа */
        public function preupdate():void {
            movePlayer();
        }
        
        private function movePlayer():void {
            inputForce.SetZero();
            
            if (MOVE_DOWN) {
                inputForce.y += SPEED;
            }
            if (MOVE_LEFT) {
                inputForce.x -= SPEED;
            }
            if (MOVE_RIGHT) {
                inputForce.x += SPEED;
            }
            if (MOVE_UP) {
                inputForce.y -= SPEED;
            }
            
            body.ApplyForce(inputForce, body.GetLocalCenter());
        }
        
        public function update():void {
            if ( !body || !_HEALTH ) return;
            
            var worldScale:Number = Game.WORLD_SCALE;
            var bodyPosition:b2Vec2 = body.GetPosition();
            
            costume.x = bodyPosition.x * worldScale;
            costume.y = bodyPosition.y * worldScale;
            
            if ( DIRECTION_CHANGED ) {
                applyDirectionChanges();
                costume.setType(PlayerCostume.MOVE_TYPE);
            }
            
            if ( isStopped() ) {
                costume.setType(PlayerCostume.STAND_TYPE);
            }
            
            costume.setState(state_label);
            
            updateHoldObject();
        }
        
        private function applyDirectionChanges():void {
            if ( dir_x != 0 ) {
                if ( dir_y > 0 ) state_label = DIR_DOWN_STATE;
                else if ( dir_y < 0 ) state_label = DIR_UP_STATE;
                else {
                    if ( dir_x > 0 ) state_label = DIR_RIGHT_STATE;
                    else state_label = DIR_LEFT_STATE;
                }
            }
            else {
                if ( dir_y > 0 ) state_label = DIR_DOWN_STATE;
                else if ( dir_y < 0 ) state_label = DIR_UP_STATE;
            }
        }
        
        private function updateHoldObject():void {
            if ( holdObject && holdObject is Updatable ) {
                Updatable(holdObject).update();
            }
        }
        
        public function changeStat(change:ChangePlayerStatObject):Boolean {
            var stat:String = change.stat_name;
            if ( this.hasOwnProperty(stat) ) {
                switch (stat) {
                    case ChangePlayerStatObject.HEALTH_STAT:
                        if ( change.is_enemy ) {
                            if ( immune ) return false;
                            immune = true;
                            startInvincibilityTimer();
                        }
                        else {
                            if ( _HEALTH == MAX_HEALTH ) return false;
                        }
                    break;
                    case ChangePlayerStatObject.MANA_STAT:
                        if ( change.delta < 0 ) {
                            if ( Math.abs(change.delta) > _MANA ) return false;
                        }
                        else {
                            if ( _MANA == MAX_MANA ) return false;
                        }
                    break;
                }
                
                if ( change.delta > 0 ) {
                    messager.requestDisplayDelta(change);
                }
                
                this[change.stat_name] += change.delta;
                return true;
            }
            return false;
        }
        
        public function addToStats(statObject:Object):Boolean {
            for ( var stat in statObject ) {
                if ( this.hasOwnProperty(stat) ) {
                    // if ( stat == "HEALTH" && HEALTH == MAX_HEALTH ) return false;
                    // if ( stat == "MANA" && MANA == MAX_MANA ) return false;
                    this[stat] += statObject[stat];
                }
            }
            game.playerStat.update();
            return true;
        }
        
        // delete me
        public function getColliderBad ():Collider {
            trace("Player.getCollider: NO WAY!! use public method");
            return collider as Collider;
        }
        
        public function makeHit (dmg:Number):Boolean {
            if (immune) return false;
            
            _HEALTH -= dmg;
            if ( HEALTH <= 0 ) {
                HEALTH = 0;
            }
            else {
                immune = true;
                startInvincibilityTimer();
            }
            return true;
        }
        
        private function startInvincibilityTimer() {
            invincibilityTimer.addEventListener(TimerEvent.TIMER, blink);
            invincibilityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, stopInvincibilityTimer);
            invincibilityTimer.reset();
            invincibilityTimer.start();
        }
        
        private function blink(e:TimerEvent) {
            costume.visible = !costume.visible;
        }
        
        private function stopInvincibilityTimer (e:TimerEvent) {
            immune = false;
            costume.visible = true;
            invincibilityTimer.stop();
        }
        
        public static function isImmune():Boolean {
            return false;
        }
        
        public function die() {
            costume.setType(PlayerCostume.DEATH_TYPE);
            costume.setAnimatedState();
        }
    }
}
