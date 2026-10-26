package screen;

import model.Game;
import model.Game.Link;
import view.Art;
import view.Camera;
import view.IconButton;
import view.Palette;
import view.Plasma;

/**
	The board (Java: `AtomixPartieVue` and `AtomixPartieControleur`). Left click an atom to select
	it: marks show where it can go; click a mark to slide it. Right drag moves the board, the wheel
	zooms, a right click shows the molecule. Buttons: menu (top left corner), molecule (top right
	corner), undo and restart the level (top middle).
**/
class GameScreen extends Screen {
	/** Seconds per cell crossed by a sliding atom, and at least. **/
	static inline var SLIDE_PER_CELL = 0.045;
	static inline var SLIDE_MIN = 0.08;
	/** Seconds the built molecule shines before the next level. **/
	static inline var WIN_DELAY = 0.9;
	/** Seconds for a filament to form, and to break. **/
	static inline var FILAMENT_GROW = 0.45;
	static inline var FILAMENT_BREAK = 0.22;

	var main : Main;
	var camera = new Camera();
	var menuButton = new IconButton(40, 40);
	var moleculeButton = new IconButton(-40, 40);
	var undoButton = new IconButton();
	var restartButton = new IconButton();

	/** The selected atom, or null. **/
	var selected : Null<{ x : Int, y : Int }>;
	/** The atom sliding: drawn between its cells until `t` reaches `duration`. **/
	var slide : Null<{ move : Move, t : Float, duration : Float }>;
	/** Time left before the next level, once the molecule is built. **/
	var winTimer = -1.;
	/**
		The filaments between compatible neighbour atoms (`Game.links`), by their cells: when each
		one formed, and when it broke (-1 while it holds). A broken one shrinks, then goes.
	**/
	var filaments = new Map<String, { link : Link, born : Float, broke : Float }>();

	var floor : h2d.Bitmap;
	/** The level the floor was drawn for. **/
	var floorLevel : model.Level;

	// Where the board is drawn, computed by `measure` like the Java `mesure`.
	var cellSize = 0;
	var boardX = 0;
	var boardY = 0;
	var lastWidth = -1;
	var lastHeight = -1;

	public function new( main : Main ) {
		super(Plasma.BOARD);
		this.main = main;
		floor = new h2d.Bitmap(null, layer);
		floor.smooth = true;
	}

	var game(get, never) : Game;

	inline function get_game() return main.campaign.game;

	/** A new level, or the level changed outside: forget the selection. **/
	public function refresh() {
		selected = null;
		slide = null;
		winTimer = -1;
		filaments.clear();
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
		undoButton.place(center - 140, 18, 56);
		restartButton.place(center + 84, 18, 56);
	}

	function overButton() : Bool {
		return menuButton.hovered || moleculeButton.hovered || undoButton.hovered || restartButton.hovered;
	}

	override function onPush( button : Int ) {
		if( button == Screen.RIGHT )
			camera.grab(mouseX, mouseY);
		if( button == Screen.LEFT && !overButton() && winTimer < 0 ) {
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
				var cells = Math.abs(m.toX - m.fromX) + Math.abs(m.toY - m.fromY);
				slide = { move : m, t : 0, duration : Math.max(SLIDE_MIN, cells * SLIDE_PER_CELL) };
				selected = { x : m.toX, y : m.toY };
				if( game.won ) {
					selected = null;
					winTimer = slide.duration + WIN_DELAY;
				} else
					main.save();
				return;
			}
	}

