import model.*;
import model.Game.Move;

/** Tests of the rules: `haxe test.hxml`. **/
class TestModel {
	static var failures = 0;

	static function check( ok : Bool, what : String, ?pos : haxe.PosInfos ) {
		if( !ok ) {
			failures++;
			Sys.println('FAIL ${pos.lineNumber}: $what');
		}
	}

	static function main() {
		difficulty();
		generatedLevels();
		movesAndUndo();
		saveRoundTrip();
		campaign();
		Sys.println(failures == 0 ? "All tests passed" : '$failures failure(s)');
		Sys.exit(failures == 0 ? 0 : 1);
	}

	/** Same progression as the Java version: atoms and colors by level number. **/
	static function difficulty() {
		var atoms = [for( n in 1...11 ) Level.atomCount(n)];
		var colors = [for( n in 1...11 ) Level.colorCount(n)];
		check(atoms.join(",") == "2,2,3,3,3,4,4,4,4,5", 'atoms ${atoms}');
		check(colors.join(",") == "1,2,1,2,3,1,2,3,4,1", 'colors ${colors}');
	}

	/** Many levels: well formed, and solved by the moves of the generator. **/
	static function generatedLevels() {
		var g = new Generator();
		for( number in 1...60 )
			for( seed in 1...6 ) {
				var level = g.generate(number, seed * 7919 + number);
				var where = 'level $number seed $seed';
				check(level.width >= 7 && level.height >= 7, '$where: size');
				for( x in 0...level.width ) {
					check(!level.floor[x][0] && !level.floor[x][level.height - 1], '$where: border');
				}
				check(level.atoms.length == level.molecule.length, '$where: atoms and molecule');
				check(level.atoms.length >= 1 && level.atoms.length <= Level.atomCount(number), '$where: atom count');
				var minX = 999, minY = 999;
				for( a in level.molecule ) {
					minX = Std.int(Math.min(minX, a.x));
					minY = Std.int(Math.min(minY, a.y));
					check(a.color >= 0 && a.color < Level.colorCount(number), '$where: color');
				}
				check(minX == 0 && minY == 0, '$where: molecule from its corner');
				for( a in level.atoms )
					check(level.floor[a.x][a.y], '$where: atom on the floor');
				var game = new Game(level);
				for( m in g.solution ) {
					var done = game.move(m.fromX, m.fromY, m.dir);
					check(done != null && done.toX == m.toX && done.toY == m.toY, '$where: solution move');
					if( done == null || game.won )
						break;
				}
				check(game.won, '$where: solved');
			}
	}

	static function movesAndUndo() {
		// #####
		// #a.b#
		// #####   a and b both color 0; the molecule is two atoms side by side.
		var level = new Level(1, 1, 5, 3);
		level.floor[1][1] = level.floor[2][1] = level.floor[3][1] = true;
		level.atoms = [{ x : 1, y : 1, color : 0 }, { x : 3, y : 1, color : 0 }];
		level.molecule = [{ x : 0, y : 0, color : 0 }, { x : 1, y : 0, color : 0 }];
		var game = new Game(level);
		check(!game.canMove(1, 1, Game.direction(-1, 0)), "blocked by the wall");
		check(game.canMove(1, 1, Game.direction(1, 0)), "free to the east");
		var m = game.move(1, 1, Game.direction(1, 0));
		check(m != null && m.toX == 2 && m.toY == 1, "slides until the atom");
		check(game.won, "molecule built");
		check(game.move(1, 1, 0) == null, "no atom there");
		game.undo();
		check(!game.won && game.isAtom(1, 1) && !game.isAtom(2, 1), "undo");
		game.move(1, 1, Game.direction(1, 0));
		game.restart();
		check(game.moves.length == 0 && game.isAtom(1, 1) && game.isAtom(3, 1), "restart");
	}

	static function saveRoundTrip() {
		var level = new Generator().generate(12, 42);
		var copy = Level.fromData(level.toData());
		check(haxe.Json.stringify(copy.toData()) == haxe.Json.stringify(level.toData()), "level saved and read back");
	}

	static function campaign() {
		var seed = 1;
		var c = new Campaign(() -> seed++);
		check(c.number == 1, "starts at level 1");
		c.next();
		c.next();
		check(c.number == 3, "next");
		var g = c.game;
		var moved = 0;
		for( x in 0...g.width )
			for( y in 0...g.height )
				if( moved == 0 && g.isAtom(x, y) )
					for( d in 0...4 )
						if( moved == 0 && g.move(x, y, d) != null )
							moved++;
		var saved = c.savedMoves();
		var level = c.game.level;
		var other = new Campaign(() -> 99);
		other.resume(level, saved);
		check(other.number == 3 && other.game.moves.length == moved, "resume with moves");
		c.restart();
		check(c.number == 1, "restart");
	}
}
