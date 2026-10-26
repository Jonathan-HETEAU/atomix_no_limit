import model.Level.LevelData;

/** What is saved. Add fields freely: `hxd.Save.load` fills the ones missing in older saves. **/
typedef SaveData = {
	/** The level being played, null before the first game. **/
	var level : Null<LevelData>;
	/** Its moves: x, y, direction of each. **/
	var moves : Array<Int>;
}

/**
	The saved game (Java: `AtomixFile`, which wrote `NoLimit/Joueur.j` and the levels), kept with
	`hxd.Save`: `atomix.sav` in the working directory on HashLink, the `localStorage` of the browser
	on the web. Saved at each move and each new level, so closing the game loses nothing.
**/
class Progress {
	static inline var NAME = "atomix";

	public static function load() : SaveData {
		return hxd.Save.load({ level : null, moves : [] }, NAME);
	}

	public static function save( c : model.Campaign ) {
		var data : SaveData = { level : c.game.level.toData(), moves : c.savedMoves() };
		hxd.Save.save(data, NAME);
	}
}
