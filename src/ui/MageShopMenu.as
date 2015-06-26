package src.ui {
    import flash.automation.StageCaptureEvent;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import src.costumes.ItemLogoCostume;
    import src.costumes.MenuButtonCostume;
    import src.costumes.MenuItemCostume;
    import src.costumes.MenuSprites;
    import src.Player;
    import src.ui.mageShop.MageShopContainer;
    import src.ui.mageShop.InventoryItem;
    import src.User;

    public class MageShopMenu extends AbstractMenu {
        
        private var menu:MovieClip;
        private var itemContainer:Sprite;
        
        private var dragTarget:MovieClip;
        private var placeHolders:Vector.<MenuItemCostume>;
        private var menuItems:Vector.<MenuItemCostume>;
        
        public function MageShopMenu() {
            super();
            
            menu = new MenuSprites();
            MenuSprites(menu).setSprite(MenuSprites.MAGE_SHOP);
            menu.x = 55;
            menu.y = 197.9;
            
            addChild(menu);
            
            var titleBtn:MenuButtonCostume = new MenuButtonCostume();
            titleBtn.setState(MenuButtonCostume.GOTO_TITLE_BTN);
            titleBtn.name = GOTO_TITLE_BTN;
            titleBtn.x = GOTO_TITLE_BTN_POSITION.x;
            titleBtn.y = GOTO_TITLE_BTN_POSITION.y;
            addChild(titleBtn);
            
            placeHolders = new <MenuItemCostume>[];
            menuItems = new <MenuItemCostume>[];
            
        }
        
        override public function readData(data:Object):void {
            super.readData(data);
            
            addPlaceholders(data.user.playerData);
            
            addItems();
        }
        
        private function addPlaceholders(playerData:Object):void {
            var maxSpells:int = playerData.MAX_SPELLS,
                maxItems:int = playerData.MAX_ITEMS,
                i:int,
                scale_factor:Number=206/317,
                locked:Boolean = false,
                inputMI:MenuItemCostume;
            
            inputMI = new MenuItemCostume();
            inputMI.x = 431;
            inputMI.y = 205;
            inputMI.setType(MenuItemCostume.SPELL_TYPE);
            placeHolders[placeHolders.length] = inputMI;
            
            inputMI = new MenuItemCostume();
            inputMI.x = 425.5;
            inputMI.y = 122.5;
            inputMI.setType(MenuItemCostume.SPELL_TYPE);
            placeHolders[placeHolders.length] = inputMI;
            
            inputMI = new MenuItemCostume();
            inputMI.x = 424;
            inputMI.y = 50;
            inputMI.setType(MenuItemCostume.SPELL_TYPE);
            placeHolders[placeHolders.length] = inputMI;
            
            inputMI = new MenuItemCostume();
            inputMI.x = 503.5;
            inputMI.y = 154;
            inputMI.setType(MenuItemCostume.ITEM_TYPE);
            placeHolders[placeHolders.length] = inputMI;
            
            inputMI = new MenuItemCostume();
            inputMI.x = 494;
            inputMI.y = 28;
            inputMI.setType(MenuItemCostume.ITEM_TYPE);
            placeHolders[placeHolders.length] = inputMI;
            
            i = placeHolders.length;
            while ( i-- ) {
                inputMI = placeHolders[i];
                locked = inputMI.isSpell ? maxSpells--<=0 : maxItems--<=0;
                
                if ( locked ) inputMI.setState(MenuItemCostume.SHORT_LOCKED_STATE);
                else inputMI.setState(MenuItemCostume.SHORT_STATE);
                
                inputMI.scaleX = inputMI.scaleY = scale_factor;
                menu.addChild(inputMI);
            }
        }
        
        private function addItems():void {
            var items: Array = user.inventory,
                item:InventoryItem,
                mi, inputMenuItem:MenuItemCostume,
                itemCount:int = items.length,
                placeHoldersCount = placeHolders.length,
                i:int, j:int, k:int,
                spr:Sprite;
            
            itemContainer = new Sprite();
            
            for (i = 0; i < itemCount; i++ ) {
                item = items[i];
                
                mi = new MenuItemCostume();
                mi.y = i * mi.height;
                
                mi.setLogo(item.item_name);
                mi.setName(item.rus_name);
                mi.setDescription(item.dsc);
                
                menuItems[menuItems.length] = mi;
                itemContainer.addChild(mi);
                
                if ( item.isSpell ) mi.setType(MenuItemCostume.SPELL_TYPE);
                else mi.setType(MenuItemCostume.ITEM_TYPE);
                
                mi.setState(MenuItemCostume.LONG_STATE);
                
                mi.activate();
                
                if ( item.onPlayer ) {
                    mi.deactivate();
                    
                    // search available placeholder
                    for ( j = 0; j < placeHoldersCount; j++ ) {
                        inputMenuItem = placeHolders[j];
                        if ( inputMenuItem.isInput && !inputMenuItem.logo && mi.isSpell == inputMenuItem.isSpell ) {
                            inputMenuItem.addLogo(mi.logo_copy);
                            break;
                        }
                    }
                }
            }
            
            itemContainer.x = 35.5;
            itemContainer.y = 21.1;
            menu.addChild(itemContainer);
        }
        
        override public function activate():void {
            super.activate();
            
            addEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
            addEventListener(MouseEvent.MOUSE_UP, mouseUpListener);
            addEventListener(MouseEvent.MOUSE_OVER, mouseOverListener);
            addEventListener(MouseEvent.MOUSE_OUT, mouseOutListener);
        }
        
        private function mouseDownListener(e:MouseEvent):void {
            var name:String = DisplayObject(e.target).name;
            var menuItem:MenuItemCostume;
            
            if ( name == MenuItemCostume.NAME ) {
                menuItem = MenuItemCostume(e.target);
                
                if ( menuItem.isInput ) {
                    if ( menuItem.logo ) {
                        dragTarget = menuItem.logo;
                        menuItem.logo = null;
                    }
                    else return;
                }
                else {
                    dragTarget = menuItem.logo_copy;
                    menuItem.deactivate();
                }
                
                dragTarget.x = mouseX;
                dragTarget.y = mouseY;
                addChild(dragTarget);
                dragTarget.startDrag();
            }
        }
        
        private function mouseUpListener(e:MouseEvent):void {
            var i:int = placeHolders.length,
                itemHolder:MenuItemCostume;
            
            if ( dragTarget ) {
                dragTarget.stopDrag();
                
                // check if over placeholder
                while (i--) {
                    itemHolder = MenuItemCostume(placeHolders[i]);
                    if ( itemHolder.hitTestPoint(mouseX, mouseY) ) {
                        trace(i);
                        if ( itemHolder.logo ) {
                            itemHolder.logo_copy = ItemLogoCostume(dragTarget);
                            dragTarget = itemHolder.logo;
                            itemHolder.addLogo(itemHolder.logo_copy);
                            itemHolder.logo_copy = null;
                            addChild(dragTarget);
                            break;
                        }
                        else {
                            itemHolder.addLogo(ItemLogoCostume(dragTarget));
                            dragTarget = null;
                            return;
                        }
                    }
                }
                
                // return dragTarget
                i = menuItems.length;
                while (i--) {
                    itemHolder = menuItems[i];
                    if ( itemHolder.logo_copy == dragTarget ) {
                        removeChild(dragTarget);
                        dragTarget = null;
                        itemHolder.activate();
                    }
                }
            }
        }
        
        private function mouseOverListener(e:MouseEvent):void {
            
        }
        
        private function mouseOutListener(e:MouseEvent):void {
            
        }
        
        override public function deactivate():void {
            super.deactivate();
            
            removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownListener);
            removeEventListener(MouseEvent.MOUSE_UP, mouseUpListener);
            removeEventListener(MouseEvent.MOUSE_OVER, mouseOverListener);
            removeEventListener(MouseEvent.MOUSE_OUT, mouseOutListener);
        }
        
        override protected function clickListener(e:MouseEvent):void {
            super.clickListener(e);
            var i:int, menuItem:MenuItemCostume;
            
            var name:String = DisplayObject(e.target).parent.name;
            switch ( name ) {
                case GOTO_TITLE_BTN:
                    i = placeHolders.length;
                    while ( i-- ) {
                        menuItem = placeHolders[i];
                        if ( menuItem.isSpell ) {
                            if ( menuItem.logo ) {
                                parentMenu.switchToMenu(parentMenu.TITLE_MENU);
                                return;
                            }
                        }
                    }
                    
                    trace("nope");
                    break;
            }
        }
        
        override public function destroy():void {
            super.destroy();
            
            var i:int;
            
            i = placeHolders.length;
            while (i--)
                placeHolders.pop();
            
            var child:DisplayObject;
            while (numChildren) {
                child = getChildAt(numChildren - 1);
                if ( child is MenuButtonCostume ) MenuButtonCostume(child).destroy();
                removeChild(child);
            }
            
            menu = null;
            dragTarget = null;
        }
    }

}