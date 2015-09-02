package src.objects {
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2World;
    import fl.motion.Color;
    import flash.display.DisplayObject;
	import flash.display.MovieClip;
    import flash.geom.Point;
    import src.costumes.Costume;
    import src.Game;
    import src.util.CreateBodyRequest;
	
    public class AbstractObject {
        public static var game:Game;
        public var body:b2Body;
        public var costume:Costume;
        
        public function AbstractObject() {
            super();
        }
        
        public function set x (param:Number):void {
            costume.x = param;
        }
        
        public function get x ():Number {
            return costume.x;
        }
        
        public function set y (param:Number):void {
            costume.y = param;
        }
        
        public function get y ():Number {
            return costume.y;
        }
        
        public function requestBodyAt(world:b2World):CreateBodyRequest {
            var collider:DisplayObject = costume.getCollider();
            
            var createBodyRequest:CreateBodyRequest = new CreateBodyRequest(world, collider, this);
            createBodyRequest.setAsStaticBody();
            
            var sin_rotation:Number = Math.sin(costume.rotation * Math.PI / 180);
            var cos_rotation:Number = Math.cos(costume.rotation * Math.PI / 180);
            
            createBodyRequest.setBodyPosition( new Point(
                        x + collider.x * cos_rotation - collider.y * sin_rotation,
                        y + collider.y * cos_rotation + collider.x * sin_rotation ) );
            
            game.bodyCreator.add(createBodyRequest);
            return createBodyRequest;
        }
        
        public function setPosition(point:Point):void {
            costume.x = point.x;
            costume.y = point.y;
            //body.SetPosition(new b2Vec2(point.x / Game.WORLD_SCALE, point.y / Game.WORLD_SCALE));
        }
        
        public function refreshCostumePosition():void {
            var pos:b2Vec2 = body.GetPosition();
            costume.x = pos.x * Game.WORLD_SCALE;
            costume.y = pos.y * Game.WORLD_SCALE;
        }
        
        public function rotate(angleGrad:Number):void {
            costume.rotation = angleGrad;
            body.SetAngle(angleGrad * Game.TO_RAD);
        }
        
        public function destroy():void {
            game.deleteManager.add(body);
        }
        
        public function setTint(color:uint):void {
            var col:Color = new Color();
            col.setTint(color, 0.3);
            costume.transform.colorTransform = col;
        }
        
        public function readXMLParams(paramsXML:XML):void {
            costume.readXMLParams(paramsXML);
        }
        
        public function getID():int {
            return 0;
        }
        
    }

}