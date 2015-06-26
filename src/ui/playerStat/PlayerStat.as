package src.ui.playerStat {
    
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import src.costumes.ItemLogoCostume;
    import src.costumes.PlayerStatCostume;
    import src.objects.AbstractObject;
    import src.Player;
    import src.ui.AbstractMenu;
    import src.ui.playerStat.StatPoint;
    import src.bullets.*;
    import flash.utils.*;
    
    public class PlayerStat extends AbstractMenu {
        public static const FIRE_BTN_ID:int = 1;
        public static const SPELL_LEFT_BTN_ID:int = 2;
        public static const SPELL_RIGHT_BTN_ID:int = 3;
        
        public static const BTN_FLASH_STATE:String = "_flash";
        
        static public var instance:PlayerStat = null; // delete this
        public var current_theme = 1;
        var level_map:Map;
        
        private var healthBar:Bar;
        private var manaBar:Bar;
        
        private static const HEARTS_START_X:Number = 90;
        private static const HEARTS_START_Y:Number = 29;
        private static const SPELL_MENU_CENTER_X:Number = 445.7;
        private static const SPELL_MENU_CENTER_Y:Number = 48.8;
        
        var hearts:Array = new Array();
        
        private var spell_logo:ItemLogoCostume;
        private var spell_place, spell_change_left, spell_change_right :PlayerStatCostume;
        
        public var spellPic_mc, spellFire_mc, spellLeft_mc, spellRight_mc :MovieClip;
        public var level_txt, money_txt, exp_txt: TextField;
        
        public function PlayerStat() {
            super();
            level_map = new Map();
            level_map.x = 519;
            level_map.y = 13;
            level_map._player = game.player;
            addChild (level_map);
            
            healthBar = new Bar(StatHeart as Class, "HEALTH");
            healthBar.x = 90;
            healthBar.y = 29;
            addChild(healthBar);
            
            manaBar = new Bar(StatMana as Class, "MANA");
            manaBar.x = 90;
            manaBar.y = 67;
            manaBar.pointsLeftPadding = 7;
            manaBar.redraw();
            addChild(manaBar);
            
            // setting variables
            //spellPic_mc = getChildByName("spellPic_mc") as MovieClip;
            //spellFire_mc = getChildByName("spellFire_mc") as MovieClip;
            //spellLeft_mc = getChildByName("spellLeft_mc") as MovieClip;
            //spellRight_mc = getChildByName("spellRight_mc") as MovieClip;
            
            level_txt = getChildByName("level_txt") as TextField;
            money_txt = getChildByName("money_txt") as TextField;
            exp_txt = getChildByName("exp_txt") as TextField;
            
            createSpellMenu();
        }
        
        private function createSpellMenu():void {
            spell_place = new PlayerStatCostume();
            spell_place.setType(PlayerStatCostume.SPELL_PLACE_TYPE);
            spell_place.setState("");
            spell_place.x = SPELL_MENU_CENTER_X;
            spell_place.y = SPELL_MENU_CENTER_Y;
            addChild(spell_place);
            
            spell_change_left = new PlayerStatCostume();
            spell_change_left.setType(PlayerStatCostume.SPELL_CHANGE_TYPE);
            spell_change_left.setState("");
            spell_change_left.x = SPELL_MENU_CENTER_X - spell_place.width/2 -spell_change_left.width/2;
            spell_change_left.y = SPELL_MENU_CENTER_Y;
            addChild(spell_change_left);
            
            spell_change_right = new PlayerStatCostume();
            spell_change_right.setType(PlayerStatCostume.SPELL_CHANGE_TYPE);
            spell_change_right.setState("");
            spell_change_right.scaleX = -1;
            spell_change_right.x = SPELL_MENU_CENTER_X + spell_place.width/2 + spell_change_right.width/2;
            spell_change_right.y = SPELL_MENU_CENTER_Y;
            addChild(spell_change_right);
        }
        
        public function setCurrentSpell(spellName:String):void {
            return;
            spellPic_mc.gotoAndStop(spellName);
        }
        
        public static function getInstance():PlayerStat {
            if ( instance === null ) instance = new PlayerStat();
            return instance;
        }
        
        public function flashButtonByID(btnID:int):void {
            switch (btnID) {
                case FIRE_BTN_ID:
                    spell_place.setState(BTN_FLASH_STATE);
                break;
                case SPELL_LEFT_BTN_ID:
                    spell_change_left.setState(BTN_FLASH_STATE);
                break;
                case SPELL_RIGHT_BTN_ID:
                    spell_change_right.setState(BTN_FLASH_STATE);
                break;
            }
        }
        
        public function swapMenuTheme(keyFrame:int) {
            //gotoAndStop(keyFrame);
        }
        
        public function nextMenuTheme () {
            current_theme ++;
            /*if (current_theme == totalFrames + 1) current_theme = 1;
            gotoAndStop( current_theme );*/
        }
        
        public function getMapMC ():Map {
            return level_map;
        }
        
        public function update():void {
            updateText();
            healthBar.updatePoints();
            manaBar.updatePoints();
        }
        
        private function updateText():void {
            level_txt.text = String(game.player.LEVEL);
            money_txt.text = String(game.player.MONEY);
            exp_txt.text = String(game.player.EXP);
        }
        
        public function registerDamage (dmg:Number) {
            //healthBar.updatePoints(dmg);
        }
        
        public function registerManaLoss (manaLoss:Number):void {
            //manaBar.updatePoints(manaLoss);
        }
    }
    
}
