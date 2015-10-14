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
    import src.bullets.Bullet;
    import src.enemy.Enemy;
    import src.enemy.Projectile;
    import src.events.RoomEvent;
    import src.Game;
    import src.Ids;
    import src.interfaces.Breakable;
    import src.objects.Door;
    import src.objects.DropObject;
    import src.objects.Obstacle;
    import src.Player;
    import src.task.Record;
    import src.util.ChangePlayerStatObject;
    import src.util.Recorder;

    public class ContactListener extends b2ContactListener {
        private var game:Game;
        private static const MAX_DOOR_DAMAGE:int = 80;
        
        public function ContactListener(game:Game) {
            this.game = game;
        }
        
        override public function BeginContact(contact:b2Contact):void {
            super.BeginContact(contact);
            
            var userDataA:Object = contact.GetFixtureA().GetUserData();
            var userDataB:Object = contact.GetFixtureB().GetUserData();
            
            checkBulletCollision(userDataA, userDataB);
            
            /*if ( userDataA == null  || userDataB == null) return;
            
            if ( contact.GetFixtureA().IsSensor() || contact.GetFixtureB().IsSensor() ) {
                checkExitCollide(userDataA, userDataB);
            
                checkPlayerDropCollision(userDataA, userDataB);
            }*/
            
        }
        
        private function checkBulletCollision(userDataA:Object, userDataB:Object):void {
            if ( userDataA == null && userDataB == null ) return;
            
            if ( userDataA is Object && userDataA.hasOwnProperty("object") ) {
                if ( userDataA.object is Bullet )
                    asymetricBulletCheck(userDataA.object as Bullet, userDataB);
                    
                if ( userDataA.object is Projectile )
                    asymetricEnemyBulletCheck(Projectile(userDataA.object), userDataB);
                    
            }
            
            if ( userDataB is Object && userDataB.hasOwnProperty("object") ) {
                if ( userDataB.object is Bullet )
                    asymetricBulletCheck(userDataB.object as Bullet, userDataA);
                    
                if ( userDataB.object is Projectile )
                    asymetricEnemyBulletCheck(Projectile(userDataB.object), userDataA);
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
                
                if ( userData.object is Obstacle) {
                    if ( Obstacle(userData.object).isBulletTransparent() ) {
                        return;
                    }
                }
                
                /*if ( bullet.bulletDef.is_boom ) {
                    bullet.explode = true;
                    game.bulletController.hideBullet(bullet);
                    return;
                }*/
                
                if ( userData.object is Enemy ) {
                    Enemy(userData.object).makeHit(bullet.bulletDef.damage);
                }
            }
            bullet.breakBullet();
            // game.bulletController.hideBullet(bullet);
        }
        
        private function asymetricEnemyBulletCheck(bullet:Projectile, userData:Object):void {
            if ( userData is Object ) {
                if ( userData.object is Enemy ) return;
                
                if ( userData.object is Obstacle) {
                    if ( Obstacle(userData.object).isBulletTransparent() ) {
                        return;
                    }
                }
                
                if ( userData.object is Player ) {
                    if ( game.player.immune ) return;
                    game.changePlayerStat(new ChangePlayerStatObject(ChangePlayerStatObject.HEALTH_STAT, -bullet.damage, bullet.getID(), true));
                }
            }
            bullet.die();
        }
        
        // D!
        private function checkExitCollide(userDataA:Object, userDataB:Object):void {
            if ( userDataA.object is Player || userDataB.object is Player ) {
                /*if ( userDataA.object is Door ) {
                    Sprite(userDataA.object).dispatchEvent(new RoomEvent(RoomEvent.EXIT_ROOM_EVENT));
                }
                if ( userDataB.object is Door ) {
                    Sprite(userDataB.object).dispatchEvent(new RoomEvent(RoomEvent.EXIT_ROOM_EVENT));
                }*/
            }
        }
        
        // D!
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
            if ( game.player.immune ) return;
            
            var userDataA:Object = fixtureA.GetUserData();
            var userDataB:Object = fixtureB.GetUserData();
            
            if ( userDataA.object is Enemy || userDataB.object is Enemy ) {
                var bodyA:b2Body = fixtureA.GetBody();
                var bodyB:b2Body = fixtureB.GetBody();
                
                if ( userDataA.object is Player ) {
                    hitPlayer(bodyA, bodyB, Enemy(userDataB.object));
                }
                
                if ( userDataB.object is Player ) {
                    hitPlayer(bodyB, bodyA, Enemy(userDataA.object));
                }
            }
        }
        
        private function hitPlayer(playerBod:b2Body, enemyBody:b2Body, enemy:Enemy):void {
            var dr:b2Vec2 = playerBod.GetPosition().Copy();
            dr.Subtract(enemyBody.GetPosition());
            dr.Multiply(3);
            playerBod.ApplyImpulse( dr , playerBod.GetWorldCenter());
            game.changePlayerStat(new ChangePlayerStatObject(ChangePlayerStatObject.HEALTH_STAT, -enemy.damage, enemy.getID(), true));
        }
        
    }

}