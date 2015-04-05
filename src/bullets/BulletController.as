package src.bullets {
    import Box2D.Common.Math.b2Vec2;
    import flash.display.DisplayObjectContainer;
    import flash.geom.Point;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import src.events.RoomEvent;
    import src.Game;
    import src.util.AbstractManager;
    
    import src.levels.Room;
    import src.Player;
    
    public class BulletController extends AbstractManager {
        private var _bullets:Array = new Array();
        private var _bulletsToRemove:Array = new Array();
        private var fire:Boolean;
        
        private var bulletClasses:Array = [Spark, BombSpell, Bombastic];
        private var currentBulletClass:int = 0;
        public var BulletClass:Class;
        
        private var bulletDelay:Timer;
        private var block:Boolean = false;
        
        private var currentRoom:Room = null;
        
        private var stage:DisplayObjectContainer;

        public function BulletController(stage:DisplayObjectContainer) {
            this.stage = stage;
            
            bulletClasses = game.player.spells;
            
            BulletClass = bulletClasses[currentBulletClass];
            
            bulletDelay = new Timer(BulletClass.bulletDef.delay);
            bulletDelay.addEventListener(TimerEvent.TIMER, unlockSpawn);
        }
        
        public function changeLevel (level:Room):void {
            currentRoom = level;
        }
        
        public function update () {
            if (fire && game.player.MANA >= BulletClass.bulletDef.manaCost) {
                var b:Bullet = spawnBullet();
                if ( b ) {
                    game.player.MANA -= BulletClass.bulletDef.manaCost;
                    game.playerStat.update();
                }
            }
            
            var i = _bullets.length;
            while ( i-- ) {
                _bullets[i].update();
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
            
            var spawnPoint:Point = new Point();
            spawnPoint.x = player.x + player.dir_x * bullet.colliderWidth;
            spawnPoint.y = player.y + player.dir_y * bullet.colliderHeight;
            
            var direction:Point = new Point(player.dir_x, player.dir_y);
            
            if ( bullet.body ) {
                bullet.moveTo(spawnPoint.x, spawnPoint.y);
                
                bullet.setSpeedDirection (direction.x, direction.y);
                
            }
            else {
                bullet.requestBodyAt(currentRoom.world, spawnPoint, direction);
                stage.addChild (bullet);
                _bullets.push(bullet);
            }
            
            //var player:Player = Player.getInstance();
            
            //bullet.moveTo(player.x + player.dir_x * bullet.colliderWidth , player.y + player.dir_y*bullet.colliderHeight);
            
            
            lockSpawn();
            
            return bullet;
        }
        
        public function getFreeBullet():Bullet {
            var i = _bullets.length;
            while (i--) {
                if (!_bullets[i].isActive()) {
                    _bullets[i].activate();
                    _bullets[i].gotoAndPlay(1);
                    return _bullets[i];
                }
            }
            return new BulletClass();
        }
        
        public function hideBullet (B:Bullet) {
            B.safeCollide();
            //B.moveTo(100, 100);
            //B.disableMovement();
            /*var i = _bullets.length;
            while (i--) {
                if ( B == _bullets[i] ) {
                    _bullets[i].disableMovement();
                    //_bullets[i].gotoAndPlay("destroy");
                    return;
                }
            }*/
        }
        
        public function setNextBullet():void {
            currentBulletClass ++;
            if ( currentBulletClass == bulletClasses.length ) {
                currentBulletClass = 0;
            }
            updateBulletClass();
        }
        
        public function setPrevBullet():void {
            currentBulletClass --;
            if ( currentBulletClass == -1 ) {
                currentBulletClass = bulletClasses.length - 1;
            }
            updateBulletClass();
        }
        
        private function updateBulletClass():void {
            BulletClass = bulletClasses[currentBulletClass];
            bulletDelay.delay = BulletClass.bulletDef.delay;
            smartClearBullets();
        }
        
        private function deleteBullet(b:Bullet) {
            b.moveTo(-100, -100);
            currentRoom.world.DestroyBody(b.body);
            stage.removeChild(b);
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
