package src.ui {
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.Font;
    import flash.text.FontStyle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import src.Game;
    import src.Main;
    import src.MainMenu;
    import src.User;

    public class AbstractMenu extends Sprite {
        public static var main:Main;
        public static var game:Game;
        public static var user:User;
        
        public static const GOTO_TITLE_BTN:String = "GotoTitle";
        public static const GOTO_TITLE_BTN_POSITION:Point = new Point(375.3, 583);
        
        public var parentMenu:MainMenu;
        
        protected var active:Boolean = false;
        
        protected var defaultTextFormat:TextFormat;
        
        public function AbstractMenu() {
            super();
            
            var font:Font = new MagicFont();
            
            defaultTextFormat = new TextFormat();
            defaultTextFormat.font = font.fontName;
            defaultTextFormat.size = 30;
            defaultTextFormat.color = 0xffffff;
            defaultTextFormat.bold = FontStyle.BOLD;
        }
        
        public function readData(data:Object):void {
            
        }
        
        // delete me. used in EndLevelMenu and GameMenu
        protected function createTitledButton(title:String, textFormtat:TextFormat):SimpleButton {
            var button:SimpleButton = new SimpleButton();
            
            var upState:Sprite = new Sprite();
            upState.addChild(createTextField(title, textFormtat));
            button.upState = upState;
            
            var overState:Sprite = new Sprite();
            var TF:TextFormat = new TextFormat(textFormtat.font, textFormtat.size, 0x000000, textFormtat.bold );
            overState.addChild(createTextField(title, TF));
            button.overState = overState;
            
            button.hitTestState = upState;
            return button;
        }
        
        // delete me. used above
        protected function createTextField(title:String, textFormat:TextFormat):TextField {
            var textField:TextField = new TextField();
            textField.embedFonts = true;
            textField.text = title;
            textField.setTextFormat(textFormat,-1, textField.length);
            textField.width = textField.textWidth + 4;
            textField.height = textField.textHeight + 4;
            return textField;
        }
        
        public function setUpMenu():void {
            
        }
        
        protected function clickListener(e:MouseEvent):void {
            
        }
        
        public function activate():void {
            active = true;
            addEventListener(MouseEvent.CLICK, clickListener);
        }
        
        public function deactivate():void {
            active  = false;
            removeEventListener(MouseEvent.CLICK, clickListener);
        }
        
        public function show():void {
            activate();
            visible = true;
        }
        
        public function hide():void {
            deactivate();
            visible = false;
        }
        
        public function destroy():void {
            deactivate();
            
            while (numChildren > 0) {
                removeChildAt(numChildren-1);
            }
        }
        
    }

}