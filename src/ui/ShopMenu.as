package src.ui {
    import fl.motion.Color;
    import flash.display.ActionScriptVersion;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import src.costumes.GameMenuCostume;
    import src.costumes.ItemLogoCostume;
    import src.costumes.MenuButtonCostume;
    import src.costumes.MenuItemCostume;
    import src.costumes.MenuSprites;
    import src.costumes.PlayerStatCostume;
    import src.Ids;
    import src.ui.mageShop.InventoryItem;
    import src.ui.playerStat.StatDescriteBar;
    import src.util.ChangePlayerStatObject;
    import src.util.MagicBag;


    public class ShopMenu extends AbstractMenu {
        private const SHOP_ITEM_MARGIN:int = 2;
        
        private static const MIN_PANEL_Y_POS:Number = 175.95;
        
        private var user_stat_panel:Sprite;
        private var vending_panel:Sprite;
        private var vending_container:Sprite;
        
        private var player_health_bar:StatDescriteBar;
        private var player_mana_bar:StatDescriteBar;
        private var gold_txt:TextField;
        
        private var _shop_items:Vector.<InventoryItem>;
        private var _shop_item_containers:Vector.<MenuItemCostume>;
        
        public function ShopMenu() {
            super();
            
            _shop_items = new Vector.<InventoryItem>();
            _shop_item_containers = new Vector.<MenuItemCostume>();
            
            user_stat_panel = new Sprite();
            user_stat_panel.x = 495.5;
            user_stat_panel.y = MIN_PANEL_Y_POS;
            addChild(user_stat_panel);
            
            vending_panel = new Sprite();
            vending_panel.x = 93.35;
            vending_panel.y = MIN_PANEL_Y_POS;
            addChild(vending_panel);
            
            var titleBtn:MenuButtonCostume = new MenuButtonCostume();
            titleBtn.setState(MenuButtonCostume.GOTO_TITLE_BTN);
            titleBtn.name = GOTO_TITLE_BTN;
            titleBtn.x = GOTO_TITLE_BTN_POSITION.x;
            titleBtn.y = GOTO_TITLE_BTN_POSITION.y;
            addChild(titleBtn);
        }
        
        override public function readData(data:Object):void {
            super.readData(data);
            
            // SHOP LEFT PART
            
            var itemsXML:XMLList = data.shop;
            var margin_y:Number = 5;
            
            var vending_title_spr:Sprite = new Sprite();
            
            var vending_title_txt:TextField = createMagicTextField("МАГАЗИН");
            vending_title_spr.addChild(vending_title_txt);
            vending_title_txt.x = 102.35;
            
            with (vending_title_spr.graphics) {
                beginFill(0, 0.3);
                drawRect(0, 0, 327.6, 29.1);
                endFill();
            }
            
            vending_panel.addChild(vending_title_spr);
            
            vending_container = new Sprite();
            vending_container.x = 5;
            vending_container.y = 38;
            
            var user_money:Number = user.player.MONEY;
            
            for each ( var itemXML:XML in itemsXML.* ) {
                var item:InventoryItem = new InventoryItem();
                item.setParametersFromXML(itemXML);
                
                _shop_items.push(item);
                
                var item_box:MenuItemCostume = new MenuItemCostume();
                item_box.y = margin_y;
                item_box.name = "" + item.iid;
                _shop_item_containers.push(item_box);
                
                if ( item.isSpell ) {
                    item_box.setType(MenuItemCostume.SPELL_TYPE);
                }
                else {
                    item_box.setType(MenuItemCostume.ITEM_TYPE);
                }
                
                item_box.setState(MenuItemCostume.LONG_STATE);
                item_box.setName(item.rus_name);
                item_box.setDescription(item.dsc);
                item_box.setLogo(item.item_name);
                
                if ( item.price < user_money )
                    item_box.activate();
                else
                    item_box.deactivate();
                
                var buy_btn:MenuButtonCostume = new MenuButtonCostume();
                buy_btn.setType(MenuButtonCostume.BUY_BTN);
                buy_btn.setState();
                
                var coin_gr:MenuSprites = new MenuSprites();
                coin_gr.setSprite(MenuSprites.COIN_GRAPHIC);
                coin_gr.scaleX = coin_gr.scaleY = 0.5;
                
                var price_tag:TextField = createMagicTextField("" + item.price);
                price_tag.x = (buy_btn.width - price_tag.width) / 2;
                price_tag.y = 4;
                price_tag.selectable = false;
                buy_btn.addChild(price_tag);
                
                coin_gr.x = buy_btn.width - coin_gr.width - 5;
                coin_gr.y = price_tag.y + price_tag.height / 2 - coin_gr.height / 2;
                buy_btn.addChild(coin_gr);
                
                price_tag.x = coin_gr.x - price_tag.width;
                
                buy_btn.x = 255.4;
                
                item_box.addChild(buy_btn);
                
                vending_container.addChild(item_box);
                
                margin_y += item_box.height + SHOP_ITEM_MARGIN;
            }
            
            vending_panel.addChild(vending_container);
            
            with (vending_panel.graphics) {
                beginFill(0, 0.3);
                drawRect(0, 0, 327.6, 314.15);
                endFill();
            }
            
            // USER RIGHT PART
            
            margin_y = SHOP_ITEM_MARGIN;
            var margin_x = 17.5;
            
            var user_title_gr:Sprite = new Sprite();
            with (user_title_gr.graphics) {
                beginFill(0, 0.3);
                drawRect(0, 0, 128.15, 29.1);
                endFill();
            }
            
            var user_title_txt:TextField = createMagicTextField("ИГРОК");
            user_title_txt.x = 24.5;
            
            user_title_gr.addChild(user_title_txt);
            user_stat_panel.addChild(user_title_gr);
            
            margin_y += user_title_gr.height;
            
            player_health_bar = new StatDescriteBar(user.player, PlayerStatCostume.HEART_TYPE, "HEALTH");
            player_health_bar.x = margin_x + 23 / 2;
            player_health_bar.y = margin_y + player_health_bar.height / 2;
            user_stat_panel.addChild(player_health_bar);
            
            margin_y += player_health_bar.height + 8;
            
            player_mana_bar = new StatDescriteBar(user.player, PlayerStatCostume.MANA_TYPE, "MANA");
            player_mana_bar.x = margin_x + 23 / 2;
            player_mana_bar.y = margin_y + player_mana_bar.height / 2;
            user_stat_panel.addChild(player_mana_bar);
            
            margin_y += player_mana_bar.height + 8;
            
            var coin_gr:MenuSprites = new MenuSprites();
            coin_gr.setSprite(MenuSprites.COIN_GRAPHIC);
            coin_gr.x = margin_x;
            coin_gr.y = margin_y;
            user_stat_panel.addChild(coin_gr);
            
            gold_txt = createMagicTextField("" + user.player.MONEY);
            gold_txt.textColor = 0xFEB401;
            gold_txt.x = coin_gr.x + coin_gr.width + SHOP_ITEM_MARGIN;
            gold_txt.y = coin_gr.y;
            user_stat_panel.addChild(gold_txt);
            
            drawBlackRecktangleInSprite(user_stat_panel, 0, 8);
        }
        
        private function updateUserStats():void {
            player_health_bar.updatePoints();
            player_mana_bar.updatePoints();
            
            var text_format:TextFormat = gold_txt.getTextFormat();
            gold_txt.text = "" + user.player.MONEY;
            gold_txt.setTextFormat(text_format);
            
            var i:int = _shop_item_containers.length;
            var user_money:int = user.player.MONEY;
            while ( i-- ) {
                if ( _shop_items[i].price > user_money ) {
                    _shop_item_containers[i].deactivate();
                }
            }
        }
        
        override protected function clickListener(e:MouseEvent):void {
            super.clickListener(e);
            
            var name:String = DisplayObject(e.target).parent.name;
            
            switch ( name ) {
                case GOTO_TITLE_BTN:
                    parentMenu.switchToMenu(0);
                    break;
            }
            
            var id:Number = Number(DisplayObject(e.target).name);
            
            if (!isNaN(id)) {
                var i:int = _shop_items.length;
                var item:InventoryItem = null;
                
                while ( i-- ) {
                    if ( id == _shop_items[i].iid ) {
                        item = _shop_items[i];
                        break;
                    }
                }
                
                if ( item == null )
                    return;
                
                if ( user.player.MONEY < item.price )
                    return;
                
                switch ( id ) {
                    case Ids.ITEM_POTION_MANA_ID:
                        if ( user.player.changeStat(MagicBag.SMALL_MP_STAT_OBJ) ) {
                            user.player.changeStat(createPriceObject(item.price, item.iid));
                        }
                        break;
                    case Ids.ITEM_POTION_HEALTH_ID:
                        if ( user.player.changeStat(MagicBag.SMALL_HP_STAT_OBJ) ) {
                            user.player.changeStat(createPriceObject(item.price, item.iid));
                        }
                        break;
                }
                
                updateUserStats();
            }
        }
        
        private function createPriceObject(price:Number, id:Number = 1):ChangePlayerStatObject {
            return new ChangePlayerStatObject(ChangePlayerStatObject.MONEY_STAT, -price, id);
        }
    }

}