package view;

/**
	Draws the game the way the Java version did (Java: `AtomixPainter`): atoms are two circles,
	buttons are atoms with a symbol, the floor is cyan. Everything is drawn again each frame, in
	order, like a `paint(Graphics)`: call `begin` first. Texts are `h2d.Text` objects; what is drawn
	after a text goes on a new layer above it, so the order of the calls is kept.
**/
class Painter {
	/** The colors of the floor and of the buttons: [hovered][0] border, [hovered][1] inside. **/
	static final BUTTON : Array<Array<Color>> = [
		[new Color(0, 255, 255, 100).darker(), new Color(0, 255, 255, 100)],
		[Color.CYAN.darker(), Color.CYAN],
	];
	static inline var FONT_SIZE = 64;

	var root : h2d.Object;
	var layers : Array<h2d.Graphics> = [];
	var texts : Array<h2d.Text> = [];
	var usedLayers = 0;
	var usedTexts = 0;
	var g : h2d.Graphics;
	var font : h2d.Font;
	/** Not shown: measures texts. **/
	var measure : h2d.Text;
	/** The atom colors of the level: [color][0] border, [1] inside, [2] brighter. **/
	var atomColors : Array<Array<Color>> = [];

	public function new( root : h2d.Object ) {
		this.root = root;
		font = hxd.Res.font.bold.toFont();
		measure = new h2d.Text(font);
	}

	/** Starts a new picture. **/
	public function begin() {
		root.removeChildren();
		usedLayers = usedTexts = 0;
		newLayer();
	}

	/** Prepares the colors of a level with `count` colors. **/
	public function setColorCount( count : Int ) {
		if( atomColors.length == count )
			return;
		atomColors = [for( i in 0...count ) {
			var c = Color.ofAtom(i);
			var c1 = c.brighter();
			[c, c1, c1.brighter()];
		}];
	}

	public function fillRect( color : Color, x : Float, y : Float, w : Float, h : Float ) {
		g.beginFill(color.rgb, color.alpha);
		g.drawRect(x, y, w, h);
		g.endFill();
	}

	/** Like Java's `fillOval`: the ellipse in the box x, y, w, h (circles only here). **/
	public function fillOval( color : Color, x : Float, y : Float, w : Float, h : Float ) {
		g.beginFill(color.rgb, color.alpha);
		g.drawEllipse(x + w / 2, y + h / 2, w / 2, h / 2);
		g.endFill();
	}

	/** Like Java's `fillRoundRect`: `arc` is the diameter of the corners. **/
	public function fillRoundRect( color : Color, x : Float, y : Float, w : Float, h : Float, arc : Float ) {
		g.beginFill(color.rgb, color.alpha);
		g.drawRoundedRect(x, y, w, h, Math.min(arc / 2, Math.min(w, h) / 2));
		g.endFill();
	}

	/**
		Like Java's `fillArc`: a pie in the box x, y, size, size, from `start` degrees for `extent`
		degrees, counterclockwise from 3 o'clock (Heaps turns clockwise: mirrored here).
	**/
	public function fillArc( color : Color, x : Float, y : Float, size : Float, start : Float, extent : Float ) {
		g.beginFill(color.rgb, color.alpha);
		var r = size / 2;
		g.drawPie(x + r, y + r, r, hxd.Math.degToRad(-(start + extent)), hxd.Math.degToRad(extent));
		g.endFill();
	}

	/**
		A text in the bold font, `size` pixels high, its baseline at `baseline`. Returns its width.
		`centerX`: x is the middle of the text instead of its left.
	**/
	public function text( s : String, color : Color, x : Float, baseline : Float, size : Float, centerX = false ) : Float {
		var t = texts[usedTexts];
		if( t == null ) {
			t = new h2d.Text(font);
			t.smooth = true;
			texts.push(t);
		}
		usedTexts++;
		root.addChild(t);
		var scale = size / FONT_SIZE;
		t.text = s;
		t.textColor = color.rgb;
		t.alpha = color.alpha;
		t.setScale(scale);
		var w = t.textWidth * scale;
		t.setPosition(centerX ? x - w / 2 : x, baseline - font.baseLine * scale);
		newLayer();
		return w;
	}

