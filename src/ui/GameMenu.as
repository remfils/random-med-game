package src.ui {
    //import fl.controls.*;
    import fl.transitions.easing.Strong;
    import fl.transitions.Tween;
    import fl.transitions.TweenEvent;
    import flash.automation.StageCaptureEvent;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.*;
    import flash.text.FontStyle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import src.costumes.GameMenuCostume;
    import src.costumes.MenuSprites;
    import src.events.ExitLevelEvent;
    import src.events.GameEvent;
    import src.task.Record;
    import src.util.ObjectPool;
    import src.util.Recorder;
    
    public class GameMenu extends AbstractMenu {
        public static const GAME_MENU_TYPE:int = 1;
        public static const END_LEVEL_TYPE:int = 2;
        public static const DEATH_TYPE:int = 3;
        public static const LOADING_TYPE:int = 4;
        
        public var menu_is_hidden_callback:Function;
        public var menu_is_shown_callback:Function;
        
        protected var MAX_MENU_STRANPARENCY:Number = 0.7;
        
        protected static const LEFT_BTN_X:Number = -150;
        protected static const RIGHT_CORNER_X:Number = 156;
        protected static const FOOTER_Y:Number = 352;
        
        private var type:int;
        
        protected var resume_button:SimpleButton;
        protected var exit_button:SimpleButton;
        
        protected var menuBG:Sprite = new GameMenuBG(); // D!
        protected var costume:GameMenuCostume;
        
        public function GameMenu(stage_:DisplayObjectContainer) {
            super();
            
            stage_.addChild(this);
            
            graphics.beginFill(0x000000);
            graphics.drawRect(0, 0, stage_.width, stage_.height);
            graphics.endFill();
            
            costume.alpha = 1 + MAX_MENU_STRANPARENCY;
            addChild(costume);
            
            alpha = 0;
            deactivate();
            
            //menuBG.alpha = 2;
            //addChild(menuBG);
        }
        
        override public function setUpMenu():void {
            costume = new GameMenuCostume();
            costume.setState(GameMenuCostume.GREEN_STATE);
            costume.clearText();
            
            resume_button = createTitledButton("ПРОДОЛЖИТЬ", defaultTextFormat);
            resume_button.x = - resume_button.width / 2;
            resume_button.y = 171;
            costume.addChild(resume_button);
            
            exit_button = createTitledButton("ВЫХОД", defaultTextFormat);
            exit_button.x = - exit_button.width / 2;
            exit_button.y = 300;
            costume.addChild(exit_button);
        }
        
        protected function createGameMenuElements():void {
            
        }
        
        override public function activate():void {
            //super.activate();
            stage.addEventListener(KeyboardEvent.KEY_UP, handleMenuInput);
            resume_button.addEventListener(MouseEvent.CLICK, resumeGame);
            exit_button.addEventListener(MouseEvent.CLICK, exitGame);
            
            menu_is_shown_callback = function() {
                Recorder.add(new Record(Record.GAMEMENU_ENTER_TYPE));
            };
            
            menu_is_hidden_callback = function() {
                game.resume();
                Recorder.add(new Record(Record.GAMEMENU_LEAVE_TYPE));
            }
            
            activateElements();
        }
        
        protected function handleMenuInput(e:KeyboardEvent):void {
            if ( e.keyCode == 27 ) {
                hide();
                e.stopImmediatePropagation();
            }
        }
        
        protected function resumeGame(e:MouseEvent):void {
            hide();
            game.setAsFocus();
        }
        
        protected function exitGame(e:MouseEvent):void {
            main.exitGame(ExitLevelEvent.EXIT_TO_MENU_CMD, false);
        }
        
        override public function deactivate():void {
            active = false;
            stage.removeEventListener(KeyboardEvent.KEY_UP, handleMenuInput);
            resume_button.removeEventListener(MouseEvent.CLICK, resumeGame);
            exit_button.removeEventListener(MouseEvent.CLICK, exitGame);
        }
        
        override public function show():void {
            if ( active ) return;
            
            super.show();
            stage.addChild(this);
            addChild(costume);
            
            var tween:Tween = ObjectPool.getTween(this, "alpha", Strong.easeIn, 0, MAX_MENU_STRANPARENCY, 10);
            tween = ObjectPool.getTween(costume, "x", Strong.easeInOut, -costume.width, stage.stageWidth / 2, 10);
            tween.addEventListener(TweenEvent.MOTION_FINISH, menuIsShownHandler);
        }
        
        private function menuIsShownHandler(e:TweenEvent):void {
            var t:Tween = Tween(e.target);
            t.removeEventListener(TweenEvent.MOTION_FINISH, menuIsShownHandler);
            
            if ( menu_is_shown_callback ) {
                menu_is_shown_callback();
                menu_is_shown_callback = null;
            }
        }
        
        override public function hide():void {
            var tween:Tween = ObjectPool.getTween(this, "alpha", Strong.easeIn, MAX_MENU_STRANPARENCY, 0, 10);
            tween = ObjectPool.getTween(costume,"x", Strong.easeInOut, stage.stageWidth / 2, -costume.width, 10);
            tween.addEventListener(TweenEvent.MOTION_FINISH, menuIsHiddenHandler);
        }
        
        private function menuIsHiddenHandler(e:Event):void {
            var tween:Tween = e.target as Tween;
            tween.removeEventListener(TweenEvent.MOTION_FINISH, menuIsHiddenHandler);
            
            deactivate();
            visible = false;
            
            removeChild(costume);
            
            if ( menu_is_hidden_callback ) {
                menu_is_hidden_callback();
                menu_is_hidden_callback = null;
            }
        }
        
        protected function menuIsHiddenCallback():void {
            game.resume();
        }
        
        override public function destroy():void {
            super.destroy();
            
            deactivate();
            
            resume_button = null;
            exit_button = null;
            
            var i:int = numChildren;
            while ( i-- ) {
                var g:DisplayObject = getChildAt(i);
                removeChild(g);
            }
            
            //graphics.clear();
            stage.removeChild(this);
        }
        
        protected function activateElements():void {}
        
        protected function addElementsToBackground():void {}
        
        protected function deactivateElements():void {}
    }

}