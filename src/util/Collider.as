package src.util {

    import Box2D.Collision.Shapes.b2PolygonShape;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2BodyDef;
    import Box2D.Dynamics.b2Fixture;
    import Box2D.Dynamics.b2FixtureDef;
    import Box2D.Dynamics.b2World;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import src.Game;
    import src.Main;
    import flash.display.DisplayObject;


    public class Collider extends MovieClip {
        public var unlocked:Boolean = true;
        
        protected var top_left:Point;
        protected var bottom_right:Point;

        //создаём коллайдер
        public function Collider () {
            this.visible = Game.TEST_MODE;
        }
        
        public function replaceWithStaticB2Body(world:b2World, userData:Object = null):b2Body {
            var bodyDef:b2BodyDef = new b2BodyDef();
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            
            return replaceWithB2Body(world, bodyDef, fixtureDef, userData);
        }
        
        public function replaceWithDynamicB2Body(world:b2World, fixtureDef:b2FixtureDef, userData:Object = null):b2Body {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.type = b2Body.b2_dynamicBody;
            bodyDef.fixedRotation = true;
            
            return replaceWithB2Body(world, bodyDef, fixtureDef, userData);
        }
        
        public function replaceWithSensor(world:b2World, userData:Object = null ):b2Body {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.type = b2Body.b2_staticBody;
            
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.isSensor = true;
            
            return replaceWithB2Body(world, bodyDef, fixtureDef, userData);
        }
        
        public function replaceWithDynamicSensor(world:b2World, userData:Object = null):b2Body {
            var bodyDef:b2BodyDef = new b2BodyDef();
            bodyDef.type = b2Body.b2_dynamicBody;
            
            var fixtureDef:b2FixtureDef = new b2FixtureDef();
            fixtureDef.isSensor = true;
            
            return replaceWithB2Body(world, bodyDef, fixtureDef, userData);
        }
        
        public function replaceWithB2Body(world:b2World, bodyDef:b2BodyDef, fixtureDef:b2FixtureDef, userData:Object = null):b2Body {
            var position:Point = new Point(getGlobalX(), getGlobalY());
            bodyDef.position.Set( position.x / Game.WORLD_SCALE, position.y / Game.WORLD_SCALE);
            
            var shape:b2PolygonShape = new b2PolygonShape();
            shape.SetAsBox(width / 2 / Game.WORLD_SCALE, height / 2 / Game.WORLD_SCALE);
            
            fixtureDef.shape = shape;
            
            if ( fixtureDef.userData == null )
                fixtureDef.userData = userData;
            
            var body:b2Body = world.CreateBody(bodyDef);
            body.CreateFixture(fixtureDef);
            
            if (parent != null) parent.removeChild(this);
            return body;
        }
        
        public function copy():Collider {
            var result:Collider = new Collider();
            result.width = this.width;
            result.height = this.height;
            result.rotation = this.rotation;
            result.x = this.x;
            result.y = this.y;
            if (parent) {
                parent.addChild(result);
            }
            return result;
        }
        
        public function isActive():Boolean {
            return unlocked;
        }

        // разблокирываем коллайдер
        public function unlock () {
            unlocked = true;
        }

        // блокируем коллайдер
        public function lock () {
            unlocked = false;
        }
        
        public function checkObjectCollision (O:DisplayObject):Boolean {
            return unlocked && this.hitTestObject(O);
        }

        // проверка столкновений
        public function checkCollision ( X:Number, Y:Number ):Boolean {
            return unlocked && this.hitTestPoint( X, Y );
        }
        
        public function getCollider ():Collider {
            return this;
        }
        
        public function getGlobalX():Number {
            return localToGlobal(new Point(0,0)).x;
        }
        
        public function getGlobalY():Number {
            return localToGlobal(new Point(0,0)).y;
        }

    }

}