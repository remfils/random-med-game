package src.util {
    import flash.text.TextField;
	/**
     * ...
     * @author vlad
     */
    public class ErrorOuput {
        private static var outputField:TextField;
        
        public function ErrorOuput() {
            
        }
        
        public static function init(textField:TextField):void {
            outputField = textField;
        }
        
        public static function add(msg:String):void {
            outputField.appendText(msg + '\n');
        }
    }

}