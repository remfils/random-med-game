package src.util {
    import flash.display.DisplayObjectContainer;
    import flash.system.System;
    import flash.text.TextField;

    public class Output {
        private static var outputField:TextField;
        
        public function Output() {
            
        }
        
        public static function init(textField:TextField):void {
            outputField = textField;
        }
        
        public static function add(msg:String):void {
            /*var parent:DisplayObjectContainer = outputField.parent;
            parent.addChild(outputField);*/
            outputField.appendText(msg + '\n');
            trace(msg);
        }
        
        public static function copyLog():void {
            System.setClipboard(outputField.text);
        }
    }

}