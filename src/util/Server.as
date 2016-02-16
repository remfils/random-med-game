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
        private var server_name:String;
        private const START_GAME_PAGE = "/start_game.php";
        private const RECORD_PAGE = "/record.php";
        private const SAVE_GAME_PAGE = "/save_game.php";
        private const CREATE_PLAYER_PAGE = "/create_player.php";
        
        private const GET_UID:String = "uid=";
        private const GET_SID:String = "sid=";
        
        public var flashVars:Object = null;
        public var user:User;
        public var vkID:int = 0;
        
        private static var data:XML = null;
        private var styleSheet:StyleSheet;
        private var users_avatars:Array;
        
        private var data_load_complete_callback:Function;
        private var game_is_saved_callback:Function;
        private var level_loaded_callback:Function;
        
        public var main:Main;
        
        public function Server(server_name:String, flashVars:Object ):void {
            super();
            this.server_name = server_name;
            this.flashVars = flashVars;
            
            // Security.allowDomain("http://5.1.53.16");
            // Security.allowDomain("http://5.1.53.16/magicworld");
            // Security.allowDomain(server_name);
            // Security.loadPolicyFile(server_name + "/crossdomain.xml");
            
            user = AbstractMenu.user;
            user.uid = flashVars['viewer_id'];
            
            Recorder.server = this;
        }
        
        private function get GET_TIME_VAR():String {
            return "time=" + (new Date()).getTime();
        }
        
        public function startGameDataLoading(callback:Function):void {
            var path:String;
            var loader:URLLoader = new URLLoader();
            
            data_load_complete_callback = callback;
            
            path = server_name + START_GAME_PAGE + "?" + GET_UID + user.uid;
            if ( user.sid ) path += "&" + GET_SID + user.sid;
            path += "&" + GET_TIME_VAR;
            
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
                
                var user_ids:Array = new Array();
                user_ids.push(user.uid);
                
                for each ( var top_user_xml:XML in data.GameData.topusers.* ) {
                    user_ids.push(int(top_user_xml.@id));
                }
                
                if ( Main.mode == Main.HOME_TEST_MODE || Main.mode == Main.HOME_RELEASE_MODE  ) {
                    var user_img_array:Array = [];
                    for each (var _id:int in user_ids) {
                        var o:Object = { "uid": _id, "photo_50": "https://thingiverse-production-new.s3.amazonaws.com/renders/16/04/2d/b5/ed/smiley_face_thumb_small.jpg" };
                        user_img_array.push(o);
                    }
                    
                    createUserLoaders(user_img_array);
                }
                else {
                    startGettingAvatars(user_ids);
                }
            }
            else {
                startGettingUserData();
            }
        }
        
        private function startGettingAvatars(user_ids:Array):void {
            var VK:APIConnection = new APIConnection(flashVars);
            VK.api("users.get", { "user_ids": user_ids, "fields":["photo_50"]}, createUserLoaders, checkError);
        }
        
        private function createUserLoaders(users_avatars:Object):void {
            this.users_avatars = users_avatars as Array;
            
            if ( data_load_complete_callback ) {
                data_load_complete_callback();
                data_load_complete_callback = null;
            }
        }
        
        private function serverConnectErrorListener(e:IOErrorEvent):void {
            main.showOutOfOrder();
            Output.add(e.text);
        }
        
        private function serverSecurityErrorListener(e:SecurityErrorEvent):void {
            main.showOutOfOrder();
            Output.add("security error" + e.toString());
        }
        
        private function startGettingUserData():void {
            var VK:APIConnection = new APIConnection(flashVars);
            VK.api("users.get", { user_ids: flashVars["viewer_id"]}, sendCreateUserRequest, checkError);
        }
        
        private function sendCreateUserRequest(allUsersData:Object):void {
            var loader:URLLoader = new URLLoader();
            var req:URLRequest = new URLRequest(server_name + CREATE_PLAYER_PAGE);
            req.method = URLRequestMethod.POST;
            
            Output.add("sending create_player req");
            
            var urlVars:URLVariables = new URLVariables();
            
            var userData:Object = allUsersData[0];
            
            for (var key in userData) {
                urlVars[key] = userData[key];
            }
            
            req.data = urlVars;
            
            loader.addEventListener(Event.COMPLETE, userWasCreatedListener);
            
            loader.load(req);
            
            main.setToTutorialMode();
        }
        
        private function userWasCreatedListener(e:Event):void {
            var target:URLLoader = URLLoader(e.target);
            target.removeEventListener(Event.COMPLETE, userWasCreatedListener);
            
            Output.add("user was created\n" + target.data);
            
            startGameDataLoading(data_load_complete_callback);
        }
        
        private function checkError(e:Object):void {}
        
        public function getMainMenuData():Object {
            return {
                "user": user,
                "css": styleSheet,
                "levels": data.GameData.levels,
                "topusers": data.GameData.topusers,
                "shop": data.GameData.shopitems,
                "users_avatars": users_avatars
            };
        }
        
// LEVEL LOAD
        public function startLevelLoading(level_id:int, callback:Function = null):void {
            level_loaded_callback = callback;
            
            var url_req:URLRequest = new URLRequest(server_name + '/' + data.GameData.levels.level.(id == "" + level_id)[0].src + "?" + GET_TIME_VAR);
            
            var level_loader = new URLLoader();
            level_loader.addEventListener(Event.COMPLETE, levelLoadedHandler);
            
            Output.add("starting to load level: " + url_req.url);
            level_loader.load(url_req);
        }
        
        public function getLevelURL(level_id:int):URLRequest {
            return new URLRequest(server_name + '/' + data.GameData.levels.level.(id == "" + level_id).src + "?" + GET_TIME_VAR);
        }
        
        private function levelLoadedHandler(e:Event):void {
            var t:URLLoader = URLLoader(e.target);
            t.removeEventListener(Event.COMPLETE, levelLoadedHandler);
            
            var level_data:XML = XML(t.data);
            
            if ( level_loaded_callback ) {
                level_loaded_callback(level_data);
                level_loaded_callback = null;
            }
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
            game_is_saved_callback = callback;
            
            var urlVars:URLVariables = createSaveDataVariable();
            
            var loader:URLLoader = new URLLoader();
            var req:URLRequest = new URLRequest(server_name + SAVE_GAME_PAGE);
            req.data = urlVars;
            req.method = URLRequestMethod.POST;
            
            loader.addEventListener(Event.COMPLETE, onGameDataSaved);
            
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
                        <id>{game.level_id}</id>
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
            
            if ( game_is_saved_callback ) {
                game_is_saved_callback();
                game_is_saved_callback = null;
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