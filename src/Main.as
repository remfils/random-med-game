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
        private static const HOME_TEST_MODE:int = 1;
        private static const HOME_RELEASE_MODE:int = 4;
        private static const RELEASE_TEST_MODE:int = 2;
        private static const RELEASE_MODE:int = 3;
        
        private var mode:int = HOME_TEST_MODE;
        Game.VERSION = "0.44";
        
        public var is_first_time:Boolean = false;
        
        private const HOME_SERVER:String = "http://game.home";
        private const PUBLIC_SERVER:String = "http://5.1.53.16/magicworld";
        
        private static var LOAD_SCREEN_DELAY:int = 500;
        
        private const TEST_MODE:Boolean = false;
        
        var main_menu:MainMenu;
        var game:Game;
        private var server:Server;
        public var user:User;
        
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
            
            stage.color = 0;
            
            loading_screen = new GameLoadingMenu(stage);
            loading_screen.show();
            
            user = new User();
            
            AbstractMenu.main = this;
            AbstractMenu.user = user;
            
            var flash_vars:Object = stage.loaderInfo.parameters as Object;
            if ( TEST_MODE || !flash_vars.api_id ) {
                flash_vars['api_id'] = 4700251;
                flash_vars['viewer_id'] = 18524077;
                flash_vars['sid'] = "17cc0211c20d4f000d947426bebd64dbb2a0203d9cc3106e61747328302228b71be7ff5caa6ce5f251f37";
                flash_vars['secret'] = "11f0eec60d";
                //AbstractMenu.user.sid = 1;
            }
            
            var server_name:String = PUBLIC_SERVER;
            
            switch (mode) {
                case HOME_TEST_MODE:
                    LOAD_SCREEN_DELAY = 0;
                    Game.TEST_MODE = true;
                    
                    server_name = HOME_SERVER;
                    
                    Game.VERSION += "-H";
                    
                    break;
                case HOME_RELEASE_MODE:
                    Game.TEST_MODE = false;
                    LOAD_SCREEN_DELAY = 0;
                    server_name = HOME_SERVER;
                    Game.VERSION += "-HR";
                    break;
                case RELEASE_TEST_MODE:
                    LOAD_SCREEN_DELAY = 0;
                    Game.TEST_MODE = false;
                    
                    Game.VERSION += "-T";
                    
                    if ( TEST_MODE && (flash_vars['viewer_id'] != 18524077 || flash_vars['viewer_id'] != 15976844 ) ) {
                        showOutOfOrder();
                        return;
                    }
                    break;
                case RELEASE_MODE:
                    Game.TEST_MODE = false;
                    break;
                default:
            }
            
            createErrorTextField();
            
            server = new Server(server_name, flash_vars);
            server.main = this;
            
            loadGameData();
        }
        
        public function showOutOfOrder():void {
            var gameError:ErrorScreen = new ErrorScreen();
            addChild(gameError);
            gameError.x += gameError.width / 2 + ( stage.stageWidth - gameError.width ) / 2;
        }
        
        public function setToTutorialMode():void {
            Game.show_tutorial = true;
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
        
        private function loadGameData():void {
            server.startGameDataLoading(dataLoadedCallback);
            
            addEventListener(MenuItemSelectedEvent.LEVEL_SELECTED, MenuItemSelectedListener);
        }
        
        private function dataLoadedCallback():void {
            main_menu = new MainMenu();
            main_menu.visible = false;
            addChild(main_menu);
            
            var data:Object = server.getMainMenuData();
            
            main_menu.render( data );
            main_menu.switchToMenu(main_menu.TITLE_MENU);
            
            level_counter = data.levels.level.length();
            
            var t:Timer = ObjectPool.getTimer(LOAD_SCREEN_DELAY);
            t.addEventListener(TimerEvent.TIMER_COMPLETE, dellayedShowMenu);
        }
        
        private function dellayedShowMenu(e:TimerEvent):void {
            var t:Timer = Timer(e.target);
            t.removeEventListener(TimerEvent.TIMER_COMPLETE, dellayedShowMenu);
            
            main_menu.visible = true;
            
            loading_screen.hide();
        }
        
        private function MenuItemSelectedListener(e:MenuItemSelectedEvent):void {
            removeEventListener(MenuItemSelectedEvent.LEVEL_SELECTED, MenuItemSelectedListener);
            
            loading_screen.menu_is_shown_callback = function() {
                startLevelLoading(e.id);
                e = null;
            }
            
            loading_screen.show();
        }
        
        private function startLevelLoading(level_id:int):void {
            user.preparePlayerForGame();
            
            game = new Game(user.player);
            game.level_id = level_id;
            
            server.startLevelLoading(level_id, levelDataLoaded);
        }
        
        private function levelDataLoaded(level_data:XML) {
            Output.add(level_data);
            
            addChild(game);
            
            var levelCreator:LevelParser = new LevelParser(game);
            game.init( levelCreator.parseXML(level_data) );
            
            AbstractMenu.user.backupPlayer();
            
            var timer:Timer = ObjectPool.getTimer(LOAD_SCREEN_DELAY);
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, dellayedGameInit);
        }
        
        private function dellayedGameInit(e:TimerEvent):void {
            var t:Timer = Timer(e.target);
            t.removeEventListener(TimerEvent.TIMER_COMPLETE, dellayedGameInit);
            
            main_menu.hide();
            
            loading_screen.hide();
        }
        
        public function exitGame(exit_cmd:int, level_completed:Boolean):void {
            Recorder.add(new Record(Record.LEVEL_END_TYPE, game.level_id, exit_cmd, int(level_completed)));
            Recorder.send();
            
            loading_screen.show();
            
            if ( !level_completed ) {
                var user:User = server.user;
                var player:Player = game.player;
                
                user.resetPlayer();
                
                game.rating = 0;
            }
            else {
                var user:User = server.user;
                if ( game.level_id > user.levels_completed ) {
                    user.levels_completed = game.level_id;
                }
            }
            
            switch (exit_cmd) {
                case ExitLevelEvent.EXIT_TO_MENU_CMD:
                    server.saveGameData(loadGameData);
                    break;
                case ExitLevelEvent.NEXT_LEVEL_CMD:
                    var level_id:int = game.level_id + 1;
                    if ( level_id > level_counter ) {
                        server.saveGameData(loadGameData);
                    }
                    else {
                        server.saveGameData(function(){startLevelLoading(level_id);});
                    }
                    break;
                case ExitLevelEvent.RESTART_LEVEL_CMD:
                    server.saveGameData(function(){startLevelLoading(game.level_id);});
                    break;
                default:
            }
            
            game.destroy();
            removeChild(game);
        }
    }

}


