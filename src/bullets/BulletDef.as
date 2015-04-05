package src.bullets {
	/**
     * ...
     * @author vlad
     */
    public class BulletDef {
        public var damage:Number = 0;
        public var speed:Number = 0;
        public var delay:Number = 0;
        public var manaCost:Number = 0;
        
        public function BulletDef(damage:Number, speed:Number, manaCost:int, delay:Number) {
            this.damage = damage;
            this.speed = speed;
            this.manaCost = manaCost;
            this.delay = delay;
        }
        
    }

}