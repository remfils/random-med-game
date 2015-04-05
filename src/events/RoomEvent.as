package src.events {
    import flash.events.Event;
    
    public class RoomEvent extends Event {
        public static const EXIT_ROOM_EVENT = "exit_room";
        public static const ENEMY_KILL_EVENT = "enemy_kill_event"

        public function RoomEvent(type:String) {
            super(type);
        }

    }
    
}
