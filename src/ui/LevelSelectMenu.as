package src.ui {
    import fl.transitions.easing.Strong;
    import fl.transitions.Tween;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import src.costumes.MenuSprites;
    import src.events.MenuItemSelectedEvent;
    import src.User;
    import src.util.DeleteManager;

    public class LevelSelectMenu extends AbstractMenu {
        public static const MOVE_LEVELS_LEFT_BTN:String = "MoveLeft";
        public static const MOVE_LEVELS_RIGHT_BTN:String = "MoveRight";
        
        private var allLevelsContainer:Sprite;
        
        public function LevelSelectMenu() {
            super();
        }
        
        override public function readData(data:Object):void {
            super.readData(data);
            
            var rake_y:Number = 485.45
            
            var btn:MenuButton = new MenuButton();
            btn.setState(MenuButton.MOVE_LEVELS_LEFT);
            btn.x = 55.4;
            btn.y = rake_y;
            btn.name = MOVE_LEVELS_LEFT_BTN;
            
            addChild(btn);
            
            btn = new MenuButton();
            btn.setState(MenuButton.MOVE_LEVELS_RIGHT);
            btn.x = 697.95;
            btn.y = rake_y;
            btn.name = MOVE_LEVELS_RIGHT_BTN;
            
            addChild(btn);
            
            btn = new MenuButton();
            btn.setState(MenuButton.GOTO_TITLE_BTN);
            btn.name = GOTO_TITLE_BTN;
            btn.x = GOTO_TITLE_BTN_POSITION.x;
            btn.y = GOTO_TITLE_BTN_POSITION.y;
            addChild(btn);
            
            createLevelSelectButtons(data.user, data.levels);
        }
        
        private function createLevelSelectButtons(user:User, levels:XMLList):void {
            var btn:MenuButton,
                star:MenuSprites,
                i:int = 0,
                j:int = 0,
                k:int = 0,
                rating_i:int = 0,
                levelCounter:int = 0,
                ammendX:Number = 0,
                ammendY:Number = 0;
            
            btn = new MenuButton();
            btn.setState(MenuButton.LEVEL_SELECT_BTN);
            
            star = new MenuSprites();
            star.setSprite(MenuSprites.STAR_EMPTY);
            
            ammendX = btn.width / 2 - star.width * 3 / 2;
            ammendY = - star.height / 2;
            
            allLevelsContainer = new Sprite();
            addChild(allLevelsContainer);
            
            for each ( var level:XML in levels.* ) {
                btn = new MenuButton();
                btn.setState(MenuButton.LEVEL_SELECT_BTN);
                btn.name = level.id;
                btn.level_name.text = level.name;
                
                btn.y = 200 + j * (btn.height + 10);
                btn.x = 110 + stage.width * k + 140 * i++;
                
                if ( levelCounter++ > user.levelsCompleted ) {
                    btn.mouseEnabled = false;
                }
                
                // rating
                for ( rating_i = 0; rating_i < 3; rating_i++ ) {
                    star = new MenuSprites();
                    if ( rating_i < level.rating )
                        star.setSprite(MenuSprites.STAR_FULL);
                    else
                        star.setSprite(MenuSprites.STAR_EMPTY);
                    
                    star.x = ammendX + star.width * rating_i;
                    star.y = ammendY;
                    
                    btn.addChild(star);
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
                
                allLevelsContainer.addChild(btn);
            }
        }
        
        override protected function clickListener(e:MouseEvent):void {
            var objectName:String = DisplayObject(e.target).parent.name;
            
            switch( objectName ) {
                case GOTO_TITLE_BTN:
                    parentMenu.switchToMenu(parentMenu.TITLE_MENU);
                    break;
                case MOVE_LEVELS_RIGHT_BTN:
                    moveAllLevelsContainerRight();
                    break;
                case MOVE_LEVELS_RIGHT_BTN:
                    moveAllLevelsContainerLeft();
                    break;
                case null:
                    return;
                default:
                    dispatchEvent(new MenuItemSelectedEvent(MenuItemSelectedEvent.LEVEL_SELECTED, int(objectName)));
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
        
        override public function destroy():void {
            super.destroy();
            
            var child:DisplayObject;
            var i = numChildren;
            while (i--) {
                child = getChildAt(i);
                if ( child is MenuButton ) MenuButton(child).destroy();
            }
            DeleteManager.stripDisplayObject(this);
            DeleteManager.stripDisplayObject(allLevelsContainer)
            allLevelsContainer = null;
        }
    }

}