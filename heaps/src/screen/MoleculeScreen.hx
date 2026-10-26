package screen;

import view.Camera;
import view.IconButton;
import view.Palette;
import view.Plasma;

/**
	The molecule to build (Java: `AtomixMoleculeVue`): its atoms as bubbles, joined by bonds. Drag
	to move it, the wheel zooms; a right click or the top right button goes back to the board, the
	top left button opens the menu.
**/
class MoleculeScreen extends Screen {
	var main : Main;
	var camera = new Camera();
	var menuButton = new IconButton(40, 40);
	var gameButton = new IconButton(-40, 40);
	var lastWidth = -1;
	var lastHeight = -1;

	public function new( main : Main ) {
		super(Plasma.MOLECULE);
		this.main = main;
	}

	override function onShow() {
		layoutButtons();
	}

	function layoutButtons() {
		lastWidth = width;
		lastHeight = height;
		menuButton.place(-60, -60, 100);
		gameButton.place(width - 40, -60, 100);
	}

	override function onPush( button : Int ) {
		camera.grab(mouseX, mouseY);
	}

	override function onClick( button : Int ) {
		if( button == Screen.RIGHT ) {
			main.switchView();
			return;
		}
		if( button != Screen.LEFT )
			return;
		if( menuButton.hovered ) {
			menuButton.hover(-1000, -1000);
			main.showMenu();
		} else if( gameButton.hovered ) {
			gameButton.hover(-1000, -1000);
			main.showGame();
		}
	}

	override function onMove() {
		menuButton.hover(mouseX, mouseY);
		gameButton.hover(mouseX, mouseY);
	}

	override function onDrag() {
		camera.drag(mouseX, mouseY);
	}

	override function onWheel( delta : Float ) {
		if( delta > 0 )
			camera.zoomOut();
		else if( delta < 0 )
			camera.zoomIn();
	}

	override function draw() {
		if( width != lastWidth || height != lastHeight )
			layoutButtons();
		var level = main.campaign.game.level;
		var w = level.moleculeWidth(), h = level.moleculeHeight();
		// A margin of half a cell around the molecule, so the bubbles and their glow fit.
		var size = Math.min(width / (w + 0.6), height / (h + 0.6));
		var cell = size / camera.zoom;
		var x0 = width / 2 - (w * size * camera.x) / camera.zoom;
		var y0 = height / 2 - (h * size * camera.y) / camera.zoom;
		// The bonds between neighbour atoms, under them.
		var bond = cell * 0.22;
		for( a in level.molecule )
			for( b in level.molecule )
				if( (b.x == a.x + 1 && b.y == a.y) || (b.y == a.y + 1 && b.x == a.x) ) {
					// From the edge of a bubble to the edge of the other: the bubbles are see-through.
					var gap = 0.33;
					var ax = x0 + (a.x + 0.5 + (b.x - a.x) * gap) * cell, ay = y0 + (a.y + 0.5 + (b.y - a.y) * gap) * cell;
					var bx = x0 + (b.x + 0.5 - (b.x - a.x) * gap) * cell, by = y0 + (b.y + 0.5 - (b.y - a.y) * gap) * cell;
					painter.pill(0xFFFFFF, 0.5, Math.min(ax, bx) - bond / 2, Math.min(ay, by) - bond / 2, Math.abs(bx - ax) + bond, Math.abs(by - ay) + bond);
				}
		for( i => a in level.molecule )
			painter.bubble(Palette.atom(a.color), x0 + (a.x + 0.5) * cell, y0 + (a.y + 0.5) * cell, cell * 0.8, time, i * 1.7, 0.6);
		painter.iconButton(Menu, menuButton.hovered, menuButton.x, menuButton.y, menuButton.size, time);
		painter.iconButton(Molecule, gameButton.hovered, gameButton.x, gameButton.y, gameButton.size, time);
	}
}
