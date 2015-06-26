package src.ui {
    import flash.display.DisplayObject;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.Font;
    import flash.text.FontStyle;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import src.costumes.MenuButtonCostume;
    import src.costumes.MenuSprites;
    import src.Player;
    import src.User;

    public class TitleMenu extends AbstractMenu {
        
        private static const LEVELS_BTN:String = "levels_btn";
        private static const INVENTORY_BTN:String = "inventory_btn";
        private static const ACHIVEMENTS_BTN:String = "achivements_btn";
        
        public function TitleMenu() {
            
        }
        
        override public function readData(data:Object):void {
            super.readData(data);
            
            addUserData(data.user as User, data.css as StyleSheet);
            
            // create btns
            
            var rake_y:Number = 504.3;
            
            var btn:MenuButtonCostume = new MenuButtonCostume();
            btn.setState(MenuButtonCostume.LEVEL_BTN);
            btn.x = 236.25;
            btn.y = rake_y;
            btn.name = LEVELS_BTN;
            addChild(btn);
            
            btn = new MenuButtonCostume();
            btn.setState(MenuButtonCostume.INVENTORY_BTN);
            btn.x = 401.25;
            btn.y = rake_y;
            btn.name = INVENTORY_BTN;
            addChild(btn);
            
            btn = new MenuButtonCostume();
            btn.setState(MenuButtonCostume.ACHIVEMENTS_BTN);
            btn.x = 544.15;
            btn.y = rake_y;
            btn.name = ACHIVEMENTS_BTN;
            addChild(btn);
        }
        
        private function addUserData(user:User, styleSheet:StyleSheet):void {
            var userBg:Sprite = new Sprite();
            userBg.x = 30;
            userBg.y = 160;
            
            var userInfo:TextField = new TextField();
            userInfo.x = 10;
            userInfo.y = 10;
            
            var magicFont:Font = new MagicFont();
            
            var textFormat:TextFormat = new TextFormat(magicFont.fontName, 20, 0xffffff, FontStyle.BOLD);
            
            userInfo.embedFonts = true;
            userInfo.defaultTextFormat = textFormat;
            
            userInfo.text = "Имя: " + user.name + "\n"
                + "Фамилия: " + user.surname + "\n"
                + "Уровень: " + user.playerData.LEVEL + "\n"
                + "♥ = " + user.playerData.HEALTH / 2. + " / " + user.playerData.MAX_HEALTH / 2. + "    "
                + "ѽ =  " + user.playerData.MANA / 2. + " / " + user.playerData.MAX_MANA / 2. + ""
                + "";
            userInfo.width = userInfo.textWidth + 20;
            userInfo.height = userInfo.textHeight + 20;
            
            userBg.addChild(userInfo);
            
            userBg.graphics.beginFill(0, 0.3);
            userBg.graphics.drawRect(0, 0, userBg.width, userBg.height);
            userBg.graphics.endFill();
            
            addChild(userBg);
        }
        
        override protected function clickListener(e:MouseEvent):void {
            var objectName:String = DisplayObject(e.target).parent.name;
                
            switch (objectName) {
            case LEVELS_BTN:
                    parentMenu.switchToMenu(parentMenu.LEVELS_MENU);
                    break;
                case INVENTORY_BTN:
                    parentMenu.switchToMenu(parentMenu.MAGE_MENU);
                    break;
                case ACHIVEMENTS_BTN:
                    parentMenu.switchToMenu(0);
                    break;
            }
        }
        
        override public function destroy():void {
            super.destroy();
            
            var child:DisplayObject;
            while (numChildren) {
                child = getChildAt(numChildren - 1);
                if ( child is MenuButtonCostume ) MenuButtonCostume(child).destroy();
                removeChild(child);
            }
        }
    }

}