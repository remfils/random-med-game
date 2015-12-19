package src.ui {
    import flash.display.Graphics;
    import flash.display.Sprite;
    import src.costumes.PlayerStatCostume;


    public class BossHealhBar {
        public var costume:PlayerStatCostume;
        private var bar:Sprite;
        
        private var max_health:Number;
        
        private const HEALTH_COLOR:uint = 0xC52320;
        private const MAX_BAR_WIDTH:Number = 374.9;
        private const BAR_HEIGHT:Number = 15.1;
        
        public function BossHealhBar(boss_max_health:Number) {
            costume = new PlayerStatCostume();
            costume.setType(PlayerStatCostume.BOSS_HP_BAR);
            costume.setState();
            
            bar = new Sprite();
            bar.x = -187.45;
            bar.y = -7.55;
            
            max_health = boss_max_health;
            
            costume.addChild(bar);
            
            redrawHealth(boss_max_health);
        }
        
        public function redrawHealth(health:Number):void {
            var g:Graphics = bar.graphics;
            
            g.clear();
            
            g.lineStyle(null);
            g.beginFill(HEALTH_COLOR, 1);
            
            g.drawRect(0, 0, MAX_BAR_WIDTH * health / max_health, BAR_HEIGHT);
            
            g.endFill();
        }
        
    }

}