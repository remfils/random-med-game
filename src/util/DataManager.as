package src.util {
    import flash.events.Event;
    import flash.net.*;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.utils.ByteArray;
    import src.Main;
    import src.Player;
    import src.ui.AbstractMenu;
    import src.User;
    import src.util.Output;
    import vk.api.DataProvider;
    import vk.APIConnection;
    import flash.system.Security;

    public class DataManager extends AbstractManager {
        public const server_name = "http://game.home";
        public var flashVars:Object = null;
        public var user:User;
        public var vkID:int = 0;
        
        private static var data:XML = null;
        private var styleSheet:StyleSheet;
        private var testMode:Boolean = true;
        private var dataLoadIsCompleteCallback:Function;
        
        public var main:Main;
        
        public function DataManager(flashVars:Object):void {
            super();
            this.flashVars = flashVars;
            
            user = AbstractMenu.user;
            user.uid = flashVars['viewer_id'];
            
            if ( testMode ) {
                startSettingGameStats();
            }
        }
        
        public function startGameDataLoading(callback:Function):void {
            var path:String;
            var loader:URLLoader = new URLLoader();
            
            path = server_name + "/start_game.php?user_vk_id=" + flashVars['viewer_id'];
            
            //dataLoadIsCompleteCallback = callback;
            loader.addEventListener(Event.COMPLETE, gameDataLoadComplete);
            
            Output.add("sending start_game req to " + path);
            
            loader.load(new URLRequest(path));
        }
        
        private function gameDataLoadComplete(e:Event):void {
            var loader:URLLoader = e.target as URLLoader;
            loader.removeEventListener(Event.COMPLETE, gameDataLoadComplete);
            Output.add('server response\n' + loader.data);
            
            data = new XML(loader.data);
            
            if ( data.BaseData.length() > 0 ) {
                formUser();
            }
            else {
                startGettingUserData(new Event(Event.ACTIVATE));
            }
            
            main.dispatchEvent(new Event(Main.DATA_LOADED_EVENT, true));
        }
        
        public function setGameData():void {
            //user.setPlayerInventory();
        }
        
        private function formUser():void {
            user.setDataFromXML(data.BaseData.User);
        }
        
        private function CSSLoadedListener(e:Event):void {
            var loader:URLLoader = e.target as URLLoader;
            styleSheet = new StyleSheet();
            styleSheet.parseCSS(loader.data);
        }
        
        private function startGettingUserData(e:Event):void {
            var VK:APIConnection = new APIConnection(flashVars);
            VK.api("users.get", { user_ids: flashVars["viewer_id"]}, sendCreateUserRequest, checkError);
        }
        
        private function sendCreateUserRequest(allUsersData:Object):void {
            var loader:URLLoader = new URLLoader();
            Output.add("sending create_player req");
            var req:URLRequest = new URLRequest(server_name + "/create_player.php");
            req.method = URLRequestMethod.POST;
            
            var urlVars:URLVariables = new URLVariables();
            
            var userData:Object = allUsersData[0];
            
            for (var key in userData) {
                urlVars[key] = userData[key];
            }
            
            req.data = urlVars;
            
            loader.load(req);
            loader.addEventListener(Event.COMPLETE, gameDataLoadComplete);
        }
        
        private function checkError(e:Object):void {
            
        }
        
        public function getMainMenuData():Object {
            return {
                "user": user,
                "css": styleSheet,
                "levels": data.GameData.levels
            };
        }
        
        public function getLevelLinkById(ID:int):String {
            return server_name + '/' + data.GameData.levels.level.(id == "" + ID).src + "?" + (new Date()).getTime();
        }
        
// SAVE DATA
        public function saveGameData(callback:Function=null):void {
            var urlVars:URLVariables = createSaveDataVariable();
            
            var loader:URLLoader = new URLLoader();
            var req:URLRequest = new URLRequest(server_name + "/save_game.php");
            req.data = urlVars;
            req.method = URLRequestMethod.POST;
            
            loader.addEventListener(Event.COMPLETE, onGameDataSaved);
            this.dataLoadIsCompleteCallback = callback;
            loader.load(req);
        }
        
        private function createSaveDataVariable():URLVariables {
            var result:URLVariables = new URLVariables();
            
            var resultXML:XML = <Data>
                <UserData>
                    {user.toXML()}
                </UserData>
                <LevelData>
                    <level>
                        <id>{game.levelId}</id>
                        <rating>{game.rating}</rating>
                    </level>
                </LevelData>
                
                {game.taskManager.eventsToXML()}
            </Data>;
            
            Output.add(resultXML);
            
            result.dataXML = resultXML;
            
            return result;
        }
        
        private function onGameDataSaved(e:Event):void {
            var loader:URLLoader = e.target as URLLoader;
            loader.removeEventListener(Event.COMPLETE, onGameDataSaved);
            
            Output.add('server response:\n' + loader.data);
            
            if ( dataLoadIsCompleteCallback ) {
                dataLoadIsCompleteCallback();
                dataLoadIsCompleteCallback = null;
            }
            
        }
        
        private function setRatingOfLevel(rating:int, levelId:int):void {
            var level:XMLList = data.GameData.levels.level.(id == levelId.toString());
            
            if ( level.rating as int < rating ) {
                level.rating = rating;
            }
        }
        
// SET STATIC DATA IN GAME
        public function startSettingGameStats():void {
            /*var loader:URLLoader = new URLLoader(new URLRequest("GameStats.xml"));
            loader.addEventListener(Event.COMPLETE, setGameStats);*/
        }
        
        private function setGameStats(e:Event):void {
            var loader:URLLoader = e.target as URLLoader;
            loader.removeEventListener(Event.COMPLETE, setGameStats);
            
            LevelParser.setGameStats( XML(loader.data) );
        }
        
    }

}