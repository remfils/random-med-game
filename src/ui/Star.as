package src.ui {
	
	import flash.display.MovieClip;
	
	
	public class Star extends MovieClip {
		
		
		public function Star() {
			gotoAndStop(1);
		}
		
		public function setScore() {
			gotoAndStop("score");
		}
	}
	
}
