package src.ui {
    import fl.motion.Color;
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.media.SoundMixer;
    import flash.text.Font;
    import flash.text.FontStyle;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import src.costumes.MenuButtonCostume;
    import src.costumes.MenuSprites;
    import src.costumes.PlayerStatCostume;
    import src.enemy.ChargerEnemy;
    import src.Player;
    import src.ui.playerStat.StatDescriteBar;
    import src.User;
    import src.util.SoundManager;

    public class TitleMenu extends AbstractMenu {
        private static const MAX_CHARS_IN_NAME:int = 30;
        private static const MAX_CHARS_IN_NUMBER:int = 6;
        private static const LARGE_NUMBER_END:String = "M";
        private static const LARGE_STRING_END:String = "...";
        
        private static const LEVELS_BTN:String = "levels_btn";
        private static const INVENTORY_BTN:String = "inventory_btn";
        private static const ACHIVEMENTS_BTN:String = "achivements_btn";
        private static const SHOP_BTN:String = "shop_btn";
        
        private static const MENU_LEFT_PADDING:int = 20;
        
        private static const DEFAULT_MARGIN:int = 5;
        
        private var user_display:Sprite;
        private var topusers_display:Sprite;
        
        private var player_health_bar:StatDescriteBar;
        private var player_mana_bar:StatDescriteBar;
        
        public function TitleMenu() {
            
        }
        
        override public function activate():void {
            super.activate();
            
            player_health_bar.updatePoints();
            player_mana_bar.updatePoints();
        }
        
        override public function readData(data:Object):void {
            super.readData(data);
            
            drawUserData(data.user as User, data.css as StyleSheet);
            
            drawTopUsersData(data.topusers);
            
            // create btns
            
            var rake_y:Number = 504.3;
            
            var btn:MenuButtonCostume = new MenuButtonCostume();
            btn.setState(MenuButtonCostume.LEVEL_BTN);
            btn.x = 177.1;
            btn.y = rake_y;
            btn.name = LEVELS_BTN;
            addChild(btn);
            
            btn = new MenuButtonCostume();
            btn.setState(MenuButtonCostume.INVENTORY_BTN);
            btn.x = 315.4;
            btn.y = rake_y;
            btn.name = INVENTORY_BTN;
            addChild(btn);
            
            btn = new MenuButtonCostume();
            btn.setState(MenuButtonCostume.SHOP_BTN);
            btn.x = 444.9;
            btn.y = rake_y;
            btn.name = SHOP_BTN;
            addChild(btn);
            
            btn = new MenuButtonCostume();
            btn.setState(MenuButtonCostume.ACHIVEMENTS_BTN);
            btn.x = 567.8;
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
            var title:Sprite = createMenuTitleText("ИГРОК", 450 + 4 * DEFAULT_MARGIN);
            
            user_display.addChild(title);
            
            var userInfo:TextField = new TextField();
            userInfo.x = left_padding;
            userInfo.y = title.height + DEFAULT_MARGIN;
            
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
            player_health_bar = new StatDescriteBar(user.player, PlayerStatCostume.HEART_TYPE, "HEALTH");
            player_health_bar.x = 450 + 2 * DEFAULT_MARGIN - player_health_bar.width;
            player_health_bar.y = userInfo.y + 2 * DEFAULT_MARGIN;
            user_display.addChild(player_health_bar);
            
            player_mana_bar = new StatDescriteBar(user.player, PlayerStatCostume.MANA_TYPE, "MANA");
            player_mana_bar.x = player_health_bar.x;
            player_mana_bar.y = player_health_bar.y + player_mana_bar.height;
            user_display.addChild(player_mana_bar);
            
            // left_padding += MENU_LEFT_PADDING;
            drawBlackRecktangleInSprite(user_display);
            
            user_display.x = (stage.stageWidth - user_display.width) / 2;
            user_display.y = 145;
            addChild(user_display);
        }
        
        private function drawTopUsersData(topusers_xml:XMLList):void {
            var createTextColumn:Function = function (col_title:String, width_:Number, is_right_allign:Boolean = true):TextField {
                var text_format:TextFormat;
                var tf:TextField = new TextField();
                tf.multiline = true;
                tf.selectable = false;
                
                var magic_font:Font = new MagicFont();
                
                text_format = new TextFormat(magic_font.fontName, 14, 0xffffff);
                text_format.align = is_right_allign ? "right" : "left";
                
                tf.defaultTextFormat = text_format;
                
                tf.width = width_;
                
                tf.text = col_title.toLocaleUpperCase();
                
                return tf;
            };
            
            topusers_display = new Sprite();
            
            var padding_top:Number = 0;
            var padding_left:Number = DEFAULT_MARGIN;
            
            var menu_title:Sprite = createMenuTitleText("ТОП", 450 + 4 * DEFAULT_MARGIN);
            
            menu_title.x = 0;
            menu_title.y = padding_top;
            
            topusers_display.addChild(menu_title);
            
            padding_top += menu_title.height + 2 * DEFAULT_MARGIN;
            
            var user_name_col:TextField = createTextColumn("имя", 250, false);
            var user_money_col:TextField = createTextColumn("золото", 100);
            var user_exp_col:TextField = createTextColumn("опыт", 100);
            
            for each (var usr_xml:XML in topusers_xml.*) {
                user_name_col.appendText("\n" + stripString(usr_xml.@name));
                user_exp_col.appendText("\n" + stripNumber(usr_xml.@exp));
                user_money_col.appendText("\n" + stripNumber(usr_xml.@money));
            }
            
            user_name_col.x = padding_left;
            user_name_col.y = padding_top;
            user_name_col.height = user_name_col.textHeight + 10;
            topusers_display.addChild(user_name_col);
            
            padding_left += DEFAULT_MARGIN + user_name_col.width;
            
            user_exp_col.x = padding_left;
            user_exp_col.y = padding_top;
            user_exp_col.height = user_exp_col.textHeight + 10;
            topusers_display.addChild(user_exp_col);
            
            padding_left += DEFAULT_MARGIN + user_exp_col.width;
            
            user_money_col.x = padding_left;
            user_money_col.y = padding_top;
            user_money_col.height = user_money_col.textHeight + 10;
            topusers_display.addChild(user_money_col);
            
            padding_left += DEFAULT_MARGIN + user_money_col.width;
            
            drawBlackRecktangleInSprite(topusers_display);
            
            topusers_display.x = ( this.stage.stageWidth - topusers_display.width ) / 2;
            topusers_display.y = user_display.y + user_display.height + 2 * DEFAULT_MARGIN;
            addChild(topusers_display);
        }
        
        private function createMenuTitleText(title:String, titile_width:Number = 450):Sprite {
            var container:Sprite = new Sprite();
            
            var magic_font:Font = new MagicFont();
            var text_format:TextFormat = new TextFormat(magic_font.fontName, 20, 0xFFFFFF, true);
            text_format.align = "center";
            
            var tf:TextField = createTextField(title, text_format);
            tf.width = titile_width;
            
            container.addChild(tf);
            
            drawBlackRecktangleInSprite(container);
            
            return container;
        }
        
        private function stripString(str:String):String {
            var res_str:String = str;
            
            if ( res_str.length > MAX_CHARS_IN_NAME ) {
                res_str = str.slice(MAX_CHARS_IN_NAME) + LARGE_STRING_END;
            }
            
            return res_str;
        }
        
        private function stripNumber(num:Number):String {
            var res_str:String = "";
            var res_num:Number = num;
            var max_number:Number = Math.pow(10, MAX_CHARS_IN_NUMBER);
            
            while ( res_num > max_number ) {
                res_num = Math.round( res_num / max_number );
                res_str += LARGE_NUMBER_END;
            }
            
            res_str = res_num + res_str;
            return res_str;
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
                case SHOP_BTN:
                    parentMenu.switchToMenu(parentMenu.SHOP_MENU);
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