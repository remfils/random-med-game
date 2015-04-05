package src.objects {
    import src.interfaces.ExtrudeObject;
	/**
     * ...
     * @author vlad
     */
    public class ExtrudedDynamicObstacle extends DynamicObstacle implements ExtrudeObject {
        
        public function ExtrudedDynamicObstacle() {
            super();
            colliderName = "collider001";
        }
        
    }

}