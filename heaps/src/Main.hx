import model.Campaign;
import model.Level;
import screen.*;

/**
	The game (Java: `AtomixControleur` and `AtomixVue`): the campaign and its three views, the menu,
	the board and the molecule. One view is shown at a time; the menu remembers the view it was
	opened from, to go back to it.
**/
class Main extends hxd.App {
	public var campaign(default, null) : Campaign;

	var menu : MenuScreen;
	var board : GameScreen;
	var molecule : MoleculeScreen;
	var current : Screen;
	/** The view the menu was opened from. **/
	var beforeMenu : Screen;

	override function init() {
		#if hl
		var window = hxd.Window.getInstance();
		window.title = "Atomix NoLimit";
		window.resize(800, 800);
		#end
		campaign = new Campaign(() -> Std.random(0x7FFFFFFE) + 1);
		var saved = Progress.load();
		if( saved.level != null )
			campaign.resume(Level.fromData(saved.level), saved.moves);
		save();
		menu = new MenuScreen(this);
		board = new GameScreen(this);
		molecule = new MoleculeScreen(this);
		// As in Java, the game opens on the menu, over the board.
		beforeMenu = board;
		show(menu);
		#if (js && debug)
		(cast js.Browser.window).game = this;
		#end
	}

	function show( s : Screen ) {
		current = s;
		setScene(s.scene, false);
		s.onShow();
	}

	/** Opens the menu, or closes it when it is shown. **/
	public function showMenu() {
		if( current == menu )
			show(beforeMenu);
		else {
			beforeMenu = current;
			show(menu);
		}
	}

	public function showGame() {
		show(board);
	}

	public function showMolecule() {
		show(molecule);
	}

	/** From the board to the molecule and back. **/
	public function switchView() {
		if( current == board )
			showMolecule();
		else if( current == molecule )
			showGame();
	}

	public function nextLevel() {
		campaign.next();
		board.refresh();
		save();
		trace('level ${campaign.number}');
	}

	public function restartCampaign() {
		campaign.restart();
		board.refresh();
		save();
		showGame();
	}

	#if debug
	/** Plays a given level (browser tests: `window.game.debugLevel({...})`). **/
	public function debugLevel( data : model.Level.LevelData ) {
		campaign.resume(Level.fromData(data), []);
		board.refresh();
		save();
	}
	#end

	public function save() {
		Progress.save(campaign);
	}

	public function quit() {
		save();
		hxd.System.exit();
	}

	override function update( dt : Float ) {
		current.update(dt);
	}

	static function main() {
		#if hl
		hxd.Res.initLocal();
		#else
		hxd.Res.initEmbed();
		#end
		new Main();
	}
}
