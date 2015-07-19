package src.objects {
    import Box2D.Dynamics.b2FixtureDef;
    import flash.display.Graphics;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import Box2D.Dynamics.b2World;
    import fl.motion.Color;
    import flash.display.DisplayObject;
    import src.Game;
    import src.Player;
    import src.util.Collider;
    import src.util.CreateBodyRequest;

    public class TaskKey extends TaskObject {
        public static const KEY_TYPE:String = "TaskKey";
        
        public static const SHOW_STATE:String = "_show";
        public static const HIDE_STATE:String = "_hide";
        
        public function TaskKey() {
            super();
            costume.setType(KEY_TYPE);
            costume.setState();
        }
        
        override public function update():void {
            super.update();
            var player:Player = game.player;
            var to:TaskObject = player.holdObject;
            
            if ( game.ACTION_PRESSED && is_active ) {
                
                if ( active_area.hitTestObject(player.collider) ) {
                    if ( to ) {
                        if ( !to.is_active ) return;
                        to.costume.setState(HIDE_STATE);
                        to.is_active = false;
                        game.cRoom.addActiveObject(to);
                    }
                    
                    deactivate();
                    player.holdObject = this;
                    costume.setState(HIDE_STATE);
                }
            }
            else if ( !is_active ) {
                if ( costume.visible ) return;
                // else add hold object to player
                if ( player.holdObject == this ) {
                    costume.x = Player.HOLD_OBJECT_X;
                    costume.y = Player.HOLD_OBJECT_Y;
                    is_active = costume.visible = true;
                    costume.setState(SHOW_STATE);
                    player.costume.addChild(costume);
                    game.cRoom.removeActiveObject(this);
                    return;
                }
                else {
                    activate();
                    costume.setState(SHOW_STATE);
                    game.cRoom.addActiveObject(this);
                    costume.visible = true;
                }
            }
            
            if ( body && body.IsActive() ) {
                x = body.GetPosition().x * Game.WORLD_SCALE;
                y = body.GetPosition().y * Game.WORLD_SCALE;
            }
            
        }
        
        public function changePlace():void {
            /*is_active = true;
            //gotoAndPlay("show");
            var player:Player = game.player;
            
            if ( body && costume.parent != player.costume ) {
                player.costume.addChild(costume);
                x = -15;
                y = -30;
                
                body.SetActive(false);
                game.cRoom.removeActiveObject(this);
            }
            else {
                x = player.x + ( playerCollider.width + _collider.width ) * player.dir_x / 2;
                y = player.y + ( playerCollider.height + _collider.height ) * player.dir_y / 2;
                
                if ( player.holdObject == this ) {
                    player.holdObject = null;
                }
                
                game.cRoom.addActiveObject(this);
            }*/
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createBodyReq:CreateBodyRequest = super.requestBodyAt(world);
            
            var fixtureDef:b2FixtureDef = createBodyReq.fixtureDef;
            fixtureDef.density = 0.3;
            fixtureDef.friction = 1;
            createBodyReq.setAsDynamicBody();
            
            createBodyReq.bodyDef.linearDamping = 5;
            
            return createBodyReq;
        }
        
        override public function setTint(color:uint):void {
            var col:Color = new Color();
            col.setTint(color, 0.5);
            var tintObject:DisplayObject = costume.getChildByName("tintObject_mc");
            tintObject.transform.colorTransform = col;
        }
        
        override public function destroy():void {
            super.destroy();
        }
        
    }

}