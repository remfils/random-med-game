package src.ui.playerStat {
    
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import src.objects.AbstractObject;
    import src.Player;
    import src.ui.AbstractMenu;
    import src.ui.playerStat.StatPoint;
    import src.bullets.*;
    import flash.utils.*;
    
    public class PlayerStat extends AbstractMenu {
        static public var instance:PlayerStat = null;
        public var current_theme = 1;
        var level_map:Map;
        
        private var healthBar:Bar;
        private var manaBar:Bar;
        
        private const HEARTS_START_X:Number = 90;
        private const HEARTS_START_Y:Number = 29;
        
        var hearts:Array = new Array();
        
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
            spellPic_mc = getChildByName("spellPic_mc") as MovieClip;
            spellFire_mc = getChildByName("spellFire_mc") as MovieClip;
            spellLeft_mc = getChildByName("spellLeft_mc") as MovieClip;
            spellRight_mc = getChildByName("spellRight_mc") as MovieClip;
            
            level_txt = getChildByName("level_txt") as TextField;
            money_txt = getChildByName("money_txt") as TextField;
            exp_txt = getChildByName("exp_txt") as TextField;
        }
        
        public function setCurrentSpell(spellName:String):void {
            spellPic_mc.gotoAndStop(spellName);
        }
        
        public static function getInstance():PlayerStat {
            if ( instance === null ) instance = new PlayerStat();
            return instance;
        }
        
        public function flashButton(btnName:String):void {
            switch (btnName) {
                case "fire":
                    spellFire_mc.play();
                break;
                case "spellLeft":
                    spellLeft_mc.play();
                break;
                case "spellRight":
                    spellRight_mc.play();
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
