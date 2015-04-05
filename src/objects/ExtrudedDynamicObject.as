package src.objects {
    import src.interfaces.ExtrudeObject;
	/**
     * ...
     * @author vlad
     */
    public class ExtrudedDynamicObject extends DynamicObject implements ExtrudeObject {
        
        public function ExtrudedDynamicObject() {
            super();
            colliderName = "collider001";
        }
        
    }

}