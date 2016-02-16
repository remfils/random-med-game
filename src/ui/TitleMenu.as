package src.ui {
    import fl.motion.Color;
    import flash.display.DisplayObject;
    import flash.display.Graphics;
    import flash.display.Loader;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;
    import flash.media.SoundMixer;
    import flash.net.URLRequest;
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
    import src.util.Output;
    import src.util.SoundManager;

    public class TitleMenu extends AbstractMenu {
        private static const MAX_CHARS_IN_NAME:int = 30;
        private static const MAX_CHARS_IN_NUMBER:int = 6;
        private static const LARGE_NUMBER_END:String = "M";
        private static const LARGE_STRING_END:String = "...";
        private static const AVATAR_WIDTH:Number = 50;
        
        private static const USER_DISPLAY_WIDTH:Number = 271.95;
        
        private static const TOP_USER_NAME_COL_WIDTH:Number = 120;
        private static const TOP_NUMBER_COL_WIDTH:Number = 30;
        private static const TOP_EXP_COL_WIDTH:Number = 70;
        private static const TOP_MONEY_COL_WIDTH:Number = 70;
        
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
            
            drawUserData(data.user as User, data.css as StyleSheet, data.users_avatars);
            
            drawTopUsersData(data.topusers, data.users_avatars);
            
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
        
        private function drawUserData(user:User, styleSheet:StyleSheet, users_avatars:Array):void {
            var left_padding:int = MENU_LEFT_PADDING;
            if ( user_display ) {
                while ( user_display.numChildren ) {
                    user_display.removeChildAt(user_display.numChildren - 1);
                }
                removeChild(user_display);
            }
            
            var margin_y:Number = 0;
            
            user_display = new Sprite();
            // user_display.x = 30;
            var title:Sprite = createMenuTitleText("ИГРОК", USER_DISPLAY_WIDTH);
            
            user_display.addChild(title);
            margin_y += title.height + DEFAULT_MARGIN;
            
            var user_logo:Loader = new Loader();
            
            Output.add("users_avatars.length:" + users_avatars.length);
            
            for each ( var o:Object in users_avatars ) {
                Output.add("user:");
                for ( var s:String in o ) {
                    Output.add(s + ": " + o[s]);
                }
                if ( int(o.uid) == user.uid ) {
                    user_logo.load(new URLRequest(o.photo_50));
                    break;
                }
            }
            
            var user_name_card:Sprite = new Sprite();
            user_name_card.x = DEFAULT_MARGIN;
            user_name_card.y = margin_y;
            user_name_card.addChild(user_logo);
            
            var user_name:TextField = createMagicTextField(user.name + "\n" + user.surname, "left");
            user_name.x = AVATAR_WIDTH + DEFAULT_MARGIN;
            user_name_card.addChild(user_name);
            
            user_display.addChild(user_name_card);
            margin_y += user_name_card.height + DEFAULT_MARGIN;
            
            // player hearts and bottels
            left_padding += MENU_LEFT_PADDING;
            player_health_bar = new StatDescriteBar(user.player, PlayerStatCostume.HEART_TYPE, "HEALTH");
            player_health_bar.x = DEFAULT_MARGIN + player_health_bar.height / 2;
            player_health_bar.y = margin_y + player_health_bar.height / 2;
            user_display.addChild(player_health_bar);
            margin_y += player_health_bar.height + DEFAULT_MARGIN;
            
            player_mana_bar = new StatDescriteBar(user.player, PlayerStatCostume.MANA_TYPE, "MANA");
            player_mana_bar.x = player_health_bar.x;
            player_mana_bar.y = margin_y + player_mana_bar.height / 2;
            user_display.addChild(player_mana_bar);
            margin_y += player_mana_bar.height + DEFAULT_MARGIN;
            
            var exp_display:Sprite = new Sprite();
            exp_display.x = DEFAULT_MARGIN;
            exp_display.y = margin_y;
            var star:MenuSprites = new MenuSprites();
            star.setSprite(MenuSprites.EXP_GRAPHIC);
            
            var user_lvl:int = user.player.LEVEL;
            var user_lvl_txt:TextField = createMagicTextField("" + user_lvl);
            user_lvl_txt.defaultTextFormat.size = 7;
            user_lvl_txt.filters = new Array(new DropShadowFilter(1, 45, 0, 1, 1, 1));
            star.addChild(user_lvl_txt);
            //user_lvl_txt.scaleX = user_lvl_txt.scaleY = 15 / user_lvl_txt.textWidth;
            user_lvl_txt.x = (star.width - user_lvl_txt.textWidth) / 2 - 2;
            user_lvl_txt.y = (star.height - user_lvl_txt.textHeight) / 2 - 2;
            
            exp_display.addChild(star);
            
            var prev_xp:Number = user_lvl == 0 ?
                0 :
                user.player.getXPToLevel(user_lvl - 1);
            
            var current_xp:Number = user.player.EXP;
            /*if ( current_xp <= 0 ) {
                current_xp = 3;
            }*/
            
            var next_xp:Number = user.player.getXPToLevel(user_lvl);
            
            var user_exp_txt:TextField = createMagicTextField( user.player.EXP + "/" + next_xp);
            user_exp_txt.scaleX = user_exp_txt.scaleY = 0.6;
            user_exp_txt.x = star.width + DEFAULT_MARGIN;
            exp_display.addChild(user_exp_txt);
            
            var bar:Sprite = new Sprite();
            bar.x = star.width + DEFAULT_MARGIN;
            bar.y = user_exp_txt.height * user_exp_txt.scaleX + DEFAULT_MARGIN;
            // bar.y = ;
            
            var g:Graphics = bar.graphics;
            var bar_width:Number = USER_DISPLAY_WIDTH / 2;
            g.beginFill(0, 0.3);
            g.drawRect(0, 0, bar_width, 10);
            g.endFill();
            g.beginFill(0x610085);
            g.drawRect(1, 1, (current_xp - prev_xp + 1) / (next_xp - prev_xp) * bar_width - 2, 8)
            g.endFill();
            
            exp_display.addChild(bar);
            
            user_display.addChild(exp_display);
            margin_y += user_display.height + DEFAULT_MARGIN;
            
            /*userInfo.x = DEFAULT_MARGIN;
            userInfo.y = margin_y;
            userInfo.width = userInfo.textWidth + left_padding;
            userInfo.height = userInfo.textHeight + left_padding;
            
            user_display.addChild(userInfo);*/
            
            // left_padding += MENU_LEFT_PADDING;
            drawBlackRecktangleInSprite(user_display, 0, DEFAULT_MARGIN);
            
            //user_display.x = (stage.stageWidth - user_display.width) / 2;
            user_display.x = 82.45;
            user_display.y = 145;
            addChild(user_display);
        }
        
        private function drawTopUsersData(topusers_xml:XMLList, users_avatars:Array):void {
            var createRow:Function = function (num:int, name:String, uid:int, exp:int, money:int):Sprite {
                var row:Sprite = new Sprite();
                var margin_x:Number = 0;
                
                //margin_x += DEFAULT_MARGIN
                
                var num_tf:TextField = createMagicTextField(num + ".", "right");
                num_tf.width = TOP_NUMBER_COL_WIDTH;
                row.addChild(num_tf);
                margin_x += TOP_NUMBER_COL_WIDTH + DEFAULT_MARGIN;
                
                var img_url:String = "";
                for each ( var o:Object in users_avatars ) {
                    if ( int(o.uid) == uid ) {
                        img_url = o.photo_50;
                        Output.add(img_url);
                        break;
                    }
                }
                
                var loader:Loader = new Loader();
                loader.load(new URLRequest(img_url));
                //loader.width = AVATAR_WIDTH;
                loader.scaleX = loader.scaleY = 0.5;
                loader.x = margin_x;
                row.addChild(loader);
                margin_x += AVATAR_WIDTH / 2 + DEFAULT_MARGIN;
                
                var name_tf:TextField = createMagicTextField(name, "left");
                name_tf.x = margin_x;
                name_tf.scaleX = name_tf.scaleY = 0.65;
                row.addChild(name_tf);
                margin_x += TOP_USER_NAME_COL_WIDTH + DEFAULT_MARGIN;
                
                var exp_txt:TextField = createMagicTextField(stripNumber(exp), "right");
                exp_txt.width = TOP_EXP_COL_WIDTH;
                exp_txt.x = margin_x;
                row.addChild(exp_txt);
                margin_x += TOP_EXP_COL_WIDTH + DEFAULT_MARGIN;
                
                var money_txt:TextField = createMagicTextField(stripNumber(money), "right");
                money_txt.textColor = 0xFEB401;
                money_txt.x = margin_x;
                money_txt.width = TOP_MONEY_COL_WIDTH;
                row.addChild(money_txt);
                margin_x += TOP_MONEY_COL_WIDTH + DEFAULT_MARGIN;
                
                loader.y = (name_tf.height - AVATAR_WIDTH / 2) / 2;
                num_tf.y = (name_tf.height - num_tf.height) / 2;
                exp_txt.y = (name_tf.height - exp_txt.height) / 2;
                money_txt.y = (name_tf.height - money_txt.height) / 2;
                
                return row;
            };
            
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
            
            var margin_top:Number = 0;
            
            topusers_display = new Sprite();
            
            var menu_title:Sprite = createMenuTitleText("ТОП", 6 * DEFAULT_MARGIN
                                        + TOP_NUMBER_COL_WIDTH
                                        + AVATAR_WIDTH / 2
                                        + TOP_USER_NAME_COL_WIDTH
                                        + TOP_EXP_COL_WIDTH
                                        + TOP_MONEY_COL_WIDTH);
            
            topusers_display.addChild(menu_title);
            
            margin_top += menu_title.height + DEFAULT_MARGIN;
            
            var row_header:Sprite = new Sprite();
            var margin_left:Number = TOP_NUMBER_COL_WIDTH + 2 * DEFAULT_MARGIN;
            row_header.y = margin_top;
            
            var magic_font:Font = new MagicFont();
            var title_text_format:TextFormat = new TextFormat(magic_font.fontName, 12, 0xffffff, true);
            
            var txt:TextField = createTextField("ИГРОК", title_text_format);
            txt.x = margin_left;
            txt.width = AVATAR_WIDTH / 2 + TOP_USER_NAME_COL_WIDTH + DEFAULT_MARGIN;
            row_header.addChild(txt);
            margin_left += txt.width + DEFAULT_MARGIN;
            
            var num_text_format:TextFormat = new TextFormat(magic_font.fontName, 12, 0xffffff, true);
            num_text_format.align = "right";
            
            txt = createTextField("ОПЫТ", num_text_format);
            //txt.scaleX = txt.scaleY = 0.8;
            txt.x = margin_left;
            txt.width = TOP_EXP_COL_WIDTH;
            row_header.addChild(txt);
            margin_left += txt.width + DEFAULT_MARGIN;
            
            txt = txt = createTextField("ЗОЛОТО", num_text_format);
            //txt.scaleX = txt.scaleY = 0.8;
            txt.textColor = 0xFEB401;
            txt.x = margin_left;
            txt.width = TOP_MONEY_COL_WIDTH;
            row_header.addChild(txt);
            margin_left += txt.width + DEFAULT_MARGIN;
            
            var gr:Graphics = row_header.graphics;
            gr.lineStyle(0.3, 0, 0.3);
            gr.moveTo( DEFAULT_MARGIN, row_header.height );
            gr.lineTo( menu_title.width - DEFAULT_MARGIN, row_header.height );
            
            topusers_display.addChild(row_header);
            
            margin_top += row_header.height + DEFAULT_MARGIN;
            
            var users_count:int = 1;
            for each ( var userXML:XML in topusers_xml.* ) {
                var user_rank:int = int(userXML.@rank);
                var user_id:int = int(userXML.@id);
                var row:Sprite = createRow(user_rank, userXML.@name, user_id, int(userXML.@exp), int(userXML.@money));
                
                if ( user_rank < 5 ) {
                    if ( user_id == user.uid ) {
                        //drawBlackRecktangleInSprite(row);
                        var g:Graphics = row.graphics;
                        g.beginFill(0xffffff, 0.3);
                        g.drawRect(-DEFAULT_MARGIN, 0, row.width + 2*DEFAULT_MARGIN, row.height);
                    }
                }
                else if ( user_rank > 6 ) {
                    margin_top -= 2 * DEFAULT_MARGIN;
                    
                    var tf:TextField = createMagicTextField("...");
                    tf.y = margin_top;
                    tf.width = menu_title.width;
                    topusers_display.addChild(tf);
                    margin_top += tf.height;
                }
                
                row.x = DEFAULT_MARGIN;
                row.y = margin_top;
                topusers_display.addChild(row);
                margin_top += row.height + DEFAULT_MARGIN;
                users_count++;
            }
            
            /*var padding_top:Number = 0;
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
            
            padding_left += DEFAULT_MARGIN + user_money_col.width;*/
            
            drawBlackRecktangleInSprite(topusers_display, 0, DEFAULT_MARGIN);
            
            topusers_display.x = user_display.x + user_display.width +  DEFAULT_MARGIN * 5;
            topusers_display.y = user_display.y;
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