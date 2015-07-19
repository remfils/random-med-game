﻿package src.levels {
    import Box2D.Collision.Shapes.*;
    import Box2D.Common.Math.*;
    import Box2D.Dynamics.*;
    import flash.display.*;
    import src.*;
    import src.costumes.ObjectCostume;
    import src.enemy.*;
    import src.objects.*;
    import src.task.*;
    import src.util.*;
    
    
    public class Room extends MovieClip {
        private static const PLAYER_START_POINT:int = 100;
        
        private static const MIN_X:Number = 89.2;
        private static const MAX_X:Number = 662.75;
        private static const MIN_Y:Number = 91.55;
        private static const MAX_Y:Number = 413.1;
        private static const CENTER_X:Number = 372.8;
        private static const CENTER_Y:Number = 257.3;
        private static const HALF_DOOR_WIDTH:Number = 65 / 2;
        
        private var TIME_STEP:Number = Game.TIME_STEP;
        
        public var isSecret:Boolean = false;
        protected static const directions:Array = ["left", "right", "up", "down"]; // deleteme
        public static var taskManager:TaskManager; // deleteme
        
        public static const DOOR_DIRECTION_LEFT:int = 0;
        public static const DOOR_DIRECTION_UP:int = 1;
        public static const DOOR_DIRECTION_RIGHT:int = 2;
        public static const DOOR_DIRECTION_DOWN:int = 3;
        
        public static var game:Game;
        
        public var world:b2World;
        private static var gravity:b2Vec2 = new b2Vec2(0, 0);
        protected var ROOM_FRICTION:Number = 8;
        
        var _doors:Array = new Array(); // deleteme
        var _activeAreas:Vector.<DisplayObject> = new Vector.<DisplayObject>();
        var _gameObjects:Array = new Array();
        var _enemies:Array = new Array();
        public var drops:Array = new Array();
        
        var _tasks:Array = new Array(); // deleteme
        public var currentTask:Task = null;
        
        static var _player:Player;
        private var playerBody:b2Body;
        public var gameObjectPanel:GameObjectPanel;
        
        public var magic_bag:MagicBag;

        public function Room() {
            world = new b2World(gravity, true);
            world.SetContactListener(new ContactListener(game));
            gameObjectPanel = new GameObjectPanel();
            addChildAt(gameObjectPanel, numChildren);
            
            _player = game.player;
            
            createPlayerBody();
            
            addWalls();
            
            addDoors();
            
            magic_bag = new MagicBag();
            
            if (Game.TEST_MODE) setDebugDraw();
        }
        
        private function createPlayerBody():void {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.type = b2Body.b2_dynamicBody;
            bodyDef.fixedRotation = true;
            bodyDef.position.Set(PLAYER_START_POINT / Game.WORLD_SCALE, PLAYER_START_POINT / Game.WORLD_SCALE);
            
            playerBody = world.CreateBody(bodyDef);
            playerBody.SetLinearDamping(ROOM_FRICTION);
            playerBody.CreateFixture(Player.fixtureDef);
        }
        
        private function addWalls():void {
            
            // horisontal top box
            createWall( (CENTER_X - MIN_X ) / 2 + HALF_DOOR_WIDTH, MIN_Y - HALF_DOOR_WIDTH);
            createWall( (MAX_X - CENTER_X + HALF_DOOR_WIDTH) / 2 + CENTER_X + HALF_DOOR_WIDTH, MIN_Y - HALF_DOOR_WIDTH);
            
            // horisontal bottom box
            
            createWall( (CENTER_X - MIN_X ) / 2 + HALF_DOOR_WIDTH, MAX_Y + HALF_DOOR_WIDTH );
            createWall( (MAX_X - CENTER_X + HALF_DOOR_WIDTH) / 2 + CENTER_X + HALF_DOOR_WIDTH, MAX_Y + HALF_DOOR_WIDTH);
            
            // vertical left box
            createWall( MIN_X - HALF_DOOR_WIDTH , (CENTER_Y - MIN_Y ) / 2 + HALF_DOOR_WIDTH, true);
            
            createWall( MIN_X - HALF_DOOR_WIDTH, (MAX_Y - CENTER_Y + HALF_DOOR_WIDTH) / 2 + CENTER_Y + HALF_DOOR_WIDTH, true);
            
            // vertical right box
            createWall( MAX_X + HALF_DOOR_WIDTH , (CENTER_Y - MIN_Y ) / 2 + HALF_DOOR_WIDTH, true);
            createWall( MAX_X + HALF_DOOR_WIDTH , (MAX_Y - CENTER_Y + HALF_DOOR_WIDTH) / 2 + CENTER_Y + HALF_DOOR_WIDTH, true);
        }
        
        private function createWall(x_:Number, y_:Number, is_vertical_:Boolean = false):void {
            var gws:Number = Game.WORLD_SCALE;
            
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.type = b2Body.b2_staticBody;
            
            var wall_shape:b2PolygonShape = new b2PolygonShape()
            if ( is_vertical_ ) {
                wall_shape.SetAsBox( HALF_DOOR_WIDTH / gws, (CENTER_Y - MIN_Y + HALF_DOOR_WIDTH) / 2 / gws);
            }
            else {
                wall_shape.SetAsBox( (CENTER_X - MIN_X + HALF_DOOR_WIDTH) / 2 / gws , HALF_DOOR_WIDTH / gws );
            }
            
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.shape = wall_shape;
            
            bodyDef.position.Set(x_ / gws, y_ / gws);
            var bod:b2Body = world.CreateBody(bodyDef);
            bod.CreateFixture(fixtureDef);
        }
        
        private function addDoors():void {
            var i = 4;
            while ( i -- ) {
                _doors[i] = new Door();
                addChild(Door(_doors[i]).costume);
            }
            
            _doors[DOOR_DIRECTION_LEFT].costume.x = MIN_X;
            _doors[DOOR_DIRECTION_LEFT].costume.y = CENTER_Y;
            _doors[DOOR_DIRECTION_LEFT].costume.rotation = -90;
            
            _doors[DOOR_DIRECTION_UP].costume.x = CENTER_X;
            _doors[DOOR_DIRECTION_UP].costume.y = MIN_Y;
            _doors[DOOR_DIRECTION_UP].costume.rotation = 0;
            
            _doors[DOOR_DIRECTION_RIGHT].costume.x = MAX_X;
            _doors[DOOR_DIRECTION_RIGHT].costume.y = CENTER_Y;
            _doors[DOOR_DIRECTION_RIGHT].costume.rotation = 90;
            
            _doors[DOOR_DIRECTION_DOWN].costume.x = CENTER_X;
            _doors[DOOR_DIRECTION_DOWN].costume.y = MAX_Y;
            _doors[DOOR_DIRECTION_DOWN].costume.rotation = 180;
            
            i = _doors.length;
            while (i--) {
                Door(_doors[i]).requestBodyAt(world);
                Door(_doors[i]).hide();
            }
            
        }
        
        private function setDebugDraw():void {
            var debugDraw:b2DebugDraw = new b2DebugDraw();
            debugDraw.SetSprite(Game.TestModePanel);
            debugDraw.SetDrawScale(Game.WORLD_SCALE);
            debugDraw.SetFillAlpha(0.3);
            debugDraw.SetAlpha(0.3);
            debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_pairBit | b2DebugDraw.e_jointBit);
            
            world.SetDebugDraw(debugDraw);
        }
        
        override public function addChild(child:DisplayObject):DisplayObject {
            var obj:DisplayObject = super.addChild(child);
            setChildIndex(gameObjectPanel, numChildren - 1);
            return obj;
        }
        
        public function init():void {
            playerBody.SetAwake(false);
            playerBody.SetPosition(new b2Vec2(_player.x / Game.WORLD_SCALE, _player.y / Game.WORLD_SCALE));
            
            _player.setActorBody(playerBody);
            gameObjectPanel.addChild(_player.costume);
            
            var i:int = _enemies.length;
            while (i--) {
                _enemies[i].deactivate();
            }
            
            unlockDoorsWithoutTasks();
            
            if ( hasTask() ) {
                lock();
            }
        }
        
        private function unlockDoorsWithoutTasks():void {
            for each ( var door:Door in _doors ) {
                if ( !door.specialLock ) {
                    door.unlock();
                }
            }
        }
        
        public function unlockDoorsWithTaskID(task_id:int):void {
            for each (var door:Door in _doors ) {
                if (door.task_id == task_id) {
                    door.specialLock = false;
                    door.unlock();
                }
            }
        }
        
        public function addPlayerToWorld():void {
            //_player.getColliderBad();
        }
        
        public function addActiveObject(object:TaskObject):void {
            gameObjectPanel.addChild(object.costume);
            
            _gameObjects.push(object);
            
            // _activeAreas.push(object.getActiveArea()); // D!
            
            if ( !object.body ) {
                object.requestBodyAt(world);
            }
        }
        
        public function removeActiveObject(activeObject:TaskObject):void {
            var i:int = _gameObjects.length;
            
            while ( i-- ) {
                if ( _gameObjects[i] == activeObject ) {
                    _gameObjects.splice(i, 1);
                    break;
                }
            }
        }
        
        public function addEnemy(enemy:Enemy) {
            _enemies.push(enemy);
            gameObjectPanel.addChild(enemy.costume);
            enemy.cRoom = this;
            
            enemy.requestBodyAt(world);
            
            enemy.deactivate();
            
            if ( enemy is FlyingEnemy ) {
                FlyingEnemy(enemy).setTarget(playerBody);
            }
            
            // if (Game.TEST_MODE) trace("enemy added", enemy.x);
        }
        
        // depracated
        public function killEnemy(enemy:Enemy):void {
            //gameObjectPanel.removeChild(enemy);
            //world.DestroyBody(enemy.body);
            //removeEnemy(enemy)
        }
        
        public function removeEnemy(enemy:Enemy):void {
            var i = _enemies.length;
            while ( i-- ) {
                if ( _enemies[i] == enemy ) {
                    _enemies.splice(i, 1);
                    break;
                }
            }
        }
        
        public function addObstacle(obstacle:Obstacle):void {
            if ( obstacle.active ) _gameObjects.push(obstacle);
            gameObjectPanel.addChild(obstacle.costume);
            obstacle.requestBodyAt(world);
        }
        // delete me in GlassPanel
        public function getGameObjects():Array {
            return new Array();
        }
        
        // D!
        public function makeDoorWay (direction:int) {
            var door:Door = getDoorByDirection(direction);
            door.show();
        }
        
        public function getDoorByDirection(direction:int):Door {
            return _doors[direction] as Door;
        }
        
        public function update () {
            world.Step(TIME_STEP, 5, 5);
            world.ClearForces();
            
            updateEnemies();
            
            updateGameObjects();
            
            gameObjectPanel.update();
            
            if ( magic_bag ) magic_bag.update();
            
            if (Game.TEST_MODE) world.DrawDebugData();
        }
        
        private function updateEnemies() {
            var i = _enemies.length;
            while (i--) {
                _enemies[i].update();
            }
        }
        
        private function updateGameObjects():void {
            var i = _gameObjects.length;
            while ( i-- ) {
                _gameObjects[i].update();
            }
        }
        
        public function hasTask():Boolean {
            return currentTask != null;
        }
        
        public function changeTaskObjectsToCoins(task_id:int):void {
            var i = _gameObjects.length;
            
            while (i--) {
                if ( _gameObjects[i] is TaskObject && !(_gameObjects[i] is TaskDoorLock) ) {
                    var taskObject:TaskObject = _gameObjects[i] as TaskObject;
                    if ( taskObject.task_id == task_id ) {
                        game.deleteManager.add(taskObject);
                        ItemDropper.dropAtPointFrom([DropFactory.createCoin()], taskObject.x, taskObject.y);
                    }
                    
                }
                
            }
        }
        
        public function lock () {
            var i=_doors.length;
            
            while ( i-- ) {
                _doors[i].lock ();
            }
        }
        
        public function unlock () {
            var i=_doors.length;

            while ( i-- ) {
                _doors[i].unlock ();
            }
            
            unlockDoorsWithoutTasks();
        }
        
        public function setParametersFromXML (paramsXML:XMLList):void {
            var param:String = paramsXML.(name() == "type").toString();
            
            switch ( param ) {
                case "start_room":
                    gotoAndStop("start_room");
                break;
                case "secret_room":
                    gotoAndStop("secret_room");
                    isSecret = true;
                    for each (var door:Door in _doors) {
                        door.setType(Door.DOOR_SECRET_TYPE);
                    }
                break;
                case "end_room" :
                    gotoAndStop("end_room");
                break;
                default:
                    gotoAndStop("normal_room");
            }
            
            setChildIndex(gameObjectPanel, numChildren-1);
        }
        
        public function assignTask(task:Task) {
            currentTask = task;
            
            if ( currentTask == null ) {
                unlock();
                ItemDropper.dropAtPointFrom(drops, 387, 267);
            }
        }
        
        public function checkOverlapGameObjects(object:DisplayObject):Boolean {
            var i:int = gameObjectPanel.numChildren;
            while ( i-- ) {
                if ( gameObjectPanel.getChildAt(i).hitTestObject(object) ) {
                    return true;
                }
            }
            return false;
        }
        
        public function getTaskObjectNearPlayer():TaskObject {
            var i:int = _gameObjects.length;
            var playerCollider:DisplayObject = game.player.costume.getCollider();
            var activeArea:DisplayObject;
            while (i--) {
                if ( _gameObjects[i] is TaskObject ) {
                    activeArea = TaskObject(_gameObjects[i]).getActiveArea();
                    if ( activeArea.hitTestObject(playerCollider) ) return TaskObject(_gameObjects[i]);
                }
            }
            return null;
        }
        
        public function checkEnemiesForTask(task_id:int):Boolean {
            var i:int = _enemies.length;
            while (i--) {
                if ( _enemies[i].task_id == task_id ) return true;
            }
            return false;
        }
        
        public function createDrop():void {
            if (magic_bag.is_empty) return;
            
            var costume:ObjectCostume = magic_bag.open();
            costume.x = CENTER_X;
            costume.y = CENTER_Y;
            gameObjectPanel.addChild(costume);
        }
        
        public function exit():void {
            //removeEventListener(Game.GUESS_EVENT, taskManager.guessEventListener, true);
        }

    }
    
}
