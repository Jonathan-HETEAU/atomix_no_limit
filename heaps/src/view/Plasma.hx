package view;

/**
	The background of a lava lamp lit like a plasma lamp: a dark gradient, a slow plasma of light,
	and glowing blobs of liquid that rise, merge and fall.
**/
class PlasmaShader extends hxsl.Shader {
	static var SRC = {
		var calculatedUV : Vec2;
		var pixelColor : Vec4;

		@param var time : Float;
		/** Width / height of the screen: the blobs stay round. **/
		@param var ratio : Float;
		@param var top : Vec3;
		@param var bottom : Vec3;
		@param var plasmaA : Vec3;
		@param var plasmaB : Vec3;
		@param var blob : Vec3;
		/** How visible the blobs are, 0 to 1. **/
		@param var blobStrength : Float;

		function fragment() {
			var uv = calculatedUV;
			var p = vec2(uv.x * ratio, uv.y);
			var t = time;
			var col = mix(top, bottom, uv.y);

			var v = sin(p.x * 3.1 + t * 0.31) + sin(p.y * 2.7 - t * 0.23) + sin((p.x + p.y) * 2.2 + t * 0.17)
				+ sin(length(p - vec2(ratio * 0.5 + 0.3 * sin(t * 0.11), 0.5 + 0.3 * cos(t * 0.13))) * 5.0 - t * 0.4);
			v = v * 0.25;
			var plasma = mix(plasmaA, plasmaB, 0.5 + 0.5 * sin(v * 3.14159));
			col += plasma * (0.10 + 0.08 * v);

			var f = 0.0;
			@unroll for( i in 0...8 ) {
				var fi = float(i);
				var phase = fract(fi * 0.618034);
				var speed = 0.035 + 0.025 * fract(fi * 0.37);
				var y = 0.5 + 0.62 * sin(t * speed * 6.2832 + fi * 1.9);
				var x = (0.12 + 0.76 * phase) * ratio + 0.06 * sin(t * 0.27 + fi * 1.7);
				var r = 0.05 + 0.05 * fract(fi * 0.43);
				var d = p - vec2(x, y);
				f += r * r / max(dot(d, d), 0.0001);
			}
			var body = smoothstep(0.85, 1.15, f);
			var halo = clamp(f * 0.35, 0.0, 1.0);
			// The blobs are brighter in their middle, like lit wax.
			var core = smoothstep(1.5, 4.0, f);
			col += blob * blobStrength * (halo * 0.35 + body * 0.45 + core * 0.25);
			pixelColor = vec4(col, 1.0);
		}
	};
}

typedef Theme = {
	var top : Int;
	var bottom : Int;
	var plasmaA : Int;
	var plasmaB : Int;
	var blob : Int;
	var blobStrength : Float;
}

class Plasma extends h2d.Bitmap {
	/** The menu: bright, lively. **/
	public static final MENU : Theme = { top : 0x14062E, bottom : 0x3A0A4A, plasmaA : 0x6A2CFF, plasmaB : 0xFF3CA8, blob : 0xFF5AB8, blobStrength : 1.0 };
	/** The board: darker, so the atoms stand out. **/
	public static final BOARD : Theme = { top : 0x05051A, bottom : 0x12062A, plasmaA : 0x2A3CFF, plasmaB : 0x8A2CFF, blob : 0x6A4CFF, blobStrength : 0.45 };
	/** The molecule: blue green. **/
	public static final MOLECULE : Theme = { top : 0x021A24, bottom : 0x0A0A30, plasmaA : 0x1CC8C8, plasmaB : 0x3A5CFF, blob : 0x2CE0D0, blobStrength : 0.5 };

	var shader : PlasmaShader;
	var time = Math.random() * 100;

	public function new( theme : Theme, ?parent ) {
		super(h2d.Tile.fromColor(0xFFFFFF), parent);
		shader = addShader(new PlasmaShader());
		shader.top.setColor(theme.top);
		shader.bottom.setColor(theme.bottom);
		shader.plasmaA.setColor(theme.plasmaA);
		shader.plasmaB.setColor(theme.plasmaB);
		shader.blob.setColor(theme.blob);
		shader.blobStrength = theme.blobStrength;
	}

	/** Covers w x h pixels and moves on by dt seconds. **/
	public function update( dt : Float, w : Float, h : Float ) {
		time += dt;
		width = w;
		height = h;
		shader.time = time;
		shader.ratio = h > 0 ? w / h : 1;
	}
}
