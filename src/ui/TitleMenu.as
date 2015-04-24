package src.ui {
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.Font;
    import flash.text.FontStyle;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import src.Player;
    import src.User;

    public class TitleMenu extends AbstractMenu {
        
        public function TitleMenu() {
            
        }
        
        override public function readData(data:Object):void {
            super.readData(data);
            
            addUserData(data.user as User, data.css as StyleSheet);
            
            addTitleMenuButtons();
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
        
        private function addTitleMenuButtons():void {
            var btn:SimpleButton = createButtonFromClass(GotoLevelsButton, 236.25, 504.3);
            addChild(btn);
            
            btn = createButtonFromClass(GotoShopButton, 401.25, 506);
            addChild(btn);
            
            btn = createButtonFromClass(GotoAchievementsButton, 544.15, 504.5);
            addChild(btn);
        }
        
        override protected function clickListener(e:MouseEvent):void {
            if ( e.target is GotoLevelsButton ) {
                parentMenu.switchToMenu(parentMenu.LEVELS_MENU);
            }
            if ( e.target is GotoShopButton ) {
                parentMenu.switchToMenu(parentMenu.MAGE_MENU);
            }
            if ( e.target is GotoAchievementsButton ) {
                parentMenu.switchToMenu(0);
            }
        }
        
        
    }

}