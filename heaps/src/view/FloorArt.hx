package view;

import view.Art.*;

/**
	The floor of a level as one texture, with all its corners rounded: the outer corners of the
	floor, and the inner ones (the corners of the walls). Each cell has a glassy tile, the edges of
	the floor a bright rim and a glow around them, like a lit liquid.

	The rounding works per quarter of cell: a quarter of floor whose two neighbours on that side
	are walls is cut by a quarter circle; a quarter of wall whose two neighbours are floor gets the
	matching fillet (when the cell across that corner is floor too). The distance to these shapes gives smooth edges.
**/
class FloorArt {
	/** Radius of the rounded corners, in cells. **/
	static inline var RADIUS = 0.42;
	static inline var HALF = 0.5;
	/** The largest texture made. **/
	static inline var MAX_SIZE = 2048;

	static inline var FILL = 0x1A1450;
	static inline var TILE_TOP = 0x3A3290;
	static inline var TILE_BOTTOM = 0x241C6C;
	static inline var RIM = 0x8CEBFF;
	static inline var GLOW = 0x9A5CFF;

	/** Pixels per cell of the last texture made. **/
	public static var cellPixels(default, null) = 48;

	/** The texture of the floor: `width * cellPixels` by `height * cellPixels`. **/
	public static function make( level : model.Level ) : h2d.Tile {
		var p = Std.int(Math.min(48, MAX_SIZE / Math.max(level.width, level.height)));
		cellPixels = p;
		var w = level.width * p, h = level.height * p;
		inline function floor( x : Int, y : Int ) {
			return x >= 0 && y >= 0 && x < level.width && y < level.height && level.floor[x][y];
		}

		// Distance to the edge of the floor, in cells (negative inside): exact within a pixel or
		// two of the edges, which is all the smoothing of the edges needs.
		function distance( px : Float, py : Float ) : Float {
			var cx = Math.floor(px), cy = Math.floor(py);
			var fx = px - cx - HALF, fy = py - cy - HALF;
			var sx = fx < 0 ? -1 : 1, sy = fy < 0 ? -1 : 1;
			var ax = Math.abs(fx), ay = Math.abs(fy);
			var sideX = floor(cx + sx, cy), sideY = floor(cx, cy + sy);
			var inCorner = ax > HALF - RADIUS && ay > HALF - RADIUS;
			var dx = ax - (HALF - RADIUS), dy = ay - (HALF - RADIUS);
			var arc = Math.sqrt(dx * dx + dy * dy) - RADIUS;
			if( floor(cx, cy) ) {
				if( !sideX && !sideY )
					return inCorner ? arc : -Math.min(HALF - ax, HALF - ay);
				var d = HALF;
				if( !sideX ) d = Math.min(d, HALF - ax);
				if( !sideY ) d = Math.min(d, HALF - ay);
				return -d;
			}
			// The fillet only where the floor goes round the corner: two walls touching by a corner
			// stay joined (the floor corners next to them are rounded instead).
			if( sideX && sideY && floor(cx + sx, cy + sy) )
				return inCorner ? -arc : Math.min(HALF - ax, HALF - ay);
			var d = HALF;
			if( sideX ) d = Math.min(d, HALF - ax);
			if( sideY ) d = Math.min(d, HALF - ay);
			return d;
		}

		// The coverage of the floor, then a blurred copy of it for the glow.
		var cover = new haxe.ds.Vector<Float>(w * h);
		for( y in 0...h )
			for( x in 0...w ) {
				var d = distance((x + 0.5) / p, (y + 0.5) / p);
				cover[x + y * w] = Math.max(0, Math.min(1, 0.5 - d * p));
			}
		var glow = blur(cover, w, h, Std.int(p * 0.3));
		// Near the edge, a slightly blurred floor is no longer full: that is where the rim goes,
		// whatever the shape of the edge.
		var near = blur(cover, w, h, Std.int(Math.max(1, p * 0.05)));

		var pixels = hxd.Pixels.alloc(w, h, RGBA);
		for( y in 0...h )
			for( x in 0...w ) {
				var i = x + y * w;
				var c = cover[i];
				// Inside: the floor, its tile and its rim, over the glow outside.
				var fx = (x + 0.5) / p, fy = (y + 0.5) / p;
				var tx = fx - Math.floor(fx) - HALF, ty = fy - Math.floor(fy) - HALF;
				var tileD = roundBox(tx, ty, 0.43, 0.43, 0.2);
				var tile = Math.max(0, Math.min(1, 0.5 - tileD * p)) * 0.85;
				var col = Palette.mix(FILL, Palette.mix(TILE_TOP, TILE_BOTTOM, ty + HALF), tile);
				// A thin light on the top edge of each tile.
				var tileRim = smooth(-0.06, -0.015, tileD) * (1 - smooth(-0.015, 0.0, tileD)) * smooth(0.2, -0.3, ty) * 0.5;
				col = Palette.mix(col, 0xB0A8FF, tileRim);
				var rim = smooth(0.02, 0.4, 1 - near[i]);
				col = Palette.mix(col, RIM, rim * 0.85);
				var inside = 0.82 + 0.18 * rim;
				var g = glow[i] * 0.75 * (1 - c);
				var a = c * inside + g;
				var rgb = c > 0 ? Palette.mix(GLOW, col, Math.min(1, c * inside / Math.max(a, 0.0001))) : GLOW;
				pixels.setPixel(x, y, (Std.int(Math.min(a, 1) * 255) << 24) | rgb);
			}
		return h2d.Tile.fromPixels(pixels);
	}

	/** Three box blurs of radius r: close to a gaussian. **/
	static function blur( src : haxe.ds.Vector<Float>, w : Int, h : Int, r : Int ) : haxe.ds.Vector<Float> {
		var a = new haxe.ds.Vector<Float>(w * h);
		var b = new haxe.ds.Vector<Float>(w * h);
		for( i in 0...w * h )
			a[i] = src[i];
		if( r < 1 )
			return a;
		for( _ in 0...3 ) {
			boxPass(a, b, w, h, r, 1, w);   // rows
			boxPass(b, a, h, w, r, w, 1);   // columns
		}
		return a;
	}

	/** One box blur along lines: `count` lines of `len` values, `step` apart, lines `lineStep` apart. **/
	static function boxPass( src : haxe.ds.Vector<Float>, dst : haxe.ds.Vector<Float>, len : Int, count : Int, r : Int, step : Int, lineStep : Int ) {
		var scale = 1 / (2 * r + 1);
		for( line in 0...count ) {
			var base = line * lineStep;
			var sum = 0.;
			for( k in -r...r + 1 )
				sum += src[base + Std.int(Math.max(0, Math.min(len - 1, k))) * step];
			for( i in 0...len ) {
				dst[base + i * step] = sum * scale;
				var out = Std.int(Math.max(0, i - r));
				var inn = Std.int(Math.min(len - 1, i + r + 1));
				sum += src[base + inn * step] - src[base + out * step];
			}
		}
	}
}
