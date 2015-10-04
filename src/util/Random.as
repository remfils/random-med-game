package src.util {
    import flash.utils.getTimer;
    import flash.utils.Timer;
    import src.Game;

    public class Random {
        
        public static function getOneFromThree():Number {
            if ( Game.TEST_MODE ) return 1;
            return getOneFrom(3);
        }
        
        public static function getOneFrom(N:Number):Number {
            var d:Date = new Date();
            var random:Number = Math.random() * 400;
            var t_ms:Number = d.milliseconds,
                r:Number = t_ms * random % N + 1;
                
            return r;
        }
    }

}