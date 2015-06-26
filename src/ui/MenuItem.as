package src.ui {
    import flash.display.MovieClip;
    import flash.text.TextField;


    public class MenuItem extends MovieClip {
        
        public var item_name_txt:TextField;
        public var item_dsc_txt:TextField;
        public var block_curtain_mc:MovieClip;
        
        public static const NAME:String = "menu_item_name";
        
        public static const ITEM_TYPE:String = "item";
        public static const SPELL_TYPE:String = "spell";
        
        public static const LONG_STATE:String = "_long";
        public static const SHORT_STATE:String = "_short";
        public static const SHORT_LOCKED_STATE:String = "_short_locked";
        
        public static const LOGO_X:Number = 27.9;
        public static const LOGO_Y:Number = 17;
        
        public var isSpell:Boolean;
        public var isInput:Boolean;
        
        public var logo_copy:ItemLogo;
        public var logo:ItemLogo;
        
        public function MenuItem() {
            super();
            
            name = NAME;
            
            mouseChildren = false;
            
            item_name_txt = TextField(getChildByName("item_name_txt"));
            item_dsc_txt = TextField(getChildByName("item_dsc_txt"));
            item_dsc_txt.mouseEnabled = false;
            item_name_txt.mouseEnabled = false;
            
            block_curtain_mc = MovieClip(getChildByName("block_curtain_mc"));
            
            logo = new ItemLogo();
            addChildAt(logo, getChildIndex(block_curtain_mc) - 1);
            logo.x = LOGO_X;
            logo.y = LOGO_Y;
            
            logo_copy = new ItemLogo();
        }
        
        public function setType(type:String):void {
            isSpell = type == SPELL_TYPE;
        }
        
        public function setState(state:String):void {
            if (isSpell) gotoAndStop(SPELL_TYPE + state);
            else gotoAndStop(ITEM_TYPE + state);
            
            if ( state == SHORT_STATE ) {
                isInput = true;
                logo = logo_copy = null;
            }
            else isInput = false;
            
            if ( state == SHORT_LOCKED_STATE ) logo = logo_copy = null;
        }
        
        public function setLogo(logoType:String ):void {
            logo.setType(logoType);
            logo_copy.setType(logoType);
        }
        
        public function setName(name:String):void {
            item_name_txt.text = name;
        }
        
        public function setDescription(dsc_text:String):void {
            item_dsc_txt.text = dsc_text;
        }
        
        public function activate():void {
            block_curtain_mc.visible = false;
            mouseEnabled = useHandCursor = buttonMode = true;
        }
        
        public function deactivate():void {
            block_curtain_mc.visible = true;
            mouseEnabled = useHandCursor = buttonMode = false;
        }
        
        public function addLogo(logo_:ItemLogo):void {
            logo = logo_;
            addChild(logo);
            logo.x = LOGO_X;
            logo.y = LOGO_Y;
        }
    }

}