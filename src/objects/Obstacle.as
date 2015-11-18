package src.objects {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import src.costumes.CostumeEnemy;
    import src.costumes.ObjectCostume;
    import src.enemy.ChargerEnemy;
    import src.Game;
    import src.interfaces.SolidBody;
    import src.interfaces.Updatable;
    import src.interfaces.Update;
    import src.util.CreateBodyRequest;
    import src.util.Collider;
    import src.util.MagicBag;
    import src.util.SoundManager;

    public class Obstacle extends AbstractObject implements Update {
        
        public static const NORMAL_STATE:String = "_stand";
        public static const DESTROY_STATE:String = "_destroy";
        
        public var state:int;
        
        public var is_static:Boolean = false;
        public var extruded:Boolean = false;
        public var has_drop:Boolean = false;
        public var active:Boolean = false;
        public var is_break:Boolean = true;
        
        public function Obstacle() {
            costume = new ObjectCostume();
        }
        
        override public function readXMLParams(paramsXML:XML):void {
            super.readXMLParams(paramsXML);
            costume.setState(NORMAL_STATE);
            
            var type:String = paramsXML.name();
            switch (type) {
                case ObjectCostume.VASE_TYPE:
                    properties = IS_STATIC | IS_EXTRUDED;
                break;
                case ObjectCostume.STONE_TYPE:
                    properties = IS_STATIC | IS_BREAKABLE;
                break;
                case ObjectCostume.BARELL_TYPE:
                    properties = IS_BREAKABLE | HAS_DROP | IS_EXTRUDED;
                    break;
                case ObjectCostume.BOX_TYPE:
                    properties = IS_BREAKABLE | HAS_DROP | IS_ACTIVE;
                    break;
                case ObjectCostume.HOLE_TYPE:
                case ObjectCostume.HOLE_CORNER_TYPE:
                case ObjectCostume.HOLE_TUNNEL_TYPE:
                case ObjectCostume.HOLE_TUNNEL_END_TYPE:
                case ObjectCostume.HOLE_SIDE_TYPE:
                case ObjectCostume.HOLE_SIDE_CORNER_TYPE:
                case ObjectCostume.HOLE_CORNERED_CORNER_TYPE:
                case ObjectCostume.HOLE_CORNERS2_TYPE:
                case ObjectCostume.HOLE_CORNERS3_TYPE:
                case ObjectCostume.HOLE_CORNERS4_TYPE:
                case ObjectCostume.HOLE_CORNERS2_DIAGONAL_TYPE:
                case ObjectCostume.HOLE_EMPTY_TYPE:
                case ObjectCostume.HOLE_CORNERS1_TYPE:
                    properties = IS_STATIC | IS_BULLET_TRANSPARENT;
                    break;
            }
            
            active = !isStatic();
        }
        
        private function setState(state_:int):void {
            state = state_;
            //gotoAndStop(name + STATE_LABELS[state]);
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var createBodyReq:CreateBodyRequest = super.requestBodyAt(world);
            
            createBodyReq.fixtureDef.density = 4;
            createBodyReq.fixtureDef.friction = 1;
            
            createBodyReq.bodyDef.linearDamping = 3;
            
            if ( isStatic() ) createBodyReq.setAsStaticBody();
            else createBodyReq.setAsDynamicBody();
            
            return createBodyReq;
        }
        
        public function update():void {
            if (!active) return;
            
            x = body.GetPosition().x * Game.WORLD_SCALE;
            y = body.GetPosition().y * Game.WORLD_SCALE;
        }
        
        public function breakObject():void {
            if ( !isBreakable() ) return;
            
            active = false;
            body.SetActive(active);
            costume.setState(DESTROY_STATE);
            game.cRoom.addChild(costume);
            
            var break_sound_id:int = 0;
            
            if ( hasDrop() ) {
                var a_o:AbstractObject;
                var rand:Number = Math.random();
                
                if ( rand < 0.15 ) { // drop mana
                    a_o = new MagicBag();
                    MagicBag(a_o).setType(ObjectCostume.SMALLMP_TYPE);
                    MagicBag(a_o).open();
                }
                else if ( rand < 0.3 ) { // drop health
                    a_o = new MagicBag();
                    MagicBag(a_o).setType(ObjectCostume.SMALLHP_TYPE);
                    MagicBag(a_o).open();
                }
                else if ( rand < 0.4 ) { // spawn enemy
                    a_o = new ChargerEnemy();
                    a_o.costume.setType(CostumeEnemy.RAT);
                }
                
                if ( a_o ) {
                    a_o.x = x;
                    a_o.y = y;
                    game.cRoom.add(a_o);
                }
            }
            
            switch ( costume.type ) {
                case ObjectCostume.BARELL_TYPE:
                    break_sound_id = SoundManager.SFX_DESTROY_BARREL;
                    break;
                case ObjectCostume.STONE_TYPE:
                    break_sound_id = SoundManager.SFX_DESTROY_ROCKS1;
                    break;
            }
            
            SoundManager.instance.safePlaySFX(break_sound_id);
        }
        
        override public function destroy():void {
            super.destroy();
        }
        
        public function isActive():Boolean {
            return active;
        }
        
    }

}