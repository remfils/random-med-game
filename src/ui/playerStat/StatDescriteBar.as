package src.ui.playerStat {
    import flash.display.Sprite;
    import src.costumes.PlayerStatCostume;
    import src.Player;
    
    public class StatDescriteBar extends Sprite {
        private var PointClass:Class;
        private var points:Array;
        private var stat:String;
        private var player:Player;
        
        private var statType:String;
        
        public var pointsLeftPadding:Number = 3;
        
        public static const EMPTY_STATE:String = "_empty";
        public static const HALF_STATE:String = "_half";
        public static const NORMAL_STATE:String = "";
        
        public function StatDescriteBar(player_:Player, statType_:String, statToObserve:String) {
            points = [];
            
            player = player_;
            
            statType = statType_;
            
            stat = statToObserve;
            
            redraw();
            updatePoints();
        }
        
        public function redraw():void {
            clear();
            var i:int = player["MAX_" + stat] / 2;
            
            while ( i-- ) {
                var point:PlayerStatCostume = new PlayerStatCostume();
                point.setType(statType);
                point.setState(NORMAL_STATE);
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
            var health:Number = player[stat] / 2.0 - 1,
                i:int = points.length;
            
            trace(health);
            while ( i -- ) {
                if ( i <= health ) {
                    PlayerStatCostume(points[i]).setState(NORMAL_STATE);
                }
                else {
                    if ( i - health == 0.5 ) {
                        PlayerStatCostume(points[i]).setState(HALF_STATE);
                    }
                    else {
                        PlayerStatCostume(points[i]).setState(EMPTY_STATE);
                    }
                }
            }
        }

    }
    
}
