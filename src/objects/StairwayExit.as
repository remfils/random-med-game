package src.objects {
    import Box2D.Collision.b2Point;
    import Box2D.Collision.Shapes.b2PolygonShape;
    import Box2D.Collision.Shapes.b2Shape;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import flash.display.DisplayObject;
    import flash.geom.Point;
    import src.costumes.ActiveObjectCostume;
    import src.costumes.PlayerCostume;
    import src.Game;
    import src.interfaces.Update;
    import src.Player;
    import src.util.CreateBodyRequest;


    public class StairwayExit extends AbstractObject implements Update {
        
        var active_area:DisplayObject;
        
        public function StairwayExit() {
            super();
            
            var c:ActiveObjectCostume = new ActiveObjectCostume();
            c.setType(ActiveObjectCostume.STAIRWAY_TYPE);
            c.setState();
            
            active_area = c.getActiveArea();
            
            costume = c;
        }
        
        override public function requestBodyAt(world:b2World):CreateBodyRequest {
            var req:CreateBodyRequest = super.requestBodyAt(world);
            
            var shape:b2PolygonShape = new b2PolygonShape();
            shape.SetAsOrientedBox(costume.costume_collider.width / 2 / Game.WORLD_SCALE, costume.costume_collider.height / 2 / Game.WORLD_SCALE, new b2Vec2(140 / Game.WORLD_SCALE, 0));
            
            var fixture_def:b2FixtureDef = new b2FixtureDef();
            fixture_def.shape = shape;
            
            req.fixture_defs.push(fixture_def);
            
            req.setAsStaticBody();
            
            return req;
        }
        
        public function update():void {
            var player:Player = game.player;
            
            if ( active_area.hitTestObject(player.collider) ) {
                if ( player.y > y - costume.height + 10 ) {
                    player.costume.scaleX = player.costume.scaleY = 0.5 * (player.y - y) / costume.height + 1.5;
                    
                    if ( player.y > y - costume.height * 0.5 ) {
                        game.finishLevel();
                        player.costume.setType(PlayerCostume.STAND_TYPE);
                        player.costume.setState(Player.DIR_DOWN_STATE);
                    }
                }
                else {
                    player.costume.scaleX = player.costume.scaleY = 1;
                }
            }
        }
    }

}