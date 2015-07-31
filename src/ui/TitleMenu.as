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
    import src.costumes.PlayerStatCostume;
    import src.Player;
    import src.ui.playerStat.StatDescriteBar;
    import src.User;

    public class TitleMenu extends AbstractMenu {
        
        private static const LEVELS_BTN:String = "levels_btn";
        private static const INVENTORY_BTN:String = "inventory_btn";
        private static const ACHIVEMENTS_BTN:String = "achivements_btn";
        
        private static const MENU_LEFT_PADDING:int = 20;
        
        private var user_display:Sprite;
        
        public function TitleMenu() {
            
        }
        
        override public function readData(data:Object):void {
            super.readData(data);
            
            drawUserData(data.user as User, data.css as StyleSheet);
            
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
        
        private function drawUserData(user:User, styleSheet:StyleSheet):void {
            var left_padding:int = MENU_LEFT_PADDING;
            if ( user_display ) {
                while ( user_display.numChildren ) {
                    user_display.removeChildAt(user_display.numChildren - 1);
                }
                removeChild(user_display);
            }
            
            user_display = new Sprite();
            // user_display.x = 30;
            
            var userInfo:TextField = new TextField();
            userInfo.x = left_padding;
            userInfo.y = 10;
            
            var magicFont:Font = new MagicFont();
            var textFormat:TextFormat = new TextFormat(magicFont.fontName, 20, 0xffffff, FontStyle.BOLD);
            
            userInfo.embedFonts = true;
            userInfo.defaultTextFormat = textFormat;
            
            userInfo.text = "Имя: " + user.name + "\n"
                + "Фамилия: " + user.surname + "\n"
                + "Опыт: " + user.player.EXP + "\n"
                + "До следующего уровня: " + (user.player.EXP_TO_NEXT - user.player.EXP) + "\n";
            userInfo.width = userInfo.textWidth + left_padding;
            userInfo.height = userInfo.textHeight + left_padding;
            
            user_display.addChild(userInfo);
            
            // player hearts and bottels
            left_padding += MENU_LEFT_PADDING;
            var bar:StatDescriteBar = new StatDescriteBar(user.player, PlayerStatCostume.HEART_TYPE, "HEALTH");
            bar.x = userInfo.width + left_padding;
            bar.y = 20;
            user_display.addChild(bar);
            
            bar = new StatDescriteBar(user.player, PlayerStatCostume.MANA_TYPE, "MANA");
            bar.x = userInfo.width + left_padding;
            bar.y = 20 + bar.height;
            user_display.addChild(bar);
            
            // left_padding += MENU_LEFT_PADDING;
            user_display.graphics.beginFill(0, 0.3);
            user_display.graphics.drawRect(0, 0, user_display.width + left_padding, user_display.height);
            user_display.graphics.endFill();
            
            user_display.x = (stage.stageWidth - user_display.width) / 2;
            user_display.y = 160;
            addChild(user_display);
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