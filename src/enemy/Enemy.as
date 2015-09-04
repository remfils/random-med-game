package src.enemy {
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import fl.motion.Color;
    import flash.display.DisplayObject;
    import src.costumes.CostumeEnemy;
    import src.events.SubmitTaskEvent;
    import src.Game;
    import src.Ids;
    import src.levels.Room;
    import src.objects.TaskObject;
    import src.Player;
    import src.util.ChangePlayerStatObject;
    import src.util.CreateBodyRequest;
    
    public class Enemy extends TaskObject {
        public static const DEATH_STATE:String = "_death";
        
        public static var MAX_HEALTH:Number = 100;
        public var agroDistance:Number = 150;
        
        protected var health:Number = MAX_HEALTH;
        public var damage:Number = 1;
        public var exp:Number = 2;
        protected var enemy_mass:Number = 0.3;
        
        protected var isFlip:Boolean = true;
        
        public var cRoom:Room;
        var player:Player;
        var playerDistance:Number;
        private var hitFrames:uint = 0;
        
        private static var hitColor:Color = new Color();
        
        protected var enemyFixtureDef:b2FixtureDef; // D!

        public function Enemy():void {
            super();
            
            player = game.player;
            
            costume = new CostumeEnemy();
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
            if ( !is_active ){
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
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createBodyReq:CreateBodyRequest = super.requestBodyAt(world);
            
            var fixtureDef:b2FixtureDef = createBodyReq.fixtureDef;
            fixtureDef.density = enemy_mass;
            
            return createBodyReq;
        }
        
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
            hitColor.setTint(0, 0);
            hitFrames = 0;
            cRoom.removeEnemy(this);
            costume.setAnimatedState(DEATH_STATE);
            submitAnswer();
            destroy();
        }
        
        override public function destroy():void {
            super.destroy();
        }

        override public function getActiveArea():DisplayObject {
            return costume;
        }
        
        override public function getID():int {
            var costume_type:String = costume.type;
            
            switch(costume_type) {
                case CostumeEnemy.GHOST:
                    return Ids.ENEMY_GHOST_ID;
                break;
                case CostumeEnemy.MONK:
                    return Ids.ENEMY_MONK_ID;
                break;
                case CostumeEnemy.RAT:
                    return Ids.ENEMY_RAT_ID;
                break;
                case CostumeEnemy.GREEN_BULLET_TYPE:
                    return Ids.ENEMY_PROJECTILE_ID;
                break;
                default:
                    return super.getID();
            }
        }
    }
    
}
