package src {
    import fl.transitions.easing.Strong;
    import fl.transitions.Tween;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import src.costumes.MenuSprites;
    import src.objects.AbstractObject;
    import src.ui.AbstractMenu;
    import src.ui.LevelSelectMenu;
    import src.ui.MageShopMenu;
    import src.ui.TitleMenu;
    import src.util.TweenPool;
    

    public class MainMenu extends Sprite {
        private var menus:Array = new Array();
        
        private var menuContainer:Sprite;
        private var currentMenu:AbstractMenu;
        
        public const TITLE_MENU:uint = 0;
        public const LEVELS_MENU:uint = 1;
        public const MAGE_MENU:uint = 2;
        
        public function MainMenu() {
            super();
            
            // create BG
            var BG:MenuSprites = new MenuSprites();
            BG.setSprite(MenuSprites.BG);
            addChild(BG);
            
            currentMenu = menus[TITLE_MENU] = new TitleMenu();
            menus[LEVELS_MENU] = new LevelSelectMenu();
            menus[MAGE_MENU] = new MageShopMenu();
            
            menuContainer = new Sprite();
            addChild(menuContainer);
            
            var i:int = menus.length;
            while ( i-- ) {
                menuContainer.addChild(menus[i]);
                AbstractMenu(menus[i]).parentMenu = this;
            }
        }
        
        private function hideAll():void {
            hideMenusExcept();
        }
        
        private function hideMenusExcept (menu:AbstractMenu = null):void {
            var i:int = menus.length;
            
            while ( i-- ) {
                if ( menus[i] == menu )
                    AbstractMenu(menus[i]).hide();
            }
        }
        
        public function render(data:Object):void {
            placeMenus();
            
            var i:int = menus.length;
            
            while ( i-- )
                AbstractMenu(menus[i]).readData(data);
        }
        
        private function placeMenus():void {
            var spr:Sprite = menus[LEVELS_MENU];
            spr.x = 0;
            spr.y += -2 * stage.stageHeight - height;
            
            spr = menus[MAGE_MENU];
            spr.y -= -2 * stage.stageHeight - height ;
        }
        
        public function switchToMenu(MENU_NAME:uint):void {
            currentMenu.deactivate();
            
            var tween:Tween = TweenPool.getTween(menuContainer, "y", Strong.easeInOut, -currentMenu.y, -menus[MENU_NAME].y, 25);
            
            currentMenu = AbstractMenu(menus[MENU_NAME]);
            currentMenu.activate();
        }
        
        private function displayMenu(MENU_NAME:uint):void {
            currentMenu = menus[MENU_NAME] as AbstractMenu;
            currentMenu.show();
        }
        
        public function destroy():void {
            var i:int = menus.length;
            while ( i-- ) {
                AbstractMenu(menus[i]).destroy();
            }
            
            while (numChildren > 0) {
                removeChildAt(numChildren-1);
            }
            
            if (parent) parent.removeChild(this);
        }
        
    }

}