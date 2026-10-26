package model;

/**
	The endless campaign (Java: `AtomixCampagneNoLimit`): level 1, 2, 3... each one generated
	when it starts, harder as the number grows. `game` is the level being played.
**/
class Campaign {
	public var game(default, null) : Game;

	var generator = new Generator();
	/** Gives the seed of each new level. **/
	var newSeed : Void -> Int;

	public function new( newSeed : Void -> Int ) {
		this.newSeed = newSeed;
		start(1);
	}

	public var number(get, never) : Int;

	function get_number() return game.level.number;

	/** Goes on with a saved level and its moves. **/
	public function resume( level : Level, moves : Array<Int> ) {
		game = new Game(level);
		var i = 0;
		while( i + 2 < moves.length ) {
			game.move(moves[i], moves[i + 1], moves[i + 2]);
			i += 3;
		}
	}

	/** The moves of the current level, to save: x, y, direction of each. **/
	public function savedMoves() : Array<Int> {
		var out = [];
		for( m in game.moves ) {
			out.push(m.fromX);
			out.push(m.fromY);
			out.push(m.dir);
		}
		return out;
	}

	/** The next level. **/
	public function next() {
		start(number + 1);
	}

	/** Back to level 1. **/
	public function restart() {
		start(1);
	}

	function start( number : Int ) {
		game = new Game(generator.generate(number, newSeed()));
	}
}
