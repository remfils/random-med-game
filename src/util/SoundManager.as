package src.util {
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer;


    public class SoundManager {
        public static const SFX_ACTIVATE_GHOST:int = 1;
        public static const SFX_ATTACK_GHOST:int = 2;
        public static const SFX_BREAK_KEY:int = 3;
        public static const SFX_BREAK_LEVER:int = 4;
        public static const SFX_CAST_SPARK:int = 5;
        public static const SFX_DESTROY_BARREL:int = 6;
        public static const SFX_DESTROY_CRATE:int = 7;
        public static const SFX_DESTROY_ROCKS1:int = 8;
        public static const SFX_DESTROY_WALL:int = 9;
        public static const SFX_EXPLOSION:int = 10;
        public static const SFX_GUI_MENU_WHOOSH:int = 11;
        public static const SFX_GUI_PICKUP_SPELL:int = 12;
        public static const SFX_GUI_PUTDOWN_SPELL:int = 13;
        public static const SFX_HIT_ENEMY_BULLET:int = 14;
        public static const SFX_HIT_SPARK:int = 15;
        public static const SFX_HIT_SPELL_UNKNOWN:int = 16;
        public static const SFX_KNOCK:int = 17;
        public static const SFX_OPEN_DOOR:int = 18;
        public static const SFX_OPEN_LEVER:int = 19;
        public static const SFX_OPEN_LOCK1:int = 20;
        public static const SFX_OPEN_SECRET_ROOM:int = 21;
        public static const SFX_PICKUP_COIN:int = 22;
        public static const SFX_PICKUP_POTION:int = 23;
        public static const SFX_SHOOT_MONK:int = 24;
        public static const SFX_SHOW_NOTE:int = 25;
        public static const SFX_SMOKE:int = 26;
        
        [AS3][Embed(source = "assets/activate_ghost.mp3")]
        private const Activate_Ghost:Class;
        [AS3][Embed(source = "assets/attack_ghost.mp3")]
        private const Attack_Ghost:Class;
        [AS3][Embed(source = "assets/break_key.mp3")]
        private const Break_Key:Class;
        [AS3][Embed(source = "assets/break_lever.mp3")]
        private const Break_Lever:Class;
        [AS3][Embed(source = "assets/cast_spark.mp3")]
        private const Cast_Spark:Class;
        [AS3][Embed(source = "assets/destroy_barrel.mp3")]
        private const Destroy_Barrel:Class;
        [AS3][Embed(source = "assets/destroy_crate.mp3")]
        private const Destroy_Crate:Class;
        [AS3][Embed(source = "assets/destroy_rocks1.mp3")]
        private const Destroy_Rocks1:Class;
        [AS3][Embed(source = "assets/destroy_wall.mp3")]
        private const Destroy_Wall:Class;
        [AS3][Embed(source = "assets/explosion.mp3")]
        private const Explosion:Class;
        [AS3][Embed(source = "assets/gui_menu-whoosh.mp3")]
        private const Gui_MenuWhoosh:Class;
        [AS3][Embed(source = "assets/gui_pickup-spell.mp3")]
        private const Gui_PickupSpell:Class;
        [AS3][Embed(source = "assets/gui_putdown-spell.mp3")]
        private const Gui_PutdownSpell:Class;
        [AS3][Embed(source = "assets/hit_enemy-bullet.mp3")]
        private const Hit_EnemyBullet:Class;
        [AS3][Embed(source = "assets/hit_spark.mp3")]
        private const Hit_Spark:Class;
        [AS3][Embed(source = "assets/hit_spell_unknown.mp3")]
        private const Hit_Spell_Unknown:Class;
        [AS3][Embed(source = "assets/knock.mp3")]
        private const Knock:Class;
        [AS3][Embed(source = "assets/open_door.mp3")]
        private const Open_Door:Class;
        [AS3][Embed(source = "assets/open_lever.mp3")]
        private const Open_Lever:Class;
        [AS3][Embed(source = "assets/open_lock1.mp3")]
        private const Open_Lock1:Class;
        [AS3][Embed(source = "assets/open_secret-room.mp3")]
        private const Open_SecretRoom:Class;
        [AS3][Embed(source = "assets/pickup_coin.mp3")]
        private const Pickup_Coin:Class;
        [AS3][Embed(source = "assets/pickup_potion.mp3")]
        private const Pickup_Potion:Class;
        [AS3][Embed(source = "assets/shoot_monk.mp3")]
        private const Shoot_Monk:Class;
        [AS3][Embed(source = "assets/show_note.mp3")]
        private const Show_Note:Class;
        [AS3][Embed(source = "assets/smoke.mp3")]
        private const Smoke:Class;
        
        private static const MAX_TRACKS:int = 30;
        private var _tracks:Vector.<Sound> = new Vector.<Sound>(MAX_TRACKS, true);
        
        private var _channelSFX:SoundChannel = new SoundChannel();
        private var _channelBGM:SoundChannel = new SoundChannel();
        
        private static var _instance:SoundManager;
        
        
        public function SoundManager() {
            
        }
        
        public static function get instance():SoundManager {
            if ( !_instance ) {
                _instance = new SoundManager();
                _instance.init();
            }
            return _instance;
        }
        
        public function init():void {
            addResource(new Activate_Ghost(), SoundManager.SFX_ACTIVATE_GHOST);
            addResource(new Attack_Ghost(), SoundManager.SFX_ATTACK_GHOST);
            addResource(new Break_Key(), SoundManager.SFX_BREAK_KEY);
            addResource(new Break_Lever(), SoundManager.SFX_BREAK_LEVER);
            addResource(new Cast_Spark(), SoundManager.SFX_CAST_SPARK);
            addResource(new Destroy_Barrel(), SoundManager.SFX_DESTROY_BARREL);
            addResource(new Destroy_Crate(), SoundManager.SFX_DESTROY_CRATE);
            addResource(new Destroy_Rocks1(), SoundManager.SFX_DESTROY_ROCKS1);
            addResource(new Destroy_Wall(), SoundManager.SFX_DESTROY_WALL);
            addResource(new Explosion(), SoundManager.SFX_EXPLOSION);
            addResource(new Gui_MenuWhoosh(), SoundManager.SFX_GUI_MENU_WHOOSH);
            addResource(new Gui_PickupSpell(), SoundManager.SFX_GUI_PICKUP_SPELL);
            addResource(new Gui_PutdownSpell(), SoundManager.SFX_GUI_PUTDOWN_SPELL);
            addResource(new Hit_EnemyBullet(), SoundManager.SFX_HIT_ENEMY_BULLET);
            addResource(new Hit_Spark(), SoundManager.SFX_HIT_SPARK);
            addResource(new Hit_Spell_Unknown(), SoundManager.SFX_HIT_SPELL_UNKNOWN);
            addResource(new Knock(), SoundManager.SFX_KNOCK);
            addResource(new Open_Door(), SoundManager.SFX_OPEN_DOOR);
            addResource(new Open_Lever(), SoundManager.SFX_OPEN_LEVER);
            addResource(new Open_Lock1(), SoundManager.SFX_OPEN_LOCK1);
            addResource(new Open_SecretRoom(), SoundManager.SFX_OPEN_SECRET_ROOM);
            addResource(new Pickup_Coin(), SoundManager.SFX_PICKUP_COIN);
            addResource(new Pickup_Potion(), SoundManager.SFX_PICKUP_POTION);
            addResource(new Shoot_Monk(), SoundManager.SFX_SHOOT_MONK);
            addResource(new Show_Note(), SoundManager.SFX_SHOW_NOTE);
            addResource(new Smoke(), SoundManager.SFX_SMOKE);
        }
        
        public function addResource(sound:Sound, id:int):void {
            if ( id < MAX_TRACKS ) {
                _tracks[id] = sound;
            }
            else {
                throw new Error("addResource(): sound index out of range sid=" + id);
            }
        }
        
        public function playSFX(id:int):void {
            if ( id == 0 ) return;
            
            var sound:Sound = _tracks[id];
            if ( sound ) {
                _channelSFX = sound.play();
            }
            else {
                throw new Error("playSFX(): sound is null with sid=" + id);
            }
        }
        
        public function playBGM(music_id:int):void {
            var sound:Sound = _tracks[music_id];
            if ( sound ) {
                _channelBGM = sound.play();
            }
            else {
                throw new Error("playBGM(): music is null with sid=" + music_id);
            }
        }
    }

}