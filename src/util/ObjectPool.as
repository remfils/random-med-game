package src.util {
    import fl.transitions.Tween;
    import fl.transitions.TweenEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    public final class ObjectPool extends AbstractManager {
        
        private static var _tween_pool:Vector.<Tween>;
        private static var _timer_pool:Vector.<Timer>;
        
        public static function init():void {
            _tween_pool = new Vector.<Tween>();
            _timer_pool = new Vector.<Timer>();
        }
        
        public static function getTween( obj:Object, prop:String, func:Function, begin:Number, finish:Number, duration:Number):Tween {
            var tween:Tween;
            
            if (!_tween_pool.length) { // fixme
                tween = new Tween(obj, prop, func, begin, finish, duration);
            }
            else {
                tween = _tween_pool.pop();
                tween.obj = obj;
                tween.prop = prop;
                tween.begin = begin;
                tween.finish = finish
                tween.duration = duration;
                tween.func = func;
                tween.start();
            }
            
            tween.addEventListener(TweenEvent.MOTION_FINISH, releaseTween);
            return tween;
        }
        
        private static function releaseTween(e:TweenEvent):void {
            var tween:Tween = Tween(e.target);
            tween.removeEventListener(TweenEvent.MOTION_FINISH, releaseTween);
            tween.stop();
            _tween_pool.push(tween);
        }
        
        public static function getTimer(delay_:Number):Timer {
            var timer:Timer;
            
            if ( _timer_pool.length ) {
                timer = _timer_pool.pop();
                timer.delay = delay_;
            }
            else {
                timer = new Timer(delay_, 1);
            }
            
            timer.addEventListener(TimerEvent.TIMER_COMPLETE, releaseTimer);
            timer.start();
            
            return timer;
        }
        
        private static function releaseTimer(e:TimerEvent):void {
            var timer:Timer = e.target as Timer;
            timer.removeEventListener(TimerEvent.TIMER_COMPLETE, releaseTimer);
            timer.reset();
            timer.stop();
            _timer_pool.push(timer);
        }
        
        {init();}
    }

}