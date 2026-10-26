package model;

typedef Atom = { x : Int, y : Int, color : Int }

/** A level as saved: plain data, read back by `Level.fromData`. **/
typedef LevelData = {
	var id : Int;
	var number : Int;
	var width : Int;
	var height : Int;
	/** One character per cell, row by row: `1` floor, `0` wall. **/
	var map : String;
	/** x, y, color of each atom. **/
	var molecule : Array<Int>;
	var atoms : Array<Int>;
}

/**
	A generated level (Java: `AtomixNiveau`): the floor, the molecule to build (positions relative
	to its top left corner) and the starting atoms.
**/
class Level {
	/** The seed it was generated from. **/
	public var id : Int;
	/** Its number in the campaign, from 1. **/
	public var number : Int;
	public var width : Int;
	public var height : Int;
	/** `floor[x][y]`: true where atoms can go. **/
	public var floor : Array<Array<Bool>>;
	public var molecule : Array<Atom>;
	public var atoms : Array<Atom>;

	public function new( id : Int, number : Int, width : Int, height : Int ) {
		this.id = id;
		this.number = number;
		this.width = width;
		this.height = height;
		floor = [for( _ in 0...width ) [for( _ in 0...height ) false]];
		molecule = [];
		atoms = [];
	}

	/** Atoms of a level: grows by one each time the number of colors has gone through 1...n. **/
	public static function atomCount( number : Int ) : Int {
		return Math.round(Math.sqrt((number + 1) * 2));
	}

	/** Colors of a level: 1, then 1 2, then 1 2 3... as the levels go. **/
	public static function colorCount( number : Int ) : Int {
		var atoms = atomCount(number);
		return (number + 1) - Std.int(atoms * (atoms - 1) / 2);
	}

	public function moleculeWidth() : Int {
		var min = width, max = 0;
		for( a in molecule ) {
			if( a.x > max ) max = a.x;
			if( a.x < min ) min = a.x;
		}
		return max - min + 1;
	}

	public function moleculeHeight() : Int {
		var min = height, max = 0;
		for( a in molecule ) {
			if( a.y > max ) max = a.y;
			if( a.y < min ) min = a.y;
		}
		return max - min + 1;
	}

	public function toData() : LevelData {
		var map = new StringBuf();
		for( y in 0...height )
			for( x in 0...width )
				map.add(floor[x][y] ? "1" : "0");
		return {
			id : id,
			number : number,
			width : width,
			height : height,
			map : map.toString(),
			molecule : flatten(molecule),
			atoms : flatten(atoms),
		};
	}

	public static function fromData( d : LevelData ) : Level {
		var l = new Level(d.id, d.number, d.width, d.height);
		var i = 0;
		for( y in 0...d.height )
			for( x in 0...d.width )
				l.floor[x][y] = d.map.charAt(i++) == "1";
		l.molecule = unflatten(d.molecule);
		l.atoms = unflatten(d.atoms);
		return l;
	}

	static function flatten( list : Array<Atom> ) : Array<Int> {
		var out = [];
		for( a in list ) {
			out.push(a.x);
			out.push(a.y);
			out.push(a.color);
		}
		return out;
	}

	static function unflatten( v : Array<Int> ) : Array<Atom> {
		return [for( i in 0...Std.int(v.length / 3) ) { x : v[i * 3], y : v[i * 3 + 1], color : v[i * 3 + 2] }];
	}
}
