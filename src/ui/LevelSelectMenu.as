package src.ui {
    import fl.transitions.easing.Strong;
    import fl.transitions.Tween;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import src.events.MenuItemSelectedEvent;
    import src.User;
	/**
     * ...
     * @author vlad
     */
    public class LevelSelectMenu extends AbstractMenu {
        private var allLevelsContainer:Sprite;
        
        public function LevelSelectMenu() {
            super();
        }
        
        override public function readData(data:Object):void {
            super.readData(data);
            
            createMoveLeftButton();
            createMoveRigthButton();
            
            var titleBtn:Sprite = getGotoMenuButton();
            addChild(titleBtn);
            
            createLevelSelectButtons(data.user, data.levels);
        }
        
        private function createMoveLeftButton():void {
            var btnContainer:Sprite = getCustomButtonAt(TabletButton, 55.4, 485.45);
            btnContainer.name = "MoveLeft";
            btnContainer.rotation = 4;
            
            var arrow:Sprite = new PaintedArrow();
            arrow.rotation = 180;
            arrow.mouseEnabled = false;
            btnContainer.addChild(arrow);
            
            addChild(btnContainer);
        }
        
        private function createMoveRigthButton():void {
            var btnContainer:Sprite = getCustomButtonAt(TabletButton, 697.95, 485.45);
            btnContainer.name = "MoveRight";
            btnContainer.rotation = -4;
            
            var arrow:Sprite = new PaintedArrow();
            arrow.mouseEnabled = false;
            btnContainer.addChild(arrow);
            
            addChild(btnContainer);
        }
        
        private function createLevelSelectButtons(user:User, levels:XMLList):void {
            var btnLevel:GenericLevelButton,
                i:int = 0,
                j:int = 0,
                k:int = 0,
                levelCounter:int = 0;
                
            allLevelsContainer = new Sprite();
            addChild(allLevelsContainer);
            
            for each ( var level:XML in levels.* ) {
                btnLevel = new GenericLevelButton();
                // IMPORTANT: add label and rating first to increase btnLevel height for y alignment
                btnLevel.setLabel(level.name);
                btnLevel.setRating(level.rating);
                
                btnLevel.y = 200 + j * (btnLevel.height + 10);
                btnLevel.x = 110 + stage.width * k + 140 * i++;
                
                if ( levelCounter++ > user.levelsCompleted ) {
                    btnLevel.block();
                }
                
                if ( i == 4 ) {
                    i = 0;
                    j++;
                }
                
                if ( j == 2 ) {
                    i = 0;
                    j = 0;
                    k++;
                }
                
                btnLevel.levelId = level.id;
                
                allLevelsContainer.addChild(btnLevel);
            }
        }
        
        // попробовать закинуть name в GenericLevelButton
        override protected function clickListener(e:MouseEvent):void {
            var target:Sprite = e.target.parent;
            
            switch( target.name ) {
                case "GotoTitle":
                    parentMenu.switchToMenu(parentMenu.TITLE_MENU);
                    break;
                case "MoveRight":
                    moveAllLevelsContainerRight();
                    break;
                case "MoveLeft":
                    moveAllLevelsContainerLeft();
                    break;
            }
            
            if ( e.target is GenericLevelButton ) {
                dispatchEvent(new MenuItemSelectedEvent(MenuItemSelectedEvent.LEVEL_SELECTED, GenericLevelButton(e.target).levelId));
            }
        }
        
        private function moveAllLevelsContainerLeft () {
            if (allLevelsContainer.x < -10) {
                var tween:Tween = new Tween (allLevelsContainer, "x", Strong.easeInOut, allLevelsContainer.x, allLevelsContainer.x + 750, 18 );
            }
        }
        
        private function moveAllLevelsContainerRight () {
            if (Math.abs(allLevelsContainer.x - 750) <= allLevelsContainer.width) {
                var tween:Tween = new Tween (allLevelsContainer, "x", Strong.easeInOut, allLevelsContainer.x, allLevelsContainer.x - 750, 18 );
            }
        }
    }

}