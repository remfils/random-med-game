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
    import src.costumes.GameMenuCostume;
    import src.events.ExitLevelEvent;
    import src.events.GameEvent;
    
    public class GameMenu extends AbstractMenu {
        public static const GAME_MENU_TYPE:int = 1;
        public static const END_LEVEL_TYPE:int = 2;
        public static const DEATH_TYPE:int = 3;
        
        private static const MAX_MENU_STRANPARENCY:Number = 0.7;
        
        private static const LEFT_BTN_X:Number = -150;
        private static const RIGHT_CORNER_X:Number = 156;
        private static const FOOTER_Y:Number = 352;
        
        private var type:int;
        
        private var resumeButton:SimpleButton;
        private var exitButton:SimpleButton;
        
        protected var menuBG:Sprite = new GameMenuBG(); // D!
        private var costume:GameMenuCostume;
        
        public function GameMenu(type_:int = 1) {
            super();
            
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, game.stage.stageWidth, game.stage.stageHeight);
            graphics.endFill();
            
            costume = new GameMenuCostume();
            costume.alpha = 1 + MAX_MENU_STRANPARENCY;
            addChild(costume);
            
            type = type_;
            switch (type_) {
                case GAME_MENU_TYPE:
                    costume.setState(GameMenuCostume.GREEN_STATE);
                    costume.clearText();
                    resumeButton = createTitledButton("ПРОДОЛЖИТЬ", defaultTextFormat);
                    resumeButton.x = - resumeButton.width / 2;
                    resumeButton.y = 171;
                    
                    exitButton = createTitledButton("ВЫХОД", defaultTextFormat);
                    exitButton.x = - exitButton.width / 2;
                    exitButton.y = 300;
                break;
                case END_LEVEL_TYPE:
                    costume.setState(GameMenuCostume.GREEN_STATE);
                    costume.setTitle("УРОВЕНЬ ПРОЙДЕН");
                    
                    exitButton = createTitledButton("ВЫХОД", defaultTextFormat);
                    exitButton.x = LEFT_BTN_X;
                    exitButton.y = FOOTER_Y;
                    menuBG.addChild(exitButton);
                    
                    resumeButton = createTitledButton("ДАЛЬШЕ", defaultTextFormat);
                    resumeButton.x = RIGHT_CORNER_X - resumeButton.width;
                    resumeButton.y = exitButton.y;
                    menuBG.addChild(resumeButton);
                break;
                case DEATH_TYPE:
                    costume.setState(GameMenuCostume.RED_STATE);
                    costume.setTitle("ПОРАЖЕНИЕ");
                    
                    exitButton = createTitledButton("ВЫХОД", defaultTextFormat);
                    exitButton.x = LEFT_BTN_X;
                    exitButton.y = FOOTER_Y;
                    menuBG.addChild(exitButton);
                    
                    resumeButton = createTitledButton("СНАЧАЛА", defaultTextFormat);
                    resumeButton.x = RIGHT_CORNER_X - resumeButton.width;
                    resumeButton.y = exitButton.y;
                    menuBG.addChild(resumeButton);
                break;
                default:
                    resumeButton = new SimpleButton();
                    exitButton = new SimpleButton();
            }
            costume.addChild(resumeButton);
            costume.addChild(exitButton);
            alpha = 0;
            deactivate();
            //menuBG.alpha = 2;
            //addChild(menuBG);
        }
        // D!
        override public function setUpMenu():void {
            
        }
        
        protected function createGameMenuElements():void {
            
        }
        
        override public function activate():void {
            //super.activate();
            resumeButton.visible = true;
            exitButton.visible = true;
            
            switch (type) {
                case GAME_MENU_TYPE:
                    game.stage.addEventListener(KeyboardEvent.KEY_UP, handleMenuInput);
                    resumeButton.addEventListener(MouseEvent.CLICK, resumeGame);
                    exitButton.addEventListener(MouseEvent.CLICK, exitGame);
                break;
                case END_LEVEL_TYPE:
                    exitButton.addEventListener(MouseEvent.CLICK, exitGame);
                    resumeButton.addEventListener(MouseEvent.CLICK, nextLevel);
                break;
                case DEATH_TYPE:
                    exitButton.addEventListener(MouseEvent.CLICK, exitGame);
                    resumeButton.addEventListener(MouseEvent.CLICK, restartLevelListener);
                break;
            }
            activateElements();
        }
        
        protected function handleMenuInput(e:KeyboardEvent):void {
            if ( e.keyCode == 27 ) {
                hide();
                e.stopImmediatePropagation();
            }
        }
        
        private function resumeGame(e:MouseEvent):void {
            hide();
        }
        
        private function exitGame(e:MouseEvent):void {
            var event:ExitLevelEvent = new ExitLevelEvent(ExitLevelEvent.EXIT_TO_MENU_CMD);
            if ( type == GAME_MENU_TYPE ) event.level_completed = false;
            dispatchEvent(event);
        }
        
        private function restartLevelListener(e:MouseEvent):void {
            var event:ExitLevelEvent = new ExitLevelEvent(ExitLevelEvent.RESTART_LEVEL_CMD);
            event.level_completed = false;
            dispatchEvent(event);
        }
        
        private function nextLevel(e:MouseEvent):void {
            destroy();
            dispatchEvent(new ExitLevelEvent(ExitLevelEvent.NEXT_LEVEL_CMD));
        }
        
        override public function deactivate():void {
            active = false;
            
            game.stage.removeEventListener(KeyboardEvent.KEY_UP, handleMenuInput);
            resumeButton.removeEventListener(MouseEvent.CLICK, resumeGame);
            exitButton.removeEventListener(MouseEvent.CLICK, exitGame);
            
            resumeButton.visible = false;
            exitButton.visible = false;
        }
        
        override public function show():void {
            var tween:Tween = new Tween(this, "alpha", Strong.easeIn, 0, MAX_MENU_STRANPARENCY, 10);
            tween = new Tween (costume,"x", Strong.easeInOut, -costume.width, game.stage.stageWidth / 2, 10);
            super.show();
        }
        
        override public function hide():void {
            var tween:Tween = new Tween(this, "alpha", Strong.easeIn, MAX_MENU_STRANPARENCY, 0, 10);
            tween = new Tween (costume,"x", Strong.easeInOut, game.stage.stageWidth / 2, -costume.width, 10);
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
        
        protected function activateElements():void {}
        
        protected function addElementsToBackground():void {}
        
        protected function deactivateElements():void {}
    }

}