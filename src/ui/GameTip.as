package src.ui {
    import fl.transitions.easing.Strong;
    import fl.transitions.Tween;
    import fl.transitions.TweenEvent;
    import flash.display.Sprite;
    import flash.text.Font;
    import flash.text.TextField;
    import flash.text.TextFormat;
	/**
     * ...
     * @author vlad
     */
    public class GameTip extends Sprite {
        
        private var textField:TextField;
        
        public var active:Boolean = true;
        public var isTransition:Boolean = false;
        
        public function GameTip() {
            
            
            textField = new TextField();
            
            var font:Font = new MagicFont();
            
            var textFormat:TextFormat = new TextFormat(font.fontName, 12, 0xffffff);
            textField.defaultTextFormat = textFormat;
            textField.wordWrap = true;
            
            mouseEnabled = false;
            
            addChild(textField);
            textField.width = 150;
        }
        
        public function setText(title:String, str:String=""):void {
            textField.htmlText = "<b>" + title + "</b>\n" + str;
            
            //height = textField.textHeight + 10;
            
            redraw();
        }
        
        public function redraw():void {
            this.graphics.clear();
            this.graphics.beginFill(0x000000);
            this.graphics.drawRect(-5, -5, width + 5, height + 5);
            this.graphics.endFill();
        }
        
        public function show():void {
            if ( isTransition ) return;
            
            visible = true;
            active = true;
            isTransition = true;
            var tween:Tween = new Tween(this, "alpha", Strong.easeIn, 0, 1, 20);
            tween.addEventListener(TweenEvent.MOTION_FINISH, showEndListener);
        }
        
        private function showEndListener( e: TweenEvent):void {
            var tween:Tween = e.target as Tween;
            tween.removeEventListener(TweenEvent.MOTION_FINISH, showEndListener);
            
            isTransition = false;
        }
        
        public function hide():void {
            if ( isTransition ) return;
            
            forceHide();
        }
        
        public function forceHide():void {
            active = false;
            isTransition = true;
            var tween:Tween = new Tween(this, "alpha", Strong.easeIn, 1, 0, 10);
            tween.addEventListener(TweenEvent.MOTION_FINISH, hideEndListener);
        }
        
        public function hideEndListener(e:TweenEvent):void {
            var tween:Tween = e.target as Tween;
            tween.removeEventListener(TweenEvent.MOTION_FINISH, hideEndListener);
            
            x = 0;
            y = 0;
            
            visible = false;
            
            isTransition = false;
        }
        
    }

}