package screen;

import view.Palette;
import view.Plasma;

/** A bubble rising through the menu, like the wax of a lava lamp. **/
private class Deco {
	public var x = 0.;
	public var y = 0.;
	public var size = 0.;
	public var color = 0;
	public var seed = 0.;
	var speed = 0.;
	var sway = 0.;

	public function new( w : Float, h : Float ) {
		init(w, h);
		// The first ones are spread over the screen, not all at the bottom.
		y = Math.random() * h;
	}

	public function move( dt : Float, time : Float, w : Float, h : Float ) {
		y -= speed * dt;
		x += Math.sin(time * 0.8 + seed) * sway * dt;
		if( y < -size )
			init(w, h);
	}

	function init( w : Float, h : Float ) {
		size = 20 + Math.random() * 70;
		x = Math.random() * w;
		y = h + size;
		// Big bubbles are slower, as in a lava lamp.
		speed = 25 + 60 * (1 - (size - 20) / 70) + Math.random() * 20;
		sway = 10 + Math.random() * 25;
		color = Palette.atom(Std.random(10));
		seed = Math.random() * 10;
	}
}

/**
	The menu (Java: `AtomixMenuVue`): bubbles rising behind the title and the buttons. Continue goes
	back to the view the menu was opened from, Restart starts the campaign again from level 1, Quit
	saves and closes the game (HashLink only: a web page cannot close itself).
**/
class MenuScreen extends Screen {
	var main : Main;
	var decos : Array<Deco> = [];
	var labels = ["Continuer", "Recommencer" #if hl , "Quitter" #end];
	var hovered = -1;

	public function new( main : Main ) {
		super(Plasma.MENU);
		this.main = main;
	}

	/** The box of button i. **/
	function button( i : Int ) {
		var w = Math.min(400, width - 40);
		return { x : (width - w) / 2, y : height * (0.42 + 0.17 * i), w : w, h : 90. };
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
		if( decos.length == 0 && width > 0 )
			decos = [for( _ in 0...40 ) new Deco(width, height)];
		for( d in decos )
			d.move(dt, time, width, height);
		super.update(dt);
	}

	override function draw() {
		for( d in decos )
			painter.bubble(d.color, d.x, d.y, d.size, time, d.seed, 0.45);
		var titleSize = Math.min(96, width / 7);
		painter.text("Atomix", 0xFFFFFF, width / 2, height * 0.2, titleSize, true);
		painter.text("NoLimit", Palette.BUTTON_HOVER, width / 2, height * 0.2 + titleSize * 0.75, titleSize * 0.55, true);
		for( i => label in labels ) {
			var b = button(i);
			painter.menuButton(hovered == i, b.x, b.y, b.w, b.h, label);
		}
	}
}
