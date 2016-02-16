package src.ui.playerStat {
    
    import fl.motion.easing.Bounce;
    import fl.motion.easing.Elastic;
    import fl.transitions.Tween;
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.media.SoundMixer;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import src.costumes.ItemLogoCostume;
    import src.costumes.PlayerCostume;
    import src.costumes.PlayerStatCostume;
    import src.objects.AbstractObject;
    import src.Player;
    import src.ui.AbstractMenu;
    import src.ui.playerStat.StatPoint;
    import src.bullets.*;
    import flash.utils.*;
    import src.util.ObjectPool;
    import src.util.SoundManager;
    
    public class PlayerStat extends AbstractMenu {
        public static const FIRE_BTN_ID:int = 1;
        public static const SPELL_LEFT_BTN_ID:int = 2;
        public static const SPELL_RIGHT_BTN_ID:int = 3;
        public static const HEALTH_BAR_ID:int = 4;
        public static const MANA_BAR_ID:int = 5;
        
        public static const BTN_FLASH_STATE:String = "_flash";
        
        static public var instance:PlayerStat = null; // delete this
        public var current_theme = 1;
        var level_map:Map;
        
        private var healthBar:StatDescriteBar;
        private var manaBar:StatDescriteBar;
        
        private static const BUTTON_MARGIN:int = 5;
        
        private static const HEARTS_START_X:Number = 90;
        private static const HEARTS_START_Y:Number = 29;
        private static const SPELL_MENU_CENTER_X:Number = 445.7;
        private static const SPELL_MENU_CENTER_Y:Number = 48.8;
        
        var hearts:Array = new Array();
        
        private var spell_logo:ItemLogoCostume;
        private var spell_place, spell_change_left, spell_change_right, help_button, sound_toggle_btn, music_toggle_btn, volume_up_btn, volume_down_btn :PlayerStatCostume;
        
        public var spellPic_mc, spellFire_mc, spellLeft_mc, spellRight_mc :MovieClip;
        public var level_txt, money_txt, exp_txt: TextField;
        
        public function PlayerStat() {
            super();
            level_map = new Map();
            level_map.x = 519;
            level_map.y = 13;
            level_map._player = game.player;
            addChild (level_map);
            
            healthBar = new StatDescriteBar(game.player, PlayerStatCostume.HEART_TYPE, "HEALTH");
            healthBar.x = 90;
            healthBar.y = 29;
            addChild(healthBar);
            
            manaBar = new StatDescriteBar(game.player, PlayerStatCostume.MANA_TYPE, "MANA");
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
            
            help_button = new PlayerStatCostume();
            help_button.setType(PlayerStatCostume.HELP_BUTTON_TYPE);
            help_button.setState();
            help_button.buttonMode = true;
            help_button.mouseEnabled = true;
            help_button.x = this.width;
            addChild(help_button);
            
            help_button.addEventListener(MouseEvent.CLICK, toggleCheatSheet);
            
            // up button
            
            volume_up_btn = new PlayerStatCostume();
            volume_up_btn.setType(PlayerStatCostume.ARROW_BUTTON_TYPE);
            volume_up_btn.setState();
            
            volume_up_btn.x = this.width;
            volume_up_btn.y = help_button.height + help_button.getChildAt(0).y;
            
            volume_up_btn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent){
                var volume:Number = SoundManager.instance.changeVolume(1);
                
                if ( volume > 0 ) {
                    sound_toggle_btn.setType(PlayerStatCostume.SOUND_ON_BUTTON_TYPE);
                    sound_toggle_btn.setState();
                }
            });
            
            addChild(volume_up_btn);
            
            // down button
            
            volume_down_btn = new PlayerStatCostume();
            volume_down_btn.setType(PlayerStatCostume.ARROW_BUTTON_TYPE);
            volume_down_btn.setState();
            volume_down_btn.getChildAt(0).rotation = 180;
            
            volume_down_btn.x = this.width;
            volume_down_btn.y = help_button.height + help_button.getChildAt(0).y;
            
            volume_down_btn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent){
                var volume:Number = SoundManager.instance.changeVolume(-1);
                
                if ( volume == 0 ) {
                    sound_toggle_btn.setType(PlayerStatCostume.SOUND_OFF_BUTTON_TYPE);
                    sound_toggle_btn.setState();
                }
            });
            
            addChild(volume_down_btn);
            
            // sfx toggle
            
            sound_toggle_btn = new PlayerStatCostume();
            sound_toggle_btn.setType(PlayerStatCostume.SOUND_ON_BUTTON_TYPE);
            sound_toggle_btn.setState();
            
            sound_toggle_btn.x = volume_up_btn.x - sound_toggle_btn.width - BUTTON_MARGIN;
            sound_toggle_btn.y = volume_up_btn.y;
            
            sound_toggle_btn.addEventListener(MouseEvent.CLICK, toggleSoundListener);
            
            addChild(sound_toggle_btn);
            
            // bgx toggle
            
            music_toggle_btn = new PlayerStatCostume();
            music_toggle_btn.x = sound_toggle_btn.x - sound_toggle_btn.width - BUTTON_MARGIN;
            music_toggle_btn.y = sound_toggle_btn.y;
            
            music_toggle_btn.setType(PlayerStatCostume.MUSIC_ON_BUTTON_TYPE);
            music_toggle_btn.setState();
            music_toggle_btn.addEventListener(MouseEvent.CLICK, toggleMusicListener);
            
            addChild(music_toggle_btn);
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
            
            spell_logo = new ItemLogoCostume();
            spell_logo.setType(ItemLogoCostume.SPELL_SPARK);
            spell_logo.x = SPELL_MENU_CENTER_X - spell_logo.width / 2;
            spell_logo.y = SPELL_MENU_CENTER_Y - spell_logo.height / 2;
            addChild(spell_logo);
        }
        
        private function toggleCheatSheet(e:MouseEvent):void {
            game.toggleControlCheatSheet();
            
            game.setAsFocus();
        }
        
        private function toggleSoundListener(e:MouseEvent):void {
            if ( SoundManager.instance.toggleSFXChannel() ) {
                sound_toggle_btn.setType(PlayerStatCostume.SOUND_OFF_BUTTON_TYPE);
            }
            else {
                sound_toggle_btn.setType(PlayerStatCostume.SOUND_ON_BUTTON_TYPE);
            }
            
            sound_toggle_btn.setState();
            
            game.setAsFocus();
        }
        
        private function toggleMusicListener(e:MouseEvent):void {
            if ( SoundManager.instance.toggleBGMChannel() ) {
                music_toggle_btn.setType(PlayerStatCostume.MUSIC_OFF_BUTTON_TYPE);
            }
            else {
                music_toggle_btn.setType(PlayerStatCostume.MUSIC_ON_BUTTON_TYPE);
            }
            
            music_toggle_btn.setState();
            
            game.setAsFocus();
        }
        
        public function setSpellLogo(spellType_:String):void {
            spell_logo.setType(spellType_);
        }
        
        public function setCurrentSpell(spellName:String):void {
            return;
            spellPic_mc.gotoAndStop(spellName);
        }
        
        public static function getInstance():PlayerStat {
            if ( instance === null ) instance = new PlayerStat();
            return instance;
        }
        
        public function flashElementByID(elemID:int):void {
            switch (elemID) {
                case FIRE_BTN_ID:
                    spell_place.setState(BTN_FLASH_STATE);
                break;
                case SPELL_LEFT_BTN_ID:
                    spell_change_left.setState(BTN_FLASH_STATE);
                break;
                case SPELL_RIGHT_BTN_ID:
                    spell_change_right.setState(BTN_FLASH_STATE);
                break;
                case HEALTH_BAR_ID:
                    healthBar.updatePoints();
                    var tween:Tween = ObjectPool.getTween(healthBar,"alpha", Elastic.easeOut, 0, 1, 40);
                break;
                case MANA_BAR_ID:
                    manaBar.updatePoints();
                    var tween:Tween = ObjectPool.getTween(manaBar,"alpha", Elastic.easeOut, 0, 1, 40);
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
