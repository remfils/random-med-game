package src {
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
    import src.ui.GameLoadingMenu;
    import src.ui.GameMenu;
    import src.util.Server;
    import src.util.LevelParser;
    import src.events.*;
    import src.util.*;

    public class Main extends Sprite {
        private static const LOAD_SCREEN_DELAY:int = 1000;
        
        private const TEST_MODE:Boolean = false;
        
        var mainMenu:MainMenu;
        var game:Game;
        private var server:Server;
        
        public var level_counter:int;
        
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
            
            loading_screen = new GameLoadingMenu(stage);
            
            AbstractMenu.main = this;
            AbstractMenu.user = new User();
            Game.TEST_MODE = TEST_MODE;
            
            var flashVars:Object = stage.loaderInfo.parameters as Object;
            
            if ( TEST_MODE || !flashVars.api_id ) {
                flashVars['api_id'] = 4700251;
                flashVars['viewer_id'] = 18524077;
                flashVars['sid'] = "17cc0211c20d4f000d947426bebd64dbb2a0203d9cc3106e61747328302228b71be7ff5caa6ce5f251f37";
                flashVars['secret'] = "11f0eec60d";
                //AbstractMenu.user.sid = 1;
            }
            
            if ( TEST_MODE && flashVars['viewer_id'] != 18524077 ) {
                showOutOfOrder();
                return;
            }
            
            createErrorTextField();
            
            server = new Server(flashVars);
            server.main = this;
            
            loadGameData();
        }
        
        private function loadGameData():void {
            server.startGameDataLoading(dataLoadedCallback);
            
            loading_screen.show();
            
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
        
        private function dataLoadedCallback(e:Event=null):void {
            mainMenu = new MainMenu();
            mainMenu.visible = false;
            addChild(mainMenu);
            
            var data:Object = server.getMainMenuData();
            
            mainMenu.render( data );
            mainMenu.switchToMenu(mainMenu.TITLE_MENU);
            
            level_counter = data.levels.level.length();
            
            var t:Timer = ObjectPool.getTimer(LOAD_SCREEN_DELAY);
            t.addEventListener(TimerEvent.TIMER_COMPLETE, dellayedShowMenu);
        }
        
        private function dellayedShowMenu(e:TimerEvent):void {
            var t:Timer = Timer(e.target);
            t.removeEventListener(TimerEvent.TIMER_COMPLETE, dellayedShowMenu);
            
            mainMenu.visible = true;
            
            loading_screen.hide();
        }
        
        private function MenuItemSelectedListener(e:MenuItemSelectedEvent):void {
            loading_screen.menu_is_shown_callback = function() {
                startLevelLoading(e.id);
            }
            
            loading_screen.show();
            //game.player.setInventory(dataManager.user.inventory);
        }
        
        private function startLevelLoading(levelId:int):void {
            var levelLoader = new URLLoader();
            levelLoader.addEventListener(Event.COMPLETE, levelDataLoaded);
            
            Output.add("starting to load level: " + server.getLevelURL(levelId));
            
            game = new Game(levelId);
            game.getDataFromUser(server.user);
            
            levelLoader.load(server.getLevelURL(levelId));
        }
        
        private function levelDataLoaded(e:Event) {
            var levelLoader:URLLoader = e.target as URLLoader;
            levelLoader.removeEventListener(Event.COMPLETE, levelDataLoaded);
            
            Output.add(levelLoader.data);
            
            addChild(game);
            
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
            return;
            
            Recorder.add(new Record(Record.LEVEL_END_TYPE, game.levelId, e.cmd, int(e.level_completed)));
            Recorder.send();
            
            loading_screen.show();
            
            if ( !e.level_completed ) {
                var user:User = server.user;
                var player:Player = game.player;
                
                user.resetPlayer();
                
                game.rating = 0;
            }
            
            switch (e.cmd) {
                case ExitLevelEvent.EXIT_TO_MENU_CMD:
                    server.saveGameData(loadGameData);
                break;
                case ExitLevelEvent.NEXT_LEVEL_CMD:
                    server.saveGameData(function(){startLevelLoading(game.levelId + 1);});
                break;
                case ExitLevelEvent.RESTART_LEVEL_CMD:
                    server.saveGameData(function(){startLevelLoading(game.levelId);});
                break;
                default:
            }
            
            game.destroy();
            removeChild(game);
        }
        
        public function exitGame(exit_cmd:int, level_completed:Boolean):void {
            Recorder.add(new Record(Record.LEVEL_END_TYPE, game.levelId, exit_cmd, int(level_completed)));
            Recorder.send();
            
            loading_screen.menu_is_shown_callback = function() {
                trace(game.rating);
                
                if ( !level_completed ) {
                    var user:User = server.user;
                    var player:Player = game.player;
                    
                    user.resetPlayer();
                    
                    game.rating = 0;
                }
                
                trace(game.rating);
                
                switch (exit_cmd) {
                    case ExitLevelEvent.EXIT_TO_MENU_CMD:
                        server.saveGameData(loadGameData);
                    break;
                    case ExitLevelEvent.NEXT_LEVEL_CMD:
                        server.saveGameData(function(){startLevelLoading(game.levelId + 1);});
                    break;
                    case ExitLevelEvent.RESTART_LEVEL_CMD:
                        server.saveGameData(function(){startLevelLoading(game.levelId);});
                    break;
                    default:
                }
                
                game.destroy();
                removeChild(game);
                
                trace("hello");
            }
            
            loading_screen.show();
        }
        
        private function exitToMainMenu():void {
            /*game.destroy();
            removeChild(game);*/
        }
        
        private function destroyGame():void {
            /*game.destroy();
            removeChild(game);*/
        }
    }

}


