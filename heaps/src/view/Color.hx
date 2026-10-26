package view;

/**
	A color as `java.awt.Color` had it: red, green, blue and alpha from 0 to 255, with the same
	`brighter` and `darker`, so the game keeps the colors of the Java version.
**/
@:structInit
class Color {
	static inline var FACTOR = 0.7;

	public static final BLACK : Color = { r : 0, g : 0, b : 0 };
	public static final CYAN : Color = { r : 0, g : 255, b : 255 };
	public static final GREEN : Color = { r : 0, g : 255, b : 0 };
	public static final LIGHT_GRAY : Color = { r : 192, g : 192, b : 192 };

	public var r : Int;
	public var g : Int;
	public var b : Int;
	public var a : Int = 255;

	public function new( r : Int, g : Int, b : Int, a = 255 ) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	/** For `h2d.Graphics.beginFill` and `h2d.Text.textColor`. **/
	public var rgb(get, never) : Int;
	public var alpha(get, never) : Float;

	function get_rgb() return (r << 16) | (g << 8) | b;

	function get_alpha() return a / 255;

	public function brighter() : Color {
		var i = Std.int(1.0 / (1.0 - FACTOR));
		if( r == 0 && g == 0 && b == 0 )
			return new Color(i, i, i, a);
		inline function up( c : Int ) {
			if( c > 0 && c < i ) c = i;
			return Std.int(Math.min(Std.int(c / FACTOR), 255));
		}
		return new Color(up(r), up(g), up(b), a);
	}

	public function darker() : Color {
		return new Color(Std.int(r * FACTOR), Std.int(g * FACTOR), Std.int(b * FACTOR), a);
	}

	/** The color of the atoms of color `i` (and of the menu decoration). **/
	public static function ofAtom( i : Int ) : Color {
		return new Color((i * 28) % 255, (i * 100) % 255, (i * 40) % 255);
	}
}
