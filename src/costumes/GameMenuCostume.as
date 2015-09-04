package src.costumes {
    import flash.text.TextField;

    public class GameMenuCostume extends Costume {
        public static const RED_STATE:String = "red";
        public static const GREEN_STATE:String = "green";
        public static const LOADING_STATE:String = "loading";
        
        public var title_txt:TextField;
        public var main_txt:TextField;
        
        public function GameMenuCostume() {
            super();
            
            title_txt = TextField(getChildByName("title_txt"));
            main_txt = TextField(getChildByName("main_txt"));
        }
        
        public function clearText():void {
            main_txt.text = title_txt.text = "";
        }
        
        public function setTitle(text:String):void {
            title_txt.text = text;
            title_txt.width = 309.2;
        }
        
        public function setMain(text:String):void {
            main_txt.text = text;
        }
    }

}