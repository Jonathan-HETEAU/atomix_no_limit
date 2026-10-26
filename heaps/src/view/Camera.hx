package view;

/**
	What part of the board is shown (Java: `AtomixCamera`): `x`, `y` the point of the board at the
	middle of the screen (0 to 1 across it), `zoom` from 1 (all of it) down to 0.01 (closer).
	Dragging the mouse moves it, the wheel zooms.
**/
class Camera {
	static inline var SPEED = 0.002;

	public var x = 0.5;
	public var y = 0.5;
	public var zoom = 1.0;

	/** Where the mouse was at the last `drag`. **/
	var lastX = 0.;
	var lastY = 0.;

	public function new() {}

	public function zoomIn() {
		zoom = Math.max(zoom - 0.01, 0.01);
	}

	public function zoomOut() {
		zoom = Math.min(zoom + 0.01, 1.0);
	}

	/** The mouse was pressed at mx, my: drags start from there. **/
	public function grab( mx : Float, my : Float ) {
		lastX = mx;
		lastY = my;
	}

	/** The mouse moved to mx, my with a button down: the board follows it. **/
	public function drag( mx : Float, my : Float ) {
		x = clamp(x + (lastX - mx) * SPEED * zoom);
		y = clamp(y + (lastY - my) * SPEED * zoom);
		grab(mx, my);
	}

	static function clamp( v : Float ) return Math.max(0, Math.min(1, v));
}
