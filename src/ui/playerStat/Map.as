package src.ui.playerStat {
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import src.Player;
    
    public class Map extends MovieClip {
        private var _rooms:Array;
        public var _player:Player;
        
        private var miniMap:Sprite;
        private var currentRoom:Sprite;
        
        private var WIDTH:int = 10;
        private var HEIGHT:int = 6;

        public function Map() {
            miniMap = new Sprite();
            addChild(miniMap);
            
            currentRoom = new Sprite();
            addChild(currentRoom);
        }
        
        public function setUpScale (levels:Array) {
            var max_x:int = 0,
                max_y:int = 0,
                min_x:int = 10,
                min_y:int = 10,
                I:int, J:int;
            
            for ( var i:String in levels ) {
                I = int(i);
                if ( max_x < I ) max_x = I;
                if ( min_x > I ) min_x = I;
                
                for ( var j:String in levels[I] ) {
                    J = int (j);
                    if ( max_y < J ) max_y = J;
                    if ( min_y > J ) min_y = J;
                }
            }
            
            WIDTH = width / (max_x-min_x+1) - 2;
            HEIGHT = height / (max_y -min_y + 1) - 2;
            
            if ( max_x - min_x > max_y - min_y ) {
                HEIGHT = WIDTH / 1.5;
            }
            else {
                WIDTH = HEIGHT * 1.5;
            }
            
            miniMap.x = (width - WIDTH * (max_x - min_x+1))/2 ;

            miniMap.y += (height - HEIGHT * (max_y-min_y+1))/2;
            
            redrawCurrentRoom();
        }
        
        public function redrawCurrentRoom () {
            var g = currentRoom.graphics;
            g.clear();
            g.beginFill(0xffffff, 0.9);
            g.drawRect(1,1,WIDTH-3,HEIGHT-3);
        }
        
        public function update(levels:Array) {
            addLevel(_player.currentRoom.x, _player.currentRoom.y);
            
            moveRoomCursor(_player.currentRoom.x, _player.currentRoom.y);
        }
        
        public function adjustSize () {
            miniMap.width = width - 10;
            miniMap.height = height - 10;
        }
        
        public function setUpRooms( instructions:Array ) {
            //adjustRoomSize(instructions);
            
            for (var i:int=instructions.length-1; i>=0; i--) {
                addLevel(instructions[i][0],instructions[i][1]);
            }
            
            miniMap.x = width/2;
            miniMap.y = height/2;
        }
        
        private function addLevel (i:int, j:int) {
            miniMap.graphics.beginFill(0x000000,1);
            miniMap.graphics.drawRect(i*WIDTH,j*HEIGHT,WIDTH-1,HEIGHT-1);
        }
        
        private function moveRoomCursor(i:int, j:int) {
            currentRoom.x = WIDTH * i + miniMap.x;
            currentRoom.y = HEIGHT * j + miniMap.y;
        }

    }
    
}