	/** Width of a text drawn with `text`. **/
	public function textWidth( s : String, size : Float ) : Float {
		measure.text = s;
		return measure.textWidth * size / FONT_SIZE;
	}

	public function drawAtom( color : Int, selected : Bool, x : Float, y : Float, size : Float ) {
		var decal = Std.int(size * 0.05);
		var i = selected ? 1 : 0;
		fillOval(atomColors[color][i], x, y, size, size);
		fillOval(atomColors[color][i + 1], x + decal, y + decal, size - 2 * decal, size - 2 * decal);
	}

	/** An atom of any color (menu decoration, buttons). **/
	public function drawColorAtom( color : Color, x : Float, y : Float, size : Float ) {
		fillOval(color.darker(), x, y, size, size);
		var decal = Std.int(size * 0.05);
		fillOval(color, x + decal, y + decal, size - 2 * decal, size - 2 * decal);
	}

	public function drawFloor( x : Float, y : Float, size : Float ) {
		fillRect(BUTTON[1][0], x, y, size, size);
	}

	/** A button of the main menu. **/
	public function drawMenuButton( hovered : Bool, x : Float, y : Float, width : Float, height : Float, label : String ) {
		var decal = Std.int(Math.min(height, width) * 0.1);
		var c = BUTTON[hovered ? 1 : 0];
		fillRoundRect(c[0], x, y, width, height, 90);
		fillRoundRect(c[1], x + decal, y + decal, width - decal * 2, height - decal * 2, 90);
		text(label, c[0], x + width * 0.5, y + height - decal * 4, height - decal * 6, true);
	}

	/** The number of the level, centered on x, y. **/
	public function drawLevelNumber( number : Int, x : Float, y : Float, height : Float ) {
		var s = Std.string(number);
		var width = textWidth(s, height);
		x -= width / 2;
		y -= height / 2;
		fillRoundRect(BUTTON[1][0], x - width * 0.3, y - height * 0.3, width * 1.6, height * 1.6, 25);
		fillRoundRect(BUTTON[1][1], x - width * 0.2, y - height * 0.2, width * 1.4, height * 1.4, 25);
		text(s, BUTTON[1][0], x, y + height * 1.1, height);
	}

	/** The mark of a direction the selected atom can take, in the cell next to it. **/
	public function drawArrow( color : Color, x : Float, y : Float, size : Float, dir : Int ) {
		var start = [55, 235, 145, 325][dir];
		fillArc(color, x, y, size, start, 70);
		fillArc(color.darker(), x, y, size, start + 15, 40);
	}

	public function drawMenuIcon( color : Color, x : Float, y : Float, size : Float ) {
		drawColorAtom(color, x, y, size);
		var s = Std.int(size * 0.33);
		fillRect(color.darker(), x + s, y + s, s, s);
	}

	public function drawMoleculeIcon( color : Color, x : Float, y : Float, size : Float ) {
		drawColorAtom(color, x, y, size);
		for( dx in [0.2, 0.4, 0.6] )
			fillOval(color.darker(), x + size * dx, y + size * 0.4, size * 0.2, size * 0.2);
	}

	public function drawUndoIcon( color : Color, x : Float, y : Float, size : Float ) {
		drawColorAtom(color, x, y, size);
		fillArc(color.darker(), x - size * 0.25, y, size, 315, 90);
	}

	public function drawRestartIcon( color : Color, x : Float, y : Float, size : Float ) {
		drawColorAtom(color, x, y, size);
		fillOval(color.darker(), x + size * 0.15, y + size * 0.15, size * 0.7, size * 0.7);
		fillOval(color, x + size * 0.25, y + size * 0.15, size * 0.5, size * 0.5);
		fillArc(color.darker(), x, y - size * 0.25, size * 0.8, 300, 60);
	}

	function newLayer() {
		g = layers[usedLayers];
		if( g == null ) {
			g = new h2d.Graphics();
			layers.push(g);
		}
		usedLayers++;
		g.clear();
		root.addChild(g);
	}
}
