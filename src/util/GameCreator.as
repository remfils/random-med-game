package src.util {
    import fl.motion.Color;
    import flash.display.Sprite;
    import flash.text.StaticText;
    import src.bullets.Bombastic;
    import src.bullets.BombSpell;
    import src.bullets.BulletDef;
    import src.bullets.Spark;
    import src.enemy.ChargerEnemy;
    import src.enemy.Enemy;
    import src.Game;
    import src.levels.CastleLevel;
    import src.levels.Room;
    import flash.display.MovieClip;
	import src.interfaces.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.utils.*;
    import src.objects.AbstractObject;
    import src.objects.DecorObject;
    import src.objects.Door;
	import src.objects.Lever;
	import src.enemy.FlyingEnemy;
    import src.objects.Obstacle;
    import src.objects.StaticObstacle;
    import src.objects.TaskObject;
    import src.Player;
    import src.task.Task;
    import src.task.TaskManager;
    
    public class GameCreator {
        private var game:Game;
        private var gameTaskManager:TaskManager;
        private var floorCounter:int = 0;
        private var tintObjectsArray:Array = new Array();
        
        public function GameCreator() {
        }
        
        public function createLevelFromXML (game:Game, levelData:XML):void {
            gameTaskManager = game.taskManager;
            this.game = game;
            game.setLevel(createFloorArray(levelData));
        }
        
        private function createFloorArray(xmlLevel:XML):Array {
            var floors:Array = new Array();
            
            for each ( var floor:XML in xmlLevel.floor ) {
                addTasksToRoom(null, floor);
                floors.push( createRooms(floor) );
                floorCounter ++;
            }
            
            tintObjects();
            
            return floors;
        }
        
        private function createRooms (xmlFloor:XML):Array {
            var rooms:Array = new Array(),
                cRoom:CastleLevel = null;
            
            for each ( var room:XML in xmlFloor.room ) {
                cRoom = new CastleLevel(game);
                cRoom.x = room.@x * cRoom.width;
                cRoom.y = room.@y * cRoom.height;
                
                if ( !rooms[room.@x] ) {
                    rooms[room.@x] = new Array();
                }
                
                if ( room.@first_level == "true" ) {
                    Player.getInstance().currentRoom = {
                        x: room.@x,
                        y: room.@y,
                        z: floorCounter
                    };
                }
                
                addDecorationsToRoom(cRoom, room.wallDecorations.*);
                
                addObstaclesToRoom(cRoom, room.obstacles.*);
                
                addTasksToRoom(cRoom, room);
                addTaskObjectsToRoom(cRoom, room.active);
                addTasksToDoors(cRoom, room.Door);
                
                addEnemiesToRoom(cRoom, room.enemies);
                
                addDropsToRoom(cRoom, room.drop);
                
                cRoom.setParametersFromXML(room.@*);
                
                rooms[room.@x][room.@y] = cRoom;
            }
            
            rooms = makeDoorsInRooms(rooms);
            
            return rooms;
        }
        
        private function addDecorationsToRoom(cRoom:Room, wallDecorationsXML:XMLList):void {
            for each (var decorationNode:XML in wallDecorationsXML) {
                var decorObj:DecorObject = new DecorObject();
                decorObj.setType(decorationNode.name())
                
                decorObj.x = decorationNode.@x;
                decorObj.y = decorationNode.@y;
                
                if ( decorationNode.@flip == "true" ) {
                    decorObj.scaleX *= -1;
                }
                
                if ( decorationNode.@rotation ) {
                    decorObj.rotation = decorationNode.@rotation;
                }
                
                cRoom.addChild(decorObj);
            }
        }
        
        private function addObstaclesToRoom (cRoom:Room, obstaclesXMLList:XMLList):void {
            var obst:Obstacle;
            for each (var obstacle:XML in obstaclesXMLList) {
                obst = new Obstacle();
                obst.setType(obstacle.name());
                
                obstSprite.x = obstacle.@x;
                obstSprite.y = obstacle.@y;
                
                cRoom.addObstacle(obstSprite);
            }
        }
        
        private function addTasksToRoom(room:Room, roomXML:XML):void {
            var tasks:XMLList = roomXML.task;
            var enemies:XMLList = roomXML.enemies;
            var enemyCount:int = 0;
            
            for each (var task:XML in tasks) {
                switch (task.@type.toString()) {
                    case "levers":
                    case "keys":
                        gameTaskManager.addLeverTaskToRoom(room, task.@id, task.@color);
                    break;
                    
                    case "enemies":
                        enemyCount = enemies.(@task_id == task.@id).*.length();
                        gameTaskManager.addEnemyTaskToRoom(room, task.@id, enemyCount, task.@color );
                    break;
                    default:
                }
            }
        }
        
        private function addTaskObjectsToRoom (room:Room, activeObjectsXML:XMLList) {
            var taskId:int = activeObjectsXML.@taskId;
            
            for each ( var object:XML in activeObjectsXML.* ) {
                var ActiveObjectClass:Class = getDefinitionByName(object.name()) as Class;
                var currentObject:TaskObject = new ActiveObjectClass();
                
                currentObject.id = object.@id;
                currentObject.taskId = taskId;
                
                currentObject.x = object.@x;
                currentObject.y = object.@y;
                
                if ( object.@rotation ) {
                    currentObject.rotation = object.@rotation;
                }
                    
                room.addActiveObject(currentObject);
                        
                tintObjectsArray.push(currentObject);
            }
        }
        
        private function addTasksToDoors(room:Room, doorList:XMLList) {
            var doorName:String;
            var doorObj:Door;
            
            for each ( var door:XML in doorList ) {
                doorName = "door_" + door.@direction;
                doorObj = room.getChildByName(doorName) as Door;
                doorObj.setType(door.@type);
                
                doorObj.specialLock = true;
                if (door.@type == "task") {
                    doorObj.assignTask(door.@taskId);
                }
                
                tintObjectsArray.push(doorObj);
            }
        }
        
        private function addEnemiesToRoom (room:Room, enemiesXML:XMLList) {
            var taskId:uint = enemiesXML.@task_id;
            
            for each ( var object:XML in enemiesXML.* ) {
                var enemyClass:Class = getDefinitionByName(object.name()) as Class;
                
                var enemy:Enemy = new enemyClass() as Enemy;
                
                enemy.cRoom = room;
                enemy.taskId = taskId;
                
                enemy.setPosition(object.@x,object.@y);
                
                room.addEnenemy(enemy);
            }
        }
        
        private function addDropsToRoom(cRoom:Room, dropsXML:XMLList):void {
            var drops:Array = new Array();
            
            for each ( var drop:XML in dropsXML.* ) {
                switch ( drop.name().toString() ) {
                    case "SmallHP":
                        drops.push( DropFactory.createSmallHealthPotion(drop.@p) );
                    break;
                    
                    case "SmallMP":
                        drops.push( DropFactory.createSmallManaPotion(drop.@p) );
                    break;
                    
                    case "Exit":
                        drops.push( DropFactory.createExitObject() );
                    break;
                }
            }
            
            cRoom.drops = drops;
        }
        
        private function createParameters(roomParams):Object {
            var paramObj:Object = new Object();
            for (var N in roomParams) {
                paramObj[roomParams[N].name().toString()] = roomParams[N].toString();
            }
            return paramObj;
        }
    
        private function makeDoorsInRooms(rooms:Array):Array {
            for ( var i in rooms ) {
                for ( var j in rooms[i] ) {
                    if ( j < rooms[i].length-1 && rooms[i][j+1] ){
                        rooms[i][j].makeDoorWay("down");
                    }
                    if ( j > 0 && rooms[i][j-1] ){
                        rooms[i][j].makeDoorWay("up");
                    }
                    if ( i > 0 && rooms[i-1][j] ){
                        rooms[i][j].makeDoorWay("left");
                    }
                    if ( i < rooms.length-1 && rooms[i+1][j] ){
                        rooms[i][j].makeDoorWay("right");
                    }
                }
            }
            
            return rooms;
        }
        
        private function tintObjects():void {
            var i:int = tintObjectsArray.length;
            var colorNumber:uint = 0;
            while ( i-- ) {
                colorNumber = gameTaskManager.getTaskColor(tintObjectsArray[i].taskId);
                if ( colorNumber ) {
                    AbstractObject(tintObjectsArray[i]).setTint(colorNumber);
                }
            }
        }
        
        
        public static function setGameStats(stats:XML):void {
            var stat:XMLList = stats.player;
            Player.invincibilityDelay = stat.invincibility_time;
            Player.SPEED = stat.speed;
            
            stat = stats.enemy;
            Enemy.MAX_HEALTH = stat.health;
            Enemy.agroDistance = stat.agroDistance;
            FlyingEnemy.SPEED = stat.speedMultiplier;
            
            stat = stats.rat;
            ChargerEnemy.SPEED = stat.normalSpeed;
            ChargerEnemy.CHARGE_SPEED = stat.chargeSpeed;
            
            stat = stats.spells.large;
            BombSpell.bulletDef = new BulletDef(stat.damage, stat.speed, stat.manaCost, stat.delay);
            
            stat = stats.spells.spark;
            Spark.bulletDef = new BulletDef(stat.damage, stat.speed, stat.manaCost, stat.delay);
            
            stat = stats.spells.bomb;
            Bombastic.bulletDef = new BulletDef(stat.damage, stat.speed, stat.manaCost, stat.delay);
            Bombastic.BLAST_RADIUS = stat.blastRadius;
        }
    }

}