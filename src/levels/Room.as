﻿package src.levels {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2DebugDraw;
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.MovieClip;
    import src.interfaces.ExtrudeObject;
    import src.objects.Lever;
    import src.task.TaskManager;
    import src.util.DropFactory;
    import src.util.GameObjectPanel;
    import src.util.ItemDropper;
    import src.util.Random;
    import src.interfaces.Updatable;
    import src.objects.*;
    import src.events.RoomEvent;
    import src.util.Collider;
    import src.Game;
    import src.enemy.*;
    
    import src.Player;
    import flash.events.Event;
    import src.task.Task;
    
    public class Room extends MovieClip {
        public var isSecret:Boolean = false;
        protected static const directions:Array = ["left", "right", "up", "down"];
        public static var taskManager:TaskManager;

        public var game:Game;
        
        public var world:b2World;
        private static var gravity:b2Vec2 = new b2Vec2(0, 0);
        protected var ROOM_FRICTION:Number = 8;
        
        var _doors:Array = new Array();
        var _gameObjects:Array = new Array();
        var _enemies:Array = new Array();
        public var drops:Array = new Array();
        
        var _tasks:Array = new Array();
        var currentTask:Task = null;
        
        static var _player:Player;
        private var playerBody:b2Body;
        public var gameObjectPanel:GameObjectPanel;

        public function Room(game:Game) {
            this.game = game;
            
            world = new b2World(gravity, true);
            world.SetContactListener(new ContactListener(game));
            gameObjectPanel = new GameObjectPanel();
            addChild(gameObjectPanel);
            
            _player = Player.getInstance();
            
            createPlayerBody();
            
            addWalls();
            
            addDoors();
            
            if (Game.TEST_MODE) setDebugDraw();
        }
        
        private function createPlayerBody():void {
            var collider:Collider = _player.getCollider().copy();
            
            playerBody = collider.replaceWithDynamicB2Body(world, Player.fixtureDef);
            
            playerBody.GetFixtureList().SetUserData( { "object": _player } );
            
            playerBody.SetPosition(new b2Vec2(300 / Game.WORLD_SCALE, 200 / Game.WORLD_SCALE));
            playerBody.SetLinearDamping(ROOM_FRICTION);
            playerBody.SetFixedRotation(true);
        }
        
        private function addWalls():void {
            var i = 8;
            var collider:Collider = new Collider();
            while ( i-- ) {
                collider = getChildByName ( "wall" + i ) as Collider
                collider.replaceWithStaticB2Body(world);
            }
        }
        
        private function addDoors():void {
            var collider:Collider, door:Door, name:String, wall:b2Body;
            for each ( var direction:String in directions) {
                name = "door_" + direction;
                door = getChildByName(name) as Door;
                
                name = "door_collider_" + direction;
                collider = getChildByName(name) as Collider;
                wall = collider.replaceWithStaticB2Body(world, { 'object' : door });
                door.setWall(wall);
                
                name = "exit_" + direction;
                collider = getChildByName(name) as Collider;
                wall = collider.replaceWithSensor(world, { 'object' : door });
                door.setExit(wall);
                
                door.hide();
                
                _doors.push(door);
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
            gameObjectPanel.addChild(_player);
            
            addEventListener("GUESS_EVENT", taskManager.guessEventListener, true);
            
            unlockDoorsWithoutTasks();
            
            if ( hasTask() ) {
                lock();
            }
        }
        
        private function unlockDoorsWithoutTasks():void {
            for each ( var door:Door in _doors ) {
                if ( door.specialLock ) {
                    if ( door.taskId != 0 && !game.taskManager.findTaskById(door.taskId) ) {
                        door.specialLock = false;
                        door.unlock();
                    }
                }
            }
        }
        
        public function addPlayerToWorld():void {
            _player.getCollider();
        }
        
        public function addActiveObject(object:TaskObject):void {
            gameObjectPanel.addChild(object as DisplayObject);
            
            _gameObjects.push(object);
            
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
        
        public function addEnenemy(object:Enemy) {
            _enemies.push(object);
            object.requestBodyAt(world);
            gameObjectPanel.addChild(object);
            
            if ( object is FlyingEnemy ) {
                FlyingEnemy(object).setTarget(playerBody);
            }
            
            if (Game.TEST_MODE) trace("enemy added", object.x);
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
            _gameObjects.push(obstacle);
            gameObjectPanel.addChild(obstacle);
            obstacle.requestBodyAt(world);
        }
        // delete me in GlassPanel
        public function getGameObjects():Array {
            return new Array();
        }
        
        public function makeDoorWay (direction:String) {
            var door:Door = getDoorByDirection(direction);
            door.show();
            door.unlock();
        }
        
        public function getDoorByDirection(direction:String):Door {
            return getChildByName("door_" + direction) as Door;
        }
        
        public function update () {
            world.Step(Game.TIME_STEP, 5, 5);
            world.ClearForces();
            
            updateEnemies();
            
            updateGameObjects();
            
            gameObjectPanel.update();
            
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
                if ( _gameObjects[i] is TaskObject && !(_gameObjects[i] is DoorLock) ) {
                    var taskObject:TaskObject = _gameObjects[i] as TaskObject;
                    if ( taskObject.taskId == task_id ) {
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
                break;
                case "end_room" :
                    gotoAndStop("end_room");
                break;
                default:
                    gotoAndStop("normal_room");
            }
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
        
        public function exit():void {
            removeEventListener("GUESS_EVENT", taskManager.guessEventListener, true);
        }

    }
    
}
