package screen;

import model.Game;
import view.Camera;
import view.Color;
import view.IconButton;

/**
	The board (Java: `AtomixPartieVue` and `AtomixPartieControleur`). Left click an atom to select
	it: marks show where it can go; click a mark to slide it. Right drag moves the board, the wheel
	zooms, a right click shows the molecule. Buttons: menu (top left corner), molecule (top right
	corner), undo and restart the level (top middle).
**/
class GameScreen extends Screen {
	var main : Main;
	var camera = new Camera();
	var menuButton = new IconButton(40, 40);
	var moleculeButton = new IconButton(-40, 40);
	var undoButton = new IconButton();
	var restartButton = new IconButton();

	/** The selected atom, or null. **/
	var selected : Null<{ x : Int, y : Int }>;

	// Where the board is drawn, computed by `measure` like the Java `mesure`.
	var cellSize = 0;
	var boardX = 0;
	var boardY = 0;
	var lastWidth = -1;
	var lastHeight = -1;

	public function new( main : Main ) {
		super();
		this.main = main;
	}

	var game(get, never) : Game;

	inline function get_game() return main.campaign.game;

	/** A new level, or the level changed outside: forget the selection. **/
	public function refresh() {
		selected = null;
	}

	override function onShow() {
		layoutButtons();
	}

	function measure() {
		var size = Std.int(Math.min(Std.int(width / game.width), Std.int(height / game.height)));
		boardX = Std.int(Std.int(width / 2) - (game.width * size * camera.x) / camera.zoom);
		boardY = Std.int(Std.int(height / 2) - (game.height * size * camera.y) / camera.zoom);
		cellSize = Std.int(size / camera.zoom);
		if( width != lastWidth || height != lastHeight )
			layoutButtons();
	}

	function layoutButtons() {
		lastWidth = width;
		lastHeight = height;
		var center = Std.int(width / 2);
		menuButton.place(-60, -60, 100);
		moleculeButton.place(width - 40, -60, 100);
		undoButton.place(center - 75, 25, 50);
		restartButton.place(center + 25, 25, 50);
	}

	function overButton() : Bool {
		return menuButton.hovered || moleculeButton.hovered || undoButton.hovered || restartButton.hovered;
	}

	override function onPush( button : Int ) {
		if( button == Screen.RIGHT )
			camera.grab(mouseX, mouseY);
		if( button == Screen.LEFT && !overButton() ) {
			measure();
			if( cellSize > 0 )
				clickCell(Math.floor((mouseX - boardX) / cellSize), Math.floor((mouseY - boardY) / cellSize));
		}
	}

	/** Selects an atom, or moves the selected one if a mark was clicked. **/
	function clickCell( x : Int, y : Int ) {
		if( !game.isInMap(x, y) )
			return;
		if( game.isAtom(x, y) ) {
			selected = { x : x, y : y };
			return;
		}
		if( selected == null )
			return;
		for( dir in 0...4 )
			if( game.canMove(selected.x, selected.y, dir) && x == selected.x + Game.DIRS[dir][0] && y == selected.y + Game.DIRS[dir][1] ) {
				var m = game.move(selected.x, selected.y, dir);
				selected = { x : m.toX, y : m.toY };
				if( game.won )
					main.nextLevel();
				else
					main.save();
				return;
			}
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
		} else if( moleculeButton.hovered ) {
			moleculeButton.hover(-1000, -1000);
			main.showMolecule();
		} else if( undoButton.hovered ) {
			if( game.undo() != null ) {
				selected = null;
				main.save();
			}
		} else if( restartButton.hovered ) {
			game.restart();
			selected = null;
			main.save();
		}
	}

	override function onMove() {
		for( b in [menuButton, moleculeButton, undoButton, restartButton] )
			b.hover(mouseX, mouseY);
	}

	override function onDrag() {
		if( isDown(Screen.RIGHT) && !isDown(Screen.LEFT) )
			camera.drag(mouseX, mouseY);
	}

	override function onWheel( delta : Float ) {
		if( delta > 0 )
			camera.zoomOut();
		else if( delta < 0 )
			camera.zoomIn();
	}

	override function draw() {
		measure();
		painter.setColorCount(model.Level.colorCount(game.level.number));
		painter.fillRect(Color.BLACK, 0, 0, width, height);
		for( x in 0...game.width )
			for( y in 0...game.height ) {
				var c = game.get(x, y);
				if( c == Game.WALL )
					continue;
				var px = boardX + x * cellSize, py = boardY + y * cellSize;
				painter.drawFloor(px, py, cellSize);
				if( c >= 0 )
					painter.drawAtom(c, false, px, py, cellSize);
			}
		if( selected != null )
			for( dir in 0...4 )
				if( game.canMove(selected.x, selected.y, dir) ) {
					var x = selected.x + Game.DIRS[dir][0], y = selected.y + Game.DIRS[dir][1];
					painter.drawArrow(Color.GREEN, boardX + x * cellSize, boardY + y * cellSize, cellSize, dir);
				}
		painter.drawLevelNumber(game.level.number, Std.int(width / 2), 0, 50);
		painter.drawMenuIcon(menuButton.color(), menuButton.x, menuButton.y, menuButton.size);
		painter.drawMoleculeIcon(moleculeButton.color(), moleculeButton.x, moleculeButton.y, moleculeButton.size);
		painter.drawUndoIcon(undoButton.color(), undoButton.x, undoButton.y, undoButton.size);
		painter.drawRestartIcon(restartButton.color(), restartButton.x, restartButton.y, restartButton.size);
	}
}
