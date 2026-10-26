package screen;

import view.Painter;
import view.Plasma;

/**
	A view of the game (Java: the `JPanel`s shown by the `CardLayout`): its own 2D scene, kept while
	another view is shown, drawn again each frame by `draw`. The mouse comes as presses, releases,
	clicks (released without moving, like Java's `mouseClicked`), drags and wheel turns, in pixels
	of the window (the scene is not scaled).
**/
class Screen {
	public static inline var LEFT = 0;
	public static inline var RIGHT = 1;
	/** How far the mouse may move between press and release for a click. **/
	static inline var CLICK_DISTANCE = 4;

	public var scene(default, null) : h2d.Scene;

	var painter : Painter;
	/** The animated background. **/
	var background : Plasma;
	/** Between the background and what `painter` draws: what is kept between frames. **/
	var layer : h2d.Object;
	/** Seconds since the view was created: animations. **/
	var time = 0.;
	var mouseX = 0.;
	var mouseY = 0.;
	var buttonsDown = new Map<Int, Bool>();
	var pushX = 0.;
	var pushY = 0.;

	public function new( theme : view.Plasma.Theme ) {
		scene = new h2d.Scene();
		scene.addEventListener(onEvent);
		background = new Plasma(theme, scene);
		layer = new h2d.Object(scene);
		painter = new Painter(new h2d.Object(scene));
	}

	public var width(get, never) : Int;
	public var height(get, never) : Int;

	function get_width() return scene.width;

	function get_height() return scene.height;

	/** The view is shown again. **/
	public function onShow() {}

	/** Every frame: `dt` in seconds. **/
	public function update( dt : Float ) {
		time += dt;
		background.update(dt, width, height);
		painter.begin();
		draw();
	}

	function draw() {}

	function onPush( button : Int ) {}

	function onClick( button : Int ) {}

	function onMove() {}

	function onDrag() {}

	function onWheel( delta : Float ) {}

	function isDown( button : Int ) : Bool {
		return buttonsDown.exists(button);
	}

	function onEvent( e : hxd.Event ) {
		mouseX = e.relX;
		mouseY = e.relY;
		switch e.kind {
			case EPush:
				buttonsDown.set(e.button, true);
				pushX = mouseX;
				pushY = mouseY;
				onPush(e.button);
			case ERelease, EReleaseOutside:
				var wasDown = buttonsDown.remove(e.button);
				if( wasDown && e.kind == ERelease && Math.abs(mouseX - pushX) <= CLICK_DISTANCE && Math.abs(mouseY - pushY) <= CLICK_DISTANCE )
					onClick(e.button);
			case EMove:
				if( buttonsDown.keys().hasNext() )
					onDrag();
				onMove();
			case EWheel:
				onWheel(e.wheelDelta);
			default:
		}
	}
}
