package src.util {
    import flash.utils.*;
    import src.costumes.CostumeEnemy;
    import src.costumes.DecorCostume;
    import src.enemy.ChargerEnemy;
    import src.enemy.Enemy;
    import src.enemy.FlyingEnemy;
    import src.enemy.Sniper;
    import src.Game;
    import src.interfaces.*;
    import src.levels.CastleLevel;
    import src.levels.Room;
    import src.objects.AbstractObject;
    import src.objects.Door;
    import src.objects.Obstacle;
    import src.objects.TaskDoorLock;
    import src.objects.TaskKey;
    import src.objects.TaskLever;
    import src.objects.TaskObject;
    import src.task.KillEnemyTask;
    import src.task.Record;
    import src.task.Task;
    import src.task.TaskManager;
    
    public class LevelParser {
        private var game:Game;
        private var gameTaskManager:TaskManager;
        private var floorCounter:int = 0;
        private var tintObjectsArray:Array = new Array();
        
        public function LevelParser() {
        }
        
        public function createLevelFromXML (game:Game, levelData:XML):void {
            gameTaskManager = game.taskManager;
            this.game = game;
            game.setLevel(createFloorArray(levelData));
        }
        
        private function createFloorArray(xmlLevel:XML):Array {
            var floors:Array = new Array();
            
            for each ( var floor:XML in xmlLevel.floor ) {
                //addTasksToRoom(null, floor);
                floors.push( createRooms(floor) );
                floorCounter ++;
            }
            
            // tintObjects();
            
            return floors;
        }
        
        private function createRooms (xmlFloor:XML):Array {
            var rooms:Array = new Array(),
                cRoom:CastleLevel = null;
            
            for each ( var roomXML:XML in xmlFloor.room ) {
                cRoom = new CastleLevel();
                cRoom.x = roomXML.@x * cRoom.width;
                cRoom.y = roomXML.@y * cRoom.height;
                
                if ( !rooms[roomXML.@x] ) {
                    rooms[roomXML.@x] = new Array();
                }
                
                if ( roomXML.@first_level == "true" ) {
                    game.player.currentRoom.x = roomXML.@x;
                    game.player.currentRoom.y = roomXML.@y;
                    
                    var doorXML:XML = roomXML.Door.(@type == Door.DOOR_START_TYPE)[0];
                    
                    var door:Door = Door(cRoom.getDoorByDirection(doorXML.@direction));
                    
                    door.show();
                    door.setType(Door.DOOR_START_TYPE);
                    
                    // place player in front of the door
                    var angle:Number = door.costume.rotation * Math.PI / 180;
                    Game.PLAYER_START_X = door.x - game.player.collider.width * Math.sin(angle);
                    Game.PLAYER_START_Y = door.y + game.player.collider.height * Math.cos(angle);
                }
                
                addDecorationsToRoom(cRoom, roomXML.wallDecorations.*);
                
                addObstaclesToRoom(cRoom, roomXML.obstacles.*);
                
                addTasksToRoom(cRoom, roomXML);
                addTaskObjectsToRoom(cRoom, roomXML.active);
                addTasksToDoors(cRoom, roomXML.Door);
                
                addEnemiesToRoom(cRoom, roomXML.enemies);
                
                addDropsToRoom(cRoom, roomXML.drop);
                
                cRoom.setParametersFromXML(roomXML.@ * );
                
                cRoom.magic_bag.readXML(roomXML.drop);
                
                rooms[roomXML.@x][roomXML.@y] = cRoom;
            }
            
            rooms = makeDoorsInRooms(rooms);
            
            return rooms;
        }
        
        private function addDecorationsToRoom(cRoom:Room, wallDecorationsXML:XMLList):void {
            for each (var decorationNode:XML in wallDecorationsXML) {
                var decorObj:DecorCostume = new DecorCostume();
                decorObj.readXMLParams(decorationNode);
                cRoom.addChild(decorObj);
            }
        }
        
        private function addObstaclesToRoom (cRoom:Room, obstaclesXMLList:XMLList):void {
            var obst:Obstacle;
            for each (var obstacle:XML in obstaclesXMLList) {
                obst = new Obstacle();
                obst.readXMLParams(obstacle);
                cRoom.addObstacle(obst);
            }
        }
        
        private function addTasksToRoom(room:Room, roomXML:XML):void {
            var tasks:XMLList = roomXML.task;
            var enemies:XMLList = roomXML.enemies;
            var enemyCount:int = 0;
            var task:Task;
            var task_type:int;
            
            for each (var taskXML:XML in tasks) {
                task_type = taskXML.@type;
                switch (task_type) {
                    case Record.LEVER_PULL_TYPE:
                    case Record.KEY_USED_TYPE:
                    //case Task.KEY_USED_RECORD:
                        task = new Task();
                    break;
                    case Record.ENEMY_KILL_TYPE:
                        task = new KillEnemyTask();
                    break;
                    default:
                        continue;
                }
                task.readXML(taskXML);
                gameTaskManager.assignTaskToRoom(task, room);
            }
        }
        
        private function addTaskObjectsToRoom (room:Room, activeObjectsXML:XMLList) {
            var taskId:int = activeObjectsXML.@taskId;
            var taskObj:TaskObject;
            var objName:String;
            
            for each ( var object:XML in activeObjectsXML.* ) {
                objName = object.name();
                switch (objName) {
                    case TaskLever.LEVER_TYPE:
                        taskObj = new TaskLever();
                    break;
                    case TaskKey.KEY_TYPE:
                        taskObj = new TaskKey();
                    break;
                    case TaskDoorLock.LOCK_TYPE:
                        taskObj = new TaskDoorLock();
                    break;
                default:
                    Output.add("object " +objName + " not found when creating taskobjects");
                    return;
                }
                taskObj.readXMLParams(object);
                
                room.addActiveObject(taskObj);
                //tintObjectsArray.push(taskObj);
            }
        }
        
        private function addTasksToDoors(room:Room, doorList:XMLList) {
            var door:Door;
            
            for each ( var doorXML:XML in doorList ) {
                door = room.getDoorByDirection(doorXML.@direction);
                
                door.specialLock = true;
                door.readXMLParams(doorXML);
            }
        }
        
        // setPositionBad -> setPosition
        private function addEnemiesToRoom (room:Room, enemiesXML:XMLList) {
            var taskId:uint = enemiesXML.@task_id;
            var enemy:Enemy;
            var enemyName:String;
            
            for each ( var object:XML in enemiesXML.* ) {
                enemyName = object.name();
                switch ( enemyName ) {
                    case CostumeEnemy.GHOST:
                        enemy = new FlyingEnemy();
                    break;
                    case CostumeEnemy.RAT:
                        enemy = new ChargerEnemy();
                    break;
                    case CostumeEnemy.MONK:
                        enemy = new Sniper();
                        break;
                    default: continue;
                }
                
                enemy.readXMLParams(object);
                
                room.addEnemy(enemy);
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
                        connectRooms(Room(rooms[i][j]), Room(rooms[i][j+1]), Room.DOOR_DIRECTION_DOWN);
                    }
                    if ( j > 0 && rooms[i][j-1] ){
                        connectRooms(Room(rooms[i][j]), Room(rooms[i][j-1]), Room.DOOR_DIRECTION_UP);
                    }
                    if ( i > 0 && rooms[i-1][j] ){
                        connectRooms(Room(rooms[i][j]), Room(rooms[i-1][j]), Room.DOOR_DIRECTION_LEFT);
                    }
                    if ( i < rooms.length-1 && rooms[i+1][j] ){
                        connectRooms(Room(rooms[i][j]), Room(rooms[i+1][j]), Room.DOOR_DIRECTION_RIGHT);
                    }
                }
            }
            
            return rooms;
        }
        
        private function connectRooms(roomA:Room, roomB:Room, dir:int):void {
            var door:Door = roomA.getDoorByDirection(dir);
            door.show();
            
            switch (dir) {
                case Room.DOOR_DIRECTION_DOWN:
                    dir = Room.DOOR_DIRECTION_UP;
                break;
                case Room.DOOR_DIRECTION_UP:
                    dir = Room.DOOR_DIRECTION_DOWN;
                break;
                case Room.DOOR_DIRECTION_LEFT:
                    dir = Room.DOOR_DIRECTION_RIGHT;
                break;
                case Room.DOOR_DIRECTION_RIGHT:
                    dir = Room.DOOR_DIRECTION_LEFT;
                break;
            }
            
            door = roomB.getDoorByDirection(dir);
            door.show();
            
            if (roomA.isSecret) {
                door.setType(Door.DOOR_SECRET_TYPE);
            }
        }
        
        private function tintObjects():void {
            return;
            var i:int = tintObjectsArray.length;
            var colorNumber:uint = 0;
            while ( i-- ) {
                colorNumber = gameTaskManager.getTaskColor(tintObjectsArray[i].taskId);
                if ( colorNumber ) {
                    AbstractObject(tintObjectsArray[i]).setTint(colorNumber);
                }
            }
        }
        
        // D!
        public static function setGameStats(stats:XML):void {
            /*var stat:XMLList = stats.player;
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
            BombSpell.bulletDef = new BulletDef("",stat.damage, stat.speed, stat.manaCost, stat.delay);
            
            stat = stats.spells.spark;
            Spark.bulletDef = new BulletDef("",stat.damage, stat.speed, stat.manaCost, stat.delay);
            
            stat = stats.spells.bomb;
            Bombastic.bulletDef = new BulletDef("",stat.damage, stat.speed, stat.manaCost, stat.delay);
            Bombastic.BLAST_RADIUS = stat.blastRadius;*/
        }
    }

}