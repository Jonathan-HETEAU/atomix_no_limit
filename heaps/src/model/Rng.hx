package model;

/**
	A seeded random generator (Park-Miller): the same seed gives the same level on every target,
	which the tests rely on. Computed with floats: `seed * 16807` stays exact below 2^53.
**/
class Rng {
	static inline var MOD = 2147483647.;

	var seed : Float;

	public function new( seed : Int ) {
		this.seed = seed % 2147483647;
		if( this.seed <= 0 )
			this.seed += 2147483646;
	}

	/** A number in `0...max`. **/
	public function int( max : Int ) : Int {
		seed = (seed * 16807.) % MOD;
		return Std.int((seed - 1) / (MOD - 1) * max);
	}
}
