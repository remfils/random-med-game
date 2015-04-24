package src.enemy {
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import fl.motion.Color;
    import fl.motion.ColorMatrix;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.Point;
    import flash.net.NetStreamAppendBytesAction;
    import src.costumes.EnemyCostume;
    import src.events.RoomEvent;
    import src.Game;
    import src.interfaces.ExtrudeObject;
    import src.interfaces.Updatable;
    import src.levels.Room;
    import src.objects.TaskObject;
    import src.util.CreateBodyRequest;
    import src.util.Collider;
    import src.Player;
    
    public class Enemy extends TaskObject implements ExtrudeObject {
        public static const DEATH_STATE:String = "death";
        
        public static var MAX_HEALTH:Number = 100;
        public static var agroDistance:Number = 150;
        
        protected var health:Number = MAX_HEALTH;
        public var damage:Number = 1;
        public var exp:Number = 30;
        
        protected var isFlip:Boolean = true;
        
        public var cRoom:Room;
        var player:Player;
        var playerDistance:Number;
        private var hitFrames:uint = 0;
        
        private static var hitColor:Color = new Color();
        
        protected var enemyFixtureDef:b2FixtureDef;

        public function Enemy():void {
            super();
            
            player = Player.getInstance();
            
            enemyFixtureDef = new b2FixtureDef();
            enemyFixtureDef.density = 0.3;
            enemyFixtureDef.userData = { "object": this };
            
            //costume = new EnemyCostume();
            
            //addChild(costume);
            
            deactivate();
        }
        public function setCotume(enemyBreed:String):void {
            /*costume.setType(enemyBreed);
            if ( getChildIndex(costume) < 0 ) addChild(costume);*/
        }
        
        override public function update ():void {
            if ( !body ) return;
            
            calculateDistanceToPlayer();
            
            activateIfPlayerIsAround();
            
            playHitAnimationIfNeeded();
            
            updatePosition();
            
            flip();
        }
        
        protected function activateIfPlayerIsAround():void {
            if ( !isActive() ){
                if ( agroDistance > playerDistance ) {
                    activate();
                }
            }
            else {
                if ( agroDistance < playerDistance ) {
                    deactivate();
                }
            }
        }
        
        protected function playHitAnimationIfNeeded():void {
            if ( hitFrames ) {
                hitFrames --;
                
                hitColor.setTint(0xff0000, 0.5);
                if ( hitFrames == 0 )
                    hitColor.setTint(0, 0);
                
                costume.transform.colorTransform = hitColor;
            }
        }
        
        protected function updatePosition():void {
            x = body.GetPosition().x * Game.WORLD_SCALE;
            y = body.GetPosition().y * Game.WORLD_SCALE;
        }
        
        protected function flip():void {
            if ( isFlip ) {
                costume.scaleX = x < player.x ? 1 : -1;
            }
        }
        
        override public function requestBodyAt(world:b2World):void {
            var collider:DisplayObject = costume.getCollider();
            
            var bodyCreateRequest:CreateBodyRequest = new CreateBodyRequest(world, collider, this);
            bodyCreateRequest.setAsDynamicBody(enemyFixtureDef);
            
            game.bodyCreator.add(bodyCreateRequest);
        }
        
        /*override public function createBodyFromCollider(world:b2World):b2Body {
            var collider:Collider = getChildByName("collider001") as Collider;
            body = collider.replaceWithDynamicB2Body(world, enemyFixtureDef);
            return body;
        }*/
        
        public function activate ():void {
            active = true;
            //gotoAndStop("attack");
        }
        
        public function deactivate():void {
            active = false;
            //gotoAndStop("normal");
        }
        
        // remove this
        /*public function setPositionBad (X:Number, Y:Number):void {
            x = X;
            y = Y;
        }*/
        
        protected function calculateDistanceToPlayer():void {
            var dx = player.x - x,
                dy = player.y - y;
            playerDistance = Math.sqrt(dx*dx + dy*dy);
        }
        
        public function makeHit(damage:Number):void {
            if ( hitFrames ) return;
            
            health -= damage;
            
            hitFrames = 5;
            
            if ( health <= 0 ) {
                die();
            }
            
        }
        
        public function die():void {
            //gotoAndPlay("death");
            hitColor.setTint(0, 0);
            hitFrames = 0;
            cRoom.removeEnemy(this);
            game.deleteManager.add(body);
            destroy();
        }
        
        public function removeCorpse():void {
            cRoom.gameObjectPanel.removeChild(costume);
        }
        
        override public function destroy():void {
            super.destroy();
            costume.dispatchEvent(new Event("GUESS_EVENT"));
        }

    }
    
}
