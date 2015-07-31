package src {
    import flash.events.*;
    import flash.display.Sprite;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import src.Game;
    import src.MainMenu;
    import src.ui.AbstractMenu;
    import src.util.DataManager;
    import src.util.LevelParser;
    import src.events.*;
    import src.util.*;

    public class Main extends Sprite {
        private const TEST_MODE:Boolean = false;
        
        var mainMenu:MainMenu;
        var game:Game;
        private var dataManager:DataManager;
        
        // events
        public static const DATA_LOADED_EVENT:String = "evt_menu_loaded";
        
        public function Main () {
            super();

            if ( stage ) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init():void {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            AbstractMenu.user = new User();
            Game.TEST_MODE = TEST_MODE;
            
            var flashVars:Object = stage.loaderInfo.parameters as Object;
            
            if ( TEST_MODE || !flashVars.api_id ) {
                flashVars['api_id'] = 4700251;
                flashVars['viewer_id'] = 18524077;
                flashVars['sid'] = "5d01022e7987c20447c1bad1921ae0d7ab656198b89b610e1d1c97875cbd51f72d115368d06319b1006da";
                flashVars['secret'] = "f84ad7a82e";
            }
            
            if ( TEST_MODE && flashVars['viewer_id'] != 18524077 ) {
                showOutOfOrder();
                return;
            }
            
            createErrorTextField();
            
            dataManager = new DataManager(flashVars);
            dataManager.main = this;
            dataManager.startGameDataLoading(createMainMenu);
            
            addEventListener(DATA_LOADED_EVENT, dataLoadedFromServer);
            addEventListener(MenuItemSelectedEvent.LEVEL_SELECTED, MenuItemSelectedListener);
            addEventListener(ExitLevelEvent.EXIT_LEVEL_EVENT, exitLevel, true);
        }
        
        private function showOutOfOrder():void {
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
            
            addChild(tf);
            
            Output.init(tf);
        }
        
        private function dataLoadedFromServer(e:Event):void {
            createMainMenu();
            
            mainMenu.switchToMenu(mainMenu.TITLE_MENU);
        }
        
        private function createMainMenu():void {
            mainMenu = new MainMenu();
            addChild(mainMenu);
            
            mainMenu.render( dataManager.getMainMenuData() );
        }
        
        private function MenuItemSelectedListener(e:MenuItemSelectedEvent):void {
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
            
            addChild(game);
            
            var levelCreator:LevelParser = new LevelParser();
            levelCreator.createLevelFromXML(game, XML(levelLoader.data));
            
            game.init();
            
            mainMenu.destroy();
        }
        
        public function exitLevel(e:ExitLevelEvent):void {
            if ( !e.level_completed ) {
                var user:User = dataManager.user;
                var player:Player = game.player;
                
                player.EXP = user.playerData.EXP;
                player.MONEY = user.playerData.MONEY;
                
                if ( !player.HEALTH ) {
                    player.HEALTH = 1;
                }
            }
            
            switch (e.cmd) {
                case ExitLevelEvent.EXIT_TO_MENU_CMD:
                    dataManager.saveGameData(init);
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


