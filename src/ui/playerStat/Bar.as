package src.ui.playerStat {
    import flash.display.Sprite;
    import src.Player;
    
    public class Bar extends Sprite {
        private var PointClass:Class;
        private var points:Array;
        private var stat:String;
        private var player:Player;
        
        public var pointsLeftPadding:Number = 3;
        
        public function Bar(pointClass:Class, statToObserve:String) {
            PointClass = pointClass;
            points = new Array();
            
            player = Player.getInstance();
            
            stat = statToObserve;
            
            redraw();
        }
        
        public function redraw():void {
            clear();
            var player:Player = Player.getInstance();
            var i:int = player["MAX_" + stat] / 2;
            
            while ( i-- ) {
                var point = new PointClass();
                point.x = (point.width + pointsLeftPadding) * i;
                addChild(point);
                points[i] = point;
            }
        }
        
        private function clear():void {
            while ( numChildren ) {
                removeChildAt(numChildren - 1);
            }
            
            while ( points.length ) {
                points.splice( points.length - 1, 1);
            }
        }
        
        public function updatePoints():void {
            var health:Number = player[stat] / 2. - 1,
                i:int = points.length;
            
            while ( i -- ) {
                if ( i <= health ) {
                    StatPoint(points[i]).setState(StatPoint.FULL_STATE);
                }
                else {
                    if ( i - health == 0.5 ) {
                        StatPoint(points[i]).setState(StatPoint.HALF_STATE);
                    }
                    else {
                        StatPoint(points[i]).setState(StatPoint.EMPTY_STATE);
                    }
                }
            }
        }

    }
    
}
