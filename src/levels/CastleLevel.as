﻿package src.levels {
    
    import flash.display.MovieClip;
    import src.Game;
    import src.levels.Room;
    import src.Player;
    import flash.display.Sprite;
    import fl.motion.Color;
    
    
    public class CastleLevel extends Room {
        public function CastleLevel(game:Game) {
            super(game);
        }
        
        override public function setParametersFromXML (paramsXML:XMLList):void {
            super.setParametersFromXML(paramsXML);
            
            setWallColor(paramsXML.(name() == "color"));
            
            setFloorState(paramsXML.(name() == "floorState"));
            
            setWallState(paramsXML.(name() == "wallState"));
        }
        
        private function setWallColor(color:uint):void {
            if ( color == 0 ) {
                drawWalls(0xC6C6C6);
            }
            else {
                drawWalls(color);
            }
        }
        
        private function drawWalls(wall_color:uint) {
            var walls:Sprite = new Sprite();
            walls.graphics.clear();
            walls.graphics.beginFill(wall_color);
            walls.graphics.drawRect(13, 15, 723, 473);
            addChildAt(walls, 0);
        }
        
        private function setFloorState(state:String):void {
            switch (state) {
                case "ground":
                    floor_mc.gotoAndStop("ground_state");
                break;
                default:
                    floor_mc.gotoAndStop("wooden_state");
            }
        }
        
        private function setWallState(state:String):void {
            switch (state) {
                default:
                    wall_mc.gotoAndStop("brick_state");
            }
        }
        
    }
    
}
