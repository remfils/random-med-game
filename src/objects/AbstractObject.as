package src.objects {
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2World;
    import fl.motion.Color;
	import flash.display.MovieClip;
    import flash.geom.Point;
    import src.costumes.Costume;
    import src.Game;
    import src.util.CreateBodyRequest;
	
	/**
     * ...
     * @author vlad
     */
    public class AbstractObject extends MovieClip {
        public static var game:Game;
        public var body:b2Body;
        public var costume:Costume;
        
        public function AbstractObject() {
            super();
        }
        
        public function requestBodyAt(world:b2World):void {
            var collider:MovieClip = getChildByName("collider") as MovieClip;
            
            var createBodyRequest:CreateBodyRequest = new CreateBodyRequest(world, collider);
            createBodyRequest.setAsStaticBody();
            createBodyRequest.setBodyPosition( new Point(x + collider.x, y + collider.y) );
            
            game.bodyCreator.add(createBodyRequest);
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