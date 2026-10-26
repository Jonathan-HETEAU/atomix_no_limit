package view;

/** The icons drawn on round buttons. **/
enum Icon {
	Menu;
	Molecule;
	Undo;
	Restart;
	/** A rounded triangle pointing up. **/
	Arrow;
}

/**
	The pictures of the game, drawn by code once and kept as textures: bubbles (in three layers,
	so one picture serves every color), glassy pills for buttons and panels, and icons. Each is
	computed pixel by pixel from distances to shapes, which gives smooth edges at any size.
**/
class Art {
	public static inline var BUBBLE = 128;
	public static inline var PILL = 128;
	public static inline var FILAMENT_W = 256;
	public static inline var FILAMENT_H = 128;
	/** Radius of an atom's bubble on the board, in cells. **/
	public static inline var BUBBLE_RADIUS = 0.44;
	/** Corner size of the pill, for `h2d.ScaleGrid`. **/
	public static inline var PILL_BORDER = 62;

	static var cache = new Map<String, h2d.Tile>();

	/**
		The body of a bubble, white: tinted by the color of the atom. Thin and see-through in the
		middle, thicker towards the rim, a little darker at the bottom right.
	**/
	public static function bubbleBody() : h2d.Tile {
		return get("body", () -> raster(BUBBLE, BUBBLE, (x, y) -> {
			var p = centered(x, y, BUBBLE);
			var d = Math.sqrt(p.x * p.x + p.y * p.y);
			var edge = coverage(d - 1, BUBBLE / 2);
			if( edge <= 0 )
				return argb(1, 1, 1, 0);
			var rim = Math.pow(d, 3);
			var shade = 1 - 0.35 * smooth(-0.2, 1.0, (p.x + p.y) * 0.7);
			var outline = smooth(0.9, 1.0, d) * 0.35;
			var light = shade * (0.75 + 0.25 * rim) * (1 - outline);
			var alpha = (0.38 + 0.57 * rim) * edge;
			return argb(light, light, light, alpha);
		}));
	}

	/** The reflections on a bubble: not tinted. **/
	public static function bubbleShine() : h2d.Tile {
		return get("shine", () -> raster(BUBBLE, BUBBLE, (x, y) -> {
			var p = centered(x, y, BUBBLE);
			var d = Math.sqrt(p.x * p.x + p.y * p.y);
			if( d > 1 )
				return argb(1, 1, 1, 0);
			// A wide soft window reflection at the top left, rotated along the bubble.
			var rx = (p.x + 0.36) * 0.7071 + (p.y + 0.38) * 0.7071;
			var ry = -(p.x + 0.36) * 0.7071 + (p.y + 0.38) * 0.7071;
			var e = Math.sqrt(rx * rx / (0.16 * 0.16) + ry * ry / (0.33 * 0.33));
			var a = (1 - smooth(0.55, 1.0, e)) * 0.85;
			// A small one at the bottom right.
			var dx = p.x - 0.42, dy = p.y - 0.46;
			a += (1 - smooth(0.02, 0.11, Math.sqrt(dx * dx + dy * dy))) * 0.45;
			// A thin light along the top of the rim.
			a += smooth(0.86, 0.97, d) * (1 - smooth(0.97, 1.0, d)) * smooth(0.1, -0.7, p.y) * 0.5;
			return argb(1, 1, 1, Math.min(a, 1) * coverage(d - 1, BUBBLE / 2));
		}));
	}

	/** A soft halo around a bubble, added to the picture (tinted). Twice the bubble's size. **/
	public static function glow() : h2d.Tile {
		return get("glow", () -> raster(BUBBLE, BUBBLE, (x, y) -> {
			var p = centered(x, y, BUBBLE);
			var d = Math.sqrt(p.x * p.x + p.y * p.y);
			var a = Math.exp(-d * d * 5) * (1 - smooth(0.8, 1.0, d));
			return argb(1, 1, 1, a);
		}));
	}

	/**
		A rounded glassy panel, white: tinted, and stretched with `h2d.ScaleGrid` (`PILL_BORDER`).
		Lighter at the top, with a bright rim.
	**/
	public static function pill() : h2d.Tile {
		return get("pill", () -> raster(PILL, PILL, (x, y) -> {
			var p = centered(x, y, PILL);
			var d = roundBox(p.x, p.y, 1, 1, 0.97);
			var edge = coverage(d, PILL / 2);
			var rim = smooth(-0.14, -0.02, d);
			var light = 0.55 + 0.25 * smooth(0.6, -0.9, p.y) + 0.45 * rim;
			var alpha = (0.55 + 0.4 * rim) * edge;
			return argb(Math.min(light, 1), Math.min(light, 1), Math.min(light, 1), alpha);
		}));
	}

