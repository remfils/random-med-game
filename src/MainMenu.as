package src {
    import fl.transitions.easing.Strong;
    import fl.transitions.Tween;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import src.objects.AbstractObject;
    import src.ui.AbstractMenu;
    import src.ui.LevelSelectMenu;
    import src.ui.MageShopMenu;
    import src.ui.TitleMenu;
    

    public class MainMenu extends Sprite {
        private var menus:Array = new Array();
        
        private var menuContainer:Sprite;
        private var currentMenu:AbstractMenu;
        
        public const TITLE_MENU:uint = 0;
        public const LEVELS_MENU:uint = 1;
        public const MAGE_MENU:uint = 2;
        
        public function MainMenu() {
            super();
            
            createBG();
            
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
        
        private function createBG():void {
            var BG:Sprite = new MenuBackground();
            
            BG.x = -2.7;
            BG.y = -13.1;
            BG.width = 784.95;
            BG.height = 770.15;
            
            addChild(BG);
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
            var tween:Tween = new Tween(menuContainer, "y", Strong.easeInOut, -currentMenu.y, -menus[MENU_NAME].y, 25);
            currentMenu = menus[MENU_NAME] as AbstractMenu;
            currentMenu.activate();
        }
        
        private function displayMenu(MENU_NAME:uint):void {
            currentMenu = menus[MENU_NAME] as AbstractMenu;
            currentMenu.show();
        }
        
        public function destroy():void {
            var i:int = menus.length;
            while ( i-- ) {
                AbstractMenu(menus[i]).deactivate();
            }
            
            while (numChildren > 0) {
                removeChildAt(numChildren-1);
            }
            
            if (parent) parent.removeChild(this);
        }
        
    }

}