	override function onClick( button : Int ) {
		if( button == Screen.RIGHT ) {
			main.switchView();
			return;
		}
		if( button != Screen.LEFT || winTimer >= 0 )
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
				slide = null;
				main.save();
			}
		} else if( restartButton.hovered ) {
			game.restart();
			selected = null;
			slide = null;
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

	override function update( dt : Float ) {
		if( slide != null ) {
			slide.t += dt;
			if( slide.t >= slide.duration )
				slide = null;
		}
		if( winTimer >= 0 ) {
			winTimer -= dt;
			if( winTimer < 0 )
				main.nextLevel();
		}
		super.update(dt);
	}

	override function draw() {
		measure();
		drawFloor();
		var size = cellSize * view.Art.BUBBLE_RADIUS * 2;
		var half = cellSize / 2;
		drawFilaments();
		var winGlow = winTimer >= 0 ? 0.6 + 0.4 * Math.sin(time * 12) : 0.;
		for( x in 0...game.width )
			for( y in 0...game.height ) {
				var c = game.get(x, y);
				if( c < 0 )
					continue;
				var px = boardX + x * cellSize + half, py = boardY + y * cellSize + half;
				if( slide != null && slide.move.toX == x && slide.move.toY == y ) {
					// Eases out: fast start, soft stop against the obstacle.
					var t = 1 - Math.pow(1 - slide.t / slide.duration, 3);
					px = boardX + (slide.move.fromX + (x - slide.move.fromX) * t) * cellSize + half;
					py = boardY + (slide.move.fromY + (y - slide.move.fromY) * t) * cellSize + half;
				}
				var isSelected = selected != null && selected.x == x && selected.y == y;
				var glow = isSelected ? 0.85 + 0.15 * Math.sin(time * 5) : Math.max(0.35, winGlow);
				painter.bubble(Palette.atom(c), px, py, isSelected ? size * 1.05 : size, time, c * 1.3 + (x + y) * 0.1, glow);
			}
		if( selected != null && slide == null )
			for( dir in 0...4 )
				if( game.canMove(selected.x, selected.y, dir) ) {
					var x = selected.x + Game.DIRS[dir][0], y = selected.y + Game.DIRS[dir][1];
					var cx = boardX + x * cellSize + half, cy = boardY + y * cellSize + half;
					var pulse = 0.5 + 0.5 * Math.sin(time * 6);
					var push = cellSize * 0.06 * pulse;
					cx += Game.DIRS[dir][0] * push;
					cy += Game.DIRS[dir][1] * push;
					painter.sprite(Art.glow(), Palette.ARROW, 0.35 + 0.2 * pulse, cx, cy, cellSize * 0.9, 0, true);
					painter.sprite(Art.icon(Arrow), Palette.ARROW, 0.75 + 0.25 * pulse, cx, cy, cellSize * 0.5, [Math.PI, 0, Math.PI / 2, -Math.PI / 2][dir]);
				}
		painter.levelNumber(game.level.number, Std.int(width / 2), 46, 36);
		painter.iconButton(Menu, menuButton.hovered, menuButton.x, menuButton.y, menuButton.size, time);
		painter.iconButton(Molecule, moleculeButton.hovered, moleculeButton.x, moleculeButton.y, moleculeButton.size, time);
		painter.iconButton(Undo, undoButton.hovered, undoButton.x, undoButton.y, undoButton.size, time);
		painter.iconButton(Restart, restartButton.hovered, restartButton.x, restartButton.y, restartButton.size, time);
	}

	/**
		Follows the links of the game: a new one starts to grow, a lost one breaks. The atom that is
		sliding links only once it has stopped.
	**/
	function drawFilaments() {
		var now = new Map<String, Bool>();
		for( l in game.links() ) {
			if( slide != null && ((l.ax == slide.move.toX && l.ay == slide.move.toY) || (l.bx == slide.move.toX && l.by == slide.move.toY)) )
				continue;
			var key = '${l.ax},${l.ay},${l.bx},${l.by}';
			now.set(key, true);
			var f = filaments.get(key);
			if( f == null )
				filaments.set(key, { link : l, born : time, broke : -1 });
			else if( f.broke >= 0 ) {
				// Formed again while breaking: grows back from where it was.
				var left = 1 - (time - f.broke) / FILAMENT_BREAK;
				f.born = time - Math.max(0, left) * FILAMENT_GROW;
				f.broke = -1;
			}
		}
		var half = cellSize / 2;
		for( key => f in filaments ) {
			if( !now.exists(key) && f.broke < 0 )
				f.broke = time;
			var grow;
			if( f.broke >= 0 ) {
				var t = (time - f.broke) / FILAMENT_BREAK;
				if( t >= 1 ) {
					filaments.remove(key);
					continue;
				}
				grow = 1 - t * t;
			} else
				grow = elastic(Math.min(1, (time - f.born) / FILAMENT_GROW));
			var l = f.link;
			var ca = game.get(l.ax, l.ay), cb = game.get(l.bx, l.by);
			// Once broken, one of the atoms has gone: the filament takes the color of the other.
			if( ca < 0 ) ca = cb;
			if( cb < 0 ) cb = ca;
			var colorA = ca >= 0 ? Palette.atom(ca) : 0xFFFFFF, colorB = cb >= 0 ? Palette.atom(cb) : 0xFFFFFF;
			painter.filament(colorA, colorB, boardX + l.ax * cellSize + half, boardY + l.ay * cellSize + half,
				boardX + l.bx * cellSize + half, boardY + l.by * cellSize + half, cellSize, grow, time, l.ax * 0.7 + l.ay * 1.3);
		}
	}

	/** 0 to 1 with a soft overshoot, like a drop settling. **/
	static function elastic( t : Float ) : Float {
		if( t >= 1 )
			return 1;
		return 1 + Math.pow(2, -10 * t) * Math.sin((t * 10 - 0.75) * Math.PI * 2 / 3);
	}

	/** The floor texture, made again when the level changes, placed where the camera says. **/
	function drawFloor() {
		if( floorLevel != game.level ) {
			if( floor.tile != null )
				floor.tile.dispose();
			floor.tile = view.FloorArt.make(game.level);
			floorLevel = game.level;
		}
		floor.setPosition(boardX, boardY);
		floor.setScale(cellSize / view.FloorArt.cellPixels);
	}
}
