package src.util {
    import flash.text.TextField;

    public class Output {
        private static var outputField:TextField;
        
        public function Output() {
            
        }
        
        public static function init(textField:TextField):void {
            outputField = textField;
        }
        
        public static function add(msg:String):void {
            outputField.appendText(msg + '\n');
            trace(msg);
        }
    }

}