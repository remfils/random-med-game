package src.ui {
    
    import flash.display.MovieClip;
    import flash.text.Font;
    import flash.text.FontStyle;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
    import flash.ui.Mouse;
    
    public class GenericLevelButton extends MovieClip {
        public var levelId:Number;
        var mapHeight:Number;
        private var title:TextField;
        
        public function GenericLevelButton() {
            mouseChildren = false;
            mapHeight = height;

            this.addEventListener(MouseEvent.MOUSE_OVER, makeDarker);
            this.addEventListener(MouseEvent.MOUSE_OUT, makeNormal);
        }
        
        public function setLabel(levelLabel:String):void {
            title = new TextField();
            title.embedFonts = true;
            title.text = levelLabel;
            title.x = 0;
            
            title.wordWrap = true;
            
            title.setTextFormat(getLevelNameFormat());
            title.y = -20*(Math.floor(title.length/10)+1);
            
            addChild(title);
        }
        
        private function getLevelNameFormat():TextFormat {
            var tf:TextFormat = new TextFormat();
            
            var font:Font = new MagicFont();
            
            tf.font = font.fontName;
            tf.color = 0xffffff;
            tf.align = "center";
            tf.size = 15;
            tf.bold = FontStyle.BOLD;
            
            return tf;
        }
        
        public function setRating(rating:int):void {
            var star:Star=new Star(),
                ammendX:Number = (width - star.width*3)-4,
                ammendY:Number = mapHeight;
            
            for ( var i=0; i<3; i++ ) {
                star = new Star();
                star.gotoAndStop(1);
                star.x = ammendX + star.width * i;
                star.y = ammendY;
                
                if ( i < rating ) {
                    star.setScore();
                }
                
                addChild(star);
            }
        }
        
        private function makeDarker(e:MouseEvent) {
            this.transform.colorTransform = new ColorTransform(1.2,1.2,1.2);
            Mouse.cursor = "button";
            
            title.textColor = 0x000000;
        }
        
        private function makeNormal(e:MouseEvent) {
            this.transform.colorTransform = new ColorTransform();
            Mouse.cursor = "auto";
            title.textColor = 0xffffff;
        }
        
        public function block () {
            removeEventListener(MouseEvent.MOUSE_OVER, makeDarker);
            removeEventListener(MouseEvent.MOUSE_OUT, makeNormal);
            
            mouseChildren = false;
            mouseEnabled = false;
            
            this.transform.colorTransform = new ColorTransform(0.3,0.3,0.3);
        }
    }
    
}
