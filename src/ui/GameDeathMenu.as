package src.ui {
    import flash.display.DisplayObjectContainer;
    import flash.events.MouseEvent;
    import src.costumes.GameMenuCostume;
    import src.events.ExitLevelEvent;
	


    public class GameDeathMenu extends GameMenu {
        
        public function GameDeathMenu(stage_:DisplayObjectContainer) {
            super(stage_);
        }
        
        override public function setUpMenu():void {
            costume = new GameMenuCostume();
            costume.setState(GameMenuCostume.RED_STATE);
            costume.setTitle("ПОРАЖЕНИЕ");
            
            exit_button = createTitledButton("ВЫХОД", defaultTextFormat);
            exit_button.x = LEFT_BTN_X;
            exit_button.y = FOOTER_Y;
            costume.addChild(exit_button);
            
            resume_button = createTitledButton("СНАЧАЛА", defaultTextFormat);
            resume_button.x = RIGHT_CORNER_X - resume_button.width;
            resume_button.y = exit_button.y;
            costume.addChild(resume_button);
        }
        
        override public function activate():void {
            exit_button.addEventListener(MouseEvent.CLICK, exitGame);
            resume_button.addEventListener(MouseEvent.CLICK, restartLevelListener);
        }
        
        override protected function exitGame(e:MouseEvent):void {
            hide();
            main.exitGame(ExitLevelEvent.EXIT_TO_MENU_CMD, false);
        }
        
        protected function restartLevelListener(e:MouseEvent):void {
            hide();
            main.exitGame(ExitLevelEvent.RESTART_LEVEL_CMD, false);
        }
        
        override public function deactivate():void {
            exit_button.removeEventListener(MouseEvent.CLICK, exitGame);
            resume_button.removeEventListener(MouseEvent.CLICK, restartLevelListener);
        }
    }

}