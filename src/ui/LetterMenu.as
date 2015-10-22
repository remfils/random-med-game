package src.ui {
	import flash.display.DisplayObjectContainer;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import src.costumes.Costume;
    import src.costumes.GameMenuCostume;
    import src.costumes.MenuButtonCostume;
    import src.costumes.MenuSprites;
    import src.objects.Letter;
	


    public class LetterMenu extends GameMenu {
        
        var close_btn:MenuSprites;
        
        private var letter:Letter;
        
        private const DEFAULT_MESSAGE_WIDTH:Number = 450;
        
        public function LetterMenu(letter_:Letter) {
            super(letter_.costume.stage);
            
            letter = letter_;
            
            setMessage(letter.msg);
            setAuthor(letter.author);
            
            menu_is_hidden_callback = resumeGameAfterLetterIsClosed;
        }
        
        private function setMessage(str:String):void {
            costume.setTitle(str);
            GameMenuCostume(costume).title_txt.width = DEFAULT_MESSAGE_WIDTH;
        }
        
        private function setAuthor(str:String):void {
            costume.setMain(str);
        }
        
        private function resumeGameAfterLetterIsClosed():void {
            game.resume();
        }
        
        override public function setUpMenu():void {
            costume = new GameMenuCostume();
            costume.setState(GameMenuCostume.LETTER_STATE);
            
            close_btn = new MenuSprites();
            close_btn.setSprite(MenuSprites.CLOSE_BUTTON);
            close_btn.x = costume.width / 2;
            close_btn.y = 124;
            close_btn.buttonMode = true;
            costume.addChild(close_btn);
        }
       
        override public function activate():void {
            active = true;
            stage.addEventListener(KeyboardEvent.KEY_UP, handleMenuInput);
            close_btn.addEventListener(MouseEvent.CLICK, closeButtonCliclListerner);
        }
        
        override public function deactivate():void {
            active = false;
            stage.addChildAt(this, 0);
            
            stage.removeEventListener(KeyboardEvent.KEY_UP, handleMenuInput);
            close_btn.removeEventListener(MouseEvent.CLICK, closeButtonCliclListerner);
        }
        
        private function closeButtonCliclListerner(e:MouseEvent):void {
            hide();
        }
    }

}