package src {
    import fl.transitions.*;
    import fl.transitions.easing.*;
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    import src.bullets.*;
    import src.costumes.BulletCostume;
    import src.events.*;
    import src.interfaces.*;
    import src.levels.*;
    import src.objects.*;
    import src.task.*;
    import src.ui.*;
    import src.ui.mageShop.InventoryItem;
    import src.ui.playerStat.*;
    import src.util.*;
    
    public class Game extends Sprite {
        public static var VERSION:String;
        public static var TEST_MODE:Boolean = true;
        
        public var level_id:int = 0;
        public var rating:int = 0;
        
        private static var i:uint;
        private var j:uint;
        
        public static const GUESS_EVENT:String = "make_guess";
        
        public static var PLAYER_START_X:Number;
        public static var PLAYER_START_Y:Number;
        
        private const ROOM_TRANSITION_TIME:int = 18;
        
        public static const ROOM_MIN_X:int = 61;
        public static const ROOM_MAX_X:int = 695.65;
        public static const ROOM_MIN_Y:int = 57.5;
        public static const ROOM_MAX_Y:int = 443;
        
        
        // УПРАВЛЕНИЕ
        public var PAUSED:Boolean = false;
        public var ACTION_PRESSED:Boolean = false;
        public var blockControlls:Boolean = false;
        
        private var isTransition:Boolean = false;
        
        public static const FRAMES_PER_MILLISECOND:Number = 30 / 1000;
        public static const TO_RAD:Number = Math.PI / 180;
        public static const WORLD_SCALE:Number = 30;
        public static const TIME_STEP:Number = 1 / 30;
        
        public static const EXIT_ROOM_EVENT = "exit_room";
        public static const OBJECT_ACTIVATE_EVENT = "object_activate";
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
        
        public function Game(player:Player) {
            super();
            // this.levelId = levelId;
            
            AbstractObject.game = this;
            AbstractManager.game = this;
            AbstractMenu.game = this;
            Room.game = this;
            
            TestModePanel = new Sprite();
            
            this.player = player;
        }
        
        public function setAsFocus():void {
            this.stage.focus = this;
        }
        
        // D!
        public function setLevel(level:Array):void {
            _LEVEL = level;
        }
        
        // D!
        public function getDataFromUser(user:User):void {
            return;
            var userInventory:Array = user.inventory;
            var i:int, invLength:int = userInventory.length;
            var item:InventoryItem;
            
            for (i = 0; i < invLength; i++) {
                item = InventoryItem(userInventory[i]);
                if (item.onPlayer) {
                    if (item.isSpell ) {
                        player.spells.push(BulletController.getIndexOfBulletByName(item.item_name));
                    }
                }
            }
            
            var p_data:Object = user.playerData;
            for (var prop:String in p_data) {
                if ( player.hasOwnProperty(prop) ) {
                    player[prop] = p_data[prop];
                }
            }
        }
        
        public function init(level:Array) {
            setAsFocus();
            
            Recorder.add(new Record(Record.LEVEL_START_TYPE, level_id));
            
            _LEVEL = level;
            
            player.x = PLAYER_START_X;
            player.y = PLAYER_START_Y;
            
            bodyCreator.createBodies();
            
            var i, j:int;
            for (i = _LEVEL[0].length-1; i >= 0; i--) {
                for (j = _LEVEL[0][i].length-1; j >= 0; j--) {
                    if ( _LEVEL[0][i][j] ) {
                        _LEVEL[0][i][j].unlock();
                    }
                }
            }
            
            Room.taskManager = taskManager; // D!
            
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
            addChildAt(glassPanel, getChildIndex(playerStat));
            
            menuPanel = new GameMenu(stage);
            
            TestModePanel.y += playerStat.height;
            addChild(TestModePanel);
        }
        
        private function addBulletController() {
            bulletController = new BulletController(playerPanel);
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
            stage.addEventListener ( Event.ENTER_FRAME, update );
            stage.addEventListener ( KeyboardEvent.KEY_DOWN, keyDown_fun );
            stage.addEventListener ( KeyboardEvent.KEY_UP, keyUp_fun );
            stage.addEventListener ( Game.EXIT_ROOM_EVENT , nextRoom, true );
            stage.addEventListener ( SubmitTaskEvent.GUESS_EVENT, taskManager.guessEventListener2, true );
        }
        
        private function removeEventListeners():void {
            stage.removeEventListener ( Event.ENTER_FRAME, update );
            stage.removeEventListener ( KeyboardEvent.KEY_DOWN, keyDown_fun );
            stage.removeEventListener ( KeyboardEvent.KEY_UP, keyUp_fun );
            stage.removeEventListener ( RoomEvent.EXIT_ROOM_EVENT , nextRoom, true );
            stage.removeEventListener ( SubmitTaskEvent.GUESS_EVENT, taskManager.guessEventListener2, true );
        }
        
        public function initCurrentLevel() {
            Recorder.recordEnterRoom(player.currentRoom);
            bulletController.changeLevel(cRoom);
            cRoom.init();
        }

        public function update (e:Event) {
            if (PAUSED) {
                stopTheGame();
                menuPanel.show();
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
                case 13: // enter key
                case 69: // E key
                    ACTION_PRESSED = true;
                break;
                // J key
                case 74 :
                    bulletController.startBulletSpawn();
                    playerStat.flashElementByID(PlayerStat.FIRE_BTN_ID);
                break;
                // H key
                case 72:
                    bulletController.prevSpell();
                    playerStat.flashElementByID(PlayerStat.SPELL_LEFT_BTN_ID);
                    playerStat.setSpellLogo(bulletController.currentSpellDef.name);
                break;
                // K key
                case 75:
                    bulletController.nextSpell();
                    playerStat.flashElementByID(PlayerStat.SPELL_RIGHT_BTN_ID);
                    playerStat.setSpellLogo(bulletController.currentSpellDef.name);
                break;
            }
        }
        
        public function keyUp_fun (e:KeyboardEvent) {
            //trace(e.keyCode);
            
            player.handleInput(e.keyCode, false);
            
            switch (e.keyCode) {
                case 13: // enter key
                case 69: // E key
                    ACTION_PRESSED = false;
                    //var to:TaskObject = cRoom.getTaskObjectNearPlayer();
                    //if (to) {
                    //    to.submitAnswer();
                    //}
                break;
                case 74:
                    bulletController.stopBulletSpawn();
                    break;
                case 27:// ESC
                    PAUSED = true;
                    break;
                case 32 :// SPACE
                    break;
            }
        }
        
        public function changePlayerStat(change:ChangePlayerStatObject):Boolean {
            var result:Boolean = player.changeStat(change);
            
            if ( result ) {
                switch ( change.stat_name ) {
                    case ChangePlayerStatObject.HEALTH_STAT:
                        playerStat.flashElementByID(PlayerStat.HEALTH_BAR_ID);
                        Recorder.recordPlayerDmg(change.id, -change.delta);
                        break;
                    case ChangePlayerStatObject.MANA_STAT:
                        playerStat.flashElementByID(PlayerStat.MANA_BAR_ID);
                        break;
                }
                playerStat.update();
            }
            
            if ( player.HEALTH <= 0 ) {
                stopTheGame();
                Recorder.add(new Record(Record.PLAYER_DEAD_TYPE));
                Recorder.send();
                
                var gr:Graphics = glassPanel.graphics;
                gr.beginFill(0x000000);
                gr.drawRect(0, 0,stage.stageWidth, stage.stageHeight);
                gr.endFill();
                glassPanel.alpha = 0.7;
                
                glassPanel.addChild(player.costume);
                player.die();
                player.costume.alpha = 1 + glassPanel.alpha;
                
                var timer:Timer = new Timer(2000, 1);
                timer.addEventListener(TimerEvent.TIMER_COMPLETE, playerDeathAnimationListener);
                timer.start();
            }
            
            return result;
        }
        
        // D!
        public function hitPlayer(hitNumber:int ):Number {
            if ( player.makeHit(hitNumber) ) {
                playerStat.flashElementByID(PlayerStat.HEALTH_BAR_ID);
                
                if ( player.HEALTH <= 0 ) {
                    stopTheGame();
                    Recorder.add(new Record(Record.PLAYER_DEAD_TYPE));
                    Recorder.send();
                    
                    var gr:Graphics = glassPanel.graphics;
                    gr.beginFill(0x000000);
                    gr.drawRect(0, 0,stage.stageWidth, stage.stageHeight);
                    gr.endFill();
                    glassPanel.alpha = 0.7;
                    
                    glassPanel.addChild(player.costume);
                    player.die();
                    player.costume.alpha = 1 + glassPanel.alpha;
                    
                    var timer:Timer = new Timer(2000, 1);
                    timer.addEventListener(TimerEvent.TIMER_COMPLETE, playerDeathAnimationListener);
                    timer.start();
                }
                
                return hitNumber;
            }
            return 0;
        }
        
        private function playerDeathAnimationListener(e:TimerEvent) :void {
            var timer:Timer = Timer(e.target);
            timer.removeEventListener(TimerEvent.TIMER_COMPLETE, playerDeathAnimationListener);
            
            var menu:GameMenu = new GameDeathMenu(stage);
            menu.show();
        }
        
        // по возможности удалить RoomEvent
        public function nextRoom (e:Event) {
            var destination:Point;
            var directionB:int;
            var destination:Point = new Point();
            var roomWasSecret:Boolean = cRoom.isSecret;
            
            Recorder.send();
            
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
            
            if ( (cRoom.isSecret || roomWasSecret ) && doorB.specialLock ) {
                SECRET_ROOM_FOUND = true;
                doorB.specialLock = false;
                doorB.unlock();
            }
            // animate level movement
            var tween:Tween = ObjectPool.getTween(levelMap, "x", Strong.easeInOut, levelMap.x, -cRoom.x, ROOM_TRANSITION_TIME);
            ObjectPool.getTween(levelMap, "y",Strong.easeInOut, levelMap.y, -cRoom.y , ROOM_TRANSITION_TIME);
            
            // animate player movement
            ObjectPool.getTween(player, "x", Strong.easeInOut, player.x, destination.x, ROOM_TRANSITION_TIME);
            ObjectPool.getTween(player, "y", Strong.easeInOut, player.y, destination.y, ROOM_TRANSITION_TIME);
            
            tween.addEventListener(TweenEvent.MOTION_FINISH, roomTweenFinished);
            
            // var tweenX:Tween = new Tween (levelMap, "x",Strong.easeInOut, levelMap.x, -cRoom.x, 18);
            // var tweenY:Tween = new Tween (levelMap, "y",Strong.easeInOut, levelMap.y, -cRoom.y , 18);
            // tweenX.start();
            
            
            // var playerXTween:Tween = new Tween (player, "x", Strong.easeInOut, player.x, destination.x, 18 );
            // var playerYTween:Tween = new Tween (player, "y", Strong.easeInOut, player.y, destination.y, 18 );
            
            var map = playerStat.getMapMC();
            map.update(_LEVEL);

            //tweenX.addEventListener(TweenEvent.MOTION_FINISH, roomTweenFinished);
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
            isTransition = true;
            removeEventListeners();
            addEventListener(GameEvent.RESUME_EVENT, resume, true); // D!
            stopAllLoopClipsIn(this);
            player.clearInput();
        }
        
        public function resume():void {
            PAUSED = isTransition = false;
            addEventListeners();
            stopAllLoopClipsIn(this, true);
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
            
            rating = taskManager.gradeLevel();
            
            player.clearInput();
            player.body = null;
            player.costume.setType(Player.END_STATE);
            player.costume.setState();
            
            var timer:Timer = new Timer(700);
            timer.addEventListener(TimerEvent.TIMER, timeoutAfterLevelFinished);
            timer.start();
        }
        
        private function timeoutAfterLevelFinished(e:TimerEvent):void {
            var timer:Timer = e.target as Timer;
            timer.removeEventListener(TimerEvent.TIMER, timeoutAfterLevelFinished);
            timer.stop();
            
            var endGameMenu:GameMenu = new GameEndMenu(stage);
            endGameMenu.show();
        }
        // D!
        public function showEndLevelMenu():void {
            
        }
        // D!
        public function gotoNextLevel():void {
            dispatchEvent(new ExitLevelEvent());
        }
        // D!
        public function exit():void {
            var event:ExitLevelEvent = new ExitLevelEvent();
            dispatchEvent(event);
        }
        
        public function destroy():void {
            var i:int;
            removeEventListeners();
            
            i = numChildren;
            while ( i-- ) {
                deleteManager.add(getChildAt(i));
            }
            
            deleteManager.add(menuPanel);
            
            deleteManager.destroy();
            deleteManager = null;
        }
    }

}