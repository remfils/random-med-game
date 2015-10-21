package src.ui {
    import fl.motion.easing.Linear;
    import fl.transitions.easing.Strong;
    import fl.transitions.Tween;
    import fl.transitions.TweenEvent;
    import flash.filters.GlowFilter;
    import flash.text.TextField;
    import src.util.ChangePlayerStatObject;
    import src.util.ObjectPool;


    public class StatChangeMessage extends AbstractMenu {
        private var deltas_to_display:Vector.<ChangePlayerStatObject>;
        private var messages:Vector.<String>;
        
        private var text_field:TextField;
        
        public function StatChangeMessage() {
            super();
            
            deltas_to_display = new Vector.<ChangePlayerStatObject>();
            messages = new Vector.<String>();
            
            text_field = new TextField();
            text_field.setTextFormat(defaultTextFormat);
            text_field.textColor = 0xffffff;
            addChild(text_field);
        }
        
        public function init():void {
            x = 0;
            y = -90;
            
            game.player.costume.addChild(this);
        }
        
        public function requestDisplayDelta(change:ChangePlayerStatObject):void {
            if ( !deltas_to_display.length )
                dispayDelta(change);
            
            deltas_to_display.push(change);
        }
        
        public function requestDisplayMessage(str:String):void {
            if ( !deltas_to_display.length ) {
                displayMessage(str);
            }
            
            messages.push(str);
        }
        
        private function displayMessage(str:String): void {
            text_field.text = "";
            text_field.filters = [];
            text_field.text = str;
            
            text_field.x = -text_field.textWidth / 2;
            
            var tween:Tween = ObjectPool.getTween(text_field, "y", Linear.easeInOut, 0, -20, 30);
            tween = ObjectPool.getTween(text_field, "alpha", Strong.easeIn, 1, 0, 30);
            
            tween.addEventListener(TweenEvent.MOTION_FINISH, textIsHiddenListener);
        }
        
        private function dispayDelta(change:ChangePlayerStatObject):void {
            text_field.text = "";
            text_field.filters = [];
            
            if ( change.delta > 0 ) {
                text_field.text += "+";
            }
            
            text_field.text += change.delta;
            
            switch ( change.stat_name ) {
                case ChangePlayerStatObject.HEALTH_STAT:
                    text_field.text += " hp";
                    
                    var outline:GlowFilter = new GlowFilter(0xff0000, 0.4, 20, 2., 3);
                    text_field.filters = [outline];
                    break;
                case ChangePlayerStatObject.EXP_STAT:
                    text_field.text += " exp";
                    
                    var outline:GlowFilter = new GlowFilter(0xffff00, 0.4, 20, 2., 3);
                    text_field.filters = [outline];
                    break;
                case ChangePlayerStatObject.MONEY_STAT:
                    text_field.text += " $";
                    
                    var outline:GlowFilter = new GlowFilter(0x00ff00, 0.4, 20, 2., 3);
                    text_field.filters = [outline];
                    break;
                case ChangePlayerStatObject.MANA_STAT:
                    text_field.text += " mp";
                    
                    var outline:GlowFilter = new GlowFilter(0x0000ff, 0.4, 20, 2., 3);
                    text_field.filters = [outline];
                    break;
                default:
            }
            
            text_field.x = -text_field.textWidth / 2;
            
            var tween:Tween = ObjectPool.getTween(text_field, "y", Linear.easeInOut, 0, -20, 30);
            tween = ObjectPool.getTween(text_field, "alpha", Strong.easeIn, 1, 0, 30);
            
            tween.addEventListener(TweenEvent.MOTION_FINISH, textIsHiddenListener);
        }
        
        private function textIsHiddenListener(e:TweenEvent):void {
            if ( deltas_to_display.length ) {
                deltas_to_display.shift();
            }
            else if ( messages.length ) {
                messages.shift();
            }
            
            if ( deltas_to_display.length ) {
                dispayDelta(deltas_to_display[0]);
            }
            else if ( messages.length ) {
                displayMessage(messages[0]);
            }
        }
    }

}