package src.util {
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
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

    public class Server extends AbstractManager {
        //public const server_name = "http://5.1.53.16/magicworld";
        public const server_name = "http://game.home";
        private const START_GAME_PAGE = "/start_game.php";
        private const RECORD_PAGE = "/record.php";
        
        private const GET_UID:String = "uid=";
        private const GET_SID:String = "sid=";
        
        public var flashVars:Object = null;
        public var user:User;
        public var vkID:int = 0;
        
        private static var data:XML = null;
        private var styleSheet:StyleSheet;
        private var data_load_complete_callback:Function;
        
        public var main:Main;
        
        public function Server(flashVars:Object):void {
            super();
            this.flashVars = flashVars;
            
            // Security.allowDomain("http://5.1.53.16");
            // Security.allowDomain("http://5.1.53.16/magicworld");
            // Security.allowDomain(server_name);
            // Security.loadPolicyFile(server_name + "/crossdomain.xml");
            
            user = AbstractMenu.user;
            user.uid = flashVars['viewer_id'];
            
            Recorder.server = this;
        }
        
        public function startGameDataLoading(callback:Function):void {
            var path:String;
            var loader:URLLoader = new URLLoader();
            
            path = server_name + START_GAME_PAGE + "?" + GET_UID + user.uid;
            if ( user.sid ) path += "&" + GET_SID + user.sid;
            
            //dataLoadIsCompleteCallback = callback;
            loader.addEventListener(Event.COMPLETE, gameDataLoadComplete);
            loader.addEventListener(IOErrorEvent.IO_ERROR, serverConnectErrorListener);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, serverSecurityErrorListener);
            
            Output.add("sending start_game req to " + path);
            
            loader.load(new URLRequest(path));
        }
        
        private function gameDataLoadComplete(e:Event):void {
            var loader:URLLoader = e.target as URLLoader;
            loader.removeEventListener(Event.COMPLETE, gameDataLoadComplete);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, serverConnectErrorListener);
            loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, serverSecurityErrorListener);
            Output.add('server response\n' + loader.data);
            
            data = new XML(loader.data);
            
            if ( data.BaseData.length() > 0 ) {
                user.setDataFromXML(data.BaseData.User);
            }
            else {
                startGettingUserData(new Event(Event.ACTIVATE));
            }
            
            main.dispatchEvent(new Event(Main.DATA_LOADED_EVENT, true));
        }
        
        private function serverConnectErrorListener(e:IOErrorEvent):void {
            main.showOutOfOrder();
            Output.add(e.text);
        }
        
        private function serverSecurityErrorListener(e:SecurityErrorEvent):void {
            main.showOutOfOrder();
            Output.add("security error" + e.toString());
        }
        
        private function startGettingUserData(e:Event):void {
            var VK:APIConnection = new APIConnection(flashVars);
            VK.api("users.get", { user_ids: flashVars["viewer_id"]}, sendCreateUserRequest, checkError);
        }
        
        private function sendCreateUserRequest(allUsersData:Object):void {
            var loader:URLLoader = new URLLoader();
            var req:URLRequest = new URLRequest(server_name + "/create_player.php");
            req.method = URLRequestMethod.POST;
            
            Output.add("sending create_player req");
            
            var urlVars:URLVariables = new URLVariables();
            
            var userData:Object = allUsersData[0];
            
            for (var key in userData) {
                urlVars[key] = userData[key];
            }
            
            req.data = urlVars;
            
            loader.load(req);
            loader.addEventListener(Event.COMPLETE, gameDataLoadComplete);
        }
        
        private function checkError(e:Object):void {}
        
        public function getMainMenuData():Object {
            return {
                "user": user,
                "css": styleSheet,
                "levels": data.GameData.levels
            };
        }
        
        public function getLevelURL(level_id:int):URLRequest {
            return new URLRequest(server_name + '/' + data.GameData.levels.level.(id == "" + level_id).src + "?" + (new Date()).getTime());
        }
        
// RECORD
        public function sendRecordedData(recordsXML:XML):void {
            var url_vars:URLVariables = new URLVariables();
            url_vars.events = recordsXML;
            
            var req:URLRequest = new URLRequest(server_name + RECORD_PAGE + '?' + GET_SID + user.sid);
            req.data = url_vars
            req.method = URLRequestMethod.POST;
            
            var urlLoader:URLLoader = new URLLoader();
            urlLoader.load(req);
        }
        
// SAVE DATA
        public function saveGameData(callback:Function=null):void {
            var urlVars:URLVariables = createSaveDataVariable();
            
            var loader:URLLoader = new URLLoader();
            var req:URLRequest = new URLRequest(server_name + "/save_game.php");
            req.data = urlVars;
            req.method = URLRequestMethod.POST;
            
            loader.addEventListener(Event.COMPLETE, onGameDataSaved);
            this.data_load_complete_callback = callback;
            loader.load(req);
        }
        
        private function createSaveDataVariable():URLVariables {
            var result:URLVariables = new URLVariables();
            
            var resultXML:XML = <Data>
                <UserData>
                    {user.toXML()}
                </UserData>
                <LevelData/>
                
                {game.taskManager.eventsToXML()}
            </Data>;
            
            if ( game.rating ) {
                resultXML.LevelData.appendChild(<level>
                        <id>{game.levelId}</id>
                        <rating>{game.rating}</rating>
                    </level>);
            }
            
            Output.add(resultXML);
            
            result.dataXML = resultXML;
            
            return result;
        }
        
        private function onGameDataSaved(e:Event):void {
            var loader:URLLoader = e.target as URLLoader;
            loader.removeEventListener(Event.COMPLETE, onGameDataSaved);
            
            Output.add('server response:\n' + loader.data);
            
            if ( data_load_complete_callback ) {
                data_load_complete_callback();
                data_load_complete_callback = null;
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