package src.ui {
    //import fl.controls.UIScrollBar;
	import flash.display.DisplayObjectContainer;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import src.costumes.Costume;
    import src.costumes.GameMenuCostume;
    import src.costumes.MenuButtonCostume;
    import src.costumes.MenuSprites;
    import src.objects.Letter;
    import src.util.SoundManager;


    public class LetterMenu extends GameMenu {
        
        var close_btn:MenuSprites;
        //var scroll_bar:UIScrollBar;
        
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
            
            /*scroll_bar = new UIScrollBar();
            scroll_bar.direction = "vertical";
            
            var title_txt:TextField = costume.title_txt;
            
            scroll_bar.setSize(title_txt.width, title_txt.height);
            scroll_bar.move(title_txt.x + title_txt.width, title_txt.y);
            
            addChild(scroll_bar);*/
        }
       
        override public function activate():void {
            active = true;
            stage.addEventListener(KeyboardEvent.KEY_UP, handleMenuInput);
            close_btn.addEventListener(MouseEvent.CLICK, closeButtonCliclListerner);
            
            SoundManager.instance.playSFX(SoundManager.SFX_SHOW_NOTE);
        }
        
        override public function deactivate():void {
            active = false;
            stage.addChildAt(this, 0);
            
            stage.removeEventListener(KeyboardEvent.KEY_UP, handleMenuInput);
            close_btn.removeEventListener(MouseEvent.CLICK, closeButtonCliclListerner);
            
            SoundManager.instance.playSFX(SoundManager.SFX_CLOSE_NOTE);
        }
        
        private function closeButtonCliclListerner(e:MouseEvent):void {
            hide();
        }
    }

}