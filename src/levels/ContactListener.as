package src.levels {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2ContactImpulse;
    import Box2D.Dynamics.b2ContactListener;
    import Box2D.Dynamics.b2Fixture;
    import Box2D.Dynamics.Contacts.b2Contact;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.ObjectEncoding;
    import src.bullets.BombSpell;
    import src.bullets.Bullet;
    import src.enemy.Enemy;
    import src.enemy.Projectile;
    import src.events.RoomEvent;
    import src.Game;
    import src.interfaces.Breakable;
    import src.objects.Door;
    import src.objects.DropObject;
    import src.Player;
	/**
     * ...
     * @author vlad
     */
    public class ContactListener extends b2ContactListener {
        private var game:Game;
        
        public function ContactListener(game:Game) {
            this.game = game;
        }
        
        override public function BeginContact(contact:b2Contact):void {
            super.BeginContact(contact);
            
            var userDataA:Object = contact.GetFixtureA().GetUserData();
            var userDataB:Object = contact.GetFixtureB().GetUserData();
            
            checkBulletCollision(userDataA, userDataB);
            
            if ( userDataA == null  || userDataB == null) return;
            
            if ( contact.GetFixtureA().IsSensor() || contact.GetFixtureB().IsSensor() ) {
                checkExitCollide(userDataA, userDataB);
            
                checkPlayerDropCollision(userDataA, userDataB);
            }
            
        }
        
        private function checkBulletCollision(userDataA:Object, userDataB:Object):void {
            if ( userDataA == null && userDataB == null ) return;
            
            if ( userDataA is Object && userDataA.hasOwnProperty("object") ) {
                if ( userDataA.object is Bullet )
                    
                    asymetricBulletCheck(userDataA.object as Bullet, userDataB);
                    
                if ( userDataA.object is Projectile )
                    asymetricEnemyBulletCheck(userDataA.object, userDataB);
                    
            }
            
            if ( userDataB is Object && userDataB.hasOwnProperty("object") ) {
                if ( userDataB.object is Bullet )
                    asymetricBulletCheck(userDataB.object as Bullet, userDataA);
                    
                if ( userDataB.object is Projectile )
                    asymetricEnemyBulletCheck(userDataB.object, userDataA);
            }
        }
        
        private function asymetricBulletCheck(bullet:Bullet, userData:Object):void {
            if ( userData is Object && userData.hasOwnProperty("object") ) {
                if ( userData.object is DropObject ) {
                    return;
                }
                
                if ( userData.object is Player ) {
                    return;
                }
                
                if ( bullet is BombSpell && userData.object is Door ) {
                    if ( Door(userData.object).isSecret ) {
                        Door(userData.object).specialLock = false;
                        Door(userData.object).unlock();
                    }
                }
                
                if ( userData.object is Enemy ) {
                    Enemy(userData.object).makeHit(bullet.getBulletDefenition().damage);
                }
                
                if ( userData.object is Breakable && bullet is BombSpell ) {
                    Breakable(userData.object).breakObject();
                }
            }
            
            game.bulletController.hideBullet(bullet);
        }
        
        private function asymetricEnemyBulletCheck(bullet:Projectile, userData:Object):void {
            if ( userData is Object ) {
                if ( userData.object is Enemy ) return;
                
                if ( userData.object is Player ) {
                    Player(userData.object).makeHit( bullet.damage );
                }
            }
            bullet.die();
        }
        
        
        private function checkExitCollide(userDataA:Object, userDataB:Object):void {
            if ( userDataA.object is Player || userDataB.object is Player ) {
                if ( userDataA.object is Door ) {
                    Sprite(userDataA.object).dispatchEvent(new RoomEvent(RoomEvent.EXIT_ROOM_EVENT));
                }
                if ( userDataB.object is Door ) {
                    Sprite(userDataB.object).dispatchEvent(new RoomEvent(RoomEvent.EXIT_ROOM_EVENT));
                }
            }
        }
        
        private function checkPlayerDropCollision(userDataA:Object, userDataB:Object):void {
            if ( userDataA.object is Player || userDataB.object is Player ) {
                if ( userDataA.object is DropObject ) {
                    DropObject(userDataA.object).pickUp();
                }
                
                if ( userDataB.object is DropObject ) {
                    DropObject(userDataB.object).pickUp();
                }
            }
        }
        
        
        
        
        override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void {
            super.PostSolve(contact, impulse);
            
            if ( contact.GetFixtureA().GetUserData() == null  || contact.GetFixtureB().GetUserData() == null) return;
            
            checkPlayerEnemyCollision(contact.GetFixtureA(), contact.GetFixtureB());
        }
        
        
        private function checkPlayerEnemyCollision(fixtureA:b2Fixture, fixtureB:b2Fixture):void {
            var userDataA:Object = fixtureA.GetUserData();
            var userDataB:Object = fixtureB.GetUserData();
            
            if ( userDataA.object is Enemy || userDataB.object is Enemy ) {
                var bodyA:b2Body = fixtureA.GetBody();
                var bodyB:b2Body = fixtureB.GetBody();
                var dr:b2Vec2;
                
                if ( userDataA.object is Player ) {
                    dr = bodyA.GetPosition().Copy();
                    dr.Subtract(bodyB.GetPosition());
                    dr.Multiply(3);
                    bodyA.ApplyImpulse( dr ,bodyA.GetWorldCenter());
                    Player(userDataA.object).makeHit( Enemy(userDataB.object).damage );
                }
                
                if ( userDataB.object is Player ) {
                    dr = bodyB.GetPosition().Copy();
                    dr.Subtract(bodyA.GetPosition());
                    dr.Multiply(3);
                    
                    bodyB.ApplyImpulse( dr ,bodyB.GetWorldCenter());
                    Player(userDataB.object).makeHit( Enemy(userDataA.object).damage );
                }
            }
        }
        
    }

}