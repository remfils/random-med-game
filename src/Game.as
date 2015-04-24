package src {
    import fl.transitions.easing.*;
    import fl.transitions.Tween;
    import fl.transitions.TweenEvent;
    import flash.display.*;
    import flash.display.Sprite;
    import flash.events.*;
    import flash.geom.Point;
    import flash.utils.Timer;
    import src.bullets.BulletController;
    import src.events.*;
    import src.interfaces.*;
    import src.levels.*;
    import src.objects.*;
    import src.task.TaskManager;
    import src.ui.AbstractMenu;
    import src.ui.EndLevelMenu;
    import src.ui.GameMenu;
    import src.ui.playerStat.PlayerStat;
    import src.util.AbstractManager;
    import src.util.BodyCreator;
    import src.util.DeleteManager;
    
    public class Game extends Sprite {
        public var levelId:int = 0;
        public var rating:int = 1;
        
        private static var i:uint;
        private var j:uint;
        
        public static const ROOM_MIN_X:int = 61;
        public static const ROOM_MAX_X:int = 695.65;
        public static const ROOM_MIN_Y:int = 57.5;
        public static const ROOM_MAX_Y:int = 443;
        
        
        // УПРАВЛЕНИЕ
        public var PAUSED:Boolean = false;
        public var ACTION_PRESSED:Boolean = false;
        public var blockControlls:Boolean = false;
        
        private var isTransition:Boolean = false;
        
        public static const TO_RAD:Number = Math.PI / 180;
        public static const WORLD_SCALE:Number = 30;
        public static const TIME_STEP:Number = 1 / 30;
        
        public static const EXIT_ROOM_EVENT = "exit_room";
        public static const OBJECT_ACTIVATE_EVENT = "object_activate";
        public static const TEST_MODE:Boolean = false;
        public static var TestModePanel:Sprite;

        private var menuPanel:GameMenu;
        public var gamePanel:Sprite;
        var playerPanel:Sprite; // for bullets
        private var glassPanel:Sprite;
        
        public var player:Player;

        var _LEVEL:Array = new Array();
        public var cRoom:Room;
        
        var levelMap:MovieClip;
        
        public var playerStat:PlayerStat;
        public var bulletController:BulletController;
        public var taskManager:TaskManager = new TaskManager();
        
        public var deleteManager:DeleteManager;
        public var bodyCreator:BodyCreator = new BodyCreator();
        
        private var SECRET_ROOM_FOUND:Boolean = false;
        
        public function Game(levelId:int) {
            super();
            this.levelId = levelId;
            
            AbstractObject.game = this;
            AbstractManager.game = this;
            AbstractMenu.game = this;
            Room.game = this;
            
            TestModePanel = new Sprite();
            
            player = new Player();
            player.x = 385;
            player.y = 400;
        }
        
        public function setLevel(level:Array):void {
            _LEVEL = level;
        }
        
        public function init() {
            this.stage.focus = this;
            
            Room.taskManager = taskManager;
            
            cRoom = getCurrentLevel();
            
            createGamePanel();
            
            addPlayerStat();
            
            //bodyCreator = new BodyCreator();
            deleteManager = new DeleteManager();
            
            addBulletController();
            
            setUpLevelMapPosition();
            
            addEventListeners();
            
            initCurrentLevel();
            
            // change LEVEL array
            playerStat.getMapMC().setUpScale(_LEVEL[0]);
            playerStat.getMapMC().update(_LEVEL[0]);
            
            glassPanel = new Sprite();
            glassPanel.y += playerStat.height;
            addChild(glassPanel);
            
            menuPanel = new GameMenu();
            addChild(menuPanel);
            menuPanel.setUpMenu();
            
            TestModePanel.y += playerStat.height;
            addChild(TestModePanel);
        }
        
        private function addBulletController() {
            bulletController = new BulletController(playerPanel);
            playerStat.setCurrentSpell(bulletController.BulletClass);
        }
        
        private function createGamePanel():void {
            gamePanel = new Sprite();
            
            addLevelTo(gamePanel);
            
            addPlayerTo(gamePanel);
            
            gamePanel.y += PlayerStat.getInstance().height;
            
            addChild(gamePanel);
        }
        
        private function addLevelTo(panel:DisplayObjectContainer):void {
            var k:int = _LEVEL.length;
            
            levelMap = new MovieClip();
            
            while (k--) {
                for (var i in _LEVEL[k]) {
                    for (var j in _LEVEL[k][i]) {
                        levelMap.addChild(_LEVEL[k][i][j]);
                    }
                }
            }
            
            panel.addChild(levelMap);
        }
        
        private function addPlayerTo(panel:DisplayObjectContainer):void {
            playerPanel = new Sprite();
            
            playerPanel.addChild(player.costume);
            
            panel.addChild(playerPanel);
        }
        
        private function addPlayerStat() {
            playerStat = new PlayerStat();
            playerStat.x = 0;
            playerStat.y = 0;
            addChild (playerStat);
            
            playerStat.update();
        }
        
        private function setUpLevelMapPosition() {
            levelMap.x -= player.currentRoom.x * cRoom.width;
            levelMap.y -= player.currentRoom.y * cRoom.height;
        }
        
        private function getCurrentLevel ():Room {
            return _LEVEL[ 0 ][ player.currentRoom.x ][ player.currentRoom.y ]
        }
        
        private function addEventListeners() {
            this.stage.addEventListener ( Event.ENTER_FRAME, update );
            this.stage.addEventListener ( KeyboardEvent.KEY_DOWN, keyDown_fun );
            this.stage.addEventListener ( KeyboardEvent.KEY_UP, keyUp_fun );
            this.stage.addEventListener ( Game.EXIT_ROOM_EVENT , nextRoom, true );
        }
        
        private function removeEventListeners():void {
            stage.removeEventListener ( Event.ENTER_FRAME, update );
            stage.removeEventListener ( KeyboardEvent.KEY_DOWN, keyDown_fun );
            stage.removeEventListener ( KeyboardEvent.KEY_UP, keyUp_fun );
            stage.removeEventListener ( RoomEvent.EXIT_ROOM_EVENT , nextRoom, true );
        }
        
        public function initCurrentLevel() {
            bulletController.changeLevel(cRoom);
            cRoom.init();
        }

        public function update (e:Event) {
            if (PAUSED) {
                stopTheGame();
                return;
            }
            if (isTransition) return;
            
            player.preupdate();
            
            bodyCreator.createBodies();
            
            if (!blockControlls) {
                cRoom.update();
                if ( !cRoom.currentTask ) {
                    if ( player.x < ROOM_MIN_X ||
                        player.x > ROOM_MAX_X ||
                        player.y < ROOM_MIN_Y ||
                        player.y > ROOM_MAX_Y
                    ) dispatchEvent(new Event(Game.EXIT_ROOM_EVENT));
                }
            }
            player.update ();
            
            bulletController.update();
            
            deleteManager.clear();
        }

        public function keyDown_fun (e:KeyboardEvent) {
            if ( blockControlls ) return;
            
            player.handleInput(e.keyCode);
            
            switch (e.keyCode) {
                // E key
                case 69:
                    ACTION_PRESSED = true;
                break;
                // J key
                case 74 :
                    bulletController.startBulletSpawn();
                    playerStat.flashButton("fire");
                break;
                // H key
                case 72:
                    bulletController.setPrevBullet();
                    playerStat.flashButton("spellLeft");
                    playerStat.setCurrentSpell(bulletController.BulletClass);
                break;
                // K key
                case 75:
                    bulletController.setNextBullet();
                    playerStat.flashButton("spellRight");
                    playerStat.setCurrentSpell(bulletController.BulletClass);
                break;
            }
        }
        
        public function keyUp_fun (E:KeyboardEvent) {
            player.handleInput(E.keyCode, false);
            
            switch (E.keyCode) {
                // E key
                case 69:
                    ACTION_PRESSED = false;
                break;
                case 74:
                    bulletController.stopBulletSpawn();
                    break;
                // ESC
                case 27:
                    PAUSED = true;
                    break;
            }
        }
        
        // по возможности удалить RoomEvent
        public function nextRoom (e:Event) {
            var destination:Point;
            var directionB:int;
            var destination:Point = new Point();
            
            glassPanel.addChild(player.costume);
            
            isTransition = true;
            blockControlls = true;
            
            cRoom.exit();
            bulletController.clearBullets();
            
            if ( player.x < ROOM_MIN_X ) {
                player.currentRoom.x --;
                directionB = Room.DOOR_DIRECTION_RIGHT;
                destination.x -= player.collider.width / 2;
            }
            if ( player.x > ROOM_MAX_X ) {
                player.currentRoom.x ++;
                directionB = Room.DOOR_DIRECTION_LEFT;
                destination.x += player.collider.width / 2;
            }
            if ( player.y < ROOM_MIN_Y ) {
                player.currentRoom.y --;
                directionB = Room.DOOR_DIRECTION_DOWN;
                destination.y -= player.collider.height / 2;
            }
            if ( player.y > ROOM_MAX_Y ) {
                player.currentRoom.y ++;
                directionB = Room.DOOR_DIRECTION_UP;
                destination.y += player.collider.height / 2;
            }
            
            cRoom = getCurrentLevel();
            var doorB:Door = cRoom.getDoorByDirection(directionB);
            
            destination.x += doorB.x;
            destination.y += doorB.y;
            
            if ( cRoom.isSecret ) SECRET_ROOM_FOUND = true;
            
            var shouldUnlockDoorInFuture:Boolean = cRoom.isSecret;
            
            if ( cRoom.isSecret || shouldUnlockDoorInFuture ) {
                // direction
                var door:Door = cRoom.getDoorByDirection(1);
                door.specialLock = false;
                door.unlock();
            }
            
            var tweenX:Tween = new Tween (levelMap, "x",Strong.easeInOut, levelMap.x, -cRoom.x, 18);
            var tweenY:Tween = new Tween (levelMap, "y",Strong.easeInOut, levelMap.y, -cRoom.y , 18);
            tweenX.start();
            
            
            var playerXTween:Tween = new Tween (player, "x", Strong.easeInOut, player.x, destination.x, 18 );
            var playerYTween:Tween = new Tween (player, "y", Strong.easeInOut, player.y, destination.y, 18 );
            
            var map = playerStat.getMapMC();
            map.update(_LEVEL);

            tweenX.addEventListener(TweenEvent.MOTION_FINISH, roomTweenFinished);
        }
        
        private function roomTweenFinished  (e:Event) {
            var tween:Tween = Tween(e.target);
            tween.removeEventListener(TweenEvent.MOTION_FINISH, roomTweenFinished);
            initCurrentLevel();

            blockControlls = false;
            isTransition = false;
        }
        
        // ВЫЗОВ ИГРОВОГО МЕНЮ
        public function stopTheGame():void {
            removeEventListeners();
            addEventListener(GameEvent.RESUME_EVENT, resume, true);
            stopAllLoopClipsIn(this);
            player.clearInput();
            menuPanel.show();
        }
        
        private function stopAllLoopClipsIn( obj:DisplayObjectContainer, setToPlay:Boolean=false ):void {
            var i:uint = obj.numChildren
            while ( i-- ) {
                if ( obj.getChildAt(i) is DisplayObjectContainer ) {
                    stopAllLoopClipsIn(obj.getChildAt(i) as DisplayObjectContainer, setToPlay);
                }
            }
            if ( obj is LoopClip ) {
                if ( setToPlay ) MovieClip(obj).play();
                else MovieClip(obj).stop();
            }
            return;
        }
        
        public function finishLevel():void {
            removeEventListeners();
            
            rating = 2;
            
            if ( SECRET_ROOM_FOUND ) {
                rating += 1;
            }
            
            player.clearInput();
            //player.gotoAndPlay("end");
            
            var timer:Timer = new Timer(700);
            timer.addEventListener(TimerEvent.TIMER, timeoutAfterLevelFinished);
            timer.start();
        }
        
        private function timeoutAfterLevelFinished(e:TimerEvent):void {
            var timer:Timer = e.target as Timer;
            timer.removeEventListener(TimerEvent.TIMER, timeoutAfterLevelFinished);
            timer.stop();
            
            endGame();
        }
        
        private function endGame():void {
            var endGameMenu:EndLevelMenu = new EndLevelMenu();
            addChild(endGameMenu);
            endGameMenu.setUpMenu();
            endGameMenu.show();
        }
        
        public function gotoNextLevel():void {
            dispatchEvent(new ExitLevelEvent(true));
        }
        
        public function exit():void {
            dispatchEvent(new ExitLevelEvent(false));
        }
        
        public function resume():void {
            PAUSED = false;
            stopAllLoopClipsIn(this, true);
            addEventListeners();
            removeEventListener(GameEvent.RESUME_EVENT, resume, true);
        }
        
        public function destroy():void {
            var i:int;
            removeEventListeners();
            
            i = numChildren;
            while ( i-- ) {
                deleteManager.add(getChildAt(i));
            }
            
            deleteManager.destroy();
            deleteManager = null;
        }
    }

}