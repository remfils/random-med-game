package src.ui {
    //import fl.controls.*;
    import fl.transitions.easing.Strong;
    import fl.transitions.Tween;
    import fl.transitions.TweenEvent;
    import flash.automation.StageCaptureEvent;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.*;
    import flash.text.FontStyle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import src.events.GameEvent;
    
    public class GameMenu extends AbstractMenu {
        private var resumeButton:SimpleButton;
        private var exitButton:SimpleButton;
        
        protected var menuBG:Sprite = new GameMenuBG();
        
        public function GameMenu() {
            super();
            
            menuBG.alpha = 2;
            addChild(menuBG);
        }
        
        override public function setUpMenu():void {
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            graphics.endFill();
            alpha = 0;
            
            addElementsToBackground();
            deactivate();
        }
        
        protected function addElementsToBackground():void {
            resumeButton = createTitledButton("ПРОДОЛЖИТЬ", defaultTextFormat);
            resumeButton.x = - resumeButton.width / 2;
            resumeButton.y = 171;
            
            menuBG.addChild(resumeButton);
            
            exitButton = createTitledButton("ВЫХОД", defaultTextFormat);
            exitButton.x = - exitButton.width / 2;
            exitButton.y = 300;
            
            menuBG.addChild(exitButton);
        }
        
        override public function activate():void {
            //super.activate();
            stage.addEventListener(KeyboardEvent.KEY_UP, handleMenuInput);
            activateElements();
        }
        
        protected function handleMenuInput(e:KeyboardEvent):void {
            if ( e.keyCode == 27 ) {
                hide();
                e.stopImmediatePropagation();
            }
        }
        
        protected function activateElements():void {
            resumeButton.addEventListener(MouseEvent.CLICK, resumeGame);
            exitButton.addEventListener(MouseEvent.CLICK, exitGame);
            resumeButton.visible = true;
            exitButton.visible = true;
        }
        
        private function resumeGame(e:MouseEvent):void {
            hide();
        }
        
        private function exitGame(e:MouseEvent):void {
            game.exit();
        }
        
        override public function deactivate():void {
            active = false;
            stage.removeEventListener(KeyboardEvent.KEY_UP, handleMenuInput);
            deactivateElements();
        }
        
        protected function deactivateElements():void {
            resumeButton.removeEventListener(MouseEvent.CLICK, resumeGame);
            exitButton.removeEventListener(MouseEvent.CLICK, exitGame);
            resumeButton.visible = false;
            exitButton.visible = false;
        }
        
        override public function show():void {
            var tween:Tween = new Tween(this, "alpha", Strong.easeIn, 0, 0.7, 10);
            tween = new Tween (menuBG,"x", Strong.easeInOut, -menuBG.width, stage.stageWidth / 2, 10);
            super.show();
        }
        
        override public function hide():void {
            var tween:Tween = new Tween(this, "alpha", Strong.easeIn, 0.7, 0, 10);
            tween = new Tween (menuBG,"x", Strong.easeInOut, stage.stageWidth / 2, -menuBG.width, 10);
            tween.addEventListener(TweenEvent.MOTION_FINISH, menuIsHiddenHandler);
        }
        
        private function menuIsHiddenHandler(e:Event):void {
            var tween:Tween = e.target as Tween;
            tween.removeEventListener(TweenEvent.MOTION_FINISH, menuIsHiddenHandler);
            
            deactivate();
            game.resume();
        }
        
        override public function destroy():void {
            super.destroy();
            deactivate();
            resumeButton = null;
            exitButton = null;
        }
        
    }

}