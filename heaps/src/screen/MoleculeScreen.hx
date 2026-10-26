package screen;

import view.Camera;
import view.Color;
import view.IconButton;

/**
	The molecule to build (Java: `AtomixMoleculeVue`), on a gray background. Drag to move it, the
	wheel zooms; a right click or the top right button goes back to the board, the top left
	button opens the menu.
**/
class MoleculeScreen extends Screen {
	var main : Main;
	var camera = new Camera();
	var menuButton = new IconButton(40, 40);
	var gameButton = new IconButton(-40, 40);
	var lastWidth = -1;
	var lastHeight = -1;

	public function new( main : Main ) {
		super();
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
		var size = Std.int(Math.min(Std.int(width / w), Std.int(height / h)));
		var x0 = Std.int(Std.int(width / 2) - (w * size * camera.x) / camera.zoom);
		var y0 = Std.int(Std.int(height / 2) - (h * size * camera.y) / camera.zoom);
		var cell = Std.int(size / camera.zoom);
		painter.setColorCount(model.Level.colorCount(level.number));
		painter.fillRect(Color.LIGHT_GRAY, 0, 0, width, height);
		for( a in level.molecule )
			painter.drawAtom(a.color, false, x0 + a.x * cell, y0 + a.y * cell, cell);
		painter.drawMenuIcon(menuButton.color(), menuButton.x, menuButton.y, menuButton.size);
		painter.drawMoleculeIcon(gameButton.color(), gameButton.x, gameButton.y, gameButton.size);
	}
}
