package src.interfaces {
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2World;
    import flash.geom.Point;
    import src.util.Collider;
    
    /**
     * ...
     * @author vlad
     */
    public interface SolidBody {
        function createBodyFromCollider (world:b2World):b2Body;
        
        function requestBodyAt(world:b2World, position:Point=null, speed:Point=null):void;
    }
    
}