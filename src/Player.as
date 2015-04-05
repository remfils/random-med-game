package src  {
    
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2FixtureDef;
    import flash.display.MovieClip;
    import flash.events.KeyboardEvent;
    import flash.geom.Point;
    import src.interfaces.ExtrudeObject;
    import src.interfaces.Updatable;
    import src.objects.AbstractObject;
    import src.util.Collider;
    
    import src.bullets.*;
    import src.ui.playerStat.PlayerStat;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    
    
    /**
     * Главный класс игрока
     */
    public class Player extends AbstractObject implements ExtrudeObject {
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
        
        public var spells:Array = [];
        
        public static var fixtureDef:b2FixtureDef;
//invincibility
        static var immune:Boolean = false;
        public static var invincibilityDelay:Number = 140;
        var invincibilityTimer:Timer;
        
        static public var instance:Player = null;
        
// переменные движения
        private var inputForce:b2Vec2 = new b2Vec2();
        private var DIRECTION_CHANGED:Boolean = false;
        public static var SPEED:uint = 40;
        public var MOVE_RIGHT:Boolean = false;
        public var MOVE_LEFT:Boolean = false;
        public var MOVE_UP:Boolean = false;
        public var MOVE_DOWN:Boolean = false;
        
// направление персонажа
        private const STAND_SATE:String = "stand_";
        private const DIR_LEFT:String = "left";
        private const DIR_RIGHT:String = "right";
        private const DIR_UP:String = "up";
        private const DIR_DOWN:String = "down";
        private var state_label:String = DIR_UP + MOVE_STATE;
        
        public var dir_x:Number;
        public var dir_y:Number;
        private var collider:MovieClip;
        
        public var holdObject:Object = null;
        
        public var currentRoom:Object = {x:0, y:0, z:0};
        
        public function Player():void {
            // задаём стандартное направление
            gotoAndStop("stand_down");
            dir_x = 0;
            dir_y = -1;

            // получаем коллайдер
            collider = getChildByName( "collider" ) as Collider;
            
            invincibilityTimer = new Timer(invincibilityDelay,6);
            
            definePlayerFixture();
        }
        
        private function definePlayerFixture():void {
            fixtureDef = new b2FixtureDef();
            fixtureDef.density = 1;
            fixtureDef.friction = 0.3;
        }
        
        public function set HEALTH (hp:Number):void {
            if ( hp > MAX_HEALTH ) _HEALTH = MAX_HEALTH;
            else _HEALTH = hp;
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
                
                if ( game ) {
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
        
        public function handleInput(keyCode:uint, keyDown:Boolean=true):void {
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
                case 32 :
                    makeHit(2);
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
            x = body.GetPosition().x * Game.WORLD_SCALE;
            y = body.GetPosition().y * Game.WORLD_SCALE;
            
            if ( DIRECTION_CHANGED ) {
                applyDirectionChanges();
                gotoAndStop(state_label);
            }
            
            if ( isStopped() ) {
                state_label += STAND_SATE;
                gotoAndStop(state_label);
            }
            
            updateHoldObject();
        }
        
        private function applyDirectionChanges():void {
            if ( dir_x != 0 ) {
                if ( dir_y > 0 ) state_label = DIR_DOWN;
                else if ( dir_y < 0 ) state_label = DIR_UP;
                else {
                    if ( dir_x > 0 ) state_label = DIR_RIGHT;
                    else state_label = DIR_LEFT;
                }
            }
            else {
                if ( dir_y > 0 ) state_label = DIR_DOWN;
                else if ( dir_y < 0 ) state_label = DIR_UP;
            }
        }
        
        private function updateHoldObject():void {
            if ( holdObject && holdObject is Updatable ) {
                Updatable(holdObject).update();
            }
        }
        
        public function addToStats(statObject:Object):Boolean {
            for ( var stat in statObject ) {
                if ( this.hasOwnProperty(stat) ) {
                    if ( stat == "HEALTH" && HEALTH == MAX_HEALTH ) return false;
                    if ( stat == "MANA" && MANA == MAX_MANA ) return false;
                    this[stat] += statObject[stat];
                }
            }
            game.playerStat.update();
            return true;
        }

        public function getCollider ():Collider {
            return collider;
        }
        
        public function makeHit (dmg:Number) {
            if (isImmune()) return;
            
            startInvincibilityTimer();

            HEALTH -= dmg;
            if ( HEALTH <= 0 ) {
                die();
                HEALTH = 0;
            }
            
            game.playerStat.update();
        }
        
        private function startInvincibilityTimer() {
            invincibilityTimer.addEventListener(TimerEvent.TIMER, blink);
            invincibilityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, stopInvincibilityTimer);
            invincibilityTimer.reset();
            invincibilityTimer.start();
            immune = true;
        }
        
        private function blink(e:TimerEvent) {
            visible = !visible;
        }
        
        private function stopInvincibilityTimer (e:TimerEvent) {
            immune = false;
            visible = true;
            invincibilityTimer.stop();
        }
        
        public static function isImmune():Boolean {
            return immune;
        }
        
        public function die() {
            trace("Player is dead");
        }
    }
}
