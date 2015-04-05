package src.bullets {
    import Box2D.Collision.b2RayCastInput;
    import Box2D.Collision.b2RayCastOutput;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Fixture;
    import Box2D.Dynamics.b2World;
    import flash.display.MovieClip;
    import src.enemy.Enemy;
    import src.Game;
    import src.interfaces.Breakable;
    import src.objects.Door;
    import src.Player;
    import src.ui.EndLevelMenu;
	/**
     * ...
     * @author vlad
     */
    public class Bombastic extends Bullet {
        public static var bulletDef:BulletDef = new BulletDef(100, 10, 0, 1000);
        public static var BLAST_RADIUS:Number = 50;
        
        public function Bombastic() {
            super();
        }
        
        override public function getBulletDefenition():BulletDef {
            return bulletDef;
        }
        
        override public function safeCollide():void {
            explode();
            
            super.safeCollide();
        }
        
        private function explode():void {
            var world:b2World = body.GetWorld(),
                startPoint:b2Vec2 = new b2Vec2(x / Game.WORLD_SCALE, y / Game.WORLD_SCALE),
                endPoint:b2Vec2 = new b2Vec2(),
                rayRadius:Number = BLAST_RADIUS / Game.WORLD_SCALE,
                N:int = 14;
            
            var i:int = N;
            while ( i-- ) {
                endPoint.x = startPoint.x + rayRadius * Math.cos( 2 * Math.PI * i / N );
                endPoint.y = startPoint.y + rayRadius * Math.sin( 2 * Math.PI * i / N );
                world.RayCast(explodeObject, startPoint, endPoint);
            }
        }
        
        private function explodeObject( fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Number ):Number {
            if ( fixture.GetUserData() ) {
                var object:Object = fixture.GetUserData().object;
                
                if ( object is MovieClip ) {
                    var force:b2Vec2 = new b2Vec2 ( x / Game.WORLD_SCALE - point.x, y / Game.WORLD_SCALE - point.y );
                    force.Multiply( - 6 / force.Length() );
                    
                    if ( object is Door && Door(object).isSecret ) {
                        Door(object).specialLock = false;
                        Door(object).unlock();
                    }
                    
                    if ( object is Player ) {
                        Player(object).body.ApplyImpulse(force, Player(object).body.GetWorldCenter() );
                        Player(object).makeHit(2);
                    }
                    
                    if ( object is Enemy ) {
                        Enemy(object).body.ApplyImpulse(force, Enemy(object).body.GetWorldCenter() );
                        Enemy(object).makeHit(getBulletDefenition().damage);
                    }
                    
                    if ( object is Breakable ) {
                        Breakable(object).breakObject();
                    }
                }
            }
            
            return 0;
        }
    }

}