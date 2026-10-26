package screen;

import view.Color;

/** An atom floating across the menu. **/
private class Deco {
	static inline var VMAX = 5;
	static inline var VMAX2 = 2;

	public var size = 0;
	public var color : Color;
	public var x = 0;
	public var y = 0;
	var vx = 0;
	var vy = 0;

	public function new( zone : Zone, color : Color ) {
		this.color = color;
		init(zone);
	}

	public function move( zone : Zone ) {
		x += vx;
		y += vy;
		if( !zone.contains(x, y) )
			init(zone);
	}

	/** Starts again from a random side, towards the other side. **/
	function init( zone : Zone ) {
		size = Std.random(50) + 30;
		switch Std.random(4) {
			case 0:
				x = zone.x;
				y = zone.y + Std.random(zone.h);
				vx = 1 + Std.random(VMAX);
				vy = Std.random(VMAX2 * 2) - VMAX2;
			case 1:
				x = zone.x + zone.w;
				y = zone.y + Std.random(zone.h);
				vx = -1 - Std.random(VMAX);
				vy = Std.random(VMAX2 * 2) - VMAX2;
			case 2:
				x = zone.x + Std.random(zone.w);
				y = zone.y;
				vx = Std.random(VMAX2 * 2) - VMAX2;
				vy = 1 + Std.random(VMAX);
			default:
				x = zone.x + Std.random(zone.w);
				y = zone.y + zone.h;
				vx = Std.random(VMAX2 * 2) - VMAX2;
				vy = -1 - Std.random(VMAX);
		}
	}
}

@:structInit
private class Zone {
	public var x : Int;
	public var y : Int;
	public var w : Int;
	public var h : Int;

	public function contains( px : Int, py : Int ) : Bool {
		return px >= x && px < x + w && py >= y && py < y + h;
	}
}

/**
	The menu (Java: `AtomixMenuVue`): atoms floating on black behind three buttons. Continue goes
	back to the view the menu was opened from, Restart starts the campaign again from level 1,
	Quit saves and closes the game (HashLink only: a web page cannot close itself).
**/
class MenuScreen extends Screen {
	/** The atoms move by one step every STEP seconds (Java: a 20 ms timer). **/
	static inline var STEP = 0.02;

	var main : Main;
	var decos : Array<Deco>;
	var zone : Zone = { x : -70, y : -70, w : 870, h : 670 };
	var labels = ["Continuer", "Recommencer" #if hl , "Quitter" #end];
	var hovered = -1;
	var time = 0.;

	public function new( main : Main ) {
		super();
		this.main = main;
		decos = [for( _ in 0...75 ) new Deco(zone, Color.ofAtom(Std.random(10) + 1))];
	}

	/** The box of button i. **/
	function button( i : Int ) {
		return { x : Std.int(width * 0.5) - 200, y : Std.int(height * [0.2, 0.5, 0.8][i]), w : 400, h : 100 };
	}

	override function onMove() {
		hovered = -1;
		for( i in 0...labels.length ) {
			var b = button(i);
			if( mouseX >= b.x && mouseX < b.x + b.w && mouseY >= b.y && mouseY < b.y + b.h )
				hovered = i;
		}
	}

	override function onClick( button : Int ) {
		if( button != Screen.LEFT )
			return;
		var choice = hovered;
		hovered = -1;
		switch choice {
			case 0: main.showMenu();
			case 1: main.restartCampaign();
			case 2: main.quit();
			default:
		}
	}

	override function update( dt : Float ) {
		zone.x = zone.y = -75;
		zone.w = width + 75;
		zone.h = height + 75;
		time += dt;
		while( time >= STEP ) {
			time -= STEP;
			for( d in decos )
				d.move(zone);
		}
		super.update(dt);
	}

	override function draw() {
		painter.fillRect(Color.BLACK, 0, 0, width, height);
		for( d in decos )
			painter.drawColorAtom(d.color, d.x, d.y, d.size);
		for( i => label in labels ) {
			var b = button(i);
			painter.drawMenuButton(hovered == i, b.x, b.y, b.w, b.h, label);
		}
	}
}
