package src.objects {
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2World;
    import fl.motion.Color;
	import flash.display.MovieClip;
    import src.Game;
	
	/**
     * ...
     * @author vlad
     */
    public class AbstractObject extends MovieClip {
        public static var game:Game;
        public var body:b2Body;
        
        public function AbstractObject() {
            super();
        }
        
        public function requestBodyAt(world:b2World):void {
            
        }
        
        public function destroy():void {
            game.deleteManager.add(body);
        }
        
        public function setTint(color:uint):void {
            var col:Color = new Color();
            col.setTint(color, 0.3);
            transform.colorTransform = col;
        }
        
    }

}