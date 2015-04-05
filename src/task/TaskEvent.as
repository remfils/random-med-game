package src.task {
	import flash.events.Event;
	
	public class TaskEvent extends Event {
		
		public var completed;

		public function TaskEvent( COMPLETED:Boolean ) {
			completed = COMPLETED;
		}

	}
	
}
