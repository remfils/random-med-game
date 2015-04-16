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
	/**
     * ...
     * @author vlad
     */
    public class Key extends TaskObject {
        private var playerCollider:Collider;
        public var _activeArea:MovieClip;
        public var _collider:MovieClip;
        
        public function Key() {
            super();
            _activeArea = getChildByName("activeArea") as MovieClip;
            _collider = getChildByName("collider001") as MovieClip;
            playerCollider = game.player.getCollider();
        }
        
        override public function update():void {
            super.update();
            
            if ( active && playerCollider.checkObjectCollision(_activeArea) ) {
                var player:Player = game.player;
                
                if ( player.ACTION_PRESSED ) {
                    if ( !player.holdObject || player.holdObject == this ) {
                        gotoAndPlay("hide");
                        active = false;
                        player.holdObject = this;
                    }
                }
            }
            
            if ( body && body.IsActive() ) {
                x = body.GetPosition().x * Game.WORLD_SCALE;
                y = body.GetPosition().y * Game.WORLD_SCALE;
            }
            
        }
        
        public function changePlace():void {
            active = true;
            gotoAndPlay("show");
            var player:Player = game.player;
            
            if ( body && parent != player ) {
                player.addChild(this);
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
            }
        }
        
        override public function requestBodyAt(world:b2World, position:Point = null, speed:Point = null):void {
            
            var createBodyRequest:CreateBodyRequest = new CreateBodyRequest(world, _collider);
            
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.density = 0.3;
            fixtureDef.friction = 1;
            createBodyRequest.setAsDynamicBody(fixtureDef);
            
            createBodyRequest.bodyDef.linearDamping = 5;
            createBodyRequest.setBodyPosition( new Point(x + _collider.x, y + _collider.y) );
            
            game.bodyCreator.add(createBodyRequest);
        }
        
        override public function setTint(color:uint):void {
            var col:Color = new Color();
            col.setTint(color, 0.5);
            var tintObject:DisplayObject = getChildByName("tintObject_mc");
            tintObject.transform.colorTransform = col;
        }
        
        override public function destroy():void {
            super.destroy();
        }
        
    }

}