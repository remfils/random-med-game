package src.interfaces {
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2World;
    import src.util.Collider;

    public interface Updatable extends SolidBody {
        
        // обновляет координаты элемента
        function update ():void;
        
        // проверяет активен ли элемент
        function isActive ():Boolean;
        // @TODO: make getBody

    }

}