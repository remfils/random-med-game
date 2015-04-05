package src.ui {
    import flash.automation.StageCaptureEvent;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import src.Player;
    import src.ui.mageShop.MageShopContainer;
    import src.ui.mageShop.InventoryItem;
    import src.User;
	/**
     * ...
     * @author vlad
     */
    public class MageShopMenu extends AbstractMenu {
        private var menu:MovieClip;
        
        private var tip:GameTip;
        
        private var dragTarget:InventoryItem;
        private var placeholderProperties:Array;
        private var placeHolders:Array;
        
        public function MageShopMenu() {
            super();
            
            menu = new MagesShop();
            menu.x = 55;
            menu.y = 197.9;
            
            addChild(menu);
            
            var titleBtn:Sprite = getGotoMenuButton();
            addChild(titleBtn);
            
            placeHolders = [];
            
            placeholderProperties = [];
            placeholderProperties.push( { "x":431, "y":205,"isSpell":true } );
            placeholderProperties.push( { "x":425.5, "y":122.5,"isSpell":true } );
            placeholderProperties.push( { "x":424, "y":50,"isSpell":true } );
            placeholderProperties.push( { "x":503.5, "y":154,"isSpell":false } );
            placeholderProperties.push( { "x":494, "y":28, "isSpell":false } );
            
            tip = new GameTip();
            tip.hide();
        }
        
        override public function readData(data:Object):void {
            super.readData(data);
            
            addPlaceholders(data.user.player as Player);
            
            addItems(data.user as User);
        }
        
        private function addPlaceholders(player:Player):void {
            var maxSpells:int = player.MAX_SPELLS,
                maxItems:int = player.MAX_ITEMS,
                i:int,
                item:Object,
                ph:MageShopContainer,
                locked:Boolean = false;
            
            i = placeholderProperties.length;
            while ( i-- ) {
                item = placeholderProperties[i];
                locked = item.isSpell ? !maxSpells-- : !maxItems--;
                
                if ( maxItems < 0 ) maxItems = 0;
                if ( maxSpells < 0 ) maxSpells = 0;
                
                ph = createItemPlaceHolderAt(item.x, item.y, item.isSpell, locked);
                
                ph.scaleX = 56 / ph.width;
                ph.scaleY = 56 / ph.height;
                
                menu.addChild(ph);
                placeHolders.push(ph);
            }
        }
        
        private function createItemPlaceHolderAt(X:int, Y:int, isSpell:Boolean=false, locked:Boolean=false):MageShopContainer {
            var ph:MageShopContainer;
            
            ph = new ItemPlaceHolder();
            ph.x = X;
            ph.y = Y;
            
            ph.mouseEnabled = false;
            
            if ( isSpell ) ph.setAsSpell();
            else ph.setAsItem();
            
            if ( locked ) ph.setLocked();
            
            return ph;
        }
        
        private function addItems(user:User):void {
            var items: Array = user.inventory,
                item:InventoryItem,
                itemContainer:MageShopContainer,
                itemCount:int = items.length,
                i:int, j:int, k:int;
            
            for (i = 0; i < itemCount; i++ ) {
                item = items[i];
                itemContainer = createItemPlaceHolderAt(44.15 + 105.55 * j, 27.95 + 90.85 * k, item.isSpell);
                
                var spr:Sprite = new Sprite();
                spr.graphics.beginFill(0);
                spr.graphics.drawRect(0, 0, itemContainer.width, itemContainer.height);
                spr.x -= spr.width / 2;
                spr.y -= spr.height / 2;
                spr.visible = false;
                spr.mouseEnabled = false;
                item.addChild(spr);
                item.hitArea = spr;
                
                menu.addChild(itemContainer);
                
                item.setInitialPositionInContainer();
                item.buttonMode = true;
                item.parentContainer = itemContainer;
                
                if ( item.onPlayer ) {
                    placeItemOnPlayer(item);
                }
                else {
                    itemContainer.addChild(item);
                }
                
                j++;
                if ( j % 3 == 0 ) {
                    k ++;
                }
                if ( j == 3 ) j = 0;
            }
        }
        
        private function placeItemOnPlayer(mageItem:InventoryItem):void {
            var itemCount:int = placeHolders.length;
            var container:MageShopContainer;
            for ( var i = 0; i < itemCount; i++ ) {
                container = placeHolders[i] as MageShopContainer;
                if ( !container.locked && container.isSpell == mageItem.isSpell && !container.item ) {
                    container.item = mageItem;
                    container.addChild(mageItem);
                    break;
                }
            }
        }
        
        
        override public function activate():void {
            super.activate();
            
            addEventListener(MouseEvent.MOUSE_DOWN, startDragListener);
            addEventListener(MouseEvent.MOUSE_UP, stopDragListener);
            addEventListener(MouseEvent.MOUSE_OVER, mouseOverListener);
            addEventListener(MouseEvent.MOUSE_OUT, mouseOutListener);
        }
        
        private function startDragListener(e:MouseEvent):void {
            if ( e.target is InventoryItem ) {
                dragTarget = e.target as InventoryItem;
                
                dragTarget.x = mouseX;
                dragTarget.y = mouseY;
                
                var i:int = placeHolders.length;
                while ( i-- ) {
                    if ( placeHolders[i].item == dragTarget )
                        placeHolders[i].item = null;
                }
                
                addChild(dragTarget);
                dragTarget.startDrag();
                
                tip.forceHide();
            }
        }
        
        private function stopDragListener(e:MouseEvent):void {
            var i:int,
                container:MageShopContainer,
                addedToPlayer:Boolean = false;
            
            if ( dragTarget ) {
                dragTarget.stopDrag();
                i = placeHolders.length;
                
                while ( i-- ) {
                    container = placeHolders[i];
                    if ( container.hitTestObject(dragTarget) ) {
                        if ( container.locked || container.isSpell != dragTarget.isSpell ) break;
                        
                        if ( container.item ) {
                            container.item.onPlayer = false;
                            container.item.parentContainer.addChild(container.item);
                        }
                        
                        dragTarget.onPlayer = true;
                        container.addChild(dragTarget);
                        container.item = dragTarget;
                        addedToPlayer = true;
                        break;
                    }
                }
                
                if ( !addedToPlayer ) {
                    dragTarget.onPlayer = false;
                    dragTarget.parentContainer.addChild(dragTarget);
                }
                
                dragTarget.setInitialPositionInContainer();
                    
                dragTarget = null;
            }
        }
        
        private function mouseOverListener(e:MouseEvent):void {
            if ( !dragTarget && e.target is InventoryItem ) {
                if ( !tip.active && !tip.isTransition ) {
                    tip.x = mouseX + 10;
                    tip.y = mouseY + 10;
                    tip.setText(e.target.rus_name, e.target.dsc);
                    addChild(tip);
                    tip.show();
                }
            }
        }
        
        private function mouseOutListener(e:MouseEvent):void {
            if ( !dragTarget && e.target is InventoryItem ) {
                if ( tip.active ) {
                    tip.hide();
                }
            }
        }
        
        override public function deactivate():void {
            super.deactivate();
            
            removeEventListener(MouseEvent.MOUSE_DOWN, startDragListener);
            removeEventListener(MouseEvent.MOUSE_UP, stopDragListener);
            removeEventListener(MouseEvent.MOUSE_OVER, mouseOverListener);
            removeEventListener(MouseEvent.MOUSE_OUT, mouseOutListener);
        }
        
        override protected function clickListener(e:MouseEvent):void {
            super.clickListener(e);
            
            var target:Sprite = Sprite(e.target.parent);
            switch (target.name) {
                case "GotoTitle":
                    parentMenu.switchToMenu(parentMenu.TITLE_MENU);
                    break;
            }
        }
        
        override public function destroy():void {
            super.destroy();
            
            var i:int = placeholderProperties.length;
            while (i--)
                placeholderProperties.pop();
            
            i = placeHolders.length;
            while (i--)
                placeHolders.pop();
        }
    }

}