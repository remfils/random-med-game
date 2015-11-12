package src.bullets {
    import Box2D.Common.Math.b2Vec2;
    import flash.display.DisplayObjectContainer;
    import flash.geom.Point;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import src.costumes.BulletCostume;
    import src.events.RoomEvent;
    import src.Game;
    import src.util.AbstractManager;
    import src.util.Output;
    import src.util.Recorder;
    import src.util.SoundManager;
    
    import src.levels.Room;
    import src.Player;
    
    public class BulletController extends AbstractManager {
        private var _bullets:Array = new Array();
        private var _bulletsToRemove:Array = new Array();
        private var _bullets_to_deactivate:Vector.<Bullet> = new Vector.<Bullet>();
        private var fire:Boolean;
        
        public var bullet_type:String;
        
        private var currentBulletClass:int = 0;
        public var BulletClass:Class;
        
        private var bulletDelay:Timer;
        private var block:Boolean = false;
        
        private var currentRoom:Room = null;
        
        private var stage:DisplayObjectContainer;
        
        public var currentSpellDef:BulletDef;
        private var currentSpellIndex:int = 0;
        
        private static const allSpells:Vector.<BulletDef> = new <BulletDef>[
            null,
            new BulletDef(BulletCostume.SPARK_TYPE, 50, 10, 0, 500, 5 / Game.FRAMES_PER_MILLISECOND),
            new BulletDef(BulletCostume.POWER_SPELL_TYPE, 100, 10, 1, 500, 10 / Game.FRAMES_PER_MILLISECOND),
            new BulletDef(BulletCostume.NUKELINO_TYPE, 120, 10, 1, 1000, 16 / Game.FRAMES_PER_MILLISECOND, true)
        ];

        public function BulletController(stage:DisplayObjectContainer) {
            this.stage = stage;
            
            currentSpellIndex = 0;
            currentSpellDef = allSpells[game.player.spells[currentSpellIndex]];
            
            allSpells[1].setSounds(SoundManager.SFX_CAST_SPARK, SoundManager.SFX_HIT_SPARK);
            
            bulletDelay = new Timer(10);
            bulletDelay.addEventListener(TimerEvent.TIMER, unlockSpawn);
        }
        
        public static function getIndexOfBulletByName(name:String):int {
            var i:int = allSpells.length;
            while (i--) {
                if ( allSpells[i].name == name ) return i;
            }
            Output.add("Spell not found at game.getIndexOfBulletByName");
            return 0;
        }
        
        public function changeLevel (level:Room):void {
            currentRoom = level;
        }
        
        public function update () {
            if (fire && game.player.MANA >= currentSpellDef.manaCost) {
                var b:Bullet = spawnBullet();
                
                if ( b ) {
                    SoundManager.instance.playSFX(currentSpellDef.sfx_shoot);
                    game.player.MANA -= currentSpellDef.manaCost;
                    game.playerStat.update();
                    Recorder.recordManaUse(currentSpellDef.spell_id, currentSpellDef.manaCost, game.player.MANA);
                }
            }
            
            var i = _bullets.length;
            while ( i-- ) {
                _bullets[i].update();
            }
            
            while (i = _bullets_to_deactivate.length) {
                _bullets_to_deactivate[i-1].detachBody();
                _bullets_to_deactivate.pop();
            }
            
            i = _bulletsToRemove.length;
            while ( i-- ) {
                if ( !_bulletsToRemove[i].isActive() ) {
                    deleteBullet(_bulletsToRemove[i]);
                    _bulletsToRemove.splice(i,1);
                }
            }
        }
        
        public function startBulletSpawn() {
            fire = true;
        }
        
        public function stopBulletSpawn() {
            fire = false;
        }
        
        public function spawnBullet():Bullet {
            if ( block ) return null;
            
            var bullet:Bullet = getFreeBullet();
            var player:Player = game.player;
            
            bullet.setType(currentSpellDef.name);
            bulletDelay.delay = currentSpellDef.delay;
            
            var spawnPoint:Point = new Point();
            spawnPoint.x = player.x + player.dir_x * bullet.colliderWidth;
            spawnPoint.y = player.y + player.dir_y * bullet.colliderHeight;
            
            var direction:Point = new Point(player.dir_x, player.dir_y);
            
            if ( bullet.body ) {
                bullet.moveTo(spawnPoint.x, spawnPoint.y);
                
                bullet.setSpeedDirection (direction.x, direction.y);
            }
            else {
                bullet.costume.x = spawnPoint.x;
                bullet.costume.y = spawnPoint.y;
                bullet.setDirection(direction.x, direction.y);
                bullet.requestBodyAt(currentRoom.world);
                stage.addChild (bullet.costume);
                _bullets.push(bullet);
            }
            
            lockSpawn();
            return bullet;
        }
        
        public function getFreeBullet():Bullet {
            var i = _bullets.length;
            while (i--) {
                if (!_bullets[i].isActive()) {
                    _bullets[i].activate();
                    _bullets[i].bulletDef = currentSpellDef;
                    return _bullets[i];
                }
            }
            
            return new Bullet(currentSpellDef);
        }
        
        public function safeDeactivateBullet (B:Bullet) {
            _bullets_to_deactivate.push(B);
        }
        
        public function nextSpell():void {
            var spells:Array = game.player.spells;
            if ( ++currentSpellIndex > spells.length - 1 ) {
                currentSpellIndex = 0;
            }
            currentSpellDef = allSpells[spells[currentSpellIndex]];
        }
        
        public function prevSpell():void {
            var spells:Array = game.player.spells;
            if ( --currentSpellIndex < 0 ) {
                currentSpellIndex = spells.length - 1;
            }
            currentSpellDef = allSpells[spells[currentSpellIndex]];
        }
        
        public function setSpell(spell_index:int):void {
            var spells:Array = game.player.spells;
            if ( spell_index >= 0 && spell_index < spells.length ) {
                currentSpellIndex = spell_index;
            }
            currentSpellDef = allSpells[spells[currentSpellIndex]];
        }
        
        private function deleteBullet(b:Bullet) {
            b.moveTo(-100, -100);
            currentRoom.world.DestroyBody(b.body);
            stage.removeChild(b.costume);
            _bullets.splice(_bullets.indexOf(b),1);
        }
        
        public function clearBullets():void {
            var i = _bullets.length;
            
            while (i--) {
                deleteBullet(_bullets[i]);
            }
        }
        
        public function smartClearBullets():void {
            var i = _bullets.length;
            
            while (i--) {
                if ( _bullets[i].isActive() ) {
                    if ( _bulletsToRemove.indexOf(_bullets[i]) == -1 )
                        _bulletsToRemove.push(_bullets[i]);
                }
                else {
                    deleteBullet(_bullets[i]);
                }
            }
        }
        
        // timer methods
        public function lockSpawn() {
            block = true;
            bulletDelay.start();
        }
        
        public function unlockSpawn(e:TimerEvent) {
            block = false;
            bulletDelay.stop();
        }

    }
    
}
