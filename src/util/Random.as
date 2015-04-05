package src.util {
    import flash.utils.getTimer;
    import flash.utils.Timer;

    /**
     * Класс который создается, для генерирования рандомного числа, от 0 до 2
     * так же он засекает время между генерацией и попытками и записывает время в time
     */
    public class Random {
        /**
         * Функция, которая возвращает случайное число от 1 до 3
         * @return число 1, 2 или 3
         */
        public static function getOneFromThree():Number {
            return getOneFrom(3);
        }
        
        public static function getOneFrom(N:Number):Number {
            var d:Date = new Date();

            var t_ms:Number = d.milliseconds,
                r:Number = t_ms % N + 1;
                
            return r;
        }
    }

}