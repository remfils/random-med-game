package src.ui {
    import flash.display.SimpleButton;
    import flash.events.MouseEvent;
    import flash.text.Font;
    import flash.text.FontStyle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import src.events.ExitLevelEvent;
    public class EndLevelMenu extends GameMenu {
        
        private var exitButton:SimpleButton;
        private var nextLevelButton:SimpleButton;
        
        public function EndLevelMenu() {
            super();
        }
        
        override protected function addElementsToBackground():void {
            exitButton = createTitledButton("ВЫХОД", defaultTextFormat);
            exitButton.x = -150;
            exitButton.y = 352;
            menuBG.addChild(exitButton);
            
            nextLevelButton = createTitledButton("ДАЛЬШЕ", defaultTextFormat);
            nextLevelButton.x = 20;
            nextLevelButton.y = 352;
            menuBG.addChild(nextLevelButton);
            
            var font:Font = new MagicFont();
            
            var TF:TextFormat = new TextFormat(font.fontName, 30, 0xFFDD00, FontStyle.BOLD);
            var titleText:TextField = createTextField("УРОВЕНЬ ПРОЙДЕН", TF);
            
            titleText.x = - titleText.textWidth / 2;
            titleText.y = 130;
            
            menuBG.addChild(titleText);
        }
        
        override protected function activateElements():void {
            exitButton.addEventListener(MouseEvent.CLICK, exitGame);
            nextLevelButton.addEventListener(MouseEvent.CLICK, nextLevel);
        }
        
        override protected function deactivateElements():void {
            exitButton.removeEventListener(MouseEvent.CLICK, exitGame);
            nextLevelButton.removeEventListener(MouseEvent.CLICK, nextLevel);
        }
        
        private function nextLevel(e:MouseEvent):void {
            destroy();
            game.gotoNextLevel();
        }
        
        private function exitGame(e:MouseEvent):void {
            destroy();
            game.exit();
        }
        
        override public function destroy():void {
            super.destroy();
        }
    }

}