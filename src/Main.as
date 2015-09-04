﻿package src {
    import flash.events.*;
    import flash.display.Sprite;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.system.Security;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.utils.Timer;
    import src.Game;
    import src.MainMenu;
    import src.task.Record;
    import src.ui.AbstractMenu;
    import src.ui.GameMenu;
    import src.util.DataManager;
    import src.util.LevelParser;
    import src.events.*;
    import src.util.*;

    public class Main extends Sprite {
        private static const LOAD_SCREEN_DELAY:int = 1000;
        
        private const TEST_MODE:Boolean = false;
        
        var mainMenu:MainMenu;
        var game:Game;
        private var dataManager:DataManager;
        
        var loading_screen:GameMenu;
        
        // events
        public static const DATA_LOADED_EVENT:String = "evt_menu_loaded";
        
        public function Main () {
            super();

            if ( stage ) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init():void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            stage.color = 0x333333;
            
            loading_screen = new GameMenu(GameMenu.LOADING_TYPE, stage);
            
            AbstractMenu.main = this;
            AbstractMenu.user = new User();
            Game.TEST_MODE = TEST_MODE;
            
            var flashVars:Object = stage.loaderInfo.parameters as Object;
            
            if ( TEST_MODE || !flashVars.api_id ) {
                flashVars['api_id'] = 4700251;
                flashVars['viewer_id'] = 18524077;
                flashVars['sid'] = "eb7c258ba81961cc32c161729ccea427b7b1148fdca05781f6ecefe96eb02245466e656a6509162d12f4d";
                flashVars['secret'] = "4092d88adb";
                //AbstractMenu.user.sid = 1;
            }
            
            if ( TEST_MODE && flashVars['viewer_id'] != 18524077 ) {
                showOutOfOrder();
                return;
            }
            
            createErrorTextField();
            
            dataManager = new DataManager(flashVars);
            dataManager.main = this;
            
            loadGameData();
        }
        
        private function loadGameData():void {
            loading_screen.show();
            
            dataManager.startGameDataLoading(createMainMenu);
            
            addEventListener(DATA_LOADED_EVENT, dataLoadedFromServer);
            addEventListener(MenuItemSelectedEvent.LEVEL_SELECTED, MenuItemSelectedListener);
            addEventListener(ExitLevelEvent.EXIT_LEVEL_EVENT, exitLevel, true);
        }
        
        public function showOutOfOrder():void {
            var gameError:ErrorScreen = new ErrorScreen();
            addChild(gameError);
            gameError.x += gameError.width / 2 + ( stage.stageWidth - gameError.width ) / 2;
        }
        
        private function createErrorTextField():void {
            var tf:TextField = new TextField();
            tf.background = true;
            tf.backgroundColor = 0;
            tf.textColor = 0xffffff;
            tf.width = stage.stageWidth;
            tf.height = stage.stageHeight;
            
            tf.selectable = true;
            
            addChildAt(tf,0);
            tf.visible = TEST_MODE;
            Output.init(tf);
        }
        
        private function dataLoadedFromServer(e:Event):void {
            createMainMenu();
            
            mainMenu.switchToMenu(mainMenu.TITLE_MENU);
            
            var t:Timer = ObjectPool.getTimer(LOAD_SCREEN_DELAY);
            t.addEventListener(TimerEvent.TIMER_COMPLETE, dellayedShowMenu);
        }
        
        private function dellayedShowMenu(e:TimerEvent):void {
            var t:Timer = Timer(e.target);
            t.removeEventListener(TimerEvent.TIMER_COMPLETE, dellayedShowMenu);
            
            mainMenu.visible = true;
            
            loading_screen.hide();
        }
        
        private function createMainMenu():void {
            mainMenu = new MainMenu();
            mainMenu.visible = false;
            addChildAt(mainMenu,1);
            
            mainMenu.render( dataManager.getMainMenuData() );
        }
        
        private function MenuItemSelectedListener(e:MenuItemSelectedEvent):void {
            loading_screen.show();
            
            startLevelLoading(e.id);
            //game.player.setInventory(dataManager.user.inventory);
        }
        
        private function startLevelLoading(levelId:int):void {
            var levelLoader = new URLLoader();
            levelLoader.addEventListener(Event.COMPLETE, levelDataLoaded);
            
            Output.add("starting to load level: " + dataManager.getLevelURL(levelId));
            
            game = new Game(levelId);
            game.getDataFromUser(dataManager.user);
            
            levelLoader.load(dataManager.getLevelURL(levelId));
        }
        
        private function levelDataLoaded(e:Event) {
            var levelLoader:URLLoader = e.target as URLLoader;
            levelLoader.removeEventListener(Event.COMPLETE, levelDataLoaded);
            
            Output.add(levelLoader.data);
            
            addChildAt(game,1);
            
            var levelCreator:LevelParser = new LevelParser();
            levelCreator.createLevelFromXML(game, XML(levelLoader.data));
            
            AbstractMenu.user.backupPlayer();
            
            var timer:Timer = ObjectPool.getTimer(LOAD_SCREEN_DELAY);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, dellayedGameInit);
        }
        
        private function dellayedGameInit(e:TimerEvent):void {
            var t:Timer = Timer(e.target);
            t.removeEventListener(TimerEvent.TIMER_COMPLETE, dellayedGameInit);
            
            game.init();
            
            mainMenu.hide();
            
            loading_screen.hide();
        }
        
        public function exitLevel(e:ExitLevelEvent):void {
            Recorder.add(new Record(Record.LEVEL_END_TYPE, game.levelId, e.cmd, int(e.level_completed)));
            Recorder.send();
            
            loading_screen.show();
            
            if ( !e.level_completed ) {
                var user:User = dataManager.user;
                var player:Player = game.player;
                
                user.resetPlayer();
                
                game.rating = 0;
            }
            
            switch (e.cmd) {
                case ExitLevelEvent.EXIT_TO_MENU_CMD:
                    dataManager.saveGameData(loadGameData);
                break;
                case ExitLevelEvent.NEXT_LEVEL_CMD:
                    dataManager.saveGameData(function(){startLevelLoading(game.levelId + 1);});
                break;
                case ExitLevelEvent.RESTART_LEVEL_CMD:
                    dataManager.saveGameData(function(){startLevelLoading(game.levelId);});
                break;
                default:
            }
            
            game.destroy();
            removeChild(game);
        }
        
        private function exitToMainMenu():void {
            game.destroy();
            removeChild(game);
        }
        
        private function destroyGame():void {
            game.destroy();
            removeChild(game);
        }
    }

}


