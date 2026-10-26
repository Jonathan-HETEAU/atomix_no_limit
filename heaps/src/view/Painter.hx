package view;

import view.Art.Icon;

/**
	Draws the views each frame, in order, like a `paint(Graphics)` (Java: `AtomixPainter`): bubbles,
	glassy buttons and pills, icons, texts. Call `begin` first. The objects are kept from a frame
	to the next and reused in the same order.
**/
class Painter {
	static inline var FONT_SIZE = 64;

	var root : h2d.Object;
	var font : h2d.Font;
	/** Not shown: measures texts. **/
	var measure : h2d.Text;

	var bitmaps = new Pool<h2d.Bitmap>(() -> new h2d.Bitmap());
	var grids = new Pool<h2d.ScaleGrid>(() -> new h2d.ScaleGrid(Art.pill(), Art.PILL_BORDER, Art.PILL_BORDER));
	var texts : Pool<h2d.Text>;

	public function new( root : h2d.Object ) {
		this.root = root;
		font = hxd.Res.font.round.toFont();
		measure = new h2d.Text(font);
		texts = new Pool(() -> {
			var t = new h2d.Text(font);
			t.smooth = true;
			t;
		});
	}

	/** Starts a new picture. **/
	public function begin() {
		root.removeChildren();
		bitmaps.reset();
		grids.reset();
		texts.reset();
	}

	/** A picture centered on cx, cy, `size` pixels wide, tinted. **/
	public function sprite( tile : h2d.Tile, color : Int, alpha : Float, cx : Float, cy : Float, size : Float, ?rotation = 0., ?add = false, ?scaleX = 1., ?scaleY = 1. ) {
		var b = bitmaps.next();
		b.tile = tile;
		tile.setCenterRatio();
		b.smooth = true;
		b.blendMode = add ? Add : Alpha;
		Palette.tint(b, color, alpha);
		b.setPosition(cx, cy);
		b.rotation = rotation;
		b.scaleX = size / tile.width * scaleX;
		b.scaleY = size / tile.height * scaleY;
		root.addChild(b);
	}

	/**
		A bubble of `color`, `size` pixels wide, centered on cx, cy. `time` and `seed` make it
		wobble a little, each bubble at its own pace; `glow` from 0 (none) to 1 (selected).
	**/
	public function bubble( color : Int, cx : Float, cy : Float, size : Float, time : Float, seed : Float, glow = 0.5 ) {
		var w = Math.sin(time * 2.1 + seed * 7.3) * 0.035;
		sprite(Art.glow(), color, 0.25 + 0.5 * glow, cx, cy, size * (1.7 + 0.3 * glow), 0, true);
		sprite(Art.bubbleBody(), color, 1, cx, cy, size, 0, false, 1 + w, 1 - w);
		sprite(Art.bubbleShine(), 0xFFFFFF, 0.9, cx, cy, size, 0, false, 1 + w, 1 - w);
	}

	/** A round glassy button with an icon: x, y its top left corner. **/
	public function iconButton( icon : Icon, hovered : Bool, x : Float, y : Float, size : Float, time : Float ) {
		var color = hovered ? Palette.BUTTON_HOVER : Palette.BUTTON;
		var r = size / 2;
		bubble(color, x + r, y + r, size, time, x * 0.01 + y * 0.013, hovered ? 1 : 0.4);
		sprite(Art.icon(icon), 0xFFFFFF, 0.95, x + r, y + r, size * 0.62);
	}

	/** A glassy rounded panel, tinted. **/
	public function pill( color : Int, alpha : Float, x : Float, y : Float, w : Float, h : Float ) {
		var g = grids.next();
		// The corners must fit: below the size of the borders, the grid is scaled down.
		var s = Math.min(1, Math.min(w, h) / (Art.PILL_BORDER * 2));
		g.setScale(s);
		g.width = w / s;
		g.height = h / s;
		g.smooth = true;
		Palette.tint(g, color, alpha);
		g.setPosition(x, y);
		root.addChild(g);
	}

	/** A button of the menu: a glowing pill with its label. **/
	public function menuButton( hovered : Bool, x : Float, y : Float, w : Float, h : Float, label : String ) {
		var color = hovered ? Palette.BUTTON_HOVER : Palette.BUTTON;
		var glow = h * 0.5;
		sprite(Art.glow(), color, hovered ? 0.8 : 0.35, x + w / 2, y + h / 2, w + glow * 2, 0, true, 1, (h + glow * 2) / (w + glow * 2));
		pill(color, hovered ? 0.95 : 0.7, x, y, w, h);
		text(label, Palette.TEXT, x + w / 2, y + h * 0.5 + h * 0.4 * 0.36, h * 0.42, true);
	}

	/** The number of the level in a pill, centered on x, y. **/
	public function levelNumber( number : Int, x : Float, y : Float, height : Float ) {
		var s = Std.string(number);
		var w = textWidth(s, height) + height * 1.2;
		var h = height * 1.3;
		pill(Palette.BUTTON, 0.6, x - w / 2, y - h / 2, w, h);
		text(s, Palette.TEXT, x, y + height * 0.36, height, true);
	}

	/**
		A text, `size` pixels high (the size of the font), its baseline at `baseline`. `centerX`:
		x is the middle of the text instead of its left. Returns its width.
	**/
	public function text( s : String, color : Int, x : Float, baseline : Float, size : Float, centerX = false, alpha = 1. ) : Float {
		var t = texts.next();
		var scale = size / FONT_SIZE;
		t.text = s;
		t.textColor = color;
		t.alpha = alpha;
		t.dropShadow = { dx : 0, dy : 2 / scale, color : 0x200040, alpha : 0.5 };
		t.setScale(scale);
		var w = t.textWidth * scale;
		t.setPosition(centerX ? x - w / 2 : x, baseline - font.baseLine * scale);
		root.addChild(t);
		return w;
	}

	/** Width of a text drawn with `text`. **/
	public function textWidth( s : String, size : Float ) : Float {
		measure.text = s;
		return measure.textWidth * size / FONT_SIZE;
	}
}

/** Objects reused from a frame to the next. **/
private class Pool<T> {
	var items : Array<T> = [];
	var used = 0;
	var make : Void -> T;

	public function new( make : Void -> T ) {
		this.make = make;
	}

	public function reset() {
		used = 0;
	}

	public function next() : T {
		if( used == items.length )
			items.push(make());
		return items[used++];
	}
}
