package src.objects {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2World;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import src.Game;
    import src.interfaces.Breakable;
    import src.util.Collider;
	/**
     * ...
     * @author vlad
     */
    public class StaticObstacle extends Obstacle implements Breakable {
        
        public function StaticObstacle() {
            
        }
        
        public function breakObject():void {
            game.deleteManager.add(body);
            gotoAndPlay("break");
        }
        
        public function clearObject():void {
            
        }
    }

}