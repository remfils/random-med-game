package src.objects {
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import src.costumes.ActiveObjectCostume;
    import src.interfaces.Update;
    import src.ui.GameMenu;
    import src.ui.LetterMenu;
    import src.util.CreateBodyRequest;


    public class Letter extends AbstractObject implements Update {
        
        public static const READ_STATE:String = "_read";
        public static const UNREAD_STATE:String = "_unread";
        
        public var msg:String;
        public var author:String;
        
        private var is_fresh:Boolean = true;
        private var active_area:DisplayObject;
        
        public function Letter() {
            super();
            
            costume = new ActiveObjectCostume();
            costume.setType(ActiveObjectCostume.LETTER_TYPE);
            costume.setState(UNREAD_STATE);
            
            properties = IS_BULLET_TRANSPARENT | IS_ACTIVE;
            
            active_area = ActiveObjectCostume(costume).active_area_mc;
        }
        
        override public function readXMLParams(paramsXML:XML):void {
            super.readXMLParams(paramsXML);
            
            msg = paramsXML.*;
            author = paramsXML.@author;
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            /*var req:CreateBodyRequest = super.requestBodyAt(world);
            
            req.setAsDynamicBody();
            
            return req;*/
            return null;
        }
        
        public function getText():String {
            return msg + "\n" + author;
        }
        
        public function update():void {
            if ( game.ACTION_PRESSED ) {
                if ( active_area.hitTestObject(game.player.collider) ) {
                    var menu:GameMenu = new LetterMenu(this);
                    
                    costume.setState(READ_STATE);
                    
                    menu.show();
                    game.stopTheGame();
                }
            }
        }
    }

}