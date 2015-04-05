package src.util {
	/**
     * ...
     * @author vlad
     */
    public class ComboManager {
        public static const LEVER_COMBO:int = 1;
        public static const ENEMY_COMBO:int = 2;
        
        private static var comboArray:Array = new Array();
        comboArray[LEVER_COMBO] = 0;
        comboArray[ENEMY_COMBO] = 0;
        
        private static var comboFunctions:Array = new Array();
        comboFunctions[LEVER_COMBO] = leverComboFunction;
        comboFunctions[ENEMY_COMBO] = enemyComboFunction;
        
        public static function addCombo(comboIndex:int):void {
            comboArray[comboIndex] ++;
        }
        
        public static function clearCombo(comboIndex:int):void {
            comboArray[comboIndex] = 0;
        }
        
        public static function getCombo(comboIndex:int):Number {
            return comboFunctions[comboIndex]();
        }
        
        private static function leverComboFunction():Number {
            var combo:Number = 1,
                comboI:int = comboArray[LEVER_COMBO];
                
            if ( comboI == 0 ) return combo;
            
            if ( comboI > 4 ) return 20;
            
            return comboI*comboI / 2 + comboI / 2;
        }
        
        private static function enemyComboFunction():Number {
            return comboArray[ENEMY_COMBO];
        }
        
    }

}