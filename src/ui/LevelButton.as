package src.ui {
	import flash.text.TextField;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.text.TextFormat;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.events.MouseEvent;
	
	public class LevelButton extends SimpleButton {
		/*var container:Sprite = new Sprite();
		var _label:String;
		var _rating:Number;
		var _stars:Array = new Array();
		var map:GenericLevelButton = new GenericLevelButton();

		public function LevelButton(levelName:String, rating:Number = 0) {
			super();
			_label = levelName;
			_rating = rating;
			
			createButton();
			
			hitTestState = upState = container;
			overState = getOverState();
		}
		
		private function createButton() {
			container.addChild(map);
			
			var tf = getLevelLabel();
			container.addChild(tf);
			
			addStars();
			rateLevel();
		}
		
		private function addStars() {
			var star:Star=new Star(),
				ammendX:Number = (map.width - star.width*3)-4;
			
			for ( var i=0; i<3; i++ ) {
				star = new Star();
				star.gotoAndStop(1);
				star.x = ammendX + star.width * i;
				star.y = map.height;
				_stars.push(star);
				container.addChild(star);
			}
		}
		
		private function getLevelLabel():TextField {
			var tf:TextField = new TextField();
			tf.text = _label;
			tf.x = 0;
			tf.y = -20;
			
			tf.setTextFormat(getLevelNameFormat());
			
			return tf;
		}
		
		private function getLevelNameFormat():TextFormat {
			var tf:TextFormat = new TextFormat();

			tf.color = 0xffffff;
			tf.align = "center";
			tf.size = 15;
			
			return tf;
		}
		
		private function rateLevel() {
			for (var i=0; i<_rating; i++) {
				_stars[i].setScore();
			}
		}
		
		private function getOverState():Sprite {
			var sp:Sprite = container;
			//sp.transform.colorTransform = new ColorTransform(1,1,1);
			return sp;
		}*/

	}
	
}
