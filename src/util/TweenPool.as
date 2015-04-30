package src.util {
    import fl.transitions.Tween;
    import fl.transitions.TweenEvent;

    public final class TweenPool extends AbstractManager {
        
        private static const MAX_ELEMENTS:int = 3;
        
        private static var _pool:Array;
        private static var _counter:int;
        
        public static function init():void {
            _pool = new Array();
            _counter = -1;
        }
        
        public static function getTween( obj:Object, prop:String, func:Function, begin:Number, finish:Number, duration:Number):Tween {
            var tween:Tween;
            
            trace("requested Tween. Tween pool has ", _pool.length, "items");
            
            if (_counter < 0) {
                tween = new Tween(obj, prop, func, begin, finish, duration);
                _pool[_counter++] = tween;
            }
            else {
                tween = _pool[--_counter];
                
                tween.obj = obj;
                tween.prop = prop;
                tween.func = func;
                tween.begin = begin;
                tween.continueTo(finish, duration);
            }
            
            tween.addEventListener(TweenEvent.MOTION_FINISH, releaseTween);
            return tween;
        }
        
        public static function releaseTween(e:TweenEvent):void {
            var tween:Tween = Tween(e.target);
            tween.removeEventListener(TweenEvent.MOTION_FINISH, releaseTween);
            _pool[_counter++] = tween;
        }
        
        {init();}
    }

}