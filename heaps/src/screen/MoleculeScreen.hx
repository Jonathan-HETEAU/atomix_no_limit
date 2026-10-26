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
		// The bonds between neighbour atoms: the same liquid filaments as on the board.
		for( a in level.molecule )
			for( b in level.molecule )
				if( (b.x == a.x + 1 && b.y == a.y) || (b.y == a.y + 1 && b.x == a.x) )
					painter.filament(Palette.atom(a.color), Palette.atom(b.color), x0 + (a.x + 0.5) * cell, y0 + (a.y + 0.5) * cell,
						x0 + (b.x + 0.5) * cell, y0 + (b.y + 0.5) * cell, cell, 1, time, a.x * 0.7 + a.y * 1.3);
		for( i => a in level.molecule )
			painter.bubble(Palette.atom(a.color), x0 + (a.x + 0.5) * cell, y0 + (a.y + 0.5) * cell, cell * view.Art.BUBBLE_RADIUS * 2, time, i * 1.7, 0.6);
		painter.iconButton(Menu, menuButton.hovered, menuButton.x, menuButton.y, menuButton.size, time);
		painter.iconButton(Molecule, gameButton.hovered, gameButton.x, gameButton.y, gameButton.size, time);
	}
}
