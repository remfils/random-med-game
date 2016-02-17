package src.enemy {
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import fl.motion.Color;
    import flash.display.DisplayObject;
    import src.costumes.CostumeEnemy;
    import src.events.SubmitTaskEvent;
    import src.Game;
    import src.Ids;
    import src.interfaces.Init;
    import src.levels.Room;
    import src.objects.AbstractObject;
    import src.objects.TaskObject;
    import src.Player;
    import src.util.ChangePlayerStatObject;
    import src.util.CreateBodyRequest;
    import src.util.DeleteManager;
    import src.util.SoundManager;
    
    public class Enemy extends TaskObject implements Init {
        public static const DEATH_STATE:String = "_death";
        protected static const ACTION_DEATH_ID:int = 0;
        
        public static var MAX_HEALTH:Number = 100;
        public var agroDistance:Number = 150;
        
        protected var health:Number = MAX_HEALTH;
        public var damage:Number = 1;
        public var exp:Number = 2;
        protected var enemy_mass:Number = 0.3;
        
        protected var isFlip:Boolean = true;
        
        public var cRoom:Room;
        var player:Player;
        
        private var hitFrames:uint = 0;
        
        private static var hitColor:Color = new Color();
        
        protected var current_frame:int = 0;
        protected var current_state:String = DEATH_STATE;
        
        protected var _actions:Vector.<Attack>;
        protected var current_action:Attack;

        public function Enemy():void {
            super();
            
            _actions = new Vector.<Attack>();
            
            _actions[ACTION_DEATH_ID] = new Attack(0, deathInitAction, deathUpdateAction, deathEndAction);
            player = game.player;
            
            costume = new CostumeEnemy();
            
            properties = IS_EXTRUDED | IS_ACTIVE;
        }
        
        protected function deathInitAction():void {
            hitColor.setTint(0, 0);
            hitFrames = 0;
            setState(DEATH_STATE, true);
        }
        
        protected function deathUpdateAction():void {
            if ( body.IsActive() ) {
                body.SetActive(false);
            }
        }
        
        protected function deathEndAction():void {
            destroy();
            
            submitAnswer();
        }
        
        protected function setState(state:String, is_animated:Boolean = false):void {
            current_state = state;
            
            if ( is_animated ) costume.setAnimatedState(state);
            else costume.setState(state);
        }
        
        public function init():void {
            
        }
        
        override public function update ():void {
            if ( !body ) return;
            
            current_frame ++;
            
            updateCurrentAction();
            
            playHitAnimationIfNeeded();
            
            updatePosition();
            
            flip();
        }
        
        protected function updateCurrentAction():void {
            if ( current_action.update_function ) {
                current_action.update_function();
            }
            
            if ( current_action.end_animation_frame != 0 ) {
                if ( current_frame > current_action.end_animation_frame ) {
                    if ( current_action.end_function ) {
                        current_action.end_function();
                    }
                    
                    decideWhatToDo();
                }
            }
        }
        
        protected function decideWhatToDo():void {
            
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
        
        protected function isPlayerInAgroRange():Boolean {
            var distance:Number = getDistanceTo(player);
            return distance < agroDistance;
        }
        
        protected function getDistanceTo(target:AbstractObject):Number {
            var dx = target.x - x,
                dy = target.y - y;
            return Math.sqrt(dx*dx + dy*dy);
        }
        
        public function makeHit(damage:Number):void {
            if ( hitFrames ) return;
            
            health -= damage;
            
            hitFrames = 5;
            
            if ( health <= 0 ) {
                changeAction(ACTION_DEATH_ID);
            }
            
        }
        
        protected function changeAction(action_id:int):void {
            if ( current_action && current_action.end_function ) {
                current_action.end_function();
            }
            
            current_action = _actions[action_id];
            current_action.init_function();
        }
        
        override public function remove():void {
            //super.remove();
            //die();
        }
        
        override public function destroy():void {
            // super.destroy();
            cRoom.remove(this);
            cRoom.removeEnemy(this);
            
            var d_m:DeleteManager = game.deleteManager;
            d_m.add(body);
            d_m.add(costume);
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
