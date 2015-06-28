package src.bullets {
    public class BulletDef {
        public var name:String = "";
        public var damage:Number = 0;
        public var speed:Number = 0;
        public var delay:Number = 0;
        public var manaCost:Number = 0;
        
        public function BulletDef(name_:String, damage:Number, speed:Number, manaCost:int, delay:Number) {
            this.name = name_;
            this.damage = damage;
            this.speed = speed;
            this.manaCost = manaCost;
            this.delay = delay;
        }
        
    }

}