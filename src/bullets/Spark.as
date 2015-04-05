package src.bullets {
    
    public class Spark extends Bullet {
        public static var bulletDef:BulletDef = new BulletDef(50, 10, 0, 500);
        
        public function Spark() {
            super();
        }
        
        override public function getBulletDefenition():BulletDef {
            return bulletDef;
        }
    }
    
}
