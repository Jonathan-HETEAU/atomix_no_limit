package view;

/**
	A round button of the game and molecule views (Java: the `mRectangle` fields). Its box is
	`size` square at x, y; when hovered it moves by `popX`, `popY` (the corner buttons come out of
	the corner). The mouse is tested against the box where the button is now, as in Java.
**/
class IconButton {
	public var x : Float;
	public var y : Float;
	public var size : Float;
	public var hovered(default, null) = false;

	var popX : Float;
	var popY : Float;

	public function new( popX = 0., popY = 0. ) {
		this.popX = popX;
		this.popY = popY;
	}

	/** Places the button, not hovered. **/
	public function place( x : Float, y : Float, size : Float ) {
		this.x = x;
		this.y = y;
		this.size = size;
		hovered = false;
	}

	/** Follows the mouse. Returns whether the button is hovered. **/
	public function hover( mx : Float, my : Float ) : Bool {
		var inside = mx >= x && mx < x + size && my >= y && my < y + size;
		if( inside != hovered ) {
			var s = inside ? 1 : -1;
			x += popX * s;
			y += popY * s;
			hovered = inside;
		}
		return hovered;
	}
}