	/**
		A liquid bridge between two bubbles, white: tinted. The texture spans two cells, the
		bubbles' centers at a quarter and three quarters of its width: the neck is the smooth union
		of the two bubbles, without the bubbles themselves (they are drawn over it).
		`fade`: the alpha goes from 1 on the left half to 0 on the right, to blend two colors.
	**/
	public static function filament( fade : Bool ) : h2d.Tile {
		return get("filament" + fade, () -> raster(FILAMENT_W, FILAMENT_H, (x, y) -> {
			// Cell units: x in -1...1, y in -0.5...0.5.
			var u = (x + 0.5) / FILAMENT_W * 2 - 1, v = (y + 0.5) / FILAMENT_H - 0.5;
			var shape = filamentDistance(u, v);
			var px = FILAMENT_W / 2;
			var cover = coverage(shape, px);
			// Nothing under the bubbles: it starts at their rim, so it seems to come out of them.
			var a = circle(u + 0.5, v, BUBBLE_RADIUS), b = circle(u - 0.5, v, BUBBLE_RADIUS);
			var outside = smooth(-0.025, 0.005, Math.min(a, b));
			var rim = smooth(-0.07, -0.005, shape);
			var light = 0.7 + 0.3 * rim;
			var alpha = cover * outside * (0.65 + 0.35 * rim);
			if( fade )
				alpha *= smooth(0.3, -0.3, u);
			return argb(light, light, light, alpha);
		}));
	}

	/** The light on the top of the bridge: not tinted. Same layout as `filament`. **/
	public static function filamentShine() : h2d.Tile {
		return get("filamentShine", () -> raster(FILAMENT_W, FILAMENT_H, (x, y) -> {
			var u = (x + 0.5) / FILAMENT_W * 2 - 1, v = (y + 0.5) / FILAMENT_H - 0.5;
			var shape = filamentDistance(u, v);
			var a = circle(u + 0.5, v, BUBBLE_RADIUS), b = circle(u - 0.5, v, BUBBLE_RADIUS);
			var outside = smooth(0.0, 0.05, Math.min(a, b));
			// A thin streak just inside the top edge.
			var band = smooth(-0.06, -0.035, shape) * (1 - smooth(-0.025, -0.01, shape));
			var top = v < 0 ? 1. : 0.;
			return argb(1, 1, 1, band * top * outside * 0.8);
		}));
	}

	static function filamentDistance( u : Float, v : Float ) : Float {
		var a = circle(u + 0.5, v, BUBBLE_RADIUS), b = circle(u - 0.5, v, BUBBLE_RADIUS);
		// Polynomial smooth minimum: the two circles melt into each other.
		var k = 0.5;
		var h = Math.max(k - Math.abs(a - b), 0) / k;
		return Math.min(a, b) - h * h * k / 4;
	}

	/** An icon, white with smooth edges. **/
	public static function icon( i : Icon ) : h2d.Tile {
		return get("icon" + i.getName(), () -> raster(BUBBLE, BUBBLE, (x, y) -> {
			var p = centered(x, y, BUBBLE);
			return argb(1, 1, 1, coverage(iconDistance(i, p.x, p.y), BUBBLE / 2));
		}));
	}

	/** Distance to the shape of an icon, in a -1...1 square: negative inside. **/
	static function iconDistance( i : Icon, x : Float, y : Float ) : Float {
		return switch i {
			case Menu:
				// Three rounded bars.
				var d = 1e9;
				for( row in [-0.32, 0., 0.32] )
					d = Math.min(d, roundBox(x, y - row, 0.48, 0.09, 0.09));
				d;
			case Molecule:
				// Three atoms joined by bonds.
				var d = 1e9;
				var atoms = [[-0.36, 0.22], [0.0, -0.28], [0.36, 0.22]];
				for( a in atoms )
					d = Math.min(d, circle(x - a[0], y - a[1], 0.19));
				d = Math.min(d, segment(x, y, -0.36, 0.22, 0.0, -0.28, 0.06));
				d = Math.min(d, segment(x, y, 0.0, -0.28, 0.36, 0.22, 0.06));
				d;
			case Undo:
				// Most of a ring, open at the top right, with a head at its end.
				var ring = arc(x, y, 0.36, 0.09, -Math.PI * 0.5, Math.PI * 1.35);
				var head = triangle(x, y, -0.06, -0.62, -0.06, -0.1, -0.38, -0.36) - 0.04;
				Math.min(ring, head);
			case Restart:
				var ring = arc(x, y, 0.36, 0.09, Math.PI * 0.15, Math.PI * 1.6);
				var head = triangle(x, y, 0.06, -0.62, 0.06, -0.1, 0.38, -0.36) - 0.04;
				Math.min(ring, head);
			case Arrow:
				triangle(x, y, 0, -0.62, 0.55, 0.38, -0.55, 0.38) - 0.12;
		}
	}

