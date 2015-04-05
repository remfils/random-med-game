package src.bullets {
    public class BombSpell extends Bullet {
        public static var bulletDef:BulletDef = new BulletDef(100, 10, 3, 1000);
        
        public function BombSpell() {
            super();
        }
        
        override public function getBulletDefenition():BulletDef {
            return bulletDef;
        }
        
    }

}