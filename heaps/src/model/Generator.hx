package model;

import model.Level.Atom;

/**
	Generates the levels (Java: `AtomixGenerateur`), in three steps:

	1. the map: a grid of 5x5 blocks, each drawn from bit masks, with a wall all around;
	2. the molecule: atoms grown one by one next to the previous ones, from a seed on the edge of
	   a block;
	3. the puzzle: the atoms are pulled apart by moves played backwards, so the level can always
	   be solved by playing them forwards.
**/
class Generator {
	/** Bits of a 5x5 block always open: the middle cross. **/
	static inline var BASE = 4211716;
	static inline var ALL = 33554431;
	static final NW = [35, 98, 2240, 6272, 2114, 224];
	static final NE = [536, 776, 896, 8456, 8576, 12416];
	static final SW = [2164736, 137216, 198656, 2195456, 3178496, 229376];
	static final SE = [143360, 401408, 917504, 9175040, 25690112, 8658944];
	static final AROUND = [[-1, 0], [1, 0], [0, -1], [0, 1]];

	var rng : Rng;
	var level : Level;
	var atomCount : Int;
	var colorCount : Int;
	var moveCount : Int;
	/** Blocks of the map, across and down. **/
	var blocksX : Int;
	var blocksY : Int;
	/** While generating, `floor` is false on the atoms too: true means free. **/
	var floor : Array<Array<Bool>>;
	var atoms : Array<Atom>;

	/** Moves that solve the level, in order: one per backward move, reversed. **/
	public var solution(default, null) : Array<Game.Move> = [];

	public function new() {}

	public function generate( number : Int, seed : Int ) : Level {
		rng = new Rng(seed);
		atomCount = Level.atomCount(number);
		colorCount = Level.colorCount(number);
		moveCount = atomCount * 10;
		blocksY = Std.int(Math.sqrt(Std.int(atomCount / 3) + 1));
		blocksX = blocksY;
		if( blocksX * blocksY < Std.int(atomCount / 3) + 1 )
			blocksX++;
		level = new Level(seed, number, blocksX * 5 + 2, blocksY * 5 + 2);
		floor = level.floor;
		atoms = [];
		solution = [];
		makeMap();
		makeMolecule();
		makePuzzle();
		level.atoms = atoms;
		return level;
	}

	function makeMap() {
		var keep = [ALL, ALL, ALL, ALL, ALL, ALL];
		for( i in 0...blocksX )
			for( j in 0...blocksY ) {
				// One corner (or the random part, or nothing) stays closed in this block.
				var closed = rng.int(6);
				keep[closed] = 0;
				var bits = BASE;
				bits |= NW[rng.int(6)] & keep[0];
				bits |= NE[rng.int(6)] & keep[1];
				bits |= SW[rng.int(6)] & keep[2];
				bits |= SE[rng.int(6)] & keep[3];
				bits |= rng.int(ALL + 1) & keep[4];
				keep[closed] = ALL;
				for( k in 1...6 )
					for( l in 1...6 ) {
						floor[i * 5 + l][j * 5 + k] = (bits & 1) == 1;
						bits >>= 1;
					}
			}
	}

	function makeMolecule() {
		var seeds = [[0, 2], [2, 0], [2, 4], [4, 2]];
		var side = seeds[rng.int(4)];
		var atom = { x : rng.int(blocksX) * 5 + 1 + side[0], y : rng.int(blocksY) * 5 + 1 + side[1], color : 0 };
		floor[atom.x][atom.y] = false;
		atoms.push(atom);
		var minX = atom.x, minY = atom.y;
		// Free cells next to the molecule: where the next atom can go. Taken out of `floor` while
		// listed, so that a cell is listed once.
		var candidates = [];
		for( i in 1...atomCount ) {
			for( d in AROUND ) {
				var x = atom.x + d[0], y = atom.y + d[1];
				if( floor[x][y] ) {
					floor[x][y] = false;
					candidates.push([x, y]);
				}
			}
			if( candidates.length == 0 )
				break;   // walled in: a smaller molecule (the Java version crashed here)
			var c = candidates[rng.int(candidates.length)];
			candidates.remove(c);
			atom = { x : c[0], y : c[1], color : i % colorCount };
			if( atom.x < minX ) minX = atom.x;
			if( atom.y < minY ) minY = atom.y;
			atoms.push(atom);
		}
		for( c in candidates )
			floor[c[0]][c[1]] = true;
		level.molecule = [for( a in atoms ) { x : a.x - minX, y : a.y - minY, color : a.color }];
	}

	function makePuzzle() {
		var moves = 0;
		var failures = 0;
		var i = 0;
		while( moves < moveCount ) {
			var atom = atoms[i % atoms.length];
			// The atom can come from direction d if the cell there is free and the one behind it is
			// blocked: a forward move towards -d stops on it.
			var dirs = [for( d in AROUND ) if( floor[atom.x + d[0]][atom.y + d[1]] && !floor[atom.x - d[0]][atom.y - d[1]] ) d];
			if( dirs.length > 0 ) {
				floor[atom.x][atom.y] = true;
				var d = dirs[rng.int(dirs.length)];
				var endX = atom.x, endY = atom.y;
				// Where it may have started: a cell on the way where a side move stops, or the end.
				var starts = [];
				while( floor[atom.x + d[0]][atom.y + d[1]] ) {
					atom.x += d[0];
					atom.y += d[1];
					for( t in AROUND )
						if( t[0] != d[0] && t[1] != d[1] && floor[atom.x + t[0]][atom.y + t[1]] && !floor[atom.x - t[0]][atom.y - t[1]] )
							starts.push([atom.x, atom.y]);
				}
				starts.push([atom.x, atom.y]);
				var s = starts[rng.int(starts.length)];
				atom.x = s[0];
				atom.y = s[1];
				floor[atom.x][atom.y] = false;
				solution.unshift({ fromX : atom.x, fromY : atom.y, dir : Game.direction(-d[0], -d[1]), toX : endX, toY : endY });
				moves++;
				failures = 0;
			} else {
				failures++;
				if( failures == atomCount )
					moves = moveCount;
			}
			i++;
		}
		for( a in atoms )
			floor[a.x][a.y] = true;
	}
}