	// --- Distances to shapes (negative inside) ---

	public static function circle( x : Float, y : Float, r : Float ) : Float {
		return Math.sqrt(x * x + y * y) - r;
	}

	/** A box of half sizes hw, hh with corners of radius r. **/
	public static function roundBox( x : Float, y : Float, hw : Float, hh : Float, r : Float ) : Float {
		var qx = Math.abs(x) - hw + r, qy = Math.abs(y) - hh + r;
		var ox = Math.max(qx, 0), oy = Math.max(qy, 0);
		return Math.sqrt(ox * ox + oy * oy) + Math.min(Math.max(qx, qy), 0) - r;
	}

	/** A segment with round ends, of half thickness r. **/
	static function segment( x : Float, y : Float, ax : Float, ay : Float, bx : Float, by : Float, r : Float ) : Float {
		var px = x - ax, py = y - ay, dx = bx - ax, dy = by - ay;
		var h = Math.max(0, Math.min(1, (px * dx + py * dy) / (dx * dx + dy * dy)));
		var ex = px - dx * h, ey = py - dy * h;
		return Math.sqrt(ex * ex + ey * ey) - r;
	}

	/** A ring of radius r, half thickness w, from angle a0 to a1 (radians, clockwise from 3 o'clock). **/
	static function arc( x : Float, y : Float, r : Float, w : Float, a0 : Float, a1 : Float ) : Float {
		var a = Math.atan2(y, x);
		while( a < a0 ) a += Math.PI * 2;
		if( a <= a1 )
			return Math.abs(Math.sqrt(x * x + y * y) - r) - w;
		// Round ends.
		var e0 = Math.min(circle(x - Math.cos(a0) * r, y - Math.sin(a0) * r, w), circle(x - Math.cos(a1) * r, y - Math.sin(a1) * r, w));
		return e0;
	}

	static function triangle( x : Float, y : Float, ax : Float, ay : Float, bx : Float, by : Float, cx : Float, cy : Float ) : Float {
		var inside = true;
		var d = 1e9;
		var pts = [[ax, ay], [bx, by], [cx, cy]];
		var sign = 0.;
		for( i in 0...3 ) {
			var p0 = pts[i], p1 = pts[(i + 1) % 3];
			var dx = p1[0] - p0[0], dy = p1[1] - p0[1];
			var px = x - p0[0], py = y - p0[1];
			var h = Math.max(0, Math.min(1, (px * dx + py * dy) / (dx * dx + dy * dy)));
			var ex = px - dx * h, ey = py - dy * h;
			d = Math.min(d, Math.sqrt(ex * ex + ey * ey));
			var cross = dx * py - dy * px;
			if( i == 0 )
				sign = cross;
			else if( cross * sign < 0 )
				inside = false;
		}
		return inside ? -d : d;
	}

	// --- Helpers ---

	/** How much of a pixel is inside, from a distance in -1...1 units and the half size in pixels. **/
	public static inline function coverage( d : Float, halfSize : Float ) : Float {
		return Math.max(0, Math.min(1, 0.5 - d * halfSize));
	}

	public static inline function smooth( e0 : Float, e1 : Float, v : Float ) : Float {
		var t = Math.max(0, Math.min(1, (v - e0) / (e1 - e0)));
		return t * t * (3 - 2 * t);
	}

	public static inline function argb( r : Float, g : Float, b : Float, a : Float ) : Int {
		inline function c( v : Float ) return Std.int(Math.max(0, Math.min(1, v)) * 255 + 0.5);
		return (c(a) << 24) | (c(r) << 16) | (c(g) << 8) | c(b);
	}

	/** The center of pixel x, y in a -1...1 square. **/
	static inline function centered( x : Int, y : Int, size : Int ) : { x : Float, y : Float } {
		return { x : (x + 0.5) / size * 2 - 1, y : (y + 0.5) / size * 2 - 1 };
	}

	public static function raster( w : Int, h : Int, f : Int -> Int -> Int ) : h2d.Tile {
		var pixels = hxd.Pixels.alloc(w, h, RGBA);
		for( y in 0...h )
			for( x in 0...w )
				pixels.setPixel(x, y, f(x, y));
		return h2d.Tile.fromPixels(pixels);
	}

	static function get( key : String, make : Void -> h2d.Tile ) : h2d.Tile {
		var t = cache.get(key);
		if( t == null ) {
			t = make();
			cache.set(key, t);
		}
		return t;
	}
}
