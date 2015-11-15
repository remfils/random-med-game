package src.ui {
    import flash.display.DisplayObjectContainer;
    import flash.events.MouseEvent;
    import src.costumes.GameMenuCostume;
    import src.events.ExitLevelEvent;
    import src.util.SoundManager;


    public class GameEndMenu extends GameMenu {
        
        public function GameEndMenu(stage_:DisplayObjectContainer) {
            super(stage_);
        }
        
        override public function setUpMenu():void {
            costume = new GameMenuCostume();
            costume.setState(GameMenuCostume.GREEN_STATE);
            costume.setTitle("УРОВЕНЬ ПРОЙДЕН");
            
            exit_button = createTitledButton("ВЫХОД", defaultTextFormat);
            exit_button.x = LEFT_BTN_X;
            exit_button.y = FOOTER_Y;
            costume.addChild(exit_button);
            
            resume_button = createTitledButton("ДАЛЬШЕ", defaultTextFormat);
            resume_button.x = RIGHT_CORNER_X - resume_button.width;
            resume_button.y = exit_button.y;
            costume.addChild(resume_button);
        }
        
        override public function activate():void {
            SoundManager.instance.stopBGM();
            SoundManager.instance.playSFX(SoundManager.SFX_FINISH_LEVEL);
            
            exit_button.addEventListener(MouseEvent.CLICK, exitGame);
            resume_button.addEventListener(MouseEvent.CLICK, startNextLevelListener);
        }
        
        override protected function exitGame(e:MouseEvent):void {
            hide();
            main.exitGame(ExitLevelEvent.EXIT_TO_MENU_CMD, true);
        }
        
        private function startNextLevelListener(e:MouseEvent):void {
            hide();
            main.exitGame(ExitLevelEvent.NEXT_LEVEL_CMD, true);
        }
        
        override public function deactivate():void {
            exit_button.removeEventListener(MouseEvent.CLICK, exitGame);
            resume_button.removeEventListener(MouseEvent.CLICK, startNextLevelListener);
        }
    }

}