package src.util {
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer;


    public class SoundManager {
        public static const ACTION_PICKUP_COIN:int = 1;
        public static const ACTION_EXPLOSION:int = 2;
        
        private static const MAX_TRACKS:int = 10;
        private var _tracks:Vector.<Sound> = new Vector.<Sound>(MAX_TRACKS, true);
        
        private var _channelSFX:SoundChannel = new SoundChannel();
        private var _channelBGM:SoundChannel = new SoundChannel();
        
        private static var _instance:SoundManager;
        
        public function SoundManager() {
            
        }
        
        public static function get instance():SoundManager {
            if ( !_instance ) {
                _instance = new SoundManager();
            }
            return _instance;
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
            var sound:Sound = _tracks[id];
            if ( sound ) {
                _channelSFX = sound.play();
            }
            else {
                throw new Error("playSFX(): sound is null with sid=" + id);
            }
        }
        
        public function playBGM(music_id:int):void {
            var sound:Sound = _tracks[id];
            if ( sound ) {
                _channelBGM = sound.play();
            }
            else {
                throw new Error("playBGM(): music is null with sid=" + id);
            }
        }
        
    }

}

[AS3][Embed(source = "assets/pickup-coin.wav")]
private const SoundPickupCoin:Class;