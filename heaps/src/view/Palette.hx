package view;

/** The colors of the game: neon colors, like the light of a plasma lamp. **/
class Palette {
	/** The first atom colors, chosen to be told apart easily. **/
	static final ATOMS = [0xFF4FB4, 0x3EE6FF, 0xB8FF4A, 0xFFB238, 0xA070FF, 0xFFF04A, 0x4A86FF, 0xFF5A5A, 0x4AFFB0, 0xE070FF];

	/** Buttons: at rest and under the mouse. **/
	public static inline var BUTTON = 0x5FD8FF;
	public static inline var BUTTON_HOVER = 0xFF7FD8;
	/** Marks of the directions the selected atom can take. **/
	public static inline var ARROW = 0x9CFFC8;
	public static inline var TEXT = 0xFFFFFF;

	/** The color of the atoms of color `i`; past the list, hues spread by the golden angle. **/
	public static function atom( i : Int ) : Int {
		if( i < ATOMS.length )
			return ATOMS[i];
		var hue = (i * 0.618034) % 1.0;
		var light = 0.55 + 0.15 * ((i >> 1) % 2);
		return hsl(hue, 1.0, light);
	}

	public static function hsl( h : Float, s : Float, l : Float ) : Int {
		inline function f( n : Float ) {
			var k = (n + h * 12) % 12;
			var a = s * Math.min(l, 1 - l);
			return l - a * Math.max(-1, Math.min(Math.min(k - 3, 9 - k), 1));
		}
		inline function c( v : Float ) return Std.int(v * 255 + 0.5);
		return (c(f(0)) << 16) | (c(f(8)) << 8) | c(f(4));
	}

	/** Sets the color of a drawable, `alpha` included. **/
	public static function tint( d : h2d.Drawable, color : Int, alpha = 1. ) {
		d.color.set(((color >> 16) & 0xFF) / 255, ((color >> 8) & 0xFF) / 255, (color & 0xFF) / 255, alpha);
	}

	/** Mixes two colors, t from 0 (a) to 1 (b). **/
	public static function mix( a : Int, b : Int, t : Float ) : Int {
		inline function ch( c : Int, s : Int ) return (c >> s) & 0xFF;
		inline function m( s : Int ) return Std.int(ch(a, s) + (ch(b, s) - ch(a, s)) * t);
		return (m(16) << 16) | (m(8) << 8) | m(0);
	}
}
