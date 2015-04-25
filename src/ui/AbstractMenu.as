package src.ui {
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.Font;
    import flash.text.FontStyle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import src.Game;
    import src.MainMenu;
	/**
     * ...
     * @author vlad
     */
    public class AbstractMenu extends Sprite {
        public static var game:Game;
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
        
        protected function createButtonFromClass(ButtonClass:Class, x:Number=0, y:Number=0):SimpleButton {
            var btn:SimpleButton = new ButtonClass();
            
            btn.x = x;
            btn.y = y;
            
            return btn
        }
        
        protected function getCustomButtonAt(ButtonClass:Class, x:Number=0, y:Number=0):Sprite {
            var btnContainer:Sprite = new Sprite();
            btnContainer.x = x;
            btnContainer.y = y;
            
            var btn:SimpleButton = createButtonFromClass(ButtonClass);
            btnContainer.addChild(btn);
            return btnContainer;
        }
        
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
        
        protected function getGotoMenuButton():Sprite {
            var btnContainer:Sprite = getCustomButtonAt(TabletButton, 375.3, 583);
            btnContainer.name = "GotoTitle";
            btnContainer.width = 182;
            
            var text:TextField = new TextField();
            text.embedFonts = true;
            text.textColor = 0xF0D685;
            text.width = btnContainer.width;
            text.mouseEnabled = false;
            
            var font:Font = new MagicFont();
            
            var tf:TextFormat = new TextFormat(font.fontName, 30);
            tf.align = "center";
            text.defaultTextFormat = tf;
            text.text = "Меню";
            
            text.x -= text.width / 2;
            text.y -= text.height / 4;
            
            btnContainer.addChild(text);
            return btnContainer;
        }
        
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