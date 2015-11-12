package src.bullets {
    import src.costumes.BulletCostume;
    import src.util.SoundManager;
    public class BulletDef {
        public var name:String = "";
        public var damage:Number = 0;
        public var speed:Number = 0;
        public var delay:Number = 0;
        public var end_animation_delay:Number = 0;
        public var manaCost:Number = 0;
        public var is_boom:Boolean = false;
        public var sfx_shoot:int = SoundManager.SFX_CAST_SPARK;
        public var sfx_hit:int = 0;
        
        public var spell_id:int;
        
        public function BulletDef(name_:String, damage:Number, speed:Number, manaCost:int, delay:Number, end_animation_delay_:Number = 0, is_boom_:Boolean = false) {
            this.name = name_;
            this.damage = damage;
            this.speed = speed;
            this.manaCost = manaCost;
            this.end_animation_delay = end_animation_delay_;
            this.delay = delay;
            this.is_boom = is_boom_;
            
            switch (name) {
                case BulletCostume.SPARK_TYPE:
                    spell_id = 1;
                break;
                case BulletCostume.NUKELINO_TYPE:
                    spell_id = 2;
                    break;
                case BulletCostume.POWER_SPELL_TYPE:
                    spell_id = 3;
                    break;
                default:
                    spell_id = 0;
            }
        }
        
        public function setSounds(sfx_shoot:int, sfx_hit:int):void {
            this.sfx_shoot = sfx_shoot;
            this.sfx_hit = sfx_hit;
        }
    }

}