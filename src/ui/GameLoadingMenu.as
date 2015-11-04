package src.ui {
	import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import src.costumes.GameMenuCostume;
    import src.costumes.MenuSprites;
	


    public class GameLoadingMenu extends GameMenu {
        
        public function GameLoadingMenu(stage_:DisplayObjectContainer) {
            super(stage_);
            MAX_MENU_STRANPARENCY = 1;
        }
        
        override public function setUpMenu():void {
            costume = new GameMenuCostume();
            costume.setState(GameMenuCostume.LOADING_STATE);
            costume.setTitle("ЗАГРУЗКА");

            var ball:MenuSprites = new MenuSprites();
            ball.setSprite(MenuSprites.LOADING_CIRCLE);
            ball.x = 0;
            ball.y = FOOTER_Y;
            costume.addChild(ball);
        }
        
        override public function deactivate():void {
            active = false;
            //stage.addChildAt(this, 0);
        }
       
        override public function activate():void {
            active = true;
        }
    }

}