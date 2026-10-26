package model;

/** A move: the atom at `from` slid in `dir` and stopped at `to`. **/
typedef Move = { fromX : Int, fromY : Int, dir : Int, toX : Int, toY : Int }

/**
	A level being played (Java: `AtomixPartie`): where the atoms are, the moves made (to undo them)
	and whether the molecule is built. An atom slides in a direction until it meets a wall or
	another atom.
**/
class Game {
	public static inline var FLOOR = -1;
	public static inline var WALL = -2;

	/** The directions, in the order of the Java version: south, north, east, west. **/
	public static final DIRS = [[0, 1], [0, -1], [1, 0], [-1, 0]];

	public var level(default, null) : Level;
	public var won(default, null) = false;
	/** The moves made, oldest first. **/
	public var moves(default, null) : Array<Move> = [];

	/** `cells[x][y]`: `WALL`, `FLOOR` or the color of the atom there. **/
	var cells : Array<Array<Int>>;

	public function new( level : Level ) {
		this.level = level;
		cells = [for( x in 0...level.width ) [for( y in 0...level.height ) level.floor[x][y] ? FLOOR : WALL]];
		placeAtoms();
	}

	public var width(get, never) : Int;
	public var height(get, never) : Int;

	function get_width() return level.width;

	function get_height() return level.height;

	/** The index in `DIRS` of a direction. **/
	public static function direction( dx : Int, dy : Int ) : Int {
		for( i => d in DIRS )
			if( d[0] == dx && d[1] == dy )
				return i;
		throw 'not a direction: $dx $dy';
	}

	public function isInMap( x : Int, y : Int ) : Bool {
		return x >= 0 && x < level.width && y >= 0 && y < level.height;
	}

	/** `WALL` outside the map. **/
	public function get( x : Int, y : Int ) : Int {
		return isInMap(x, y) ? cells[x][y] : WALL;
	}

	public function isAtom( x : Int, y : Int ) : Bool {
		return get(x, y) >= 0;
	}

	/** Whether the atom at x, y can move at least one cell in `dir`. **/
	public function canMove( x : Int, y : Int, dir : Int ) : Bool {
		if( dir < 0 || dir >= 4 )
			return false;
		return get(x + DIRS[dir][0], y + DIRS[dir][1]) == FLOOR;
	}

	/** Slides the atom at x, y in `dir`. Returns the move, null if it cannot move. **/
	public function move( x : Int, y : Int, dir : Int ) : Null<Move> {
		if( !isAtom(x, y) || !canMove(x, y, dir) )
			return null;
		var d = DIRS[dir];
		var toX = x, toY = y;
		while( get(toX + d[0], toY + d[1]) == FLOOR ) {
			toX += d[0];
			toY += d[1];
		}
		cells[toX][toY] = cells[x][y];
		cells[x][y] = FLOOR;
		var m = { fromX : x, fromY : y, dir : dir, toX : toX, toY : toY };
		moves.push(m);
		if( formsMolecule(toX, toY) )
			won = true;
		return m;
	}

	/** Takes back the last move. Returns it, null if there is none. **/
	public function undo() : Null<Move> {
		var m = moves.pop();
		if( m == null )
			return null;
		cells[m.fromX][m.fromY] = cells[m.toX][m.toY];
		cells[m.toX][m.toY] = FLOOR;
		won = false;
		return m;
	}

	/** Puts the atoms back where the level starts. **/
	public function restart() {
		moves = [];
		for( x in 0...level.width )
			for( y in 0...level.height )
				if( cells[x][y] >= 0 )
					cells[x][y] = FLOOR;
		placeAtoms();
		won = false;
	}

	/**
		Whether the atom at x, y is part of a complete molecule: for each place of the molecule
		with its color, are all the other atoms of the molecule around it where they should be?
	**/
	public function formsMolecule( x : Int, y : Int ) : Bool {
		var color = get(x, y);
		for( anchor in level.molecule ) {
			if( anchor.color != color )
				continue;
			var ok = true;
			for( a in level.molecule )
				if( get(x - anchor.x + a.x, y - anchor.y + a.y) != a.color ) {
					ok = false;
					break;
				}
			if( ok )
				return true;
		}
		return false;
	}

	function placeAtoms() {
		for( a in level.atoms )
			cells[a.x][a.y] = a.color;
	}
}
