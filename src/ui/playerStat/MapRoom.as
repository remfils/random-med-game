package src.ui.playerStat {
	
	import flash.display.MovieClip;
	
	
	public class MapRoom extends MovieClip {
		private var status:String = "hidden";
		
		
		public function MapRoom() {
			update();
		}
		
		public function showRoom() {
			status = "visible";
		}
		
		public function setCurrent() {
			status = "current";
		}
		
		public function setEmpty() {
			status = "empty";
		}
		
		public function update() {
			gotoAndStop(status);
		}
	}
	
}
